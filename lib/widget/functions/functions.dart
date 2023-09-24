// import 'dart:io';
import 'package:cached_media/management_store_io.dart';
import 'package:cached_media/model/all_cached_media_info.dart';
import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import 'package:cached_media/management_cache_web.dart' if (dart.library.io) 'package:cached_media/management_cache_io.dart';
import 'package:cached_media/widget/functions/file_as_bytes_web.dart' if (dart.library.io) 'package:cached_media/widget/functions/file_as_bytes_io.dart';

/// Return [CachedMediaInfo?] after either finding in cache or downloading then set in cache
Future<CachedMediaInfo?> loadMedia(
  String mediaUrl, {
  required GetStorage getStorage,
  bool returnFileAsBytes = false,
}) async {
  if (kIsWeb) return null;
  CachedMediaInfo? cachedMediaInfo = await findFirstCachedMediaInfoOrNull(getStorage, mediaUrl);
  if (cachedMediaInfo == null) {
    await downloadAndSetInCache(mediaUrl, getStorage: getStorage);
  } else {
    if (await doesFileExist(cachedMediaInfo.cachedMediaUrl)) {
      return cachedMediaInfo;
    } else {
      removeCachedMediaInfo(getStorage, cachedMediaInfo.id);
      await downloadAndSetInCache(mediaUrl, getStorage: getStorage);
    }
  }
  cachedMediaInfo = await findFirstCachedMediaInfoOrNull(getStorage, mediaUrl);
  if (returnFileAsBytes) {
    cachedMediaInfo = await fileAsBytesIoWeb(cachedMediaInfo);
  }
  return cachedMediaInfo;
}
