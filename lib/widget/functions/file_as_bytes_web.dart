import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

import '../../model/all_cached_media_info.dart';

Future<CachedMediaInfo?> fileAsBytesIoWeb(CachedMediaInfo? cachedMediaInfo, String mediaUrl) async {
  Uint8List bytes = (await NetworkAssetBundle(Uri.parse(mediaUrl)).load(mediaUrl)).buffer.asUint8List();
  final cachedMediaInfo = CachedMediaInfo(
    id: const Uuid().v1(),
    mediaUrl: mediaUrl,
    bytes: bytes,
    cachedMediaUrl: '',
    dateCreated: 0,
    fileSize: 0,
  );
  return cachedMediaInfo;
}
