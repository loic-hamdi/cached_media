import 'dart:io';

import 'package:cached_media/entity_cached_media_info.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoWidget extends StatefulWidget {
  const VideoWidget({
    Key? key,
    required this.uniqueId,
    required this.cachedMediaInfo,
    required this.width,
    required this.height,
    required this.fit,
    required this.assetErrorImage,
  }) : super(key: key);

  final String uniqueId;
  final CachedMediaInfo cachedMediaInfo;
  final double width;
  final double height;
  final BoxFit? fit;
  final String? assetErrorImage;

  @override
  State<VideoWidget> createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.cachedMediaInfo.cachedMediaUrl))
      ..initialize().then((_) {
        _controller.setVolume(1.0);
        _controller.setLooping(false);
        _controller.play();
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return VideoPlayer(
      key: Key('cached-video-${widget.uniqueId}'),
      _controller,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}

class DownloadMediaBuilder extends StatefulWidget {
  const DownloadMediaBuilder({Key? key}) : super(key: key);

  @override
  State<DownloadMediaBuilder> createState() => _DownloadMediaBuilderState();
}

class _DownloadMediaBuilderState extends State<DownloadMediaBuilder> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
