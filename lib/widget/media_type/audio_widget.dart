import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:cached_media/cached_media.dart';
import 'package:cached_media/entity_cached_media_info.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;

typedef OnError = void Function(Exception exception);

enum PlayerState { stopped, playing, paused }

class AudioWidget extends StatefulWidget {
  const AudioWidget({
    Key? key,
    required this.uniqueId,
    required this.cachedMediaInfo,
    required this.width,
    required this.height,
    required this.fit,
  }) : super(key: key);

  final String uniqueId;
  final CachedMediaInfo cachedMediaInfo;
  final double width;
  final double height;
  final BoxFit? fit;

  @override
  State<AudioWidget> createState() => _AudioWidgetState();
}

class _AudioWidgetState extends State<AudioWidget> {
  Duration? duration;
  Duration? position;
  AudioPlayer? audioPlayer;

  PlayerState playerState = PlayerState.stopped;
  get isPlaying => playerState == PlayerState.playing;
  get isPaused => playerState == PlayerState.paused;
  get durationText => duration != null ? duration.toString().split('.').first : '';
  get positionText => position != null ? position.toString().split('.').first : '';

  bool isMuted = false;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _audioPlayerStateSubscription;

  @override
  void initState() {
    super.initState();
    initAudioPlayer();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _audioPlayerStateSubscription?.cancel();
    audioPlayer?.stop();
    super.dispose();
  }

  Future<void> initAudioPlayer() async {
    if (getShowLogs) developer.log('🔈 Audio player initializing ');
    audioPlayer = AudioPlayer();
    if (getShowLogs) developer.log('🔈 Audio player initialized ');
    _positionSubscription = audioPlayer!.onPositionChanged.listen((p) => setState(() => position = p));
    _audioPlayerStateSubscription = audioPlayer!.onPlayerStateChanged.listen((s) async {
      if (s == PlayerState.playing) {
        duration = await audioPlayer!.getDuration();
        setState(() {});
      } else if (s == PlayerState.stopped) {
        onComplete();
        setState(() {
          position = duration;
        });
      }
    }, onError: (msg) {
      setState(() {
        playerState = PlayerState.stopped;
        duration = const Duration(seconds: 0);
        position = const Duration(seconds: 0);
      });
    });
  }

  Future<void> _playLocal() async {
    if (getShowLogs) developer.log('🔊 Audio player started ');
    if (audioPlayer != null) {
      await audioPlayer!.play(DeviceFileSource(widget.cachedMediaInfo.cachedMediaUrl), volume: 1.0);
      setState(() => playerState = PlayerState.playing);
    }
  }

  Future<void> pause() async {
    if (audioPlayer != null) {
      await audioPlayer!.pause();
      setState(() => playerState = PlayerState.paused);
    }
  }

  Future<void> stop() async {
    if (audioPlayer != null) {
      await audioPlayer!.stop();
      setState(() {
        playerState = PlayerState.stopped;
        position = const Duration();
      });
    }
  }

  Future<void> mute(bool muted) async {
    if (audioPlayer != null) {
      await audioPlayer!.setVolume(muted ? 0.0 : 1.0);
      setState(() {
        isMuted = muted;
      });
    }
  }

  void onComplete() {
    setState(() => playerState = PlayerState.stopped);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: Key('cached-audio-${widget.uniqueId}'),
      child: _buildPlayer(),
    );
  }

  Widget _buildPlayer() => Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(mainAxisSize: MainAxisSize.min, children: [
              IconButton(
                onPressed: isPlaying ? null : () => _playLocal(),
                iconSize: 64.0,
                icon: const Icon(Icons.play_arrow),
                color: Colors.cyan,
              ),
              IconButton(
                onPressed: isPlaying ? () => pause() : null,
                iconSize: 64.0,
                icon: const Icon(Icons.pause),
                color: Colors.cyan,
              ),
              IconButton(
                onPressed: isPlaying || isPaused ? () => stop() : null,
                iconSize: 64.0,
                icon: const Icon(Icons.stop),
                color: Colors.cyan,
              ),
            ]),
            if (duration != null)
              Slider(
                value: position?.inMilliseconds.toDouble() ?? 0.0,
                onChanged: (double value) async {
                  audioPlayer != null ? await audioPlayer!.seek(Duration(seconds: (value / 1000).roundToDouble().toInt())) : 0.0;
                },
                min: 0.0,
                max: duration?.inMilliseconds.toDouble() ?? 0,
              ),
            if (position != null) _buildMuteButtons(),
            if (position != null) _buildProgressView()
          ],
        ),
      );

  Row _buildProgressView() => Row(mainAxisSize: MainAxisSize.min, children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: CircularProgressIndicator(
            value: (position?.inMilliseconds ?? 0) > 0 ? (position?.inMilliseconds.toDouble() ?? 0.0) / (duration?.inMilliseconds.toDouble() ?? 0.0) : 0.0,
            valueColor: const AlwaysStoppedAnimation(Colors.cyan),
            backgroundColor: Colors.grey.shade400,
          ),
        ),
        Text(
          position != null
              ? "${positionText ?? ''} / ${durationText ?? ''}"
              : duration != null
                  ? durationText
                  : '',
          style: const TextStyle(fontSize: 24.0),
        )
      ]);

  Row _buildMuteButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        if (!isMuted)
          ElevatedButton.icon(
            onPressed: () => mute(true),
            icon: const Icon(
              Icons.headset_off,
              color: Colors.cyan,
            ),
            label: const Text('Mute', style: TextStyle(color: Colors.cyan)),
          ),
        if (isMuted)
          ElevatedButton.icon(
            onPressed: () => mute(false),
            icon: const Icon(Icons.headset, color: Colors.cyan),
            label: const Text('Unmute', style: TextStyle(color: Colors.cyan)),
          ),
      ],
    );
  }
}
