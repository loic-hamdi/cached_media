import 'package:objectbox/objectbox.dart';

import 'objectbox.g.dart';

@Entity()
class CachedImageInfo {
  int id;
  String imageUrl;
  String cachedImageUrl;
  int fileSize;
  DateTime dateCreated;

  CachedImageInfo({
    required this.imageUrl,
    required this.cachedImageUrl,
    required this.fileSize,
    required this.dateCreated,
    this.id = 0,
  });
}
