import 'dart:developer' as developer;
import 'package:cached_media/cached_media.dart';
import 'package:cached_media/entity_cached_media_info.dart';
import 'package:cached_media/management_store.dart';
import 'package:get_storage/get_storage.dart';

double calculateCacheSize(List<CachedMediaInfo> allCachedMediaInfo) {
  double tmpCurrentCacheSize = 0;
  for (final cachedMediaInfo in allCachedMediaInfo) {
    tmpCurrentCacheSize += cachedMediaInfo.fileSize;
  }
  currentCacheSize = tmpCurrentCacheSize;
  return currentCacheSize;
}

Future<void> reduceCacheSize(GetStorage getStorage, List<CachedMediaInfo> allCachedMediaInfo) async {
  if (allCachedMediaInfo.isNotEmpty) {
    allCachedMediaInfo.sort((a, b) => a.dateCreated.compareTo(b.dateCreated));
    final a = allCachedMediaInfo.first;
    if (getShowLogs) {
      developer.log("🧽 Clearing cache from ${a.mediaUrl}", name: 'Cached Media package');
    }
    removeCachedMediaInfo(getStorage, a.id);
  }
}

Future<void> clearCacheOnInit(GetStorage getStorage) async {
  final allCmi = await findAllCachedMediaInfo(getStorage);
  var i = 1;
  for (final cmi in allCmi) {
    if (getShowLogs) {
      developer.log("🧽 [$i/${allCmi.length}] Clearing cache from ${cmi.mediaUrl}", name: 'Cached Media package');
    }
    removeCachedMediaInfo(getStorage, cmi.id);
    i++;
  }
}
