// import 'dart:io';
import 'package:cached_media/entity_cached_media_info.dart';
import 'package:flutter/material.dart';

class ImageWidget extends StatelessWidget {
  const ImageWidget({
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
  Widget build(BuildContext context) {
    return cachedMediaInfo.bytes != null
        ? Image.memory(
            key: Key('CM-ImageWidget-$uniqueId'),
            cachedMediaInfo.bytes!,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: assetErrorImage != null
                ? (context, error, stackTrace) => Image.asset(
                      assetErrorImage!,
                      fit: BoxFit.fitWidth,
                    )
                : null,
            frameBuilder: ((context, child, frame, wasSynchronouslyLoaded) {
              if (wasSynchronouslyLoaded) return child;
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: frame != null
                    ? child
                    : SizedBox(
                        height: height,
                        width: width,
                        child: const CircularProgressIndicator.adaptive(strokeWidth: 2),
                      ),
              );
            }),
          )
        : const Text('Not found');
  }
}
