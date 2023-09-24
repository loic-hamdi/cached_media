import 'package:cached_media/cached_media.dart';
import 'package:cached_media/model/all_cached_media_info.dart';
import 'package:cached_media/management_store.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:uuid/uuid.dart';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;

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

/// Avoid multiple download of same content
final isBeingDownloaded = <String>[];

/// Return [CachedMediaInfo?] after either finding in cache or downloading then set in cache
Future<CachedMediaInfo?> loadMedia(String mediaUrl, {required GetStorage getStorage}) async {
  if (getShowLogs) {
    developer.log('🟦  loadMedia () - $mediaUrl - isBeingDownloaded.length: ${isBeingDownloaded.length} ', name: 'Cached Media package');
  }
  CachedMediaInfo? cachedMediaInfo;
  final isAlreadyDownloading = isBeingDownloaded.contains(mediaUrl);
  if (isAlreadyDownloading) {
    var count = 0;
    while (cachedMediaInfo == null && count < 30) {
      if (getShowLogs) {
        developer.log('🟨  Is Already Downloading, wating to have cachedMediaInfo avaible (count: $count) - $mediaUrl', name: 'Cached Media package');
      }
      cachedMediaInfo = await findFirstCachedMediaInfoOrNull(getStorage, mediaUrl);
      if (getShowLogs) {
        developer.log('🟨  Is Already Downloading, cachedMediaInfo is not null : ${cachedMediaInfo != null} (count: $count) - $mediaUrl', name: 'Cached Media package');
      }
      if (cachedMediaInfo == null) await Future.delayed(const Duration(milliseconds: 1000));
      count++;
    }
  } else if (!isAlreadyDownloading) {
    if (getShowLogs) {
      developer.log('🟪  Not already downloading, adding to list to download - $mediaUrl', name: 'Cached Media package');
    }
    isBeingDownloaded.add(mediaUrl);
    cachedMediaInfo = await findFirstCachedMediaInfoOrNull(getStorage, mediaUrl);
    cachedMediaInfo ??= await downloadAndSetInCache(mediaUrl, getStorage: getStorage);
  }
  if (cachedMediaInfo != null) isBeingDownloaded.remove(mediaUrl);

  if (getShowLogs) {
    developer.log('''
🟢  Return loadMedia(): ${cachedMediaInfo?.id}
🟢  Return loadMedia(): ${cachedMediaInfo?.mediaUrl}
🟢  Return loadMedia() (Length: ${cachedMediaInfo?.bytes?.length ?? 0}): 
🟢  Return loadMedia() (File size: ${cachedMediaInfo?.fileSize}): 
''', name: 'Cached Media package');
  }
  return cachedMediaInfo;
}

/// Download locally the file and return the file path if succes, or [null] if error.
Future<CachedMediaInfo?> downloadMedia(String mediaUrl, {required GetStorage getStorage}) async {
  try {
    final uniqueId = const Uuid().v1();
    String imgUrl = mediaUrl;
    if (imgUrl.contains('?')) imgUrl = mediaUrl.split('?').first;
    final fileExtension = imgUrl.split('.').last;
    final mimeType = getMimeType(fileExtension.toLowerCase());
    if (getShowLogs) {
      developer.log('🪫  Downloading (Mime: $mimeType) : $mediaUrl', name: 'Cached Media package');
    }
    // Uint8List bytes = (await NetworkAssetBundle(Uri.parse(mediaUrl)).load(mediaUrl)).buffer.asUint8List();
    // if (bytes.isNotEmpty) {
    //   int sizeInBytes = bytes.length;
    //   final sizeInMb = double.parse((sizeInBytes / (1024 * 1024)).toStringAsFixed(2));
    //   final cachedMediaInfoToSet = CachedMediaInfo(
    //     id: uniqueId,
    //     mediaUrl: mediaUrl,
    //     dateCreated: DateTime.now().millisecondsSinceEpoch ~/ 1000,
    //     bytes: bytes,
    //     mimeType: mimeType,
    //     fileSize: sizeInMb,
    //   );
    //   if (getShowLogs) {
    //     developer.log('🔋  Downloaded (Length:$sizeInBytes - sizeInMb: $sizeInMb) : $mediaUrl', name: 'Cached Media package');
    //   }
    //   return cachedMediaInfoToSet;
    // }
    final response = await http.get(Uri.parse(mediaUrl));
    if (response.statusCode == 200) {
      if (getShowLogs) {
        developer.log('🟢  File Downloaded: $mediaUrl', name: 'Cached Media package');
      }
      Uint8List bytes = response.bodyBytes;
      if (bytes.isNotEmpty) {
        int sizeInBytes = bytes.length;
        final sizeInMb = double.parse((sizeInBytes / (1024 * 1024)).toStringAsFixed(2));
        final cachedMediaInfoToSet = CachedMediaInfo(
          id: uniqueId,
          mediaUrl: mediaUrl,
          dateCreated: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          bytes: bytes,
          mimeType: mimeType,
          fileSize: sizeInMb,
        );
        if (getShowLogs) {
          developer.log('🔋  Downloaded (Length:$sizeInBytes - sizeInMb: $sizeInMb) : $mediaUrl', name: 'Cached Media package');
        }
        return cachedMediaInfoToSet;
      } else {
        if (getShowLogs) {
          developer.log('❌ Error - bytes is empty : $mediaUrl', name: 'Cached Media package');
        }
      }
    } else {
      if (getShowLogs) {
        developer.log('❌ Error - CAN NOT DOWNLOAD FILE : $mediaUrl', name: 'Cached Media package');
      }
    }
    return null;
  } catch (e) {
    if (getShowLogs) {
      developer.log('❌ Error - media : $mediaUrl', name: 'Cached Media package');
    }
  }
  return null;
}

Future<CachedMediaInfo?> downloadAndSetInCache(String mediaUrl, {required GetStorage getStorage}) async {
  final cachedMediaInfoToSet = await downloadMedia(mediaUrl, getStorage: getStorage);
  if (getShowLogs) {
    developer.log('''
🟠  Return addCachedMediaInfo(): ${cachedMediaInfoToSet?.id}
🟠  Return addCachedMediaInfo(): ${cachedMediaInfoToSet?.mediaUrl}
🟠  Return addCachedMediaInfo() (Length: ${cachedMediaInfoToSet?.bytes?.length ?? 0}): 
🟠  Return addCachedMediaInfo() (File size: ${cachedMediaInfoToSet?.fileSize}): 
''', name: 'Cached Media package');
  }
  if (cachedMediaInfoToSet != null) {
    final c = CachedMediaInfo.fromJson(cachedMediaInfoToSet.toJson());
    await addCachedMediaInfo(getStorage, c);
    if (getShowLogs) {
      developer.log('''
🟣  Return addCachedMediaInfo(): ${cachedMediaInfoToSet.id}
🟣  Return addCachedMediaInfo(): ${cachedMediaInfoToSet.mediaUrl}
🟣  Return addCachedMediaInfo() (Length: ${cachedMediaInfoToSet.bytes?.length ?? 0}): 
🟣  Return addCachedMediaInfo() (File size: ${cachedMediaInfoToSet.fileSize}): 
''', name: 'Cached Media package');
    }
    return cachedMediaInfoToSet;
  }
  return null;
}
