import 'package:cached_media/entity_cached_media_info.dart';
import 'package:cached_media/enums/enums.dart';
import 'package:cached_media/widget/download_media_snapshot.dart';
import 'package:cached_media/widget/media_type/audio_widget.dart';
import 'package:cached_media/widget/media_type/image_widget.dart';
import 'package:cached_media/widget/media_type/video_widget.dart';
import 'package:flutter/widgets.dart';

class MediaWidget extends StatefulWidget {
  const MediaWidget({
    Key? key,
    required this.mediaType,
    required this.cachedMediaInfo,
    required this.uniqueId,
    required this.width,
    required this.height,
    required this.fit,
    required this.assetErrorImage,
    required this.customVideoPlayerWidget,
    required this.customAudioPlayerWidget,
    required this.customImageWidget,
    required this.builder,
  }) : super(key: key);

  final MediaType mediaType;
  final CachedMediaInfo cachedMediaInfo;
  final String uniqueId;
  final double width;
  final double height;
  final BoxFit? fit;
  final String? assetErrorImage;
  final Widget? customImageWidget;
  final Widget? customVideoPlayerWidget;
  final Widget? customAudioPlayerWidget;
  final Widget? Function(BuildContext context, DownloadMediaSnapshot snapshot)? builder;

  @override
  State<MediaWidget> createState() => _MediaWidgetState();
}

class _MediaWidgetState extends State<MediaWidget> {
  late DownloadMediaBuilderController __downloadMediaBuilderController;
  late DownloadMediaSnapshot snapshot;

  @override
  void initState() {
    super.initState();
    if (widget.builder != null) {
      //! SNAPSHOT
      snapshot = DownloadMediaSnapshot(
        status: DownloadMediaStatus.loading,
        filePath: null,
        progress: null,
      );

      /// Initializing Widget Logic Controller
      __downloadMediaBuilderController = DownloadMediaBuilderController(
        snapshot: snapshot,
        onSnapshotChanged: (snapshot) => setState(() => this.snapshot = snapshot),
      );

      /// Initializing Caching Database
      DownloadCacheManager.init().then((value) {
        /// Starting Caching Database
        __downloadMediaBuilderController.getFile(widget.url);
      });
      //! END SNAPSHOT
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.mediaType) {
      case MediaType.image:
        return widget.customImageWidget != null ? widget.customImageWidget! : ImageWidget(uniqueId: widget.uniqueId, cachedMediaInfo: widget.cachedMediaInfo, width: widget.width, height: widget.height, fit: widget.fit, assetErrorImage: widget.assetErrorImage);
      case MediaType.video:
        return widget.customVideoPlayerWidget != null ? widget.customVideoPlayerWidget! : VideoWidget(uniqueId: widget.uniqueId, cachedMediaInfo: widget.cachedMediaInfo, width: widget.width, height: widget.height, fit: widget.fit, assetErrorImage: widget.assetErrorImage);
      case MediaType.audio:
        return widget.customAudioPlayerWidget != null ? widget.customAudioPlayerWidget! : AudioWidget(uniqueId: widget.uniqueId, cachedMediaInfo: widget.cachedMediaInfo, width: widget.width, height: widget.height, fit: widget.fit, assetErrorImage: widget.assetErrorImage);
      case MediaType.custom:
        return widget.builder != null ? widget.builder!(context, snapshot) ?? const SizedBox() : const Text('Builder implementation is missing');
    }
  }
}
