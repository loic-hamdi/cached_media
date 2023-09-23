library cached_media;

import 'package:cached_media/widget/cached_media_controller.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:visibility_detector/visibility_detector.dart';

enum DownloadStatus { success, loading, error }

class CachedMedia extends StatefulWidget {
  const CachedMedia({
    required super.key,
    required this.mediaUrl,
    required this.getStorage,
    required this.uniqueId,
    required this.builder,
    this.startLoadingOnlyWhenVisible = false,
    this.wantKeepAlive = false,
  });

  /// Web url to get the media. The address must contains the file extension.
  final String mediaUrl;

  /// To save ressources & bandwidth you can delay the media download
  /// Set [startLoadingOnlyWhenVisible] to [true] to start to download the media when the widget becomes visible on user's screen
  final bool startLoadingOnlyWhenVisible;

  /// The [uniqueId] is used to generate widget keys
  /// Important: This [String] must be unique for any media you will load with [CachedMedia]
  final String? uniqueId;

  final Widget? Function(BuildContext context, CachedMediaSnapshot snapshot)? builder;

  final bool wantKeepAlive;

  final GetStorage getStorage;

  @override
  State<CachedMedia> createState() => _CachedMediaState();
}

class _CachedMediaState extends State<CachedMedia> with AutomaticKeepAliveClientMixin<CachedMedia> {
  @override
  bool get wantKeepAlive => widget.wantKeepAlive;

  late CachedMediaController _cachedMediaController;
  CachedMediaSnapshot snapshot = CachedMediaSnapshot(bytes: null, status: DownloadStatus.loading);
  bool initiating = false;
  bool initiated = false;

  @override
  void initState() {
    super.initState();
    if (!widget.startLoadingOnlyWhenVisible) init();
  }

  Future<void> init() async {
    initiating = true;
    if (mounted) setState(() {});
    snapshot = CachedMediaSnapshot(status: DownloadStatus.loading, bytes: null);
    _cachedMediaController = CachedMediaController(
      snapshot: snapshot,
      onSnapshotChanged: (snapshot) => mounted ? setState(() => this.snapshot = snapshot) : null,
    );
    await _cachedMediaController.getFile(widget.mediaUrl, getStorage: widget.getStorage);
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
            child: widget.builder != null
                ? widget.builder!(context, snapshot) ?? const SizedBox()
                : const Text(
                    'Builder implementation is missing',
                  ),
          )
        : widget.builder != null
            ? widget.builder!(context, snapshot) ?? const SizedBox()
            : const Text('Builder implementation is missing');
  }
}
