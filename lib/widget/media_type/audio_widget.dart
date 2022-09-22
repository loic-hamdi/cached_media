import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:cached_media/entity_cached_media_info.dart';
import 'package:flutter/material.dart';

class AudioWidget extends StatefulWidget {
  const AudioWidget({
    Key? key,
    required this.uniqueId,
    required this.cachedMediaInfo,
    required this.width,
    required this.height,
    required this.fit,
    required this.assetErrorImage,
  }) : super(key: key);

  final String uniqueId;
  final CachedMediaInfo cachedMediaInfo;
  final double width;
  final double height;
  final BoxFit? fit;
  final String? assetErrorImage;

  @override
  State<AudioWidget> createState() => _AudioWidgetState();
}

class _AudioWidgetState extends State<AudioWidget> {
  late PlayerController _playerController;
  @override
  void initState() {
    super.initState();
    _playerController = PlayerController();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    await _playerController.preparePlayer(widget.cachedMediaInfo.cachedMediaUrl);
    await _playerController.setVolume(1.0);
    await _playerController.startPlayer(finishMode: FinishMode.stop);
  }

  @override
  Widget build(BuildContext context) {
    return AudioFileWaveforms(
      key: Key('cached-audio-${widget.uniqueId}'),
      size: Size(widget.width, widget.height),
      playerController: _playerController,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _playerController.dispose();
  }
}
