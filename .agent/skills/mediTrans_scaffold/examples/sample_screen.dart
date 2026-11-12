import 'dart:ui';

import 'package:flutter/material.dart';

/// Canonical Ethereal Aura Mind design tokens extracted from Stitch DESIGN.md.
/// Package note: Uses only Flutter SDK primitives (`material.dart` + `dart:ui`).
/// Swap font families to GoogleFonts (`Plus Jakarta Sans`, `Inter`, `Cormorant Garamond`)
/// once typography packages or local font assets are added to `pubspec.yaml`.
abstract final class AuraTokens {
  // Light Surfaces
  static const Color surface = Color(0xFFFBF8FF);
  static const Color surfaceContainerLow = Color(0xFFF3F2FF);
  static const Color surfaceContainer = Color(0xFFECECFF);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);

  // Night / Cosmic Surfaces (Sleep & Fullscreen Resonance)
  static const Color nightDeep = Color(0xFF0E111C);
  static const Color nightCard = Color(0xFF181D2D);

  // Brand & Semantic Colors
  static const Color primary = Color(0xFF60538D);
  static const Color primaryContainer = Color(0xFF796CA8);
  static const Color secondary = Color(0xFF4A6550);
  static const Color tertiary = Color(0xFF8A4B2D);

  // Text Hierarchy
  static const Color textPrimary = Color(0xFF1A1D2B);
  static const Color textSecondary = Color(0xFF6A7188);
  static const Color textMuted = Color(0xFF9BA3B7);

  // Ambient Orbs
  static const Color auraLavender = Color(0xFFB8A9E3);
  static const Color auraSage = Color(0xFFA3C4AB);
  static const Color auraPeach = Color(0xFFFFC0A0);
  static const Color auraSunset = Color(0xFFF4937A);

  // Glassmorphism Overlays
  static const Color glassLight = Color(0x73FFFFFF); // ~45% white
  static const Color glassLightSubtle = Color(0x40FFFFFF); // ~25% white
  static const Color glassBorderLight = Color(0xA6FFFFFF); // ~65% white
  static const Color glassDark = Color(0x99181D2D); // ~60% night-card
  static const Color glassBorderDark = Color(0x33FFFFFF); // ~20% white

  // Spacing & Safe Zones
  static const double pageMargin = 20;
  static const double gutter = 16;
  static const double bottomNavBuffer = 96;
}

/// Diffused watercolor orb backdrop used across MediTrans Light and Night routes.
class AuraBackground extends StatelessWidget {
  const AuraBackground({
    super.key,
    required this.child,
    this.isNightMode = false,
  });

  final Widget child;
  final bool isNightMode;

  @override
  Widget build(BuildContext context) {
    final Color baseColor = isNightMode
        ? AuraTokens.nightDeep
        : AuraTokens.surface;

    return ColoredBox(
      color: baseColor,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: -110,
            left: -80,
            child: _AuraOrb(
              size: 320,
              color: AuraTokens.auraLavender,
              opacity: isNightMode ? 0.22 : 0.42,
            ),
          ),
          Positioned(
            top: 140,
            right: -90,
            child: _AuraOrb(
              size: 280,
              color: isNightMode
                  ? AuraTokens.primaryContainer
                  : AuraTokens.auraPeach,
              opacity: isNightMode ? 0.20 : 0.38,
            ),
          ),
          Positioned(
            bottom: -100,
            left: 20,
            child: _AuraOrb(
              size: 300,
              color: AuraTokens.auraSage,
              opacity: isNightMode ? 0.14 : 0.30,
            ),
          ),
          SafeArea(child: child),
        ],
      ),
    );
  }
}

class _AuraOrb extends StatelessWidget {
  const _AuraOrb({
    required this.size,
    required this.color,
    required this.opacity,
  });

  final double size;
  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: opacity),
              color.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
  }
}

/// Frosted glass container adhering to Ethereal Aura Mind's No-Line rule.
class AuraGlassCard extends StatelessWidget {
  const AuraGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = 24,
    this.isNightMode = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final bool isNightMode;

  @override
  Widget build(BuildContext context) {
    final Radius radius = Radius.circular(borderRadius);
    return ClipRRect(
      borderRadius: BorderRadius.all(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: isNightMode ? AuraTokens.glassDark : AuraTokens.glassLight,
            borderRadius: BorderRadius.all(radius),
            border: Border.all(
              color: isNightMode
                  ? AuraTokens.glassBorderDark
                  : AuraTokens.glassBorderLight,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AuraTokens.primary.withValues(
                  alpha: isNightMode ? 0.18 : 0.08,
                ),
                blurRadius: 32,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Reference screen demonstrating Aura layout, mode toggle, and universal audio controls.
class SampleMeditativeScreen extends StatefulWidget {
  const SampleMeditativeScreen({super.key});

  @override
  State<SampleMeditativeScreen> createState() => _SampleMeditativeScreenState();
}

class _SampleMeditativeScreenState extends State<SampleMeditativeScreen> {
  bool _isNightMode = false;
  bool _isPlaying = false;
  double _progress = 0.35;

  @override
  Widget build(BuildContext context) {
    final Color headlineColor = _isNightMode
        ? Colors.white
        : AuraTokens.textPrimary;
    final Color subtitleColor = _isNightMode
        ? AuraTokens.textMuted
        : AuraTokens.textSecondary;

    return Scaffold(
      body: AuraBackground(
        isNightMode: _isNightMode,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AuraTokens.pageMargin,
            vertical: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Meditasyon Alanı',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                          color: headlineColor,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Bugün kendine sakin bir nefes alanı aç.',
                        style: TextStyle(fontSize: 14, color: subtitleColor),
                      ),
                    ],
                  ),
                  IconButton(
                    tooltip: _isNightMode ? 'Gündüz Modu' : 'Gece Modu',
                    onPressed: () {
                      setState(() => _isNightMode = !_isNightMode);
                    },
                    icon: Icon(
                      _isNightMode ? Icons.wb_sunny_rounded : Icons.nightlight,
                      color: headlineColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              AuraGlassCard(
                isNightMode: _isNightMode,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AuraTokens.primary.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: Text(
                        '528 Hz • Evrensel Denge',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _isNightMode
                              ? AuraTokens.auraLavender
                              : AuraTokens.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Derin Rezonans & Odak',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: headlineColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Evrensel oynatıcı tüm sayfalarda aynı standart kontrolleri sunar ve arka planda çalmaya devam eder.',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: subtitleColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AuraTokens.gutter),
              _UniversalAudioPreviewBar(
                isNightMode: _isNightMode,
                isPlaying: _isPlaying,
                progress: _progress,
                onTogglePlay: () => setState(() => _isPlaying = !_isPlaying),
                onSeek: (value) => setState(() => _progress = value),
              ),
              const SizedBox(height: AuraTokens.bottomNavBuffer),
            ],
          ),
        ),
      ),
    );
  }
}

class _UniversalAudioPreviewBar extends StatelessWidget {
  const _UniversalAudioPreviewBar({
    required this.isNightMode,
    required this.isPlaying,
    required this.progress,
    required this.onTogglePlay,
    required this.onSeek,
  });

  final bool isNightMode;
  final bool isPlaying;
  final double progress;
  final VoidCallback onTogglePlay;
  final ValueChanged<double> onSeek;

  @override
  Widget build(BuildContext context) {
    final Color foreground = isNightMode
        ? Colors.white
        : AuraTokens.textPrimary;
    final Color muted = isNightMode
        ? AuraTokens.textMuted
        : AuraTokens.textSecondary;

    return AuraGlassCard(
      isNightMode: isNightMode,
      borderRadius: 28,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Column(
        children: [
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              activeTrackColor: isNightMode
                  ? AuraTokens.auraLavender
                  : AuraTokens.primary,
              inactiveTrackColor: foreground.withValues(alpha: 0.12),
              thumbColor: isNightMode
                  ? AuraTokens.auraLavender
                  : AuraTokens.primary,
            ),
            child: Slider(value: progress, onChanged: onSeek),
          ),
          Row(
            children: [
              Text(
                '01:45',
                style: TextStyle(
                  fontSize: 12,
                  color: muted,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => onSeek((progress - 0.1).clamp(0.0, 1.0)),
                icon: Icon(Icons.replay_10_rounded, color: foreground),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: onTogglePlay,
                style: FilledButton.styleFrom(
                  backgroundColor: isNightMode
                      ? AuraTokens.auraLavender
                      : AuraTokens.primary,
                  foregroundColor: isNightMode
                      ? AuraTokens.nightDeep
                      : Colors.white,
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(14),
                ),
                child: Icon(
                  isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => onSeek((progress + 0.1).clamp(0.0, 1.0)),
                icon: Icon(Icons.forward_10_rounded, color: foreground),
              ),
              const Spacer(),
              Text(
                '05:00',
                style: TextStyle(
                  fontSize: 12,
                  color: muted,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
