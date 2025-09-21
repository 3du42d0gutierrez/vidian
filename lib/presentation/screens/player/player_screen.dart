import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart' as vp;
import 'package:media_kit/media_kit.dart' as mk;
import 'package:media_kit_video/media_kit_video.dart' as mk_video;
import 'package:go_router/go_router.dart';

import 'package:vidian_stream/presentation/blocs/player/player_bloc.dart';
import 'package:vidian_stream/presentation/blocs/player/player_event.dart';
import 'package:vidian_stream/presentation/blocs/player/player_state.dart';
import 'package:vidian_stream/core/utils/platform/platform.dart' as PlatformInfo;

class PlayerScreen extends StatefulWidget {
  final String? contentId;
  final String? contentUrl;
  final String? title;

  const PlayerScreen({Key? key, this.contentId, this.contentUrl, this.title}) : super(key: key);

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  mk.Player? _mediaKitPlayer;
  vp.VideoPlayerController? _fallbackController;

  StreamSubscription<dynamic>? _mkPositionSub;
  StreamSubscription<dynamic>? _mkDurationSub;

  bool _usingMediaKit = false;
  bool _usingFallback = false;
  bool _isPlaying = false;
  bool _isBuffering = true;

  final ValueNotifier<Duration> _currentPosition = ValueNotifier(Duration.zero);
  Duration _duration = Duration.zero;

  bool _controlsVisible = true;
  Timer? _hideControlsTimer;

  @override
  void initState() {
    super.initState();
    final bloc = context.read<PlayerBloc>();
    if (widget.contentUrl != null) {
      bloc.add(LoadPlayerByUrlEvent(url: widget.contentUrl!, title: widget.title));
    } else if (widget.contentId != null) {
      bloc.add(LoadPlayerByIdEvent(widget.contentId!));
    }
  }

  @override
  void dispose() {
    _disposeAll();
    super.dispose();
  }

  void _disposeAll() {
    _mkPositionSub?.cancel();
    _mkDurationSub?.cancel();
    _mkPositionSub = null;
    _mkDurationSub = null;
    _hideControlsTimer?.cancel();

    try { _mediaKitPlayer?.dispose(); } catch (_) {}
    _mediaKitPlayer = null;

    try {
      _fallbackController?.removeListener(_onFallbackUpdated);
      _fallbackController?.pause();
      _fallbackController?.dispose();
    } catch (_) {}
    _fallbackController = null;

    _usingMediaKit = _usingFallback = false;
    _isPlaying = false;
    _isBuffering = true;
    _currentPosition.value = Duration.zero;
    _duration = Duration.zero;
  }

  void _onFallbackUpdated() {
    if (!mounted || _fallbackController == null) return;
    final value = _fallbackController!.value;
    _currentPosition.value = value.position;
    setState(() {
      _isPlaying = value.isPlaying;
      _isBuffering = value.isBuffering;
      _duration = value.duration ?? Duration.zero;
    });
  }

  Duration _toDuration(dynamic pos) {
    if (pos == null) return Duration.zero;
    if (pos is Duration) return pos;
    if (pos is int) return Duration(milliseconds: pos);
    if (pos is double) return Duration(milliseconds: (pos * 1000).round());
    return Duration.zero;
  }

  Duration _clampDuration(Duration value, Duration min, Duration max) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }

  Future<void> _startMediaKit(String url) async {
    _disposeAll();
    setState(() => _isBuffering = true);
    try {
      _mediaKitPlayer = mk.Player();
      await _mediaKitPlayer!.open(mk.Media(url));
      await _mediaKitPlayer!.play();

      _mkPositionSub = _mediaKitPlayer!.streams.position.listen((pos) {
        if (!mounted) return;
        _currentPosition.value = _toDuration(pos);
      });
      _mkDurationSub = _mediaKitPlayer!.streams.duration.listen((d) {
        if (!mounted) return;
        _duration = _toDuration(d);
      });

      setState(() {
        _isBuffering = false;
        _isPlaying = true;
        _usingMediaKit = true;
        _usingFallback = false;
      });
      _startHideControlsTimer();
      return;
    } catch (e) {
      debugPrint('MediaKit error: $e');
    }
    await _startFallback(url);
  }

  Future<void> _startFallback(String url) async {
    _disposeAll();
    setState(() => _isBuffering = true);

    _fallbackController = vp.VideoPlayerController.network(url);
    try { await _fallbackController!.initialize(); } catch (e) {
      debugPrint('video_player initialize failed: $e');
      if (mounted) _showSnack('No se pudo iniciar el reproductor de respaldo.');
      return;
    }
    _duration = _fallbackController!.value.duration ?? Duration.zero;
    await _fallbackController!.play();
    _fallbackController!.addListener(_onFallbackUpdated);

    setState(() {
      _isBuffering = false;
      _isPlaying = true;
      _usingFallback = true;
      _usingMediaKit = false;
    });
    _startHideControlsTimer();
  }

  Future<void> _startForLocation(String url) async {
    final platformIsWeb = kIsWeb || (PlatformInfo.isWeb == true);
    if (platformIsWeb) { await _startFallback(url); return; }
    await _startMediaKit(url);
  }

  void _togglePlayPause() async {
    if (_usingMediaKit && _mediaKitPlayer != null) {
      if (_isPlaying) { await _mediaKitPlayer!.pause(); setState(() => _isPlaying = false); }
      else { await _mediaKitPlayer!.play(); setState(() => _isPlaying = true); }
      _startHideControlsTimer();
      return;
    }
    if (_usingFallback && _fallbackController != null) {
      if (_fallbackController!.value.isPlaying) { await _fallbackController!.pause(); setState(() => _isPlaying = false); }
      else { await _fallbackController!.play(); setState(() => _isPlaying = true); }
      _startHideControlsTimer();
    }
  }

  Future<void> _seekBy(Duration offset) async {
    if (_usingMediaKit && _mediaKitPlayer != null) {
      final target = _clampDuration(_currentPosition.value + offset, Duration.zero, _duration);
      await _mediaKitPlayer!.seek(target);
      return;
    }
    if (_usingFallback && _fallbackController != null) {
      final current = _fallbackController!.value.position;
      final target = _clampDuration(current + offset, Duration.zero, _duration);
      await _fallbackController!.seekTo(target);
    }
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  /// Botón atrás compatible con GoRouter
  void _goBack() {
    _disposeAll();
    if (GoRouter.of(context).canPop()) {
      GoRouter.of(context).pop();
    } else {
      GoRouter.of(context).go('/catalog'); // fallback si no hay historial
    }
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _controlsVisible = false);
    });
  }

  void _onTapScreen() {
    setState(() => _controlsVisible = !_controlsVisible);
    if (_controlsVisible) _startHideControlsTimer();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<PlayerBloc>();
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocConsumer<PlayerBloc, PlayerState>(
        listener: (context, state) async {
          if (state is PlayerReady) await _startForLocation(state.url);
          else if (state is PlayerError && mounted) _showSnack(state.message);
        },
        builder: (context, state) {
          if (state is PlayerLoading || state is PlayerInitial) return const Center(child: CircularProgressIndicator());
          if (state is PlayerError) {
            return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text('Error: ${state.message}', style: const TextStyle(color: Colors.white)),
                const SizedBox(height: 8),
                ElevatedButton(onPressed: () {
                  if (widget.contentId != null) bloc.add(LoadPlayerByIdEvent(widget.contentId!));
                  else if (widget.contentUrl != null) bloc.add(LoadPlayerByUrlEvent(url: widget.contentUrl!, title: widget.title));
                }, child: const Text('Reintentar'))
              ]),
            );
          }

          return GestureDetector(
            onTap: _onTapScreen,
            child: Stack(
              children: [
                if (_usingMediaKit && _mediaKitPlayer != null)
                  mk_video.Video(controller: mk_video.VideoController(_mediaKitPlayer!))
                else if (_usingFallback && _fallbackController != null)
                  Center(
                    child: AspectRatio(
                      aspectRatio: (_fallbackController!.value.isInitialized && _fallbackController!.value.aspectRatio != 0)
                          ? _fallbackController!.value.aspectRatio : 16 / 9,
                      child: vp.VideoPlayer(_fallbackController!),
                    ),
                  )
                else
                  const Center(child: CircularProgressIndicator()),

                if (_isBuffering) const Center(child: CircularProgressIndicator()),

                AnimatedOpacity(
                  opacity: _controlsVisible ? 1 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: Column(
                    children: [
                      AppBar(
                        backgroundColor: Colors.black26,
                        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: _goBack),
                        title: Text(widget.title ?? (state is PlayerReady ? state.title ?? '' : '')),
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            FloatingActionButton(
                              heroTag: 'play_pause',
                              mini: true,
                              onPressed: _togglePlayPause,
                              child: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                            ),
                            const SizedBox(width: 8),
                            FloatingActionButton(
                              heroTag: 'rewind_10',
                              mini: true,
                              onPressed: () => _seekBy(const Duration(seconds: -10)),
                              child: const Icon(Icons.replay_10),
                            ),
                            const SizedBox(width: 8),
                            FloatingActionButton(
                              heroTag: 'forward_10',
                              mini: true,
                              onPressed: () => _seekBy(const Duration(seconds: 10)),
                              child: const Icon(Icons.forward_10),
                            ),
                            const Spacer(),
                            ValueListenableBuilder<Duration>(
                              valueListenable: _currentPosition,
                              builder: (_, value, __) {
                                return Text(
                                  "${value.inMinutes.remainder(60).toString().padLeft(2,'0')}:${value.inSeconds.remainder(60).toString().padLeft(2,'0')}"
                                  " / ${_duration.inMinutes.remainder(60).toString().padLeft(2,'0')}:${_duration.inSeconds.remainder(60).toString().padLeft(2,'0')}",
                                  style: const TextStyle(color: Colors.white),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      ValueListenableBuilder<Duration>(
                        valueListenable: _currentPosition,
                        builder: (_, value, __) {
                          return Slider(
                            value: value.inSeconds.toDouble(),
                            max: _duration.inSeconds.toDouble().clamp(1, double.infinity),
                            onChanged: (v) async => await _seekBy(Duration(seconds: v.toInt())),
                            activeColor: Colors.red,
                            inactiveColor: Colors.white38,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
