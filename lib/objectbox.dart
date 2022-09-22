import 'dart:io';

import 'package:cached_media/entity_cached_media_info.dart';
import 'package:cached_media/objectbox.g.dart';
import 'package:path_provider/path_provider.dart';

class ObjectBox {
  late final Store store;

  late final Box<CachedMediaInfo> cachedImageInfoBox;

  late final Stream<Query<CachedMediaInfo>> cachedImageInfoStream;

  ObjectBox._create(this.store) {
    cachedImageInfoBox = Box<CachedMediaInfo>(store);
    final qBuilder = cachedImageInfoBox.query()..order(CachedMediaInfo_.dateCreated, flags: Order.descending);
    cachedImageInfoStream = qBuilder.watch(triggerImmediately: true);
  }

  static Future<ObjectBox> create() async {
    Directory dir = await getApplicationDocumentsDirectory();
    final store = await openStore(directory: dir.path);
    return ObjectBox._create(store);
  }
}
