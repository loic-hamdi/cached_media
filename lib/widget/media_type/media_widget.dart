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
    required this.mediaUrl,
    required this.mediaType,
    required this.cachedMediaInfo,
    required this.uniqueId,
    required this.width,
    required this.height,
    required this.fit,
    required this.assetErrorImage,
    required this.builder,
  }) : super(key: key);

  final String mediaUrl;
  final MediaType mediaType;
  final CachedMediaInfo cachedMediaInfo;
  final String uniqueId;
  final double width;
  final double height;
  final BoxFit? fit;
  final String? assetErrorImage;
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
      snapshot = DownloadMediaSnapshot(
        status: DownloadMediaStatus.loading,
        filePath: null,
      );

      __downloadMediaBuilderController = DownloadMediaBuilderController(
        snapshot: snapshot,
        onSnapshotChanged: (snapshot) => setState(() => this.snapshot = snapshot),
      );

      __downloadMediaBuilderController.getFile(widget.mediaUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.mediaType) {
      case MediaType.image:
        return ImageWidget(uniqueId: widget.uniqueId, cachedMediaInfo: widget.cachedMediaInfo, width: widget.width, height: widget.height, fit: widget.fit, assetErrorImage: widget.assetErrorImage);
      case MediaType.video:
        return VideoWidget(uniqueId: widget.uniqueId, cachedMediaInfo: widget.cachedMediaInfo, width: widget.width, height: widget.height, fit: widget.fit);
      case MediaType.audio:
        return AudioWidget(uniqueId: widget.uniqueId, cachedMediaInfo: widget.cachedMediaInfo, width: widget.width, height: widget.height, fit: widget.fit);
      case MediaType.custom:
        return widget.builder != null ? widget.builder!(context, snapshot) ?? const SizedBox() : const Text('Builder implementation is missing');
    }
  }
}
