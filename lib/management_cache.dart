import 'dart:io';

import 'dart:developer' as developer;

import 'package:cached_media/cached_media.dart';
import 'package:cached_media/entity_cached_media_info.dart';
import 'package:cached_media/management_store.dart';
import 'package:cached_media/objectbox.dart';

double calculateCacheSize(List<CachedMediaInfo> allCachedImageInfo) {
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

Future<void> reduceCacheSize(ObjectBox objectBox, List<CachedMediaInfo> allCachedImageInfo) async {
  if (allCachedImageInfo.isNotEmpty) {
    allCachedImageInfo.sort((a, b) => a.dateCreated.compareTo(b.dateCreated));
    final a = allCachedImageInfo.first;
    if (getShowLogs) {
      developer.log("🧽 Clearing cache from ${a.cachedImageUrl}");
    }
    await deleteImageInCache(a.cachedImageUrl);
    removeCachedImageInfo(objectBox, a.id);
  }
}
