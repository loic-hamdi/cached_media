import 'dart:io';

import 'package:cached_media/cached_media.dart';
import 'package:uuid/uuid.dart';
import 'package:dio/dio.dart';
import 'dart:developer' as developer;

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
    String savePath = "${tempDir.path}/$mediaName'";
    try {
      var dio = Dio();
      developer.log('📦 downloading media: $mediaUrl');
      final response = await dio.download(mediaUrl, savePath);
      if (response.statusCode == 200) {
        return savePath;
      }
      return null;
    } on DioError catch (e) {
      developer.log('❌ Dio Error - media : $mediaUrl');
      if (e.type == DioErrorType.response) {
        return null;
      }
      if (e.type == DioErrorType.connectTimeout) {
        return null;
      }
      if (e.type == DioErrorType.receiveTimeout) {
        return null;
      }
      if (e.type == DioErrorType.other) {
        return null;
      }
    } catch (e) {
      developer.log('❌ Error - media : $mediaUrl');
    }
  } else {
    developer.log('❌  Temp directory not found!');
  }
  return null;
}
