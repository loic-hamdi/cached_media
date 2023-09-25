import 'package:cached_media/cached_media.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import 'dart:developer' as developer;
import '../../model/all_cached_media_info.dart';

Future<CachedMediaInfo?> fileAsBytesIoWeb(CachedMediaInfo? cachedMediaInfo, String mediaUrl) async {
  if (getShowLogs) developer.log('🟫  fileAsBytesIoWeb() WEB - $mediaUrl', name: 'Cached Media package');
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
