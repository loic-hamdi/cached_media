import 'dart:convert';
import 'dart:core';
import 'package:cached_media/cached_media_init.dart';
import 'package:cached_media/entity_cached_media_info.dart';
import 'package:collection/collection.dart';
import 'package:get_storage/get_storage.dart';

void addCachedMediaInfo(GetStorage objectbox, CachedMediaInfo cachedMediaInfo) {
  final all = objectbox.read(keyName);
  final tmp = AllCachedMediaInfo(cachedMediaInfo: []);
  if (all != null) {
    final allData = AllCachedMediaInfo.fromJson(json.decode(all));
    tmp.cachedMediaInfo!.addAll(allData.cachedMediaInfo ?? []);
  }
  tmp.cachedMediaInfo!.add(cachedMediaInfo);
  objectbox.write(keyName, json.encode(tmp.toJson()));
}

void removeCachedMediaInfo(GetStorage objectbox, String id) {
  final all = objectbox.read(keyName);
  if (all != null) {
    final allData = AllCachedMediaInfo.fromJson(json.decode(all));
    if (allData.cachedMediaInfo != null) {
      allData.cachedMediaInfo!.removeWhere((e) => e.id == id);
      objectbox.write(keyName, json.encode(allData.toJson()));
    }
  }
}

Future<CachedMediaInfo?> findFirstCachedMediaInfoOrNull(GetStorage objectbox, String mediaUrl) async {
  final all = objectbox.read(keyName);
  if (all != null) {
    final allData = AllCachedMediaInfo.fromJson(json.decode(all));
    if (allData.cachedMediaInfo != null && allData.cachedMediaInfo!.isNotEmpty) {
      return allData.cachedMediaInfo!.firstWhereOrNull((e) => e.mediaUrl == mediaUrl);
    }
  }
  return null;
}

Future<List<CachedMediaInfo>> findAllCachedMediaInfo(GetStorage objectbox) async {
  final all = objectbox.read(keyName);
  if (all != null) {
    final allData = AllCachedMediaInfo.fromJson(json.decode(all));
    return allData.cachedMediaInfo ?? <CachedMediaInfo>[];
  }
  return <CachedMediaInfo>[];
}

Future<int> countAllCachedMedia(GetStorage objectbox) async {
  final all = objectbox.read(keyName);
  if (all != null) {
    final allData = AllCachedMediaInfo.fromJson(json.decode(all));
    return allData.cachedMediaInfo?.length ?? 0;
  }
  return 0;
}
