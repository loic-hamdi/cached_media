import 'dart:core';

import 'package:cached_media/entity_cached_media_info.dart';
import 'package:cached_media/objectbox.dart';
import 'package:cached_media/objectbox.g.dart';

void addCachedImageInfo(Store store, CachedMediaInfo cachedImageInfo) {
  store.box<CachedMediaInfo>().put(cachedImageInfo);
}

void removeCachedImageInfo(ObjectBox objectbox, int id) {
  objectbox.cachedImageInfoBox.remove(id);
}

Future<CachedMediaInfo?> findFirstCachedImageInfoOrNull(ObjectBox objectbox, String imageUrl) async {
  final query = objectbox.cachedImageInfoBox.query(CachedMediaInfo_.imageUrl.equals(imageUrl)).build();
  final cachedImagesQuantity = query.find();
  return cachedImagesQuantity.isNotEmpty ? cachedImagesQuantity.first : null;
}

Future<List<CachedMediaInfo>?> findAllCachedImageInfoOrNull(ObjectBox objectbox, String imageUrl) async {
  final query = objectbox.cachedImageInfoBox.query(CachedMediaInfo_.imageUrl.equals(imageUrl)).build();
  final cachedImagesInfo = query.find(); // find() returns List<CachedImageInfo>
  return cachedImagesInfo.isNotEmpty ? cachedImagesInfo : null;
}

Future<List<CachedMediaInfo>> findAllCachedImageInfo(ObjectBox objectbox) async {
  return objectbox.cachedImageInfoBox.getAll();
}

Future<int> countAllCachedImage(ObjectBox objectbox) async {
  final query = objectbox.cachedImageInfoBox.getAll();
  return query.length;
}
