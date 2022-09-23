
## Cached Media

This package will store locally your media in order to save bandwidth & ressources.

## Usage

The function `initializeCachedMedia()` must be placed after `WidgetsFlutterBinding.ensureInitialized()`
```dart
await initializeCachedMedia();
```

You can define the size in megabytes(e.g. 100 MB) for `cacheMaxSize`. It will help maintain the performance of your app.
Set `showLogs` to `true` to show logs about the cache behavior & sizes.


Call `disposeCachedMedia()` when closing app.
```dart
disposeCachedMedia();
```

### Example

```dart
            //? Image example
              Container(
                color: Colors.grey[200],
                child: const CachedMedia(
                  uniqueId: 'abc',
                  height: 250,
                  width: 250,
                  mediaType: MediaType.image,
                  mediaUrl: 'https://www.gstatic.com/webp/gallery/1.jpg',
                ),
              ),
               //? Custom Builder example
              Container(
                color: Colors.grey[200],
                height: 250,
                width: 250,
                child: CachedMedia(
                  uniqueId: 'bcd',
                  mediaType: MediaType.custom,
                  mediaUrl: 'https://www.gstatic.com/webp/gallery/2.jpg',
                  builder: (context, snapshot) {
                    if (snapshot.status == DownloadStatus.loading) {
                      return const Center(child: CircularProgressIndicator.adaptive());
                    } else if (snapshot.status == DownloadStatus.success) {
                      return Image.asset(snapshot.filePath!);
                    } else {
                      return const Center(child: Text('Error'));
                    }
                  },
                ),
              ),
```
