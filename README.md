
## Cached_Image

This package will store locally your images in order to save bandwidth & ressources.

## Usage

The function `initCachedFadeInImage()` must be placed after `WidgetsFlutterBinding.ensureInitialized()`
```dart
initCachedFadeInImage();
```

You can define the size in megabytes(e.g. 100 MB) for `cacheMaxSize`. It will help maintain the performance of your app.
Set `showLogs` to `true` to show logs about the cache behavior & sizes.


Call `disposeCachedFadeInImage()` when closing app.
```dart
disposeCachedFadeInImage();
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
