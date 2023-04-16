import 'dart:convert';
import 'dart:core';
import 'package:cached_media/cached_media_init.dart';
import 'package:cached_media/entity_cached_media_info.dart';
import 'package:collection/collection.dart';
import 'package:get_storage/get_storage.dart';

void addCachedMediaInfo(GetStorage getStorage, CachedMediaInfo cachedMediaInfo) {
  final all = getStorage.read(keyName);
  final tmp = AllCachedMediaInfo(cachedMediaInfo: []);
  if (all != null) {
    final allData = AllCachedMediaInfo.fromJson(json.decode(all));
    tmp.cachedMediaInfo!.addAll(allData.cachedMediaInfo ?? []);
  }
  tmp.cachedMediaInfo!.add(cachedMediaInfo);
  getStorage.write(keyName, json.encode(tmp.toJson()));
}

void removeCachedMediaInfo(GetStorage getStorage, String id) {
  final all = getStorage.read(keyName);
  if (all != null) {
    final allData = AllCachedMediaInfo.fromJson(json.decode(all));
    if (allData.cachedMediaInfo != null) {
      allData.cachedMediaInfo!.removeWhere((e) => e.id == id);
      getStorage.write(keyName, json.encode(allData.toJson()));
    }
  }
}

Future<CachedMediaInfo?> findFirstCachedMediaInfoOrNull(GetStorage getStorage, String mediaUrl) async {
  final all = getStorage.read(keyName);
  if (all != null) {
    final allData = AllCachedMediaInfo.fromJson(json.decode(all));
    if (allData.cachedMediaInfo != null && allData.cachedMediaInfo!.isNotEmpty) {
      return allData.cachedMediaInfo!.firstWhereOrNull((e) => e.mediaUrl == mediaUrl);
    }
  }
  return null;
}

Future<List<CachedMediaInfo>> findAllCachedMediaInfo(GetStorage getStorage) async {
  final all = getStorage.read(keyName);
  if (all != null) {
    final allData = AllCachedMediaInfo.fromJson(json.decode(all));
    return allData.cachedMediaInfo ?? <CachedMediaInfo>[];
  }
  return <CachedMediaInfo>[];
}

Future<int> countAllCachedMedia(GetStorage getStorage) async {
  final all = getStorage.read(keyName);
  if (all != null) {
    final allData = AllCachedMediaInfo.fromJson(json.decode(all));
    return allData.cachedMediaInfo?.length ?? 0;
  }
  return 0;
}
