import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/audio/global_audio_controller.dart';
import '../../core/data/models/breath_cadence_model.dart';
import '../../core/data/models/session_category_model.dart';
import '../../core/data/seed_catalog.dart';
import '../../core/di/app_scope.dart';
import '../../core/theme/aura_theme.dart';

/// Breathwork Sanctuary (`nefes_egzersizleri_kompakt_oynat_c`)
/// Features animated expanding/contracting breathing orb, 4-1-4 & 4-7-8 cadence selector,
/// 5 / 10 / 15 minute session timer, bell chime cues, and compact audio player bar.
class BreathworkScreen extends StatefulWidget {
  const BreathworkScreen({super.key});

  @override
  State<BreathworkScreen> createState() => _BreathworkScreenState();
}

class _BreathworkScreenState extends State<BreathworkScreen> {
  BreathCadence _selectedCadence = SeedCatalog.breathCadences.first;
  int _selectedMinutes = 5;
  bool _isSessionActive = false;
  int _elapsedSessionSeconds = 0;
  int _phaseRemainingSeconds = 4;
  String _phaseLabel = 'Nefes Al';
  double _orbScale = 0.78;
  Timer? _breathTimer;

  @override
  void initState() {
    super.initState();
    _phaseRemainingSeconds = _selectedCadence.inhaleSec;
  }

  @override
  void dispose() {
    _breathTimer?.cancel();
    super.dispose();
  }

  int get _totalCycles =>
      ((_selectedMinutes * 60) / _selectedCadence.cycleSeconds).ceil();

  int get _currentCycle =>
      ((_elapsedSessionSeconds ~/ _selectedCadence.cycleSeconds) + 1).clamp(
        1,
        _totalCycles,
      );

  void _toggleBreathSession(AppScope scope) {
    if (_isSessionActive) {
      _stopSession(scope, completed: false);
    } else {
      _startSession(scope);
    }
  }

  void _startSession(AppScope scope) {
    _breathTimer?.cancel();
    setState(() {
      _isSessionActive = true;
      _elapsedSessionSeconds = 0;
      _updatePhaseFromElapsed(0, scope);
    });
    scope.audio.playTrack(
      SeedCatalog.fromBreathCadence(_selectedCadence),
      autoPlay: true,
    );

    _breathTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      final nextElapsed = _elapsedSessionSeconds + 1;
      final totalTarget = _selectedMinutes * 60;
      if (nextElapsed >= totalTarget) {
        _stopSession(scope, completed: true);
        return;
      }
      setState(() {
        _elapsedSessionSeconds = nextElapsed;
        _updatePhaseFromElapsed(nextElapsed, scope);
      });
    });
  }

  void _updatePhaseFromElapsed(int elapsed, AppScope scope) {
    final cyclePos = elapsed % _selectedCadence.cycleSeconds;
    final inhale = _selectedCadence.inhaleSec;
    final hold = _selectedCadence.holdSec;
    final exhale = _selectedCadence.exhaleSec;

    if (cyclePos == 0 && elapsed > 0) {
      scope.audio.playBellChime();
    }

    if (cyclePos < inhale) {
      _phaseLabel = 'Nefes Al';
      _phaseRemainingSeconds = inhale - cyclePos;
      _orbScale = 1.06;
    } else if (cyclePos < inhale + hold) {
      _phaseLabel = 'Nefesini Tut';
      _phaseRemainingSeconds = (inhale + hold) - cyclePos;
      _orbScale = 1.12;
    } else {
      _phaseLabel = 'Yavaşça Ver';
      _phaseRemainingSeconds = (inhale + hold + exhale) - cyclePos;
      _orbScale = 0.74;
    }
  }

  void _stopSession(AppScope scope, {required bool completed}) {
    _breathTimer?.cancel();
    final practicedSeconds = _elapsedSessionSeconds;
    setState(() {
      _isSessionActive = false;
      _phaseLabel = 'Hazır';
      _phaseRemainingSeconds = _selectedCadence.inhaleSec;
      _orbScale = 0.82;
    });
    scope.audio.pause();

    if (practicedSeconds > 3 || completed) {
      scope.audio.playBellChime();
      scope.localStore.recordCompletedSession(
        category: SessionCategory.breathwork,
        itemId: _selectedCadence.id,
        titleTr: _selectedCadence.titleTr,
        completedSeconds: completed ? _selectedMinutes * 60 : practicedSeconds,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              completed
                  ? '${_selectedCadence.titleTr} seansı tamamlandı! ✨'
                  : 'Nefes seansı kaydedildi (${GlobalAudioController.formatSeconds(practicedSeconds)}).',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    return Scaffold(
      body: AuraBackground(
        imageAsset: _selectedCadence.backgroundAsset,
        overlayOpacity: 0.80,
        child: SafeArea(
          child: Column(
            children: [
              // Top bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      color: AuraColors.onSurface,
                    ),
                    const Expanded(
                      child: Text(
                        'Nefes Egzersizi',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AuraColors.onSurface,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: scope.localStore.yogaBellEnabled
                          ? 'Çan Sesi Açık'
                          : 'Çan Sesi Kapalı',
                      onPressed: () {
                        final next = !scope.localStore.yogaBellEnabled;
                        scope.localStore.setYogaBellEnabled(next);
                        if (next) scope.audio.playBellChime();
                        setState(() {});
                      },
                      icon: Icon(
                        scope.localStore.yogaBellEnabled
                            ? Icons.notifications_active_outlined
                            : Icons.notifications_off_outlined,
                        color: AuraColors.primary,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  child: Column(
                    children: [
                      // Cadence switcher pills
                      Wrap(
                        spacing: 10,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: [
                          for (final cadence in SeedCatalog.breathCadences)
                            ChoiceChip(
                              label: Text(cadence.titleTr),
                              selected: _selectedCadence.id == cadence.id,
                              selectedColor: AuraColors.primaryFixed,
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.75,
                              ),
                              side: BorderSide.none,
                              labelStyle: TextStyle(
                                fontFamily: 'Segoe UI',
                                fontWeight: _selectedCadence.id == cadence.id
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: AuraColors.primary,
                              ),
                              onSelected: (_) {
                                setState(() {
                                  _selectedCadence = cadence;
                                  _phaseRemainingSeconds = cadence.inhaleSec;
                                });
                              },
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _selectedCadence.subtitleTr,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Segoe UI',
                          fontSize: 13,
                          color: AuraColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Animated Breathing Orb
                      SizedBox(
                        height: 270,
                        child: Center(
                          child: AnimatedScale(
                            scale: _orbScale,
                            duration: Duration(
                              milliseconds: _isSessionActive ? 1400 : 500,
                            ),
                            curve: Curves.easeInOutCubic,
                            child: Container(
                              width: 220,
                              height: 220,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    Colors.white.withValues(alpha: 0.95),
                                    AuraColors.primaryFixed.withValues(
                                      alpha: 0.88,
                                    ),
                                    AuraColors.primaryContainer.withValues(
                                      alpha: 0.55,
                                    ),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AuraColors.primary.withValues(
                                      alpha: 0.24,
                                    ),
                                    blurRadius: 48,
                                    spreadRadius: 12,
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _phaseLabel.toUpperCase(),
                                    style: const TextStyle(
                                      fontFamily: 'Segoe UI',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 2.0,
                                      color: AuraColors.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '$_phaseRemainingSeconds',
                                    style: const TextStyle(
                                      fontSize: 54,
                                      fontWeight: FontWeight.w400,
                                      color: AuraColors.onSurface,
                                    ),
                                  ),
                                  Text(
                                    'saniye',
                                    style: TextStyle(
                                      fontFamily: 'Segoe UI',
                                      fontSize: 12,
                                      color: AuraColors.onSurfaceVariant
                                          .withValues(alpha: 0.8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Duration chips (5 Dk, 10 Dk, 15 Dk)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (final mins
                              in _selectedCadence.durationMinutesOptions)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              child: ChoiceChip(
                                label: Text('$mins Dk'),
                                selected: _selectedMinutes == mins,
                                selectedColor: AuraColors.primary,
                                backgroundColor: Colors.white.withValues(
                                  alpha: 0.72,
                                ),
                                side: BorderSide.none,
                                labelStyle: TextStyle(
                                  fontFamily: 'Segoe UI',
                                  fontWeight: FontWeight.w600,
                                  color: _selectedMinutes == mins
                                      ? Colors.white
                                      : AuraColors.onSurface,
                                ),
                                onSelected: (_) {
                                  setState(() {
                                    _selectedMinutes = mins;
                                  });
                                },
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Primary Start / Finish Session CTA
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: _isSessionActive
                                ? AuraColors.tertiary
                                : AuraColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(99),
                            ),
                          ),
                          onPressed: () => _toggleBreathSession(scope),
                          icon: Icon(
                            _isSessionActive
                                ? Icons.stop_circle_outlined
                                : Icons.self_improvement_rounded,
                          ),
                          label: Text(
                            _isSessionActive ? 'Seansı Bitir' : 'Seansı Başlat',
                            style: const TextStyle(
                              fontFamily: 'Segoe UI',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),

                      // Compact Audio Player Card (`Döngü X / Y`, `-10s`, `Play/Pause`, `+10s`, scrubber)
                      AuraGlassCard(
                        padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                        child: ListenableBuilder(
                          listenable: scope.audio,
                          builder: (context, _) {
                            return Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _selectedCadence.titleTr,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: AuraColors.onSurface,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Döngü $_currentCycle / $_totalCycles',
                                          style: const TextStyle(
                                            fontFamily: 'Segoe UI',
                                            fontSize: 12,
                                            color: AuraColors.primary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          tooltip: '10 sn geri',
                                          onPressed: () =>
                                              scope.audio.seekRelative(-10),
                                          icon: const Icon(
                                            Icons.replay_10_rounded,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            if (!_isSessionActive &&
                                                !scope.audio.isPlaying) {
                                              _startSession(scope);
                                            } else {
                                              scope.audio.togglePlayPause();
                                            }
                                          },
                                          child: Container(
                                            width: 46,
                                            height: 46,
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: AuraColors.primary,
                                            ),
                                            child: Icon(
                                              scope.audio.isPlaying
                                                  ? Icons.pause_rounded
                                                  : Icons.play_arrow_rounded,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          tooltip: '10 sn ileri',
                                          onPressed: () =>
                                              scope.audio.seekRelative(10),
                                          icon: const Icon(
                                            Icons.forward_10_rounded,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    trackHeight: 4,
                                    thumbShape: const RoundSliderThumbShape(
                                      enabledThumbRadius: 6,
                                    ),
                                    activeTrackColor: AuraColors.primary,
                                    inactiveTrackColor: AuraColors.primary
                                        .withValues(alpha: 0.18),
                                  ),
                                  child: Slider(
                                    value: scope.audio.progress,
                                    onChanged: scope.audio.seekToFraction,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      GlobalAudioController.formatSeconds(
                                        _isSessionActive
                                            ? _elapsedSessionSeconds
                                            : scope.audio.positionSeconds,
                                      ),
                                      style: const TextStyle(
                                        fontFamily: 'Segoe UI',
                                        fontSize: 11,
                                        color: AuraColors.onSurfaceVariant,
                                      ),
                                    ),
                                    Text(
                                      GlobalAudioController.formatSeconds(
                                        _selectedMinutes * 60,
                                      ),
                                      style: const TextStyle(
                                        fontFamily: 'Segoe UI',
                                        fontSize: 11,
                                        color: AuraColors.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
