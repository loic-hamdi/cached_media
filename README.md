
## Cached_Image

This package will store locally your images in order to save bandwidth & ressources.

## How to use?

The function `initCachedFadeInImage()` must be placed after `WidgetsFlutterBinding.ensureInitialized()`
```dart
initCachedFadeInImage();
```

You can define the size in megabytes(e.g. 100 MB) for `cacheMaxSize`. It will help maintain the performance of your app.
Set `showLogs` to `true` to show logs about the cache behavior & sizes.


Call [disposeCachedFadeInImage()] when closing app.
```dart
disposeCachedFadeInImage();
```

### Usage:

```dart
CachedImage(
      uniqueId: 'abc',
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      startLoadingOnlyWhenVisible: false,
      assetErrorImage: Assets.imageError,
      showCircularProgressIndicator: false,
      customLoadingProgressIndicator: FittedBox(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              SizedBox(
                width: kPaddingElementsDefault * 1.5,
                height: kPaddingElementsDefault,
                child: CustomCircularProgressIndicator(),
              ),
            ],
          ),
        ),
      ),
      fadeInDuration: const Duration(milliseconds: 2000),
    );
```
