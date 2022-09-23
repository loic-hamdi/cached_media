library cached_media;

import 'package:cached_media/entity_cached_media_info.dart';
import 'package:cached_media/widget/cached_media_controller.dart';
import 'package:cached_media/widget/functions/functions.dart';
import 'package:cached_media/widget/media_type/media_widget.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:visibility_detector/visibility_detector.dart';

enum DownloadStatus { success, loading, error }

enum MediaVisibility { initial, downloaded, custom, error }

enum MediaType { image, custom }

class CachedMedia extends StatefulWidget {
  const CachedMedia({
    required this.mediaType,
    required this.mediaUrl,
    this.uniqueId,
    this.width,
    this.height,
    this.startLoadingOnlyWhenVisible = false,
    this.fit,
    this.assetErrorImage,
    this.fadeInDuration,
    this.customLoadingProgressIndicator,
    this.showCircularProgressIndicator = true,
    this.errorWidget,
    this.builder,
    Key? key,
  }) : super(key: key);

  /// Define the type of media you want to display. You can show: image, video or audio
  final MediaType mediaType;

  /// Web url to get the media. The address must contains the file extension.
  final String mediaUrl;
  final double? width;
  final double? height;
  final BoxFit? fit;

  /// To save ressources & bandwidth you can delay the media download
  /// Set [startLoadingOnlyWhenVisible] to [true] to start to download the media when the widget becomes visible on user's screen
  final bool startLoadingOnlyWhenVisible;

  /// Display image from 'assets' when media throw an error
  final String? assetErrorImage;

  /// Duration can be set to [Duration.zero] to deactivate the fadein effect
  final Duration? fadeInDuration;

  /// Show the [CircularProgressIndicator] when downloading media
  final bool showCircularProgressIndicator;

  /// Show a custom loader when downloading media
  final Widget? customLoadingProgressIndicator;

  /// Widget [errorWidget] will be displayed if media loading throw an error
  final Widget? errorWidget;

  /// The [uniqueId] is used to generate widget keys
  /// Important: This [String] must be unique for any media you will load with [CachedMedia]
  final String? uniqueId;

  final Widget? Function(BuildContext context, CachedMediaSnapshot snapshot)?
      builder;

  @override
  State<CachedMedia> createState() => _CachedMediaState();
}

class _CachedMediaState extends State<CachedMedia>
    with AutomaticKeepAliveClientMixin<CachedMedia> {
  @override
  bool get wantKeepAlive => true;

  MediaVisibility mediaDownloadStatus = MediaVisibility.initial;
  bool isInitiating = false;
  bool startFadeIn = false;
  late Duration fadeInDuration;

  CachedMediaInfo? cachedMediaInfo;

  @override
  void initState() {
    super.initState();
    fadeInDuration =
        widget.fadeInDuration ?? const Duration(milliseconds: 1000);
    if (widget.mediaType != MediaType.custom &&
        mediaDownloadStatus == MediaVisibility.initial) {
      if (!widget.startLoadingOnlyWhenVisible) init();
    }
  }

  Future<void> init() async {
    if (cachedMediaInfo == null) {
      isInitiating = true;
      if (mounted) setState(() {});
      cachedMediaInfo = await loadMedia(widget.mediaUrl);
      await doesFileExist(cachedMediaInfo?.cachedMediaUrl)
          ? await showMedia()
          : await errorMedia();
      isInitiating = false;
      if (mounted) setState(() {});
    }
  }

  Future<void> showMedia() async {
    mediaDownloadStatus = MediaVisibility.downloaded;
    if (mounted) setState(() {});
    await Future.delayed(const Duration(milliseconds: 25));
    startFadeIn = true;
    if (mounted) setState(() {});
  }

  Future<void> errorMedia() async {
    mediaDownloadStatus = MediaVisibility.error;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    switch (widget.mediaType) {
      case MediaType.custom:
        return MediaWidget(
          mediaUrl: widget.mediaUrl,
          mediaType: widget.mediaType,
          cachedMediaInfo: cachedMediaInfo,
          uniqueId: widget.uniqueId ?? const Uuid().v1(),
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
          assetErrorImage: widget.assetErrorImage,
          builder: widget.builder,
          startLoadingOnlyWhenVisible: widget.startLoadingOnlyWhenVisible,
        );
      default:
        {
          return SizedBox(
            width: widget.width,
            height: widget.height,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (widget.showCircularProgressIndicator &&
                    widget.customLoadingProgressIndicator == null)
                  AnimatedOpacity(
                    opacity: startFadeIn ? 0.0 : 1.0,
                    duration: fadeInDuration,
                    curve: Curves.fastOutSlowIn,
                    child: const SizedBox(
                        width: 30,
                        height: 30,
                        child: CircularProgressIndicator.adaptive()),
                  ),
                if (widget.customLoadingProgressIndicator != null)
                  AnimatedOpacity(
                    opacity: startFadeIn ? 0.0 : 1.0,
                    duration: fadeInDuration,
                    curve: Curves.fastOutSlowIn,
                    child: widget.customLoadingProgressIndicator!,
                  ),
                Builder(
                  builder: (context) {
                    switch (mediaDownloadStatus) {
                      case MediaVisibility.initial:
                        {
                          return widget.startLoadingOnlyWhenVisible
                              ? VisibilityDetector(
                                  key: widget.key ??
                                      Key('visibility-cached-media-${widget.uniqueId ?? const Uuid().v1()}'),
                                  onVisibilityChanged: !isInitiating &&
                                          mediaDownloadStatus ==
                                              MediaVisibility.initial
                                      ? (_) async => _.visibleFraction > 0
                                          ? await init()
                                          : null
                                      : null,
                                  child: SizedBox(
                                      width: widget.width,
                                      height: widget.height),
                                )
                              : const SizedBox.shrink();
                        }
                      case MediaVisibility.downloaded:
                        {
                          return cachedMediaInfo != null
                              ? AnimatedOpacity(
                                  opacity: startFadeIn ? 1.0 : 0.0,
                                  duration: fadeInDuration,
                                  curve: Curves.fastOutSlowIn,
                                  child: MediaWidget(
                                    mediaUrl: widget.mediaUrl,
                                    mediaType: widget.mediaType,
                                    cachedMediaInfo: cachedMediaInfo!,
                                    uniqueId:
                                        widget.uniqueId ?? const Uuid().v1(),
                                    width: widget.width,
                                    height: widget.height,
                                    fit: widget.fit,
                                    assetErrorImage: widget.assetErrorImage,
                                    builder: widget.builder,
                                    startLoadingOnlyWhenVisible:
                                        widget.startLoadingOnlyWhenVisible,
                                  ),
                                )
                              : widget.errorWidget ?? const Text('Error');
                        }

                      case MediaVisibility.error:
                        {
                          return widget.errorWidget ?? const Text('Error');
                        }
                      default:
                        {
                          return const Text('Error');
                        }
                    }
                  },
                ),
              ],
            ),
          );
        }
    }
  }
}
