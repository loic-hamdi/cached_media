import 'package:cached_media/enums/enums.dart';
import 'package:cached_media/widget/functions/functions.dart';

/// DTO Class make it easy to fetch process snapshot ASAP.
class DownloadMediaSnapshot {
  /// Status of download process (Success, Error, Loading)
  late DownloadMediaStatus status;

  /// File that you have downloaded.
  late String? filePath;

  DownloadMediaSnapshot({
    required this.filePath,
    required this.status,
  });
}

class DownloadMediaBuilderController {
  DownloadMediaBuilderController({required DownloadMediaSnapshot snapshot, required Function(DownloadMediaSnapshot) onSnapshotChanged}) {
    _onSnapshotChanged = onSnapshotChanged;
    _snapshot = snapshot;
  }

  /// When snapshot changes this function will called and give you the new snapshot
  late final Function(DownloadMediaSnapshot) _onSnapshotChanged;

  /// Status of the process (Success, Loading, Error)
  /// When Status is Success the FilePath won't be null
  late final DownloadMediaSnapshot _snapshot;

  Future<void> getFile(String url) async {
    _snapshot.filePath = null;
    _snapshot.status = DownloadMediaStatus.loading;
    _onSnapshotChanged(_snapshot);

    final cmi = await loadMedia(url);
    final filePath = cmi?.cachedMediaUrl;
    if (filePath != null) {
      _snapshot.filePath = filePath;
      _snapshot.status = DownloadMediaStatus.success;
      _onSnapshotChanged(_snapshot);
    } else {
      _onSnapshotChanged(_snapshot..status = DownloadMediaStatus.error);
    }
  }
}