import 'dart:async';
import 'dart:io';

import 'package:cached_image/entity_cached_image_info.dart';
import 'package:cached_image/management_cache.dart';
import 'package:cached_image/objectbox.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:developer' as developer;

late ObjectBox _objectbox;

ObjectBox get getObjectBox => _objectbox;

StreamSubscription<List<CachedImageInfo>>? streamAllCachedImageInfo;

Directory? tempDir;
Directory? get getTempDir => tempDir;

final allCachedImageInfo = <CachedImageInfo>[];
double currentCacheSize = 0;
late final double cacheMaxSizeDefault;

PermissionStatus? _permissionStatus;

bool _showLogs = false;
bool get getShowLogs => _showLogs;

/// The function [initCachedFadeInImage()] must be placed after [WidgetsFlutterBinding.ensureInitialized()]
/// You can define the size in megabytes(e.g. 100 MB) for [cacheMaxSize]. It will help maintain the performance of your app.
/// Set [showLogs] to [true] to show logs about the cache behavior & sizes.
/// Call [disposeCachedFadeInImage()] when closing app.
Future<void> initCachedFadeInImage({double cacheMaxSize = 100, bool showLogs = false}) async {
  await checkPermission();
  cacheMaxSizeDefault = cacheMaxSize * 1000000;
  _showLogs = showLogs;
  _objectbox = await ObjectBox.create();
  await initStreamListener();
  tempDir = await getTemporaryDirectory();
}

Future<void> initStreamListener() async {
  streamAllCachedImageInfo = getObjectBox.cachedImageInfoStream.map((query) => query.find()).listen((p0) async {
    allCachedImageInfo.clear();
    allCachedImageInfo.addAll(p0);
    if (currentCacheSize > cacheMaxSizeDefault) await reduceCacheSize(getObjectBox, p0);
    if (getShowLogs) {
      developer.log('''
- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -
Images in cache: ${p0.length}
Current Cache Size: ${(calculateCacheSize(p0)) / 1000000} MB
Cache Max Size: ${cacheMaxSizeDefault / 1000000} MB
- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -
''', name: 'Cached Image package');
    }
  });
}

Future<void> checkPermission() async {
  _permissionStatus = await Permission.storage.status;
  if (_permissionStatus != PermissionStatus.granted) {
    PermissionStatus permissionStatus1 = await Permission.storage.request();
    _permissionStatus = permissionStatus1;
    if (_permissionStatus != PermissionStatus.granted) {
      throw Exception('Permission error');
    }
  }
}

void disposeCachedFadeInImage() => streamAllCachedImageInfo?.cancel();
