import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Reproduce el archivo local y sustituye esta ruta por el formulario de acceso.
class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  late final VideoPlayerController _controller;
  Timer? _initializationTimeout;
  Timer? _safetyTimeout;
  bool _ready = false;
  bool _finished = false;
  bool _muted = true;
  bool _needsGesture = false;

  bool get _active => mounted && !_finished;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(
      'assets/videos/netflix_intro.mp4',
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    )..addListener(_onVideoChanged);
    // Ni un archivo incompatible ni una carga bloqueada deben impedir el login.
    _initializationTimeout = Timer(const Duration(seconds: 8), _finish);
    _safetyTimeout = Timer(const Duration(seconds: 30), _finish);
    unawaited(_initialize());
  }

  bool _isAutoplayRestriction(Object error) {
    final message = error.toString().toLowerCase();
    return message.contains('notallowed') ||
        message.contains('not allowed') ||
        message.contains('user gesture') ||
        message.contains('user interaction') ||
        message.contains("user didn't interact") ||
        message.contains('user has not interacted') ||
        message.contains('autoplay');
  }

  Future<void> _initialize() async {
    try {
      await _controller.initialize();
      if (!_active) return;
      await _controller.setVolume(0);
      if (!_active) return;
      await _controller.setLooping(false);
      if (!_active) return;
      _initializationTimeout?.cancel();
      setState(() => _ready = true);
      await _play();
    } catch (error) {
      if (!_active) return;
      if (_controller.value.isInitialized && _isAutoplayRestriction(error)) {
        _initializationTimeout?.cancel();
        setState(() {
          _ready = true;
          _needsGesture = true;
        });
      } else {
        _finish();
      }
    }
  }

  Future<void> _play() async {
    if (!_active || !_ready) return;
    try {
      await _controller.play();
      if (_active) setState(() => _needsGesture = false);
    } catch (error) {
      if (!_active) return;
      if (_controller.value.isInitialized && _isAutoplayRestriction(error)) {
        setState(() => _needsGesture = true);
      } else {
        _finish();
      }
    }
  }

  Future<void> _toggleAudio() async {
    if (!_active || !_ready) return;
    final muted = !_muted;
    try {
      // Esta acción nace de un clic: el navegador puede permitir el sonido.
      await _controller.setVolume(muted ? 0 : 1);
      if (!_active) return;
      setState(() => _muted = muted);
      if (_needsGesture) await _play();
    } catch (error) {
      if (!_active) return;
      if (_controller.value.isInitialized && _isAutoplayRestriction(error)) {
        setState(() => _needsGesture = true);
      } else {
        _finish();
      }
    }
  }

  void _onVideoChanged() {
    if (!_active) return;
    final value = _controller.value;
    if (value.hasError) {
      // Los errores de la plataforma invalidan el controlador. El login debe
      // seguir disponible incluso si el navegador rechaza la reproducción.
      _finish();
      return;
    }
    if (value.isInitialized &&
        value.duration > Duration.zero &&
        value.position >= value.duration) {
      _finish();
    }
  }

  void _finish() {
    if (!_active) return;
    _finished = true;
    _initializationTimeout?.cancel();
    _safetyTimeout?.cancel();
    // El listener puede recibir eventos mientras el video se está construyendo.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(_controller.pause().catchError((Object _) {}));
      Navigator.of(context).pushReplacementNamed('/login');
    });
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  @override
  void dispose() {
    _finished = true;
    _initializationTimeout?.cancel();
    _safetyTimeout?.cancel();
    _controller.removeListener(_onVideoChanged);
    unawaited(_controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (_ready)
            Center(
              child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: Semantics(
                  label: 'Intro de Netflix',
                  child: VideoPlayer(_controller),
                ),
              ),
            )
          else
            const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white54,
                ),
              ),
            ),
          if (_needsGesture)
            Center(
              child: ElevatedButton.icon(
                key: const Key('play-intro'),
                onPressed: _play,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Iniciar intro'),
              ),
            ),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: _ready
                    ? OutlinedButton.icon(
                        key: const Key('intro-audio'),
                        onPressed: _toggleAudio,
                        icon: Icon(_muted ? Icons.volume_off : Icons.volume_up),
                        label: Text(_muted ? 'Activar sonido' : 'Silenciar'),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: OutlinedButton.icon(
                  key: const Key('skip-intro'),
                  onPressed: _finish,
                  icon: const Icon(Icons.skip_next),
                  label: const Text('Omitir intro'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
