library cached_fadein_image;

import 'dart:io';

import 'package:cached_media/cached_media.dart';
import 'package:cached_media/constants.dart';
import 'package:cached_media/entity_cached_media_info.dart';
import 'package:cached_media/management_store.dart';
import 'package:cached_media/widget/functions.dart';
import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

class CachedMedia extends StatefulWidget {
  const CachedMedia({
    required this.imageUrl,
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
    Key? key,
  }) : super(key: key);

  /// Web url to get the image. The address must contains the file extension.
  final String imageUrl;
  final double width;
  final double height;
  final BoxFit? fit;

  /// To save ressources & bandwidth you can delay the image download
  /// Set [startLoadingOnlyWhenVisible] to [true] to start to download the image when the widget becomes visible on user's screen
  final bool startLoadingOnlyWhenVisible;

  /// Display image from 'assets' when image throw an error
  final String? assetErrorImage;

  /// Duration can be set to [Duration.zero] to deactivate the fadein effect
  final Duration? fadeInDuration;

  /// Show the [CircularProgressIndicator] when downloading image
  final bool showCircularProgressIndicator;

  /// Show a custom loader when downloading image
  final Widget? customLoadingProgressIndicator;

  /// Widget [errorWidget] will be displayed if image loading throw an error
  final Widget? errorWidget;

  /// The [uniqueId] is used to generate widget keys
  /// Important: This [String] must be unique for any image you will load with [CachedMedia]
  final String uniqueId;

  @override
  State<CachedMedia> createState() => _CachedMediaState();
}

class _CachedMediaState extends State<CachedMedia> with AutomaticKeepAliveClientMixin<CachedMedia> {
  @override
  bool get wantKeepAlive => true;

  ImageDownloadStatus imageDownloadStatus = ImageDownloadStatus.initial;
  bool isInitiating = false;
  bool startFadeIn = false;
  late Duration fadeInDuration;

  CachedMediaInfo? cachedMediaInfo;

  @override
  void initState() {
    super.initState();
    fadeInDuration = widget.fadeInDuration ?? const Duration(milliseconds: 1000);
    if (imageDownloadStatus == ImageDownloadStatus.initial) {
      if (!widget.startLoadingOnlyWhenVisible) init();
    }
  }

  Future<void> init() async {
    isInitiating = true;
    if (mounted) setState(() {});
    if (cachedMediaInfo == null) await loadFromCache(widget.imageUrl);
    await doesFileExist(cachedMediaInfo?.cachedMediaUrl) ? await showImage() : await errorImage();
    isInitiating = false;
    if (mounted) setState(() {});
  }

  Future<void> loadFromCache(String imageUrl) async {
    cachedMediaInfo = await findFirstCachedMediaInfoOrNull(getObjectBox, imageUrl);
    if (cachedMediaInfo == null) {
      await downloadAndSetInCache(imageUrl);
    } else if (cachedMediaInfo != null) {
      if (await doesFileExist(cachedMediaInfo?.cachedMediaUrl)) {
        await showImage();
      } else {
        removeCachedMediaInfo(getObjectBox, cachedMediaInfo!.id);
        await downloadAndSetInCache(imageUrl);
      }
    }
  }

  Future<void> downloadAndSetInCache(String imageUrl) async {
    final tmpPath = await downloadImageToCache(imageUrl);
    if (await doesFileExist(tmpPath)) {
      var file = File(tmpPath!);
      final cachedMediaInfoToSet = CachedMediaInfo(
        mediaUrl: imageUrl,
        dateCreated: DateTime.now(),
        fileSize: await file.length(),
        cachedMediaUrl: tmpPath,
      );
      addCachedMediaInfo(getObjectBox.store, cachedMediaInfoToSet);
      await loadFromCache(imageUrl);
    } else {
      await errorImage();
    }
  }

  Future<void> showImage() async {
    imageDownloadStatus = ImageDownloadStatus.downloaded;
    if (mounted) setState(() {});
    await Future.delayed(const Duration(milliseconds: 25));
    startFadeIn = true;
    if (mounted) setState(() {});
  }

  Future<void> errorImage() async {
    imageDownloadStatus = ImageDownloadStatus.error;
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
              switch (imageDownloadStatus) {
                case ImageDownloadStatus.initial:
                  {
                    return widget.startLoadingOnlyWhenVisible
                        ? VisibilityDetector(
                            key: widget.key ?? Key('visibility-cached-image-${widget.uniqueId}'),
                            onVisibilityChanged: !isInitiating && imageDownloadStatus == ImageDownloadStatus.initial ? (_) async => _.visibleFraction > 0 ? await init() : null : null,
                            child: SizedBox(width: widget.width, height: widget.height),
                          )
                        : const SizedBox.shrink();
                  }
                case ImageDownloadStatus.downloaded:
                  {
                    return cachedMediaInfo != null
                        ? AnimatedOpacity(
                            opacity: startFadeIn ? 1.0 : 0.0,
                            duration: fadeInDuration,
                            curve: Curves.fastOutSlowIn,
                            child: Image.file(
                              key: Key('cached-image-${widget.uniqueId}'),
                              File(cachedMediaInfo!.cachedMediaUrl),
                              width: widget.width,
                              height: widget.height,
                              fit: widget.fit,
                              errorBuilder: widget.assetErrorImage != null ? (context, error, stackTrace) => Image.asset(widget.assetErrorImage!, fit: BoxFit.fitWidth) : null,
                            ),
                          )
                        : widget.errorWidget ?? const Text('Error');
                  }
                case ImageDownloadStatus.error:
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
