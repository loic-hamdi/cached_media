library cached_media;

import 'dart:developer' as developer;
import 'dart:io';
import 'dart:typed_data';
import 'package:cached_media/cached_media.dart';
import 'package:cached_media/widget/functions/functions.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:visibility_detector/visibility_detector.dart';

enum DownloadStatus { success, loading, error }

class CachedMediaSnapshot {
  late DownloadStatus status;
  late String? filePath;
  late Uint8List? bytes;

  CachedMediaSnapshot({required this.status, required this.filePath, this.bytes});
}

class CachedMedia extends StatefulWidget {
  const CachedMedia({
    required super.key,
    required this.mediaUrl,
    required this.getStorage,
    required this.builder,
    this.startLoadingOnlyWhenVisible = true,
    this.returnFileAsBytes = false,
    this.width = double.infinity,
    this.height = double.infinity,
    this.fit,
  });

  /// Web url to get the media. The address must contains the file extension.
  final String mediaUrl;

  /// To save ressources & bandwidth you can delay the media download
  /// Set [startLoadingOnlyWhenVisible] to [true] to start to download the media when the widget becomes visible on user's screen
  final bool startLoadingOnlyWhenVisible;

  final Widget Function(CachedMediaSnapshot snapshot)? builder;
  final GetStorage getStorage;
  final bool returnFileAsBytes;
  final double width;
  final double height;
  final BoxFit? fit;

  @override
  State<CachedMedia> createState() => _CachedMediaState();
}

class _CachedMediaState extends State<CachedMedia> {
  final _snapshot = CachedMediaSnapshot(status: DownloadStatus.loading, filePath: null);
  bool initiating = false;
  bool initiated = false;
  String? filePath;
  @override
  void initState() {
    super.initState();
    if (!widget.startLoadingOnlyWhenVisible && !initiating && !initiated) init();
  }

  Future<void> init() async {
    initiating = true;
    if (mounted) setState(() {});
    filePath = await getFile(widget.mediaUrl, getStorage: widget.getStorage); //! TODO : Test to do Image.file from here?
    initiating = false;
    initiated = true;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (widget.builder != null) {
      return widget.startLoadingOnlyWhenVisible
          ? VisibilityDetector(
              key: widget.key ?? Key(const Uuid().v1()),
              onVisibilityChanged: !initiating && !initiated ? (_) async => _.visibleFraction > 0 ? await init() : null : null,
              child: widget.builder!(_snapshot),
            )
          : widget.builder!(_snapshot);
    } else {
      return widget.startLoadingOnlyWhenVisible
          ? VisibilityDetector(
              key: widget.key ?? Key(const Uuid().v1()),
              onVisibilityChanged: !initiating && !initiated ? (_) async => _.visibleFraction > 0 ? await init() : null : null,
              child: filePath != null
                  ? Image.file(
                      File(filePath!),
                      errorBuilder: (context, error, stackTrace) => const Text('Error'),
                      width: widget.width,
                      height: widget.height,
                      fit: widget.fit,
                    )
                  : SizedBox(
                      width: widget.width,
                      height: widget.height,
                    ),
            )
          : filePath != null
              ? Image.file(
                  File(filePath!),
                  errorBuilder: (context, error, stackTrace) => const Text('Error'),
                  width: widget.width,
                  height: widget.height,
                  fit: widget.fit,
                )
              : SizedBox(
                  width: widget.width,
                  height: widget.height,
                );
    }
  }

  Future<String?> getFile(String url, {required GetStorage getStorage}) async {
    if (widget.builder != null) {
      _snapshot.status = DownloadStatus.loading;
      _snapshot.filePath = null;
      widget.builder!(_snapshot);
    }

    final cmi = await loadMedia(url, getStorage: getStorage, returnFileAsBytes: widget.returnFileAsBytes);

    if (getShowLogs) {
      developer.log('''
🗣️  getFile() - from: await loadMedia()
🗣️  key: ${widget.key}
🗣️  cmi != null: ${cmi != null}
🗣️  cmi.cachedMediaUrl: ${cmi?.cachedMediaUrl}
🗣️  cmi.fileSize: ${cmi?.fileSize.toStringAsFixed(2)}
🗣️  cmi.bytes != null: ${cmi?.bytes != null}
🗣️  url: $url
''', name: 'Cached Media package');
    }

    if (cmi != null && cmi.cachedMediaUrl.isNotEmpty) {
      if (widget.builder != null) {
        _snapshot.status = DownloadStatus.success;
        _snapshot.filePath = cmi.cachedMediaUrl;
        _snapshot.bytes = cmi.bytes;
        widget.builder!(_snapshot);
        printSnapshot(url, 'Success');
      }
      return cmi.cachedMediaUrl;
    } else {
      if (widget.builder != null) {
        widget.builder!(_snapshot..status = DownloadStatus.error);
        printSnapshot(url, 'Error');
      }
    }
    return null;
  }

  void printSnapshot(String url, String from) {
    if (getShowLogs) {
      developer.log('''
🧠  _onSnapshotChanged() - from: $from
🧠  key: ${widget.key}
🧠  _snapshot.filePath != null: ${_snapshot.filePath}
🧠  _snapshot.status: ${_snapshot.status} ⬅️⬅️⬅️
🧠  _snapshot.bytes != null: ${_snapshot.bytes != null}
🧠  url: $url
''', name: 'Cached Media package');
    }
  }
}
