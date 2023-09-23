import 'dart:typed_data';
import 'package:cached_media/cached_media.dart';
import 'package:cached_media/widget/functions/functions.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:developer' as developer;

class CachedMediaSnapshot {
  late DownloadStatus status;
  late Uint8List? bytes;
  late String? mimeType;
  CachedMediaSnapshot({required this.bytes, required this.status});
}

class CachedMediaController {
  CachedMediaController({
    required Function(CachedMediaSnapshot) onSnapshotChanged,
  }) {
    _onSnapshotChanged = onSnapshotChanged;
  }

  late Function(CachedMediaSnapshot) _onSnapshotChanged;
  final CachedMediaSnapshot _snapshot = CachedMediaSnapshot(bytes: null, status: DownloadStatus.loading);

  Future<void> getFile(String url, {required GetStorage getStorage}) async {
    _snapshot.bytes = null;
    _snapshot.mimeType = null;
    _snapshot.status = DownloadStatus.loading;
    _onSnapshotChanged(_snapshot);

    final cmi = await loadMedia(url, getStorage: getStorage);

    if (cmi != null && cmi.bytes != null) {
      _snapshot.bytes = cmi.bytes;
      _snapshot.mimeType = cmi.mimeType;
      _snapshot.status = DownloadStatus.success;
      _onSnapshotChanged(_snapshot);
      printSnapshot('Success');
    } else {
      _onSnapshotChanged(_snapshot..status = DownloadStatus.error);
      printSnapshot('Error');
    }
  }

  void printSnapshot(String? from) {
    if (getShowLogs) {
      developer.log('''
🗣️  _onSnapshotChanged() - from: $from
_snapshot.bytes: ${_snapshot.bytes}
_snapshot.mimeType: ${_snapshot.mimeType}
_snapshot.status: ${_snapshot.status}
''', name: 'Cached Media package');
    }
  }
}
