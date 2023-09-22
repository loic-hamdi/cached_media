import 'package:cached_media/cached_media.dart';
import 'package:cached_media/entity_cached_media_info.dart';
import 'package:cached_media/management_store.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:uuid/uuid.dart';
import 'dart:developer' as developer;

String? getMimeType(String fileExtension) {
  final f = fileExtension.toLowerCase();
  final images = ['png', 'jpg', 'jpeg', 'gif', 'tiff', 'heic'];
  final videos = ['mp4', 'mpeg', 'mpeg2'];
  final audio = ['mp3', 'ogg', 'wav', 'x-wav', 'x-ms-wma', 'aac', 'opus', 'webm', '3gpp2'];

  if (images.contains(f)) {
    return 'image/$fileExtension';
  } else if (videos.contains(f)) {
    return 'video/$fileExtension';
  } else if (audio.contains(f)) {
    return ' audio/$fileExtension';
  } else if (f == 'mov') {
    return 'video/quicktime';
  } else if (f == 'avi') {
    return 'video/x-msvideo';
  } else if (f == 'wmv') {
    return 'video/x-ms-wmv';
  } else {
    return null;
  }
}

/// Return [CachedMediaInfo?] after either finding in cache or downloading then set in cache
Future<CachedMediaInfo?> loadMedia(String mediaUrl, {required GetStorage getStorage}) async {
  CachedMediaInfo? cachedMediaInfo = await findFirstCachedMediaInfoOrNull(getStorage, mediaUrl);
  if (cachedMediaInfo == null) {
    await downloadAndSetInCache(mediaUrl, getStorage: getStorage);
  } else {
    if (cachedMediaInfo.bytes != null) {
      return cachedMediaInfo;
    } else {
      removeCachedMediaInfo(getStorage, cachedMediaInfo.id);
      await downloadAndSetInCache(mediaUrl, getStorage: getStorage);
    }
  }
  cachedMediaInfo = await findFirstCachedMediaInfoOrNull(getStorage, mediaUrl);
  return cachedMediaInfo;
}

/// Download locally the file and return the file path if succes, or [null] if error.
Future<CachedMediaInfo?> downloadMediaToCache(String mediaUrl) async {
  try {
    String imgUrl = mediaUrl;
    if (imgUrl.contains('?')) imgUrl = mediaUrl.split('?').first;
    final fileExtension = imgUrl.split('.').last;
    final mimeType = getMimeType(fileExtension.toLowerCase());

    if (getShowLogs) {
      developer.log('🪫 Downloading (Mime: $mimeType) : $mediaUrl', name: 'Cached Media package');
    }
    Uint8List bytes = (await NetworkAssetBundle(Uri.parse(mediaUrl)).load(mediaUrl)).buffer.asUint8List();
    if (getShowLogs) {
      final length = bytes.length;
      developer.log('🔋 Downloaded (Length:$length) : $mediaUrl', name: 'Cached Media package');
    }
    if (bytes.isNotEmpty) {
      int sizeInBytes = bytes.length;
      final sizeInMb = sizeInBytes ~/ (1024 * 1024);
      final cachedMediaInfoToSet = CachedMediaInfo(
        id: const Uuid().v1(),
        mediaUrl: mediaUrl,
        dateCreated: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        bytes: bytes,
        mimeType: mimeType,
        fileSize: sizeInMb,
      );

      return cachedMediaInfoToSet;
    }
    return null;
  } catch (e) {
    if (getShowLogs) {
      developer.log('❌ Error - media : $mediaUrl', name: 'Cached Media package');
    }
  }
  return null;
}

Future<void> downloadAndSetInCache(String mediaUrl, {required GetStorage getStorage}) async {
  final cachedMediaInfoToSet = await downloadMediaToCache(mediaUrl);
  if (cachedMediaInfoToSet != null) {
    addCachedMediaInfo(getStorage, cachedMediaInfoToSet);
  }
}
