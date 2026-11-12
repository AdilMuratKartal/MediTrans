import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import '../data/local_store.dart';
import '../data/media_storage_gateway.dart';
import '../data/models/playable_track_model.dart';
import '../data/seed_catalog.dart';

/// Singleton-scoped reactive audio engine powering Hz Frequencies, Breathwork,
/// Nature Sounds, White/Brown Noise, Sleep Stories, and Yoga Bell Chimes.
class GlobalAudioController extends ChangeNotifier {
  final LocalStore localStore;
  final MediaStorageGateway mediaGateway;

  AudioPlayer? _mainPlayer;
  AudioPlayer? _chimePlayer;
  Timer? _progressTimer;
  Timer? _sleepTimer;

  PlayableTrack _currentTrack = SeedCatalog.fromFrequency(
    SeedCatalog.frequencies.firstWhere(
      (f) => f.id == 'hz_432',
      orElse: () => SeedCatalog.frequencies.first,
    ),
  );
  List<PlayableTrack> _playlist = SeedCatalog.frequencies
      .map(SeedCatalog.fromFrequency)
      .toList();

  bool _isPlaying = false;
  bool _isLooping = true;
  double _volume = 0.80;
  int _positionSeconds = 0;
  int _durationSeconds = 900; // 15:00 default session duration
  int _clipDurationSeconds = 0; // Actual underlying audio file duration
  int? _sleepTimerRemainingSeconds;
  String? _lastLoadedAssetOrUrl;

  GlobalAudioController({
    required this.localStore,
    required this.mediaGateway,
  }) {
    _syncFromLocalStoreTrack();
    localStore.addListener(_onLocalStoreUpdated);
    _initPlayers();
  }

  void _syncFromLocalStoreTrack() {
    final stored = localStore.lastPlayedTrack;
    _currentTrack = stored;
    _durationSeconds = stored.durationSeconds > 0 ? stored.durationSeconds : 300;
    _positionSeconds = stored.lastPositionSeconds.clamp(0, _durationSeconds);
  }

  void _onLocalStoreUpdated() {
    if (!_isPlaying) {
      final stored = localStore.lastPlayedTrack;
      if (stored.id != _currentTrack.id ||
          stored.title != _currentTrack.title ||
          stored.category != _currentTrack.category) {
        _syncFromLocalStoreTrack();
        notifyListeners();
      }
    }
  }

  PlayableTrack get currentTrack => _currentTrack;
  List<PlayableTrack> get playlist => List.unmodifiable(_playlist);
  bool get isPlaying => _isPlaying;
  bool get isLooping => _isLooping;
  double get volume => _volume;
  int get positionSeconds => _positionSeconds;
  int get durationSeconds => _durationSeconds <= 0 ? 300 : _durationSeconds;
  int? get sleepTimerRemainingSeconds => _sleepTimerRemainingSeconds;

  double get progress => (positionSeconds / durationSeconds).clamp(0.0, 1.0);

  String get formattedPosition => formatSeconds(_positionSeconds);
  String get formattedDuration => formatSeconds(durationSeconds);
  String? get formattedSleepTimer => _sleepTimerRemainingSeconds == null
      ? null
      : formatSeconds(_sleepTimerRemainingSeconds!);

  static String formatSeconds(int totalSeconds) {
    final safe = totalSeconds < 0 ? 0 : totalSeconds;
    final mins = (safe ~/ 60).toString().padLeft(2, '0');
    final secs = (safe % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  void _initPlayers() {
    try {
      _mainPlayer = AudioPlayer();
      _chimePlayer = AudioPlayer();
      _mainPlayer!.setReleaseMode(ReleaseMode.loop);

      // Track the actual underlying clip length (e.g. 15s for looping Hz WAVs vs 300s for stories)
      // Do NOT overwrite `_positionSeconds` from `onPositionChanged`, because looping short
      // Hz WAV files reset `pos.inSeconds` to 0 every few seconds!
      _mainPlayer!.onDurationChanged.listen((dur) {
        if (dur.inSeconds > 0) {
          _clipDurationSeconds = dur.inSeconds;
        }
      });

      // If a short clip finishes on web when loop mode isn't honored by the browser, re-trigger play
      _mainPlayer!.onPlayerComplete.listen((_) {
        if (_isPlaying && _isLooping) {
          _replayCurrentSource();
        }
      });
    } catch (_) {
      // Safe fallback in headless widget tests
    }
  }

  Future<void> _replayCurrentSource() async {
    try {
      final resolved = await mediaGateway.resolveAudio(
        localAssetPath: _currentTrack.localAudioAsset,
        remoteStoragePath: _currentTrack.remoteStoragePath,
      );
      if (resolved.isLocalAsset) {
        await _mainPlayer?.play(AssetSource(resolved.path));
      } else if (resolved.isLocalFile) {
        await _mainPlayer?.play(DeviceFileSource(resolved.path));
      } else {
        await _mainPlayer?.play(UrlSource(resolved.path));
      }
    } catch (_) {}
  }

  Future<void> playTrack(
    PlayableTrack track, {
    List<PlayableTrack>? playlist,
    bool autoPlay = true,
  }) async {
    if (playlist != null && playlist.isNotEmpty) {
      _playlist = List<PlayableTrack>.from(playlist);
    }
    final isSameTrack = _currentTrack.id == track.id;
    _durationSeconds = track.durationSeconds > 0 ? track.durationSeconds : 300;
    if (!isSameTrack) {
      _positionSeconds = 0;
      _clipDurationSeconds = 0;
    }
    _currentTrack = track.copyWith(
      lastPositionSeconds: _positionSeconds,
      updatedAt: DateTime.now(),
    );
    await localStore.setLastPlayedTrack(
      _currentTrack,
      positionSeconds: _positionSeconds,
    );

    if (!autoPlay) {
      await pause();
      return;
    }

    _isPlaying = true;
    _startProgressTicker();
    notifyListeners();

    try {
      final resolved = await mediaGateway.resolveAudio(
        localAssetPath: track.localAudioAsset,
        remoteStoragePath: track.remoteStoragePath,
      );
      if (!isSameTrack || _lastLoadedAssetOrUrl != resolved.path) {
        await _mainPlayer?.stop();
      }
      _lastLoadedAssetOrUrl = resolved.path;
      await _mainPlayer?.setVolume(_volume);
      await _mainPlayer?.setReleaseMode(
        _isLooping ? ReleaseMode.loop : ReleaseMode.stop,
      );
      if (resolved.isLocalAsset) {
        await _mainPlayer?.play(AssetSource(resolved.path));
      } else if (resolved.isLocalFile) {
        await _mainPlayer?.play(DeviceFileSource(resolved.path));
      } else {
        await _mainPlayer?.play(UrlSource(resolved.path));
      }
    } catch (_) {
      // Keep virtual timer running smoothly even if audio hardware is unavailable
    }
  }

  Future<void> togglePlayPause() async {
    if (_isPlaying) {
      await pause();
    } else {
      await playTrack(_currentTrack, autoPlay: true);
    }
  }

  Future<void> pause() async {
    _isPlaying = false;
    _progressTimer?.cancel();
    try {
      await _mainPlayer?.pause();
    } catch (_) {}
    _currentTrack = _currentTrack.copyWith(
      lastPositionSeconds: _positionSeconds,
      updatedAt: DateTime.now(),
    );
    await localStore.setLastPlayedTrack(
      _currentTrack,
      positionSeconds: _positionSeconds,
    );
    notifyListeners();
  }

  Future<void> seekRelative(int deltaSeconds) async {
    final target = (_positionSeconds + deltaSeconds).clamp(0, durationSeconds);
    await seekToSeconds(target);
  }

  Future<void> seekToSeconds(int seconds) async {
    _positionSeconds = seconds.clamp(0, durationSeconds);
    try {
      // Only seek within the valid bounds of the underlying audio clip so short looping WAVs don't EOF
      if (_clipDurationSeconds > 2) {
        final safeClipTarget = _positionSeconds % _clipDurationSeconds;
        await _mainPlayer?.seek(Duration(seconds: safeClipTarget));
      }
    } catch (_) {}
    _currentTrack = _currentTrack.copyWith(
      lastPositionSeconds: _positionSeconds,
      updatedAt: DateTime.now(),
    );
    await localStore.setLastPlayedTrack(
      _currentTrack,
      positionSeconds: _positionSeconds,
    );
    notifyListeners();
  }

  Future<void> seekToFraction(double fraction) async {
    final target = (fraction.clamp(0.0, 1.0) * durationSeconds).round();
    await seekToSeconds(target);
  }

  Future<void> nextTrack() async {
    if (_playlist.isEmpty) return;
    final idx = _playlist.indexWhere((t) => t.id == _currentTrack.id);
    final nextIdx = idx < 0 ? 0 : (idx + 1) % _playlist.length;
    await playTrack(_playlist[nextIdx], autoPlay: true);
  }

  Future<void> previousTrack() async {
    if (_playlist.isEmpty) return;
    final idx = _playlist.indexWhere((t) => t.id == _currentTrack.id);
    final prevIdx = idx <= 0
        ? _playlist.length - 1
        : (idx - 1) % _playlist.length;
    await playTrack(_playlist[prevIdx], autoPlay: true);
  }

  Future<void> setVolume(double newVolume) async {
    _volume = newVolume.clamp(0.0, 1.0);
    try {
      await _mainPlayer?.setVolume(_volume);
    } catch (_) {}
    notifyListeners();
  }

  Future<void> toggleLoop() async {
    _isLooping = !_isLooping;
    try {
      await _mainPlayer?.setReleaseMode(
        _isLooping ? ReleaseMode.loop : ReleaseMode.stop,
      );
    } catch (_) {}
    notifyListeners();
  }

  void setSleepTimerMinutes(int? minutes) {
    _sleepTimer?.cancel();
    if (minutes == null || minutes <= 0) {
      _sleepTimerRemainingSeconds = null;
      notifyListeners();
      return;
    }
    _sleepTimerRemainingSeconds = minutes * 60;
    _sleepTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_sleepTimerRemainingSeconds == null) {
        timer.cancel();
        return;
      }
      if (_sleepTimerRemainingSeconds! <= 1) {
        _sleepTimerRemainingSeconds = null;
        timer.cancel();
        pause();
      } else {
        _sleepTimerRemainingSeconds = _sleepTimerRemainingSeconds! - 1;
        notifyListeners();
      }
    });
    notifyListeners();
  }

  Future<void> playBellChime() async {
    if (!localStore.yogaBellEnabled) return;
    try {
      await _chimePlayer?.setVolume(_volume);
      await _chimePlayer?.play(AssetSource('audio/chime.wav'));
    } catch (_) {}
  }

  void _startProgressTicker() {
    _progressTimer?.cancel();
    _progressTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPlaying) {
        timer.cancel();
        return;
      }
      if (_positionSeconds + 1 >= durationSeconds) {
        localStore.recordCompletedSession(
          category: _currentTrack.category,
          itemId: _currentTrack.id,
          titleTr: _currentTrack.title,
          completedSeconds: durationSeconds,
        );
        if (_isLooping) {
          _positionSeconds = 0;
        } else {
          _isPlaying = false;
          timer.cancel();
        }
      } else {
        _positionSeconds += 1;
      }
      notifyListeners();
    });
  }

  @override
  void dispose() {
    localStore.removeListener(_onLocalStoreUpdated);
    _progressTimer?.cancel();
    _sleepTimer?.cancel();
    _mainPlayer?.dispose();
    _chimePlayer?.dispose();
    super.dispose();
  }
}
