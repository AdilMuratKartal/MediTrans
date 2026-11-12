import 'dart:ui';
import 'package:flutter/material.dart';

/// Ethereal Aura Mind Design Tokens & Shared Surface Primitives.
/// Strictly aligned with Stitch screens (`stitch_meditasyon_uygulamas_aray_z`).
class AuraColors {
  // Light Mode (Home, Meditation Portal, Breathwork, Body Exercises, Frequencies, Profile)
  static const Color surface = Color(0xFFFBF8FF);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF5F2FA);
  static const Color surfaceContainer = Color(0xFFEFECF4);
  static const Color surfaceContainerHigh = Color(0xFFE9E7EF);
  static const Color surfaceContainerHighest = Color(0xFFE3E1E9);

  static const Color primary = Color(0xFF60538D);
  static const Color primaryContainer = Color(0xFF796BA7);
  static const Color primaryFixed = Color(0xFFE6DEFF);
  static const Color primaryFixedDim = Color(0xFFCAC1FF);

  static const Color secondary = Color(0xFF605B71);
  static const Color secondaryContainer = Color(0xFFE6DFF9);
  static const Color tertiary = Color(0xFF7B5266);
  static const Color tertiaryFixed = Color(0xFFFFD8E8);

  static const Color onSurface = Color(0xFF1B1B20);
  static const Color onSurfaceVariant = Color(0xFF48454F);
  static const Color outline = Color(0xFF797580);
  static const Color outlineVariant = Color(0xFFCAC4D0);

  // Night Sanctuary Mode (Sleep Portal, Nature Sounds, Noise Mixer, Sleep Stories)
  static const Color nightBg = Color(0xFF0E111C);
  static const Color nightSurface = Color(0xFF171B2B);
  static const Color nightCard = Color(0xFF1E2336);
  static const Color nightAccent = Color(0xFFCAC1FF);
  static const Color nightMint = Color(0xFF9DE2D0);
  static const Color nightGold = Color(0xFFF3D59B);
  static const Color nightText = Color(0xFFF3EFFC);
  static const Color nightMuted = Color(0xFFA7A2BA);
}

class AuraTheme {
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AuraColors.surface,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AuraColors.primary,
        primary: AuraColors.primary,
        secondary: AuraColors.secondary,
        tertiary: AuraColors.tertiary,
        surface: AuraColors.surface,
        onSurface: AuraColors.onSurface,
      ),
      fontFamily: 'Georgia',
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.6,
          color: AuraColors.onSurface,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.3,
          color: AuraColors.onSurface,
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AuraColors.onSurface,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Segoe UI',
          fontSize: 16,
          height: 1.5,
          color: AuraColors.onSurface,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Segoe UI',
          fontSize: 14,
          height: 1.45,
          color: AuraColors.onSurfaceVariant,
        ),
        labelSmall: TextStyle(
          fontFamily: 'Segoe UI',
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.4,
          color: AuraColors.onSurfaceVariant,
        ),
      ),
    );
  }
}

/// Renders an Ethereal Aura Mind layered background with optional image asset,
/// ambient pastel blur orbs, and dark sanctuary overlay.
class AuraBackground extends StatelessWidget {
  final String? imageAsset;
  final bool isNightMode;
  final Color? tintColor;
  final double overlayOpacity;
  final Widget child;

  const AuraBackground({
    super.key,
    this.imageAsset,
    this.isNightMode = false,
    this.tintColor,
    this.overlayOpacity = 0.76,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = isNightMode ? AuraColors.nightBg : AuraColors.surface;
    return Container(
      color: baseColor,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (imageAsset != null && imageAsset!.isNotEmpty)
            Image.asset(
              imageAsset!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Container(color: baseColor),
            ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isNightMode
                    ? [
                        AuraColors.nightBg.withValues(alpha: overlayOpacity),
                        const Color(
                          0xFF141829,
                        ).withValues(alpha: overlayOpacity + 0.08),
                        AuraColors.nightBg.withValues(alpha: 0.94),
                      ]
                    : [
                        AuraColors.surface.withValues(alpha: overlayOpacity),
                        (tintColor ?? const Color(0xFFF3EEFF)).withValues(
                          alpha: overlayOpacity - 0.06,
                        ),
                        AuraColors.surface.withValues(alpha: 0.92),
                      ],
              ),
            ),
          ),
          // Soft ambient aura glow orbs
          Positioned(
            top: -80,
            left: -50,
            child: IgnorePointer(
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      (tintColor ??
                              (isNightMode
                                  ? const Color(0xFF493D78)
                                  : AuraColors.primaryFixed))
                          .withValues(alpha: isNightMode ? 0.28 : 0.42),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -90,
            right: -50,
            child: IgnorePointer(
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      (isNightMode
                              ? const Color(0xFF283A5E)
                              : AuraColors.tertiaryFixed)
                          .withValues(alpha: isNightMode ? 0.26 : 0.35),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

/// Borderless frosted glass card following the No-Line Rule (`backdrop-filter: blur`).
class AuraGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? backgroundColor;
  final bool isNightMode;
  final VoidCallback? onTap;

  const AuraGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = 28,
    this.backgroundColor,
    this.isNightMode = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg =
        backgroundColor ??
        (isNightMode
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.white.withValues(alpha: 0.72));

    final content = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: isNightMode
                  ? Colors.white.withValues(alpha: 0.10)
                  : Colors.white.withValues(alpha: 0.65),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: (isNightMode ? Colors.black : AuraColors.primary)
                    .withValues(alpha: isNightMode ? 0.24 : 0.06),
                blurRadius: 28,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );

    if (onTap == null) return content;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: content,
    );
  }
}
