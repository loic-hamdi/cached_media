import 'dart:io';

import 'package:cached_image/entity_cached_image_info.dart';
import 'package:cached_image/init.dart';
import 'package:cached_image/management_store.dart';
import 'package:cached_image/objectbox.dart';

double calculateCacheSize(List<CachedImageInfo> allCachedImageInfo) {
  double tmpCurrentCacheSize = 0;
  for (final cachedImageInfo in allCachedImageInfo) {
    tmpCurrentCacheSize += cachedImageInfo.fileSize;
  }
  currentCacheSize = tmpCurrentCacheSize;
  return currentCacheSize;
}

Future<void> deleteImageInCache(String filePath) async {
  var file = File(filePath);
  if (await file.exists()) await file.delete();
}

Future<void> reduceCacheSize(ObjectBox objectBox, List<CachedImageInfo> allCachedImageInfo) async {
  if (allCachedImageInfo.isNotEmpty) {
    allCachedImageInfo.sort((a, b) => a.dateCreated.compareTo(b.dateCreated));
    final a = allCachedImageInfo.first;
    await deleteImageInCache(a.cachedImageUrl);
    removeCachedImageInfo(objectBox, a.id);
  }
}
