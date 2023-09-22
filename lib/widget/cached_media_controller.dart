import 'dart:typed_data';

import 'package:cached_media/widget/cached_media.dart';
import 'package:cached_media/widget/functions/functions.dart';
import 'package:cross_file/cross_file.dart';
import 'package:get_storage/get_storage.dart';

class CachedMediaSnapshot {
  late DownloadStatus status;
  late Uint8List? bytes;

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
    _snapshot.status = DownloadStatus.loading;
    _onSnapshotChanged(_snapshot);

    final cmi = await loadMedia(url, getStorage: getStorage);
    final bytes = cmi?.bytes;
    if (cmi != null && bytes != null) {
      final file = XFile.fromData(
        bytes,
        mimeType: cmi.mimeType,
        length: bytes.length,
      );
      final fileLength = await file.length();
      if (fileLength > 0) {
        _snapshot.bytes = bytes;
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
