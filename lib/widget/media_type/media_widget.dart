import 'package:cached_media/entity_cached_media_info.dart';
import 'package:cached_media/widget/cached_media.dart';
import 'package:cached_media/widget/download_media_snapshot.dart';
import 'package:cached_media/widget/media_type/audio_widget.dart';
import 'package:cached_media/widget/media_type/image_widget.dart';
import 'package:cached_media/widget/media_type/video_widget.dart';
import 'package:flutter/widgets.dart';
import 'package:visibility_detector/visibility_detector.dart';

class MediaWidget extends StatefulWidget {
  const MediaWidget({
    Key? key,
    required this.mediaUrl,
    required this.mediaType,
    required this.cachedMediaInfo,
    required this.uniqueId,
    required this.width,
    required this.height,
    required this.fit,
    required this.assetErrorImage,
    required this.builder,
    required this.startLoadingOnlyWhenVisible,
  }) : super(key: key);

  final String mediaUrl;
  final MediaType mediaType;
  final CachedMediaInfo cachedMediaInfo;
  final String uniqueId;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final String? assetErrorImage;
  final Widget? Function(BuildContext context, DownloadMediaSnapshot snapshot)? builder;
  final bool startLoadingOnlyWhenVisible;

  @override
  State<MediaWidget> createState() => _MediaWidgetState();
}

class _MediaWidgetState extends State<MediaWidget> {
  late DownloadMediaBuilderController __downloadMediaBuilderController;
  late DownloadMediaSnapshot snapshot;
  bool initiating = false;
  bool initiated = false;

  @override
  void initState() {
    super.initState();
    if (widget.mediaType == MediaType.custom) {
      init();
    }
  }

  Future<void> init() async {
    initiating = true;
    if (mounted) setState(() {});
    if (widget.builder != null) {
      snapshot = DownloadMediaSnapshot(status: DownloadMediaStatus.loading, filePath: null);

      __downloadMediaBuilderController = DownloadMediaBuilderController(
        snapshot: snapshot,
        onSnapshotChanged: (snapshot) => setState(() => this.snapshot = snapshot),
      );

      __downloadMediaBuilderController.getFile(widget.mediaUrl);
    }
    initiating = false;
    initiated = true;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.mediaType) {
      case MediaType.image:
        return ImageWidget(uniqueId: widget.uniqueId, cachedMediaInfo: widget.cachedMediaInfo, width: widget.width ?? 100, height: widget.height ?? 100, fit: widget.fit, assetErrorImage: widget.assetErrorImage);
      case MediaType.video:
        return VideoWidget(uniqueId: widget.uniqueId, cachedMediaInfo: widget.cachedMediaInfo, width: widget.width ?? 100, height: widget.height ?? 100, fit: widget.fit);
      case MediaType.audio:
        return AudioWidget(uniqueId: widget.uniqueId, cachedMediaInfo: widget.cachedMediaInfo, width: widget.width ?? 100, height: widget.height ?? 100, fit: widget.fit);
      case MediaType.custom:
        return widget.startLoadingOnlyWhenVisible
            ? VisibilityDetector(
                key: widget.key ?? Key('visibility-cached-media-${widget.uniqueId}'),
                onVisibilityChanged: !initiating && !initiated ? (_) async => _.visibleFraction > 0 ? await init() : null : null,
                child: widget.builder != null ? widget.builder!(context, snapshot) ?? const SizedBox() : const Text('Builder implementation is missing'),
              )
            : widget.builder != null
                ? widget.builder!(context, snapshot) ?? const SizedBox()
                : const Text('Builder implementation is missing');
    }
  }
}
