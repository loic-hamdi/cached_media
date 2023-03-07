import 'dart:io';

import 'package:cached_media/cached_media.dart';
import 'package:cached_media/entity_cached_media_info.dart';
import 'package:cached_media/management_store.dart';
import 'package:uuid/uuid.dart';
import 'package:dio/dio.dart';
import 'dart:developer' as developer;

/// Return [CachedMediaInfo?] after either finding in cache or downloading then set in cache
Future<CachedMediaInfo?> loadMedia(String mediaUrl) async {
  CachedMediaInfo? cachedMediaInfo = await findFirstCachedMediaInfoOrNull(getObjectBox, mediaUrl);
  if (cachedMediaInfo == null) {
    await downloadAndSetInCache(mediaUrl);
  } else {
    if (await doesFileExist(cachedMediaInfo.cachedMediaUrl)) {
      return cachedMediaInfo;
    } else {
      removeCachedMediaInfo(getObjectBox, cachedMediaInfo.id);
      await downloadAndSetInCache(mediaUrl);
    }
  }
  cachedMediaInfo = await findFirstCachedMediaInfoOrNull(getObjectBox, mediaUrl);
  return cachedMediaInfo;
}

Future<void> downloadAndSetInCache(String mediaUrl) async {
  final tmpPath = await downloadMediaToCache(mediaUrl);
  if (await doesFileExist(tmpPath)) {
    var file = File(tmpPath!);
    final cachedMediaInfoToSet = CachedMediaInfo(
      id: const Uuid().v1(),
      mediaUrl: mediaUrl,
      dateCreated: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      fileSize: await file.length(),
      cachedMediaUrl: tmpPath,
    );
    addCachedMediaInfo(getObjectBox, cachedMediaInfoToSet);
  }
}

Future<String?> downloadMediaToCache(String mediaUrl) async {
  String imgName = const Uuid().v1();
  String imgUrl = mediaUrl;
  if (imgUrl.contains("?")) imgUrl = mediaUrl.split("?").first;
  final fileExtention = imgUrl.split(".").last;
  return downloadMediaToLocalCache(mediaUrl, '$imgName.$fileExtention');
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

/// Download locally the file and return the file path if succes, or [null] if error.
Future<String?> downloadMediaToLocalCache(String mediaUrl, String mediaName) async {
  final tempDir = getTempDir;
  if (tempDir != null) {
    String savePath = "${tempDir.path}/$mediaName";
    try {
      var dio = Dio();
      if (getShowLogs) {
        developer.log('📦 downloading media: $mediaUrl', name: 'Cached Media package');
      }
      final response = await dio.download(mediaUrl, savePath);
      if (response.statusCode == 200) {
        return savePath;
      }
      return null;
    } on DioError {
      if (getShowLogs) {
        developer.log('❌ Dio Error - media : $mediaUrl', name: 'Cached Media package');
      }
      return null;
    } catch (e) {
      if (getShowLogs) {
        developer.log('❌ Error - media : $mediaUrl', name: 'Cached Media package');
      }
    }
  } else {
    if (getShowLogs) {
      developer.log('❌  Temp directory not found!', name: 'Cached Media package');
    }
  }
  return null;
}
