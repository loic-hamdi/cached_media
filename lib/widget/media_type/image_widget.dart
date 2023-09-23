// import 'dart:io';
import 'package:cached_media/entity_cached_media_info.dart';
import 'package:cross_file/cross_file.dart';
import 'package:cross_file_image/cross_file_image.dart';
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
        ? Image(
            key: Key('CM-ImageWidget-$uniqueId'),
            image: XFileImage(
              XFile.fromData(
                (cachedMediaInfo.bytes!),
                length: cachedMediaInfo.bytes!.length,
                mimeType: cachedMediaInfo.mimeType,
              ),
            ),
            width: width,
            height: height,
            fit: fit,
            errorBuilder: assetErrorImage != null
                ? (context, error, stackTrace) => Image.asset(
                      assetErrorImage!,
                      fit: BoxFit.fitWidth,
                    )
                : null,
          )
        : const Text('Not bytes found');
  }
}
