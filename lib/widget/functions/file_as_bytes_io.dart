import 'dart:io';
import 'package:cached_media/cached_media.dart';
import 'dart:developer' as developer;
import '../../model/all_cached_media_info.dart';

Future<CachedMediaInfo?> fileAsBytesIoWeb(CachedMediaInfo? cachedMediaInfo, String mediaUrl) async {
  if (cachedMediaInfo != null) {
    final file = File(cachedMediaInfo.cachedMediaUrl);
    if (await file.exists()) {
      final bytes = file.readAsBytesSync();
      cachedMediaInfo.bytes = bytes;
      return cachedMediaInfo;
    } else {
      if (getShowLogs) developer.log('❌ Error - fileAsBytesIoWeb() file DOES NOT EXIST: $mediaUrl', name: 'Cached Media package');
    }
  } else {
    if (getShowLogs) developer.log('❌ Error - fileAsBytesIoWeb() cachedMediaInfo is NULL : $mediaUrl', name: 'Cached Media package');
  }
  return null;
}
