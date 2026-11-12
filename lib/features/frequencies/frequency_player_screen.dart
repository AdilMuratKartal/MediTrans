import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../core/audio/universal_player_bar.dart';
import '../../core/data/seed_catalog.dart';
import '../../core/di/app_scope.dart';
import '../../core/theme/aura_theme.dart';

/// Plays the dedicated silent MP4 background video (`assets/videos/hz/hz_*_bg.mp4`)
/// for the active Hz frequency (`animateMotion: true`) with `mixWithOthers: true`
/// and `volume: 0.0` so it never interrupts the playing `.wav` audio.
/// In list thumbnails (`animateMotion: false`), renders the lightweight static slice.
class FrequencyStyleBackdrop extends StatefulWidget {
  final int styleIndex;
  final double borderRadius;
  final bool animateMotion;
  final Widget? child;

  const FrequencyStyleBackdrop({
    super.key,
    required this.styleIndex,
    this.borderRadius = 0,
    this.animateMotion = true,
    this.child,
  });

  static const List<String> videoAssetsByStyle = [
    'assets/videos/hz/hz_396_bg.mp4', // 0: 396 Hz Kök Çakra / 174 Hz / 111
    'assets/videos/hz/hz_432_bg.mp4', // 1: 432 Hz Evrensel Uyum / 40 Hz / 222
    'assets/videos/hz/hz_528_bg.mp4', // 2: 528 Hz Mucize Frekansı / 285 Hz / 417 Hz / 333
    'assets/videos/hz/hz_639_bg.mp4', // 3: 639 Hz Kalp Çakrası / 136.1 Hz / 444
    'assets/videos/hz/hz_7_83_bg.mp4', // 4: 7.83 Hz Schumann / 10 Hz / 555
    'assets/videos/hz/hz_741_bg.mp4', // 5: 741 Hz Boğaz Çakrası / 666
    'assets/videos/hz/hz_852_bg.mp4', // 6: 852 Hz Üçüncü Göz / 4.5 Hz / 777
    'assets/videos/hz/hz_963_bg.mp4', // 7: 963 Hz Tepe Çakra / 888
    'assets/videos/hz/hz_999_bg.mp4', // 8: 999 Arınma (Release) / 2 Hz
  ];

  static const List<Color> _tints = [
    Color(0xFF9E3B62), // 0: Root / 396 Hz / 111
    Color(0xFF4F66B8), // 1: 432 Hz / 222
    Color(0xFFB38B3D), // 2: 528 Hz / 333
    Color(0xFF399378), // 3: 639 Hz / 444
    Color(0xFF2E799E), // 4: 7.83 Hz / 555
    Color(0xFF4962B5), // 5: 741 Hz / 666
    Color(0xFF6F4EB0), // 6: 852 Hz / 777
    Color(0xFF9356B0), // 7: 963 Hz / 888
    Color(0xFF84578E), // 8: 999 Release
  ];

  static Alignment _baseAlignmentForIndex(int index) {
    final safe = index % 9;
    final row = safe ~/ 3; // 0, 1, 2
    final col = safe % 3; // 0, 1, 2
    final x = col == 0 ? -0.82 : (col == 1 ? 0.0 : 0.82);
    final y = row == 0 ? -0.82 : (row == 1 ? 0.0 : 0.82);
    return Alignment(x, y);
  }

  @override
  State<FrequencyStyleBackdrop> createState() => _FrequencyStyleBackdropState();
}

class _FrequencyStyleBackdropState extends State<FrequencyStyleBackdrop>
    with SingleTickerProviderStateMixin {
  VideoPlayerController? _videoController;
  bool _videoReady = false;
  AnimationController? _fallbackController;

  @override
  void initState() {
    super.initState();
    if (widget.animateMotion) {
      _fallbackController = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 12),
      )..repeat();
      _initVideoForStyle(widget.styleIndex);
    }
  }

  @override
  void didUpdateWidget(covariant FrequencyStyleBackdrop oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animateMotion && oldWidget.styleIndex != widget.styleIndex) {
      _initVideoForStyle(widget.styleIndex);
    }
  }

  Future<void> _initVideoForStyle(int styleIdx) async {
    final oldController = _videoController;
    _videoController = null;
    _videoReady = false;
    oldController?.dispose();

    final assetPath =
        FrequencyStyleBackdrop.videoAssetsByStyle[styleIdx %
            FrequencyStyleBackdrop.videoAssetsByStyle.length];

    try {
      final controller = VideoPlayerController.asset(
        assetPath,
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );
      _videoController = controller;
      await controller.initialize();
      await controller.setVolume(0.0);
      await controller.setLooping(true);
      await controller.play();
      if (mounted && _videoController == controller) {
        setState(() => _videoReady = true);
      }
    } catch (_) {
      // Fallback to animated poster if video codec is unavailable in test environment
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _fallbackController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tint = FrequencyStyleBackdrop
        ._tints[widget.styleIndex % FrequencyStyleBackdrop._tints.length];
    final baseAlign = FrequencyStyleBackdrop._baseAlignmentForIndex(
      widget.styleIndex,
    );

    if (!widget.animateMotion) {
      return _buildStaticStack(tint, baseAlign);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Instant poster / animated fallback layer
          if (_fallbackController != null)
            AnimatedBuilder(
              animation: _fallbackController!,
              builder: (context, _) {
                final phase = _fallbackController!.value * 2 * math.pi;
                final driftX = math.sin(phase) * 0.08;
                final driftY = math.cos(phase) * 0.08;
                final zoom = 2.38 + (math.sin(phase) * 0.12);
                return Transform.scale(
                  scale: zoom,
                  alignment: Alignment(
                    (baseAlign.x + driftX).clamp(-1.0, 1.0),
                    (baseAlign.y + driftY).clamp(-1.0, 1.0),
                  ),
                  child: Image.asset(
                    'assets/images/backgrounds/hz_styles_sheet.jpg',
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),

          // 2. Active silent looping MP4 video background (`assets/videos/hz/hz_*_bg.mp4`)
          if (_videoReady &&
              _videoController != null &&
              _videoController!.value.isInitialized)
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _videoController!.value.size.width > 0
                      ? _videoController!.value.size.width
                      : 720,
                  height: _videoController!.value.size.height > 0
                      ? _videoController!.value.size.height
                      : 1280,
                  child: VideoPlayer(_videoController!),
                ),
              ),
            ),

          // 3. Soft sanctuary gradient overlay for typography legibility
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  tint.withValues(alpha: 0.34),
                  const Color(0xFF151324).withValues(alpha: 0.56),
                  const Color(0xFF0E111C).withValues(alpha: 0.84),
                ],
              ),
            ),
          ),
          ?widget.child,
        ],
      ),
    );
  }

  Widget _buildStaticStack(Color tint, Alignment baseAlign) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Transform.scale(
            scale: 2.35,
            alignment: baseAlign,
            child: Image.asset(
              'assets/images/backgrounds/hz_styles_sheet.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  tint.withValues(alpha: 0.42),
                  const Color(0xFF151324).withValues(alpha: 0.68),
                  const Color(0xFF0E111C).withValues(alpha: 0.88),
                ],
              ),
            ),
          ),
          ?widget.child,
        ],
      ),
    );
  }
}

/// Swipeable Single Frequency Player (`hz_frekans_oynat_c`) AND
/// Full-Screen Resonance Mode (`hz_frekans_oynat_c_tam_ekran_rezonans`).
/// Swiping horizontally updates the frequency, silent MP4 background video, and playing audio track.
class FrequencyPlayerScreen extends StatefulWidget {
  final int initialIndex;
  final bool startFullScreenResonance;

  const FrequencyPlayerScreen({
    super.key,
    required this.initialIndex,
    this.startFullScreenResonance = false,
  });

  @override
  State<FrequencyPlayerScreen> createState() => _FrequencyPlayerScreenState();
}

class _FrequencyPlayerScreenState extends State<FrequencyPlayerScreen>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  late final AnimationController _pulseController;
  late int _currentIndex;
  late bool _isFullScreenResonance;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(
      0,
      SeedCatalog.frequencies.length - 1,
    );
    _isFullScreenResonance = widget.startFullScreenResonance;
    _pageController = PageController(initialPage: _currentIndex);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final scope = AppScope.of(context);
      final freq = SeedCatalog.frequencies[_currentIndex];
      scope.audio.playTrack(
        SeedCatalog.fromFrequency(freq),
        playlist: SeedCatalog.frequencies
            .map(SeedCatalog.fromFrequency)
            .toList(),
        autoPlay: true,
      );
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index, AppScope scope) {
    setState(() => _currentIndex = index);
    final freq = SeedCatalog.frequencies[index];
    scope.audio.playTrack(
      SeedCatalog.fromFrequency(freq),
      playlist: SeedCatalog.frequencies.map(SeedCatalog.fromFrequency).toList(),
      autoPlay: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final currentFreq = SeedCatalog.frequencies[_currentIndex];
    final isFav = scope.localStore.isFavorite(currentFreq.id);

    return Scaffold(
      backgroundColor: AuraColors.nightBg,
      body: FrequencyStyleBackdrop(
        styleIndex: currentFreq.styleIndex,
        animateMotion: true,
        child: SafeArea(
          child: Column(
            children: [
              // Top bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        if (_isFullScreenResonance &&
                            !widget.startFullScreenResonance) {
                          setState(() => _isFullScreenResonance = false);
                        } else {
                          Navigator.of(context).maybePop();
                        }
                      },
                      icon: Icon(
                        _isFullScreenResonance
                            ? Icons.close_fullscreen_rounded
                            : Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            _isFullScreenResonance
                                ? 'TAM EKRAN REZONANS'
                                : (currentFreq.isAngelSequence
                                      ? 'MELEK SAYI FREKANSI'
                                      : 'SOLFEGGIO & BİNAURAL REZONANS'),
                            style: const TextStyle(
                              fontFamily: 'Segoe UI',
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.8,
                              color: AuraColors.nightAccent,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Kaydırarak Frekans Değiştir (${_currentIndex + 1}/${SeedCatalog.frequencies.length})',
                            style: TextStyle(
                              fontFamily: 'Segoe UI',
                              fontSize: 11,
                              color: Colors.white.withValues(alpha: 0.72),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: isFav ? 'Favorilerden Çıkar' : 'Favorilere Ekle',
                      onPressed: () {
                        scope.localStore.toggleFavorite(currentFreq.id);
                        setState(() {});
                      },
                      icon: Icon(
                        isFav
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: isFav ? const Color(0xFFFF8AA8) : Colors.white,
                      ),
                    ),
                    IconButton(
                      tooltip: _isFullScreenResonance
                          ? 'Standart Görünüme Dön'
                          : 'Tam Ekran Rezonans Modu',
                      onPressed: () => setState(
                        () => _isFullScreenResonance = !_isFullScreenResonance,
                      ),
                      icon: Icon(
                        _isFullScreenResonance
                            ? Icons.fullscreen_exit_rounded
                            : Icons.fullscreen_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // Swipeable PageView for all frequencies
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: SeedCatalog.frequencies.length,
                  onPageChanged: (idx) => _onPageChanged(idx, scope),
                  itemBuilder: (context, index) {
                    final item = SeedCatalog.frequencies[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Animated Sacred Resonance Halo
                          AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, _) {
                              final scale =
                                  0.92 + (_pulseController.value * 0.14);
                              return Transform.scale(
                                scale: scale,
                                child: Container(
                                  width: _isFullScreenResonance ? 260 : 210,
                                  height: _isFullScreenResonance ? 260 : 210,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.32,
                                      ),
                                      width: 1.5,
                                    ),
                                    gradient: RadialGradient(
                                      colors: [
                                        AuraColors.nightAccent.withValues(
                                          alpha: 0.42,
                                        ),
                                        Colors.white.withValues(alpha: 0.10),
                                        Colors.transparent,
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AuraColors.nightAccent
                                            .withValues(alpha: 0.28),
                                        blurRadius: 48,
                                        spreadRadius: 8,
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          item.codeLabel,
                                          style: TextStyle(
                                            fontSize: _isFullScreenResonance
                                                ? 46
                                                : 38,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.white,
                                            letterSpacing: -0.5,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(
                                              alpha: 0.14,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              99,
                                            ),
                                          ),
                                          child: Text(
                                            item.isAngelSequence
                                                ? 'MELEK DİZİSİ'
                                                : 'CANLI REZONANS',
                                            style: const TextStyle(
                                              fontFamily: 'Segoe UI',
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 1.4,
                                              color: AuraColors.nightAccent,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                          Text(
                            item.titleTr,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item.chakraOrThemeTr,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'Segoe UI',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AuraColors.nightAccent,
                            ),
                          ),
                          if (!_isFullScreenResonance) ...[
                            const SizedBox(height: 14),
                            Text(
                              item.descriptionTr,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Segoe UI',
                                fontSize: 14,
                                height: 1.5,
                                color: Colors.white.withValues(alpha: 0.82),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Prev / Next Page Pills
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white.withValues(alpha: 0.85),
                      ),
                      onPressed: _currentIndex > 0
                          ? () => _pageController.previousPage(
                              duration: const Duration(milliseconds: 320),
                              curve: Curves.easeOutCubic,
                            )
                          : null,
                      icon: const Icon(Icons.chevron_left_rounded),
                      label: const Text('Önceki Ton'),
                    ),
                    FilledButton.tonalIcon(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.14),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => setState(
                        () => _isFullScreenResonance = !_isFullScreenResonance,
                      ),
                      icon: Icon(
                        _isFullScreenResonance
                            ? Icons.visibility_outlined
                            : Icons.waves_rounded,
                        size: 18,
                      ),
                      label: Text(
                        _isFullScreenResonance
                            ? 'Detayları Göster'
                            : 'Tam Ekran Rezonans',
                        style: const TextStyle(
                          fontFamily: 'Segoe UI',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white.withValues(alpha: 0.85),
                      ),
                      onPressed:
                          _currentIndex < SeedCatalog.frequencies.length - 1
                          ? () => _pageController.nextPage(
                              duration: const Duration(milliseconds: 320),
                              curve: Curves.easeOutCubic,
                            )
                          : null,
                      icon: const Icon(Icons.chevron_right_rounded),
                      label: const Text('Sonraki Ton'),
                    ),
                  ],
                ),
              ),

              // Universal Transport Player Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: UniversalPlayerBar(
                  audio: scope.audio,
                  localStore: scope.localStore,
                  isNightMode: true,
                  showHeaderInfo: !_isFullScreenResonance,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
