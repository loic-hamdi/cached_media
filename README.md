<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages).
-->

## How to use?


The function `initCachedFadeInImage()` must be placed after `WidgetsFlutterBinding.ensureInitialized()`
```dart
initCachedFadeInImage();
```

You can define the size in megabytes(e.g. 100 MB) for [cacheMaxSize]. It will help maintain the performance of your app.
Set [showLogs] to [true] to show logs about the cache behavior & sizes.


Call [disposeCachedFadeInImage()] when closing app.
```dart
disposeCachedFadeInImage();
```