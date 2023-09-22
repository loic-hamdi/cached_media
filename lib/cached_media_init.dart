import 'dart:async';
import 'dart:convert';
import 'package:cached_media/entity_cached_media_info.dart';
import 'package:cached_media/management_cache.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:developer' as developer;
import 'package:cached_media/widget/functions/has_permission_web.dart' if (dart.library.io) 'package:cached_media/widget/functions/has_permission_io.dart';

final allCachedMediaInfo = <CachedMediaInfo>[];
double currentCacheSize = 0;
late double cacheMaxSizeDefault;

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
  required GetStorage getStorage,
}) async {
  if (!isInitialized) {
    final hasAccess = await hasPermission();
    if (!hasAccess) {
      developer.log('❌  Permission access denied', name: 'Cached Media package');
    }
    cacheMaxSizeDefault = cacheMaxSize * 1000000;
    _showLogs = showLogs;
    await initStreamListener(showLogs: showLogs, getStorage: getStorage);
    if (clearCache) await clearCacheOnInit(getStorage);
    isInitialized = true;
  }
}

Future<void> initStreamListener({bool showLogs = false, required GetStorage getStorage}) async {
  getStorage.listenKey(keyName, (all) async {
    final allData = AllCachedMediaInfo.fromJson(json.decode(all));
    final p0 = <CachedMediaInfo>[];
    p0.addAll(allData.cachedMediaInfo ?? []);
    allCachedMediaInfo.clear();
    allCachedMediaInfo.addAll(p0);
    if (currentCacheSize > cacheMaxSizeDefault) {
      await reduceCacheSize(getStorage, p0);
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

Future<bool> hasPermission() async {
  return await hasPermissionIoWeb();
}

Future<void> cleanCache({required GetStorage getStorage}) async {
  await clearCacheOnInit(getStorage);
  developer.log('''
- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -
Cache has been cleaned  ✅
- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -
''', name: 'Cached Media package');
}
