import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cached_media/entity_cached_media_info.dart';
import 'package:cached_media/management_cache.dart';
import 'package:get_storage/get_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:developer' as developer;

GetStorage? _getstorage;

GetStorage? get getGetStorage => _getstorage;

Directory? tempDir;
Directory? get getTempDir => tempDir;

final allCachedMediaInfo = <CachedMediaInfo>[];
double currentCacheSize = 0;
late double cacheMaxSizeDefault;

PermissionStatus? _permissionStatus;

bool _showLogs = false;
bool get getShowLogs => _showLogs;

bool isInitialized = false;

const keyName = 'all_media';

/// The function [initializeCachedMedia()] must be placed after [WidgetsFlutterBinding.ensureInitialized()]
/// You can define the size in megabytes(e.g. 100 MB) for [cacheMaxSize]. It will help maintain the performance of your app.
/// Set [showLogs] to [true] to show logs about the cache behavior & sizes.
Future<void> initializeCachedMedia({
  double cacheMaxSize = 100,
  bool showLogs = false,
  bool clearCache = false,
}) async {
  if (!isInitialized) {
    final hasAccess = await hasPermission();
    if (hasAccess) {
      cacheMaxSizeDefault = cacheMaxSize * 1000000;
      _showLogs = showLogs;
      await GetStorage.init('cached_media');
      _getstorage = GetStorage('cached_media');
      await initStreamListener(showLogs: showLogs);
      tempDir = await getTemporaryDirectory();
      if (clearCache && getGetStorage != null) await clearCacheOnInit(getGetStorage!);
      if (getGetStorage == null && showLogs) developer.log('❌  initializeCachedMedia() getGetStorage is NULL!', name: 'Cached Media package');
      isInitialized = true;
    }
  }
}

Future<void> initStreamListener({bool showLogs = false}) async {
  if (getGetStorage == null) {
    developer.log('❌  initStreamListener() getGetStorage is NULL!', name: 'Cached Media package');
  } else {
    getGetStorage!.listenKey(keyName, (all) async {
      final allData = AllCachedMediaInfo.fromJson(json.decode(all));
      final p0 = <CachedMediaInfo>[];
      p0.addAll(allData.cachedMediaInfo ?? []);
      allCachedMediaInfo.clear();
      allCachedMediaInfo.addAll(p0);
      if (currentCacheSize > cacheMaxSizeDefault) {
        if (getGetStorage != null) await reduceCacheSize(getGetStorage!, p0);
        if (getGetStorage == null && showLogs) developer.log('❌  getGetStorage is NULL!', name: 'Cached Media package');
      }
      if (getShowLogs) {
        developer.log('''
- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -
Media in cache: ${p0.length}
Current Cache Size: ${(calculateCacheSize(p0)) / 1000000} MB
Cache Max Size: ${cacheMaxSizeDefault / 1000000} MB
- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -
''', name: 'Cached Media package');
      }
    });
  }
}

Future<bool> hasPermission() async {
  _permissionStatus = await Permission.storage.status;
  if (_permissionStatus != PermissionStatus.granted) {
    PermissionStatus permissionStatus1 = await Permission.storage.request();
    _permissionStatus = permissionStatus1;
    if (_permissionStatus != PermissionStatus.granted) {
      return false;
    } else {
      return true;
    }
  } else {
    return true;
  }
}

Future<void> cleanCache() async {
  if (getGetStorage != null) {
    await clearCacheOnInit(getGetStorage!);
  } else {
    developer.log('❌  cleanCache() is NULL!', name: 'Cached Media package');
  }
  developer.log('''
- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -
Cache has been cleaned  ✅
- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -
''', name: 'Cached Media package');
}
