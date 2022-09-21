import 'dart:core';

import 'package:cached_image/entity_cached_image_info.dart';
import 'package:cached_image/objectbox.dart';
import 'package:cached_image/objectbox.g.dart';

void addCachedImageInfo(Store store, CachedImageInfo cachedImageInfo) {
  store.box<CachedImageInfo>().put(cachedImageInfo);
}

void removeCachedImageInfo(ObjectBox objectbox, int id) {
  objectbox.cachedImageInfoBox.remove(id);
}

Future<CachedImageInfo?> findFirstCachedImageInfoOrNull(ObjectBox objectbox, String imageUrl) async {
  final query = objectbox.cachedImageInfoBox.query(CachedImageInfo_.imageUrl.equals(imageUrl)).build();
  final cachedImagesQuantity = query.find();
  return cachedImagesQuantity.isNotEmpty ? cachedImagesQuantity.first : null;
}

Future<List<CachedImageInfo>?> findAllCachedImageInfoOrNull(ObjectBox objectbox, String imageUrl) async {
  final query = objectbox.cachedImageInfoBox.query(CachedImageInfo_.imageUrl.equals(imageUrl)).build();
  final cachedImagesInfo = query.find(); // find() returns List<CachedImageInfo>
  return cachedImagesInfo.isNotEmpty ? cachedImagesInfo : null;
}

Future<List<CachedImageInfo>> findAllCachedImageInfo(ObjectBox objectbox) async {
  return objectbox.cachedImageInfoBox.getAll();
}

Future<int> countAllCachedImage(ObjectBox objectbox) async {
  final query = objectbox.cachedImageInfoBox.getAll();
  return query.length;
}
