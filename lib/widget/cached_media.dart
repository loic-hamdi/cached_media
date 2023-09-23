library cached_media;

import 'dart:typed_data';
import 'dart:developer' as developer;
import 'package:cached_media/cached_media.dart';
import 'package:cached_media/widget/functions/functions.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:visibility_detector/visibility_detector.dart';

enum DownloadStatus { success, loading, error }

class CachedMediaSnapshot {
  late DownloadStatus status;
  late Uint8List? bytes;
  late String? mimeType;
  CachedMediaSnapshot({required this.bytes, required this.status});
}

class CachedMedia extends StatefulWidget {
  const CachedMedia({
    required super.key,
    required this.mediaUrl,
    required this.getStorage,
    required this.builder,
    this.startLoadingOnlyWhenVisible = true,
  });

  /// Web url to get the media. The address must contains the file extension.
  final String mediaUrl;

  /// To save ressources & bandwidth you can delay the media download
  /// Set [startLoadingOnlyWhenVisible] to [true] to start to download the media when the widget becomes visible on user's screen
  final bool startLoadingOnlyWhenVisible;

  final Widget Function(CachedMediaSnapshot snapshot) builder;
  final GetStorage getStorage;

  @override
  State<CachedMedia> createState() => _CachedMediaState();
}

class _CachedMediaState extends State<CachedMedia> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final CachedMediaSnapshot _snapshot = CachedMediaSnapshot(bytes: null, status: DownloadStatus.loading);
  bool initiating = false;
  bool initiated = false;

  @override
  void initState() {
    super.initState();
    if (!widget.startLoadingOnlyWhenVisible && !initiating && !initiated) init();
  }

  Future<void> init() async {
    initiating = true;
    if (mounted) setState(() {});
    await getFile(widget.mediaUrl, getStorage: widget.getStorage);
    initiating = false;
    initiated = true;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.startLoadingOnlyWhenVisible
        ? VisibilityDetector(
            key: widget.key ?? Key(const Uuid().v1()),
            onVisibilityChanged: !initiating && !initiated ? (_) async => _.visibleFraction > 0 ? await init() : null : null,
            child: widget.builder(_snapshot),
          )
        : widget.builder(_snapshot);
  }

  Future<void> getFile(String url, {required GetStorage getStorage}) async {
    _snapshot.bytes = null;
    _snapshot.mimeType = null;
    _snapshot.status = DownloadStatus.loading;
    widget.builder(_snapshot);

    final cmi = await loadMedia(url, getStorage: getStorage);

    await delay();

    if (getShowLogs) {
      developer.log('''
🗣️  getFile() - from: await loadMedia()
cmi != null: ${cmi != null}
cmi.bytes != null: ${cmi?.bytes != null}
url: $url
''', name: 'Cached Media package');
    }

    if (cmi != null && cmi.bytes != null) {
      _snapshot.bytes = cmi.bytes;
      _snapshot.mimeType = cmi.mimeType;
      _snapshot.status = DownloadStatus.success;
      widget.builder(_snapshot);
      printSnapshot(url, 'Success');
    } else {
      widget.builder(_snapshot..status = DownloadStatus.error);
      printSnapshot(url, 'Error');
    }
  }

  void printSnapshot(String url, String from) {
    if (getShowLogs) {
      developer.log('''
🗣️  _onSnapshotChanged() - from: $from
_snapshot.bytes != null: ${_snapshot.bytes != null}
_snapshot.mimeType: ${_snapshot.mimeType}
_snapshot.status: ${_snapshot.status}
url: $url
''', name: 'Cached Media package');
    }
  }

  Future<void> delay() async {
    await Future.delayed(const Duration(seconds: 1));
    developer.log('🗣️ 1 ', name: 'Cached Media package');
    await Future.delayed(const Duration(seconds: 1));
    developer.log('🗣️ 2 ', name: 'Cached Media package');
    await Future.delayed(const Duration(seconds: 1));
    developer.log('🗣️ 3 ', name: 'Cached Media package');
    await Future.delayed(const Duration(seconds: 1));
    developer.log('🗣️ 4 ', name: 'Cached Media package');
    await Future.delayed(const Duration(seconds: 1));
    developer.log('🗣️ 5 ', name: 'Cached Media package');
  }
}
