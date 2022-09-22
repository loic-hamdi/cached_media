import 'package:objectbox/objectbox.dart';

import 'objectbox.g.dart';

@Entity()
class CachedMediaInfo {
  int id;
  String mediaUrl;
  String cachedMediaUrl;
  int fileSize;
  DateTime dateCreated;

  CachedMediaInfo({
    required this.mediaUrl,
    required this.cachedMediaUrl,
    required this.fileSize,
    required this.dateCreated,
    this.id = 0,
  });
}
