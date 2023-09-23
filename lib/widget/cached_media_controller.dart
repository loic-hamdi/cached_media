import 'dart:typed_data';

import 'package:cached_media/widget/cached_media.dart';
import 'package:cached_media/widget/functions/functions.dart';
import 'package:get_storage/get_storage.dart';

class CachedMediaSnapshot {
  late DownloadStatus status;
  late Uint8List? bytes;
  late String? mimeType;

  CachedMediaSnapshot({required this.bytes, required this.status});
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
    _snapshot.bytes = null;
    _snapshot.mimeType = null;
    _snapshot.status = DownloadStatus.loading;
    _onSnapshotChanged(_snapshot);

    final cmi = await loadMedia(url, getStorage: getStorage);
    if (cmi != null && cmi.bytes != null) {
      _snapshot.bytes = cmi.bytes;
      _snapshot.mimeType = cmi.mimeType;
      _onSnapshotChanged(_snapshot);
      _onSnapshotChanged(_snapshot..status = DownloadStatus.success);
    } else {
      _onSnapshotChanged(_snapshot..status = DownloadStatus.error);
    }
  }
}
