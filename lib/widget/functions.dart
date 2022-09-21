import 'dart:io';

import 'package:cached_image/cached_image.dart';
import 'package:uuid/uuid.dart';
import 'package:dio/dio.dart';
import 'dart:developer' as developer;

Future<String?> downloadImageToCache(String imageUrl) async {
  String imgName = const Uuid().v1();
  String imgUrl = imageUrl;
  if (imgUrl.contains("?")) imgUrl = imageUrl.split("?").first;
  final fileExtention = imgUrl.split(".").last;
  return downloadImageToLocalCache(imageUrl, '$imgName.$fileExtention');
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
Future<String?> downloadImageToLocalCache(String imageUrl, String imageName) async {
  final tempDir = getTempDir;
  if (tempDir != null) {
    String savePath = "${tempDir.path}/$imageName'";
    try {
      var dio = Dio();
      developer.log('📦 downloading image: $imageUrl');
      final response = await dio.download(imageUrl, savePath);
      if (response.statusCode == 200) {
        return savePath;
      }
      return null;
    } on DioError catch (e) {
      developer.log('❌ Dio Error - image : $imageUrl');
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
      developer.log('❌ Error - image : $imageUrl');
    }
  } else {
    developer.log('❌  Temp directory not found!');
  }
  return null;
}
