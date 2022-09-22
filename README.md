
## Cached Media

This package will store locally your media in order to save bandwidth & ressources.

## Usage

The function `initializeCachedImage()` must be placed after `WidgetsFlutterBinding.ensureInitialized()`
```dart
initializeCachedImage();
```

You can define the size in megabytes(e.g. 100 MB) for `cacheMaxSize`. It will help maintain the performance of your app.
Set `showLogs` to `true` to show logs about the cache behavior & sizes.


Call `disposeCachedImage()` when closing app.
```dart
disposeCachedImage();
```

### Example

```dart
CachedImage(
      uniqueId: 'abc',
      imageUrl: 'https://www.foo.bar/image.jpg',
      width: 100,
      height: 100,
      startLoadingOnlyWhenVisible: false,
      assetErrorImage: 'assets/error.jpg',
      showCircularProgressIndicator: false,
      customLoadingProgressIndicator: CustomCircularProgressIndicator(),
      fadeInDuration: const Duration(milliseconds: 2000),
    );
```
