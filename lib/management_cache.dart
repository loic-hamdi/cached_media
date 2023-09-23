import 'dart:developer' as developer;
import 'package:cached_media/cached_media.dart';
import 'package:cached_media/model/all_cached_media_info.dart';
import 'package:cached_media/management_store.dart';
import 'package:get_storage/get_storage.dart';

double calculateCacheSize(List<CachedMediaInfo> allCachedMediaInfo) {
  double tmpCurrentCacheSize = 0;
  for (final cachedMediaInfo in allCachedMediaInfo) {
    tmpCurrentCacheSize += cachedMediaInfo.fileSize;
  }
  return tmpCurrentCacheSize;
}

Future<void> reduceCacheSize(GetStorage getStorage, List<CachedMediaInfo> allCachedMediaInfo) async {
  if (allCachedMediaInfo.isNotEmpty) {
    allCachedMediaInfo.sort((a, b) => a.dateCreated.compareTo(b.dateCreated));
    final a = allCachedMediaInfo.first;
    if (getShowLogs) {
      developer.log("🧽  Clearing cache from ${a.mediaUrl}", name: 'Cached Media package');
    }
    await removeCachedMediaInfo(getStorage, a.id);
  }
}

Future<void> clearCacheOnInit(GetStorage getStorage) async {
  await getStorage.erase();
  developer.log("🧽  Erasing all storage box", name: 'Cached Media package');
}
