import 'dart:core';
import 'package:cached_media/model/all_cached_media_info.dart';
import 'package:get_storage/get_storage.dart';

Future<void> addCachedMediaInfo(GetStorage getStorage, CachedMediaInfo cachedMediaInfo) async {}

Future<void> removeCachedMediaInfo(GetStorage getStorage, String id) async {}

Future<CachedMediaInfo?> findFirstCachedMediaInfoOrNull(GetStorage getStorage, String mediaUrl) async {
  return null;
}

Future<List<CachedMediaInfo>> findAllCachedMediaInfo(GetStorage getStorage) async {
  return [];
}

Future<int> countAllCachedMedia(GetStorage getStorage) async {
  return 0;
}
