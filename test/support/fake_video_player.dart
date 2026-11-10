import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

// Reproductor de prueba sin codecs ni acceso a la red.
class FakeVideoPlayer extends VideoPlayerPlatform {
  FakeVideoPlayer({
    this.failInitialization = false,
    this.holdInitialization = false,
    this.blockFirstPlay = false,
    this.throwFirstPlay = false,
  });
  final bool failInitialization;
  final bool holdInitialization;
  final bool blockFirstPlay;
  final bool throwFirstPlay;
  int playCalls = 0;
  final Map<int, StreamController<VideoEvent>> _events = {};
  final Map<int, Duration> _positions = {};
  final List<double> volumes = [];
  int _nextId = 0;

  @override
  Future<void> init() async {}

  @override
  Future<int?> createWithOptions(VideoCreationOptions options) async {
    final id = _nextId++;
    late StreamController<VideoEvent> controller;
    controller = StreamController<VideoEvent>(
      onListen: () {
        if (holdInitialization) return;
        if (failInitialization) {
          controller.addError(
            PlatformException(
              code: 'VideoError',
              message: 'Video no disponible',
            ),
          );
        } else {
          controller.add(
            VideoEvent(
              eventType: VideoEventType.initialized,
              duration: const Duration(milliseconds: 4063),
              size: const Size(1920, 1080),
            ),
          );
        }
      },
    );
    _events[id] = controller;
    _positions[id] = Duration.zero;
    return id;
  }

  void finish() {
    for (final controller in _events.values) {
      controller.add(VideoEvent(eventType: VideoEventType.completed));
    }
  }

  @override
  Stream<VideoEvent> videoEventsFor(int playerId) => _events[playerId]!.stream;

  @override
  Future<void> dispose(int playerId) async {
    await _events.remove(playerId)?.close();
    _positions.remove(playerId);
  }

  @override
  Future<void> setLooping(int playerId, bool looping) async {}

  @override
  Future<void> play(int playerId) async {
    playCalls++;
    if (throwFirstPlay && playCalls == 1) {
      throw PlatformException(
        code: 'NotAllowedError',
        message: 'Autoplay blocked',
      );
    }
    if (blockFirstPlay && playCalls == 1) {
      _events[playerId]!.addError(
        PlatformException(code: 'NotAllowedError', message: 'Autoplay blocked'),
      );
    }
  }

  @override
  Future<void> pause(int playerId) async {}

  @override
  Future<void> setVolume(int playerId, double volume) async {
    volumes.add(volume);
  }

  @override
  Future<void> seekTo(int playerId, Duration position) async {
    _positions[playerId] = position;
  }

  @override
  Future<void> setPlaybackSpeed(int playerId, double speed) async {}

  @override
  Future<Duration> getPosition(int playerId) async =>
      _positions[playerId] ?? Duration.zero;

  @override
  Widget buildViewWithOptions(VideoViewOptions options) =>
      const ColoredBox(color: Colors.black, key: Key('fake-video'));

  @override
  Future<void> setMixWithOthers(bool mixWithOthers) async {}

  @override
  Future<void> setAllowBackgroundPlayback(bool allowBackgroundPlayback) async {}
}
