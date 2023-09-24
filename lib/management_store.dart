import 'dart:convert';
import 'dart:core';
import 'package:cached_media/cached_media_init.dart';
import 'package:cached_media/model/all_cached_media_info.dart';
import 'package:collection/collection.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:developer' as developer;

Future<void> addCachedMediaInfo(GetStorage getStorage, CachedMediaInfo cachedMediaInfo) async {
  //? We store the media in a separate location for speed
  await getStorage.write(cachedMediaInfo.id, json.encode(cachedMediaInfo.toJson()));
  if (getShowLogs) {
    final cmiTmpJson = getStorage.read(cachedMediaInfo.id);
    if (cmiTmpJson == null) {
      developer.log('❌  After download - Media not found: ${cachedMediaInfo.id}', name: 'Cached Media package');
    } else {
      developer.log('''
🔷  Media stored in addCachedMediaInfo(): ${cachedMediaInfo.id}
🔷  Media stored in addCachedMediaInfo(): ${cachedMediaInfo.mediaUrl}
🔷  Media stored in addCachedMediaInfo() (Length: ${cachedMediaInfo.bytes?.length ?? 0}): 
🔷  Media stored in addCachedMediaInfo() (File size: ${cachedMediaInfo.fileSize}): 
''', name: 'Cached Media package');
    }
  }

  final all = getStorage.read(keyName);
  final tmp = AllCachedMediaInfo(cachedMediaInfo: []);
  if (all != null) {
    //? We don't store the media in long index list
    final allData = AllCachedMediaInfo.fromJson(json.decode(all));
    tmp.cachedMediaInfo!.addAll(allData.cachedMediaInfo ?? []);
  }
  cachedMediaInfo.bytes = null;
  tmp.cachedMediaInfo!.add(cachedMediaInfo);
  await getStorage.write(keyName, json.encode(tmp.toJson()));
}

Future<void> removeCachedMediaInfo(GetStorage getStorage, String id) async {
  final all = getStorage.read(keyName);
  if (all != null) {
    final allData = AllCachedMediaInfo.fromJson(json.decode(all));
    if (allData.cachedMediaInfo != null) {
      //? We remove the media from indexed list
      allData.cachedMediaInfo!.removeWhere((e) => e.id == id);
      await getStorage.write(keyName, json.encode(allData.toJson()));
    }
  }
  final cmi = getStorage.read(id);
  if (cmi != null) {
    //? We remove the media data
    await getStorage.remove(id);
  }
}

Future<CachedMediaInfo?> findFirstCachedMediaInfoOrNull(GetStorage getStorage, String mediaUrl) async {
  final all = getStorage.read(keyName);
  if (all != null) {
    final allData = AllCachedMediaInfo.fromJson(json.decode(all));
    if (allData.cachedMediaInfo != null && allData.cachedMediaInfo!.isNotEmpty) {
      final cmi = allData.cachedMediaInfo!.firstWhereOrNull((e) => e.mediaUrl == mediaUrl);
      if (cmi != null) {
        final cmiTmpJson = getStorage.read(cmi.id);
        if (cmiTmpJson == null) {
          developer.log('''
❌  Media not found in findFirstCachedMediaInfoOrNull()
UniqueId: ${cmi.id}
MediaUrl: ${cmi.mediaUrl}
''', name: 'Cached Media package');
        } else {
          final cachedMediaInfoFull = CachedMediaInfo.fromJson(json.decode(cmiTmpJson));
          developer.log('''
✅  Media found in findFirstCachedMediaInfoOrNull()
UniqueId: ${cachedMediaInfoFull.id}
MediaUrl: ${cachedMediaInfoFull.mediaUrl}
Bytes.length: ${cachedMediaInfoFull.bytes?.length}
''', name: 'Cached Media package');
          return cachedMediaInfoFull;
        }
      }
    }
  }
  return null;
}

Future<List<CachedMediaInfo>> findAllCachedMediaInfo(GetStorage getStorage) async {
  final all = getStorage.read(keyName);
  if (all != null) {
    final allData = AllCachedMediaInfo.fromJson(json.decode(all));
    return allData.cachedMediaInfo ?? <CachedMediaInfo>[];
  }
  return <CachedMediaInfo>[];
}
