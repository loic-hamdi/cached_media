library cached_media;

import 'dart:io';

import 'package:cached_media/cached_media.dart';
import 'package:cached_media/entity_cached_media_info.dart';
import 'package:cached_media/enums/enums.dart';
import 'package:cached_media/management_store.dart';
import 'package:cached_media/widget/download_media_snapshot.dart';
import 'package:cached_media/widget/functions/functions.dart';
import 'package:cached_media/widget/media_type/media_widget.dart';
import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

typedef StringCallback = void Function(String? val);

class CachedMedia extends StatefulWidget {
  const CachedMedia({
    required this.mediaType,
    required this.mediaUrl,
    required this.width,
    required this.height,
    this.startLoadingOnlyWhenVisible = false,
    this.fit,
    this.assetErrorImage,
    this.fadeInDuration,
    this.customLoadingProgressIndicator,
    this.showCircularProgressIndicator = true,
    this.errorWidget,
    required this.uniqueId,
    this.customImageWidget,
    this.customVideoPlayerWidget,
    this.customAudioPlayerWidget,
    this.builder,
    Key? key,
  }) : super(key: key);

  /// Define the type of media you want to display. You can show: image, video or audio
  final MediaType mediaType;

  /// Web url to get the media. The address must contains the file extension.
  final String mediaUrl;
  final double width;
  final double height;
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
  final String uniqueId;

  final Widget? customImageWidget;
  final Widget? customVideoPlayerWidget;
  final Widget? customAudioPlayerWidget;

  final Widget? Function(BuildContext context, DownloadMediaSnapshot snapshot)? builder;

  @override
  State<CachedMedia> createState() => _CachedMediaState();
}

class _CachedMediaState extends State<CachedMedia> with AutomaticKeepAliveClientMixin<CachedMedia> {
  @override
  bool get wantKeepAlive => true;

  MediaDownloadStatus mediaDownloadStatus = MediaDownloadStatus.initial;
  bool isInitiating = false;
  bool startFadeIn = false;
  late Duration fadeInDuration;

  CachedMediaInfo? cachedMediaInfo;

  @override
  void initState() {
    super.initState();
    fadeInDuration = widget.fadeInDuration ?? const Duration(milliseconds: 1000);
    if (mediaDownloadStatus == MediaDownloadStatus.initial) {
      if (!widget.startLoadingOnlyWhenVisible) init();
    }
  }

  Future<void> init() async {
    isInitiating = true;
    if (mounted) setState(() {});
    if (cachedMediaInfo == null) await loadFromCache(widget.mediaUrl);
    await doesFileExist(cachedMediaInfo?.cachedMediaUrl) ? await showMedia() : await errorMedia();
    isInitiating = false;
    if (mounted) setState(() {});
  }

  Future<void> loadFromCache(String mediaUrl) async {
    cachedMediaInfo = await findFirstCachedMediaInfoOrNull(getObjectBox, mediaUrl);
    if (cachedMediaInfo == null) {
      await downloadAndSetInCache(mediaUrl);
    } else if (cachedMediaInfo != null) {
      if (await doesFileExist(cachedMediaInfo?.cachedMediaUrl)) {
        await showMedia();
      } else {
        removeCachedMediaInfo(getObjectBox, cachedMediaInfo!.id);
        await downloadAndSetInCache(mediaUrl);
      }
    }
  }

  Future<void> downloadAndSetInCache(String mediaUrl) async {
    final tmpPath = await downloadMediaToCache(mediaUrl);
    if (await doesFileExist(tmpPath)) {
      var file = File(tmpPath!);
      final cachedMediaInfoToSet = CachedMediaInfo(
        mediaUrl: mediaUrl,
        dateCreated: DateTime.now(),
        fileSize: await file.length(),
        cachedMediaUrl: tmpPath,
      );
      addCachedMediaInfo(getObjectBox.store, cachedMediaInfoToSet);
      await loadFromCache(mediaUrl);
    } else {
      await errorMedia();
    }
  }

  Future<void> showMedia() async {
    mediaDownloadStatus = MediaDownloadStatus.downloaded;
    if (mounted) setState(() {});
    await Future.delayed(const Duration(milliseconds: 25));
    startFadeIn = true;
    if (mounted) setState(() {});
  }

  Future<void> errorMedia() async {
    mediaDownloadStatus = MediaDownloadStatus.error;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (widget.showCircularProgressIndicator && widget.customLoadingProgressIndicator == null)
            AnimatedOpacity(
              opacity: startFadeIn ? 0.0 : 1.0,
              duration: fadeInDuration,
              curve: Curves.fastOutSlowIn,
              child: const SizedBox(width: 30, height: 30, child: CircularProgressIndicator.adaptive()),
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
                case MediaDownloadStatus.initial:
                  {
                    return widget.startLoadingOnlyWhenVisible
                        ? VisibilityDetector(
                            key: widget.key ?? Key('visibility-cached-media-${widget.uniqueId}'),
                            onVisibilityChanged: !isInitiating && mediaDownloadStatus == MediaDownloadStatus.initial ? (_) async => _.visibleFraction > 0 ? await init() : null : null,
                            child: SizedBox(width: widget.width, height: widget.height),
                          )
                        : const SizedBox.shrink();
                  }
                case MediaDownloadStatus.downloaded:
                  {
                    return cachedMediaInfo != null
                        ? AnimatedOpacity(
                            opacity: startFadeIn ? 1.0 : 0.0,
                            duration: fadeInDuration,
                            curve: Curves.fastOutSlowIn,
                            child: MediaWidget(
                              mediaType: widget.mediaType,
                              cachedMediaInfo: cachedMediaInfo!,
                              uniqueId: widget.uniqueId,
                              width: widget.width,
                              height: widget.height,
                              fit: widget.fit,
                              assetErrorImage: widget.assetErrorImage,
                              customImageWidget: widget.customImageWidget,
                              customVideoPlayerWidget: widget.customVideoPlayerWidget,
                              customAudioPlayerWidget: widget.customAudioPlayerWidget,
                              builder: widget.builder,
                            ),
                          )
                        : widget.errorWidget ?? const Text('Error');
                  }
                case MediaDownloadStatus.error:
                  {
                    return widget.errorWidget ?? const Text('Error');
                  }
              }
            },
          ),
        ],
      ),
    );
  }
}
