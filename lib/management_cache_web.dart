import 'package:cached_media/model/all_cached_media_info.dart';
import 'package:get_storage/get_storage.dart';

Future<dynamic> getTemporaryDirectoryIoWeb() async {
  return null;
}

Future<void> downloadAndSetInCache(String mediaUrl, {required GetStorage getStorage}) async {}

Future<String?> downloadMediaToCache(String mediaUrl) async {
  return null;
}

Future<String?> downloadMediaToLocalCache(String mediaUrl, String mediaName) async {
  return null;
}

Future<bool> doesFileExist(String? filePath) async {
  return false;
}

double calculateCacheSize(List<CachedMediaInfo> allCachedMediaInfo) {
  return 0.0;
}

Future<void> deleteMediaInCache(String filePath) async {}

Future<void> reduceCacheSize(GetStorage getStorage, List<CachedMediaInfo> allCachedMediaInfo) async {}

Future<void> clearCacheOnInit(GetStorage getStorage) async {}
