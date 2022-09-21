import 'dart:io';

import 'package:cached_image/entity_cached_image_info.dart';
import 'package:path_provider/path_provider.dart';

import 'objectbox.g.dart';

class ObjectBox {
  late final Store store;

  late final Box<CachedImageInfo> cachedImageInfoBox;

  late final Stream<Query<CachedImageInfo>> cachedImageInfoStream;

  ObjectBox._create(this.store) {
    cachedImageInfoBox = Box<CachedImageInfo>(store);
    final qBuilder = cachedImageInfoBox.query()..order(CachedImageInfo_.dateCreated, flags: Order.descending);
    cachedImageInfoStream = qBuilder.watch(triggerImmediately: true);
  }

  static Future<ObjectBox> create() async {
    Directory dir = await getApplicationDocumentsDirectory();
    final store = await openStore(directory: dir.path);
    return ObjectBox._create(store);
  }
}
