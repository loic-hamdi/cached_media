import 'package:cached_media/widget/cached_media.dart';
import 'package:cached_media/widget/cached_media_controller.dart';
import 'package:flutter/widgets.dart';
import 'package:get_storage/get_storage.dart';
import 'package:visibility_detector/visibility_detector.dart';

class MediaWidget extends StatefulWidget {
  const MediaWidget({
    Key? key,
    required this.getStorage,
    required this.mediaUrl,
    required this.uniqueId,
    required this.builder,
    required this.startLoadingOnlyWhenVisible,
    required this.wantKeepAlive,
  }) : super(key: key);

  final String mediaUrl;
  final String uniqueId;
  final Widget? Function(BuildContext context, CachedMediaSnapshot snapshot)? builder;
  final bool startLoadingOnlyWhenVisible;
  final bool wantKeepAlive;
  final GetStorage getStorage;

  @override
  State<MediaWidget> createState() => _MediaWidgetState();
}

class _MediaWidgetState extends State<MediaWidget> with AutomaticKeepAliveClientMixin<MediaWidget> {
  @override
  bool get wantKeepAlive => widget.wantKeepAlive;

  late CachedMediaController _cachedMediaController;
  late CachedMediaSnapshot snapshot;
  bool initiating = false;
  bool initiated = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    initiating = true;
    if (mounted) setState(() {});
    snapshot = CachedMediaSnapshot(status: DownloadStatus.loading, bytes: null);
    _cachedMediaController = CachedMediaController(
      snapshot: snapshot,
      onSnapshotChanged: (snapshot) => mounted ? setState(() => this.snapshot = snapshot) : null,
    );
    await _cachedMediaController.getFile(widget.mediaUrl, getStorage: widget.getStorage);
    initiating = false;
    initiated = true;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.startLoadingOnlyWhenVisible
        ? VisibilityDetector(
            key: widget.key ?? Key('visibility-cached-media-${widget.uniqueId}'),
            onVisibilityChanged: !initiating && !initiated ? (_) async => _.visibleFraction > 0 ? await init() : null : null,
            child: widget.builder != null
                ? widget.builder!(context, snapshot) ?? const SizedBox()
                : const Text(
                    'Builder implementation is missing',
                  ),
          )
        : widget.builder != null
            ? widget.builder!(context, snapshot) ?? const SizedBox()
            : const Text('Builder implementation is missing');
  }
}
