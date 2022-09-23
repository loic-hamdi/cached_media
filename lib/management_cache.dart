import 'dart:io';

import 'dart:developer' as developer;

import 'package:cached_media/cached_media.dart';
import 'package:cached_media/entity_cached_media_info.dart';
import 'package:cached_media/management_store.dart';
import 'package:cached_media/objectbox.dart';

double calculateCacheSize(List<CachedMediaInfo> allCachedMediaInfo) {
  double tmpCurrentCacheSize = 0;
  for (final cachedMediaInfo in allCachedMediaInfo) {
    tmpCurrentCacheSize += cachedMediaInfo.fileSize;
  }
  currentCacheSize = tmpCurrentCacheSize;
  return currentCacheSize;
}

Future<void> deleteMediaInCache(String filePath) async {
  var file = File(filePath);
  if (await file.exists()) await file.delete();
}

Future<void> reduceCacheSize(
    ObjectBox objectBox, List<CachedMediaInfo> allCachedMediaInfo) async {
  if (allCachedMediaInfo.isNotEmpty) {
    allCachedMediaInfo.sort((a, b) => a.dateCreated.compareTo(b.dateCreated));
    final a = allCachedMediaInfo.first;
    if (getShowLogs) {
      developer.log("🧽 Clearing cache from ${a.cachedMediaUrl}",
          name: 'Cached Media package');
    }
    await deleteMediaInCache(a.cachedMediaUrl);
    removeCachedMediaInfo(objectBox, a.id);
  }
}
