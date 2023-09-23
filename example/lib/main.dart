import 'package:cached_media/cached_media.dart' as cm;
import 'package:cached_media/widget/cached_media.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await cm.initializeCachedMedia(cacheMaxSize: 50, showLogs: true);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.cyan),
      home: const MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void dispose() {
    super.dispose();
    cm.disposeCachedMedia();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cached Media Example')),
      body: SafeArea(
        child: Center(
          child: Container(
            color: Colors.grey[200],
            height: 250,
            width: 250,
            child: CachedMedia(
              uniqueId: 'bcd',
              mediaUrl: 'https://www.gstatic.com/webp/gallery/2.jpg',
              builder: (context, snapshot) {
                if (snapshot.status == DownloadStatus.loading) {
                  return const Center(child: CircularProgressIndicator.adaptive());
                } else if (snapshot.status == DownloadStatus.success && snapshot.bytes != null) {
                  return Image.memory(
                    snapshot.bytes!,
                  );
                } else {
                  return const Center(child: Text('Error'));
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
