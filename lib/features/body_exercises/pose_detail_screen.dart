import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/audio/global_audio_controller.dart';
import '../../core/data/models.dart';
import '../../core/data/seed_catalog.dart';
import '../../core/di/app_scope.dart';
import '../../core/theme/aura_theme.dart';

/// Yoga Pose Detail & Circular Countdown Timer (`sasangasana_egzersiz_ve_saya_detay`)
/// Supports horizontal `PageView` swipe across all 8 poses, circular ring countdown,
/// preset chips (`10 sn`, `20 sn`, `30 sn`, `60 sn`, `90 sn`), `+5s`, reset, bell chime toggle,
/// 3-step instructions, benefit badges, and `Tamamla & Sıradaki Poz`.
class PoseDetailScreen extends StatefulWidget {
  final int initialPoseIndex;

  const PoseDetailScreen({super.key, required this.initialPoseIndex});

  @override
  State<PoseDetailScreen> createState() => _PoseDetailScreenState();
}

class _PoseDetailScreenState extends State<PoseDetailScreen> {
  late final PageController _pageController;
  late int _currentIndex;
  int _selectedPresetSec = 60;
  int _remainingSeconds = 60;
  bool _isRunning = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialPoseIndex.clamp(
      0,
      SeedCatalog.yogaPoses.length - 1,
    );
    _pageController = PageController(initialPage: _currentIndex);
    final pose = SeedCatalog.yogaPoses[_currentIndex];
    _selectedPresetSec = pose.recommendedSeconds;
    _remainingSeconds = _selectedPresetSec;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  YogaPoseItem get _currentPose => SeedCatalog.yogaPoses[_currentIndex];

  void _onPoseChanged(int index) {
    _timer?.cancel();
    final pose = SeedCatalog.yogaPoses[index];
    setState(() {
      _currentIndex = index;
      _isRunning = false;
      _selectedPresetSec = pose.recommendedSeconds;
      _remainingSeconds = _selectedPresetSec;
    });
  }

  void _toggleTimer(AppScope scope) {
    if (_isRunning) {
      _timer?.cancel();
      setState(() => _isRunning = false);
      return;
    }

    if (_remainingSeconds <= 0) {
      _remainingSeconds = _selectedPresetSec;
    }

    setState(() => _isRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_remainingSeconds <= 1) {
        timer.cancel();
        setState(() {
          _remainingSeconds = 0;
          _isRunning = false;
        });
        scope.audio.playBellChime();
        scope.localStore.recordCompletedSession(
          category: SessionCategory.yogaPose,
          itemId: _currentPose.id,
          titleTr: '${_currentPose.sanskritName} (${_currentPose.turkishName})',
          completedSeconds: _selectedPresetSec,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${_currentPose.sanskritName} tamamlandı! Harika bir akış ✨',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        setState(() {
          _remainingSeconds -= 1;
        });
      }
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _remainingSeconds = _selectedPresetSec;
    });
  }

  void _addFiveSeconds() {
    setState(() {
      _remainingSeconds += 5;
      if (_remainingSeconds > _selectedPresetSec) {
        _selectedPresetSec = _remainingSeconds;
      }
    });
  }

  void _completeAndAdvance(AppScope scope) {
    _timer?.cancel();
    scope.audio.playBellChime();
    scope.localStore.recordCompletedSession(
      category: SessionCategory.yogaPose,
      itemId: _currentPose.id,
      titleTr: '${_currentPose.sanskritName} (${_currentPose.turkishName})',
      completedSeconds: _selectedPresetSec,
    );

    if (_currentIndex < SeedCatalog.yogaPoses.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 360),
        curve: Curves.easeOutCubic,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Tebrikler! 8 pozluk tüm yoga serisini tamamladınız 🧘‍♀️',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final bellOn = scope.localStore.yogaBellEnabled;

    return Scaffold(
      body: AuraBackground(
        imageAsset: 'assets/images/backgrounds/body_detail_bg.jpg',
        overlayOpacity: 0.82,
        child: SafeArea(
          child: Column(
            children: [
              // Header with Back, Position badge, and Bell Chime toggle
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            'POZ 0${_currentPose.orderIndex} / 08',
                            style: const TextStyle(
                              fontFamily: 'Segoe UI',
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.8,
                              color: AuraColors.primary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _currentPose.sanskritName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: AuraColors.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.75),
                        foregroundColor: AuraColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                      onPressed: () {
                        final next = !bellOn;
                        scope.localStore.setYogaBellEnabled(next);
                        if (next) scope.audio.playBellChime();
                        setState(() {});
                      },
                      icon: Icon(
                        bellOn
                            ? Icons.notifications_active_rounded
                            : Icons.notifications_off_outlined,
                        size: 18,
                      ),
                      label: Text(
                        bellOn ? 'Çan Sesi' : 'Sessiz',
                        style: const TextStyle(
                          fontFamily: 'Segoe UI',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: SeedCatalog.yogaPoses.length,
                  onPageChanged: _onPoseChanged,
                  itemBuilder: (context, index) {
                    final pose = SeedCatalog.yogaPoses[index];
                    final progress = _selectedPresetSec <= 0
                        ? 0.0
                        : (_remainingSeconds / _selectedPresetSec).clamp(
                            0.0,
                            1.0,
                          );

                    return SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(22, 8, 22, 28),
                      child: Column(
                        children: [
                          // Pose Illustration Card + Prev/Next navigation buttons
                          AuraGlassCard(
                            padding: const EdgeInsets.all(18),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AuraColors.primaryFixed,
                                        borderRadius: BorderRadius.circular(99),
                                      ),
                                      child: Text(
                                        pose.levelBadgeTr,
                                        style: const TextStyle(
                                          fontFamily: 'Segoe UI',
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: AuraColors.primary,
                                        ),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          tooltip: 'Önceki Poz',
                                          onPressed: index > 0
                                              ? () => _pageController
                                                    .previousPage(
                                                      duration: const Duration(
                                                        milliseconds: 300,
                                                      ),
                                                      curve: Curves.easeOut,
                                                    )
                                              : null,
                                          icon: const Icon(
                                            Icons.chevron_left_rounded,
                                          ),
                                        ),
                                        IconButton(
                                          tooltip: 'Sonraki Poz',
                                          onPressed:
                                              index <
                                                  SeedCatalog.yogaPoses.length -
                                                      1
                                              ? () => _pageController.nextPage(
                                                  duration: const Duration(
                                                    milliseconds: 300,
                                                  ),
                                                  curve: Curves.easeOut,
                                                )
                                              : null,
                                          icon: const Icon(
                                            Icons.chevron_right_rounded,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Hero(
                                  tag: 'yoga_pose_${pose.id}',
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(22),
                                    child: Image.asset(
                                      pose.illustrationAsset,
                                      height: 210,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  pose.turkishName,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w600,
                                    color: AuraColors.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  pose.subtitleTr,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontFamily: 'Segoe UI',
                                    fontSize: 13,
                                    color: AuraColors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),

                          // Circular Ring Countdown Timer Card
                          AuraGlassCard(
                            padding: const EdgeInsets.all(22),
                            child: Column(
                              children: [
                                SizedBox(
                                  width: 175,
                                  height: 175,
                                  child: CustomPaint(
                                    painter: _CountdownRingPainter(
                                      progress: progress,
                                      activeColor: AuraColors.primary,
                                      trackColor: AuraColors.primaryFixed,
                                    ),
                                    child: Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            GlobalAudioController.formatSeconds(
                                              _remainingSeconds,
                                            ),
                                            style: const TextStyle(
                                              fontSize: 40,
                                              fontWeight: FontWeight.w500,
                                              color: AuraColors.onSurface,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _isRunning
                                                ? 'AKIŞ DEVAM EDİYOR'
                                                : 'SAYAÇ HAZIR',
                                            style: const TextStyle(
                                              fontFamily: 'Segoe UI',
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 1.4,
                                              color: AuraColors.primary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Duration Presets: 10 sn, 20 sn, 30 sn, 60 sn (Önerilen), 90 sn
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  alignment: WrapAlignment.center,
                                  children: [
                                    for (final sec in pose.durationPresetsSec)
                                      ChoiceChip(
                                        label: Text(
                                          sec == 60
                                              ? '60 sn (Önerilen)'
                                              : '$sec sn',
                                        ),
                                        selected: _selectedPresetSec == sec,
                                        selectedColor: AuraColors.primary,
                                        backgroundColor:
                                            AuraColors.surfaceContainerLow,
                                        side: BorderSide.none,
                                        labelStyle: TextStyle(
                                          fontFamily: 'Segoe UI',
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: _selectedPresetSec == sec
                                              ? Colors.white
                                              : AuraColors.onSurface,
                                        ),
                                        onSelected: (_) {
                                          _timer?.cancel();
                                          setState(() {
                                            _isRunning = false;
                                            _selectedPresetSec = sec;
                                            _remainingSeconds = sec;
                                          });
                                        },
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 18),

                                // Timer Transport Controls: Reset | Start/Pause | +5s
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    OutlinedButton.icon(
                                      onPressed: _resetTimer,
                                      icon: const Icon(
                                        Icons.refresh_rounded,
                                        size: 18,
                                      ),
                                      label: const Text('Sıfırla'),
                                    ),
                                    const SizedBox(width: 12),
                                    FilledButton.icon(
                                      style: FilledButton.styleFrom(
                                        backgroundColor: AuraColors.primary,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 22,
                                          vertical: 14,
                                        ),
                                      ),
                                      onPressed: () => _toggleTimer(scope),
                                      icon: Icon(
                                        _isRunning
                                            ? Icons.pause_rounded
                                            : Icons.play_arrow_rounded,
                                      ),
                                      label: Text(
                                        _isRunning ? 'Duraklat' : 'Pozu Başlat',
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    OutlinedButton(
                                      onPressed: _addFiveSeconds,
                                      child: const Text('+5 sn'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),

                          // Step-by-Step Instructions ("Nasıl Yapılır?")
                          AuraGlassCard(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Nasıl Yapılır?',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: AuraColors.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                for (
                                  var i = 0;
                                  i < pose.stepInstructionsTr.length;
                                  i++
                                )
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 26,
                                          height: 26,
                                          alignment: Alignment.center,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: AuraColors.primaryFixed,
                                          ),
                                          child: Text(
                                            '${i + 1}',
                                            style: const TextStyle(
                                              fontFamily: 'Segoe UI',
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: AuraColors.primary,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            pose.stepInstructionsTr[i],
                                            style: const TextStyle(
                                              fontFamily: 'Segoe UI',
                                              fontSize: 14,
                                              height: 1.45,
                                              color: AuraColors.onSurface,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    for (final b in pose.benefitBadgesTr)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AuraColors.secondaryContainer,
                                          borderRadius: BorderRadius.circular(
                                            99,
                                          ),
                                        ),
                                        child: Text(
                                          '✦ $b',
                                          style: const TextStyle(
                                            fontFamily: 'Segoe UI',
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: AuraColors.primary,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),

                          // Complete & Next Pose CTA
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              style: FilledButton.styleFrom(
                                backgroundColor: AuraColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(99),
                                ),
                              ),
                              onPressed: () => _completeAndAdvance(scope),
                              icon: const Icon(Icons.check_circle_outline),
                              label: Text(
                                index < SeedCatalog.yogaPoses.length - 1
                                    ? 'Tamamla & Sıradaki Poz'
                                    : 'Seriyi Tamamla',
                                style: const TextStyle(
                                  fontFamily: 'Segoe UI',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CountdownRingPainter extends CustomPainter {
  final double progress;
  final Color activeColor;
  final Color trackColor;

  const _CountdownRingPainter({
    required this.progress,
    required this.activeColor,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) / 2) - 8;

    final bgPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    final fgPaint = Paint()
      ..color = activeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);
    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CountdownRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
