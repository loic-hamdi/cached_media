library cached_fadein_image;

import 'dart:io';

import 'package:cached_image/cached_image.dart';
import 'package:cached_image/constants.dart';
import 'package:cached_image/entity_cached_image_info.dart';
import 'package:cached_image/management_store.dart';
import 'package:cached_image/widget/functions.dart';
import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

class CachedImage extends StatefulWidget {
  const CachedImage({
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
  /// Important: This [String] must be unique for any image you will load with [CachedImage]
  final String uniqueId;

  @override
  State<CachedImage> createState() => _CachedImageState();
}

class _CachedImageState extends State<CachedImage> with AutomaticKeepAliveClientMixin<CachedImage> {
  @override
  bool get wantKeepAlive => true;

  ImageDownloadStatus imageDownloadStatus = ImageDownloadStatus.initial;
  bool isInitiating = false;
  bool startFadeIn = false;
  late Duration fadeInDuration;

  CachedImageInfo? cachedImageInfo;

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
    if (cachedImageInfo == null) await loadFromCache(widget.imageUrl);
    await doesFileExist(cachedImageInfo?.cachedImageUrl) ? await showImage() : await errorImage();
    isInitiating = false;
    if (mounted) setState(() {});
  }

  Future<void> loadFromCache(String imageUrl) async {
    cachedImageInfo = await findFirstCachedImageInfoOrNull(getObjectBox, imageUrl);
    if (cachedImageInfo == null) {
      await downloadAndSetInCache(imageUrl);
    } else if (cachedImageInfo != null) {
      if (await doesFileExist(cachedImageInfo?.cachedImageUrl)) {
        await showImage();
      } else {
        removeCachedImageInfo(getObjectBox, cachedImageInfo!.id);
        await downloadAndSetInCache(imageUrl);
      }
    }
  }

  Future<void> downloadAndSetInCache(String imageUrl) async {
    final tmpPath = await downloadImageToCache(imageUrl);
    if (await doesFileExist(tmpPath)) {
      var file = File(tmpPath!);
      final cachedImageInfoToSet = CachedImageInfo(
        imageUrl: imageUrl,
        dateCreated: DateTime.now(),
        fileSize: await file.length(),
        cachedImageUrl: tmpPath,
      );
      addCachedImageInfo(getObjectBox.store, cachedImageInfoToSet);
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
                    return cachedImageInfo != null
                        ? AnimatedOpacity(
                            opacity: startFadeIn ? 1.0 : 0.0,
                            duration: fadeInDuration,
                            curve: Curves.fastOutSlowIn,
                            child: Image.file(
                              key: Key('cached-image-${widget.uniqueId}'),
                              File(cachedImageInfo!.cachedImageUrl),
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
