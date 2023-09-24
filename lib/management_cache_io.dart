import 'dart:developer' as developer;
import 'dart:io';
import 'package:cached_media/cached_media.dart';
import 'package:cached_media/model/all_cached_media_info.dart';
import 'package:cached_media/management_store_io.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

Future<Directory?> getTemporaryDirectoryIoWeb() async {
  return await getTemporaryDirectory();
}

Future<void> downloadAndSetInCache(String mediaUrl, {required GetStorage getStorage}) async {
  final tmpPath = await downloadMediaToCache(mediaUrl);
  if (await doesFileExist(tmpPath)) {
    var file = File(tmpPath!);
    final cachedMediaInfoToSet = CachedMediaInfo(
      id: const Uuid().v1(),
      mediaUrl: mediaUrl,
      dateCreated: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      fileSize: (await file.length()) / 1000000,
      cachedMediaUrl: tmpPath,
    );
    addCachedMediaInfo(getStorage, cachedMediaInfoToSet);
  }
}

Future<String?> downloadMediaToCache(String mediaUrl) async {
  String imgName = const Uuid().v1();
  String imgUrl = mediaUrl;
  if (imgUrl.contains("?")) imgUrl = mediaUrl.split("?").first;
  final fileExtention = imgUrl.split(".").last;
  return downloadMediaToLocalCache(mediaUrl, '$imgName.$fileExtention');
}

/// Download locally the file and return the file path if succes, or [null] if error.
Future<String?> downloadMediaToLocalCache(String mediaUrl, String mediaName) async {
  try {
    if (getTempDir != null) {
      String savePath = "${(getTempDir as Directory).path}/$mediaName";
      if (getShowLogs) developer.log('📦 downloading media: $mediaUrl', name: 'Cached Media package');
      var dio = Dio();
      final response = await dio.download(mediaUrl, savePath);
      if (response.statusCode == 200) return savePath;
    } else {
      if (getShowLogs) developer.log('❌  Temp directory not found!', name: 'Cached Media package');
    }
    return null;
  } catch (e) {
    if (getShowLogs) developer.log('❌ Error - media : $mediaUrl', name: 'Cached Media package');
  }
  return null;
}

Future<bool> doesFileExist(String? filePath) async {
  int fileSize = 0;
  bool fileExists = false;
  if (filePath != null) {
    var file = File(filePath);
    if (await file.exists()) {
      fileSize = await file.length();
      if (fileSize > 0) fileExists = true;
    }
  }
  return fileExists;
}

double calculateCacheSize(List<CachedMediaInfo> allCachedMediaInfo) {
  double tmpCurrentCacheSize = 0;
  for (final cachedMediaInfo in allCachedMediaInfo) {
    tmpCurrentCacheSize += cachedMediaInfo.fileSize;
  }
  return tmpCurrentCacheSize;
}

Future<void> deleteMediaInCache(String filePath) async {
  var file = File(filePath);
  if (await file.exists()) await file.delete();
}

Future<void> reduceCacheSize(GetStorage getStorage, List<CachedMediaInfo> allCachedMediaInfo) async {
  if (allCachedMediaInfo.isNotEmpty) {
    allCachedMediaInfo.sort((a, b) => a.dateCreated.compareTo(b.dateCreated));
    final a = allCachedMediaInfo.first;
    if (getShowLogs) {
      developer.log("🧽  Clearing cache from ${a.cachedMediaUrl}", name: 'Cached Media package');
    }
    await deleteMediaInCache(a.cachedMediaUrl);
    removeCachedMediaInfo(getStorage, a.id);
  }
}

Future<void> clearCacheOnInit(GetStorage getStorage) async {
  final allCmi = await findAllCachedMediaInfo(getStorage);
  var i = 1;
  for (final cmi in allCmi) {
    if (getShowLogs) {
      developer.log("🧽  [$i/${allCmi.length}] Clearing cache from ${cmi.cachedMediaUrl}", name: 'Cached Media package');
    }
    await deleteMediaInCache(cmi.cachedMediaUrl);
    removeCachedMediaInfo(getStorage, cmi.id);
    i++;
  }
}
