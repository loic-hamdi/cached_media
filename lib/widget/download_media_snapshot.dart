import 'package:cached_media/enums/enums.dart';

/// DTO Class make it easy to fetch process snapshot ASAP.
class DownloadMediaSnapshot {
  /// Status of download process (Success, Error, Loading)
  late DownloadMediaStatus status;

  /// File that you have downloaded.
  late String? filePath;

  /// Progress of download process.
  late double? progress;

  DownloadMediaSnapshot({
    required this.filePath,
    required this.progress,
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

  /// Provide us a 3 Variable
  /// 1 - Status : It's the status of the process (Success, Loading, Error).
  /// 2 - Progress : The progress if the file is downloading.
  /// 3 - FilePath : When Status is Success the FilePath won't be null;
  late final DownloadMediaSnapshot _snapshot;

  /// Try to get file path from cache,
  /// If it's not exists it will download the file and cache it.
  Future<void> getFile(String url) async {
    String? filePath = DownloadCacheManager.getCachedFilePath(url);
    if (filePath != null) {
      _snapshot.filePath = filePath;
      _snapshot.status = DownloadMediaStatus.success;
      _onSnapshotChanged(_snapshot);
      return;
    }
    filePath = await Downloader.downloadFile(
      url,
      onProgress: (progress, total) {
        _onSnapshotChanged(_snapshot..progress = (progress / total));
      },
    );
    if (filePath != null) {
      _snapshot.filePath = filePath;
      _snapshot.status = DownloadMediaStatus.success;
      _onSnapshotChanged(_snapshot);

      /// Caching FilePath
      await DownloadCacheManager.cacheFilePath(url: url, path: filePath);
    } else {
      _onSnapshotChanged(_snapshot..status = DownloadMediaStatus.error);
    }
  }
}
