import 'dart:io';
import '../../model/all_cached_media_info.dart';

Future<CachedMediaInfo?> fileAsBytesIoWeb(CachedMediaInfo? cachedMediaInfo, String mediaUrl) async {
  if (cachedMediaInfo != null) {
    final file = File(cachedMediaInfo.cachedMediaUrl);
    if (await file.exists()) {
      final bytes = file.readAsBytesSync();
      cachedMediaInfo.bytes = bytes;
      return cachedMediaInfo;
    }
  }
  return null;
}
