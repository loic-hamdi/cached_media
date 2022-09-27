import 'dart:core';

import 'package:cached_media/entity_cached_media_info.dart';
import 'package:cached_media/objectbox.dart';
import 'package:cached_media/objectbox.g.dart';

void addCachedMediaInfo(Store store, CachedMediaInfo cachedMediaInfo) {
  store.box<CachedMediaInfo>().put(cachedMediaInfo);
}

void removeCachedMediaInfo(ObjectBox objectbox, int id) {
  objectbox.cachedMediaInfoBox.remove(id);
}

Future<CachedMediaInfo?> findFirstCachedMediaInfoOrNull(ObjectBox objectbox, String mediaUrl) async {
  final query = objectbox.cachedMediaInfoBox.query(CachedMediaInfo_.mediaUrl.equals(mediaUrl)).build();
  final cachedMediaQuantity = query.find();
  return cachedMediaQuantity.isNotEmpty ? cachedMediaQuantity.first : null;
}

Future<List<CachedMediaInfo>?> findAllCachedMediaInfoOrNull(ObjectBox objectbox, String mediaUrl) async {
  final query = objectbox.cachedMediaInfoBox.query(CachedMediaInfo_.mediaUrl.equals(mediaUrl)).build();
  final cachedMediaInfo = query.find(); // find() returns List<CachedMediaInfo>
  return cachedMediaInfo.isNotEmpty ? cachedMediaInfo : null;
}

Future<List<CachedMediaInfo>> findAllCachedMediaInfo(ObjectBox objectbox) async {
  return objectbox.cachedMediaInfoBox.getAll();
}

Future<int> countAllCachedMedia(ObjectBox objectbox) async {
  final query = objectbox.cachedMediaInfoBox.getAll();
  return query.length;
}
