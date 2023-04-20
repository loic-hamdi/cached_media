import 'dart:io';

import 'package:cached_media/widget/cached_media.dart';
import 'package:cached_media/widget/functions/functions.dart';
import 'package:get_storage/get_storage.dart';

class CachedMediaSnapshot {
  late DownloadStatus status;
  late String? filePath;

  CachedMediaSnapshot({required this.filePath, required this.status});
}

class CachedMediaController {
  CachedMediaController({
    required CachedMediaSnapshot snapshot,
    required Function(CachedMediaSnapshot) onSnapshotChanged,
  }) {
    _onSnapshotChanged = onSnapshotChanged;
    _snapshot = snapshot;
  }

  late final Function(CachedMediaSnapshot) _onSnapshotChanged;

  late final CachedMediaSnapshot _snapshot;

  Future<void> getFile(String url, {required GetStorage getStorage}) async {
    _snapshot.filePath = null;
    _snapshot.status = DownloadStatus.loading;
    _onSnapshotChanged(_snapshot);

    final cmi = await loadMedia(url, getStorage: getStorage);
    final filePath = cmi?.cachedMediaUrl;
    if (filePath != null) {
      final file = File(filePath);
      if (await file.exists()) {
        _snapshot.filePath = filePath;
        _snapshot.status = DownloadStatus.success;
        _onSnapshotChanged(_snapshot);
      } else {
        _onSnapshotChanged(_snapshot..status = DownloadStatus.error);
      }
    } else {
      _onSnapshotChanged(_snapshot..status = DownloadStatus.error);
    }
  }
}
