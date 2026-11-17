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
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white.withValues(alpha: 0.78),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.75),
            width: 1.2,
          ),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: Colors.transparent,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.38),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.68),
            width: 1.2,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.68),
            width: 1.2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: AuraColors.primary,
            width: 1.5,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white.withValues(alpha: 0.36),
        selectedColor: AuraColors.primary.withValues(alpha: 0.85),
        side: BorderSide(
          color: Colors.white.withValues(alpha: 0.62),
          width: 1.0,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
      ),
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

/// Renders an Ethereal Aura Mind layered glassmorphic background with optional image asset,
/// subtle uniform background blur (so no screen lacks blur, while keeping blur low/clear),
/// ambient pastel glow orbs, and translucent sanctuary overlay.
class AuraBackground extends StatelessWidget {
  final String? imageAsset;
  final bool isNightMode;
  final Color? tintColor;
  final double overlayOpacity;
  final double backgroundBlur;
  final Widget child;

  const AuraBackground({
    super.key,
    this.imageAsset,
    this.isNightMode = false,
    this.tintColor,
    this.overlayOpacity = 0.32,
    this.backgroundBlur = 4.5,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = isNightMode ? AuraColors.nightBg : AuraColors.surface;
    // Normalize any legacy high overlay opacities so backgrounds remain vivid for glassmorphism
    final effectiveOverlay = overlayOpacity > 0.50
        ? (overlayOpacity * 0.44).clamp(0.24, 0.42)
        : overlayOpacity.clamp(0.18, 0.48);

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
          // Soft ambient aura glow orbs behind the background blur
          Positioned(
            top: -70,
            left: -40,
            child: IgnorePointer(
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      (tintColor ??
                              (isNightMode
                                  ? const Color(0xFF5A4B96)
                                  : AuraColors.primaryFixed))
                          .withValues(alpha: isNightMode ? 0.36 : 0.48),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            right: -40,
            child: IgnorePointer(
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      (isNightMode
                              ? const Color(0xFF2B4370)
                              : AuraColors.tertiaryFixed)
                          .withValues(alpha: isNightMode ? 0.34 : 0.42),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Subtle uniform background blur on every page (reduced sigma so artwork shines through)
          ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: backgroundBlur,
                sigmaY: backgroundBlur,
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: isNightMode
                        ? [
                            AuraColors.nightBg.withValues(
                              alpha: effectiveOverlay,
                            ),
                            const Color(0xFF141829).withValues(
                              alpha: (effectiveOverlay + 0.06).clamp(0.0, 0.58),
                            ),
                            AuraColors.nightBg.withValues(
                              alpha: (effectiveOverlay + 0.16).clamp(0.0, 0.66),
                            ),
                          ]
                        : [
                            AuraColors.surface.withValues(
                              alpha: effectiveOverlay,
                            ),
                            (tintColor ?? const Color(0xFFF3EEFF)).withValues(
                              alpha: (effectiveOverlay - 0.04).clamp(0.14, 0.45),
                            ),
                            AuraColors.surface.withValues(
                              alpha: (effectiveOverlay + 0.10).clamp(0.24, 0.52),
                            ),
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

/// True Glassmorphic card with specular gradient, crisp luminous border, and reduced frosted blur.
class AuraGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? backgroundColor;
  final bool isNightMode;
  final double blurSigma;
  final VoidCallback? onTap;

  const AuraGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = 28,
    this.backgroundColor,
    this.isNightMode = false,
    this.blurSigma = 10.0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final topLeftColor =
        backgroundColor ??
        (isNightMode
            ? Colors.white.withValues(alpha: 0.15)
            : Colors.white.withValues(alpha: 0.46));
    final bottomRightColor =
        backgroundColor?.withValues(alpha: 0.28) ??
        (isNightMode
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.white.withValues(alpha: 0.26));

    final content = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [topLeftColor, bottomRightColor],
            ),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: isNightMode
                  ? Colors.white.withValues(alpha: 0.22)
                  : Colors.white.withValues(alpha: 0.72),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: (isNightMode ? Colors.black : AuraColors.primary)
                    .withValues(alpha: isNightMode ? 0.28 : 0.08),
                blurRadius: 24,
                offset: const Offset(0, 10),
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

/// Frosted Glassmorphic container for Modal Bottom Sheets and Dialogs.
class AuraGlassSheet extends StatelessWidget {
  final Widget child;
  final bool isNightMode;
  final EdgeInsetsGeometry padding;
  final double blurSigma;

  const AuraGlassSheet({
    super.key,
    required this.child,
    this.isNightMode = false,
    this.padding = const EdgeInsets.fromLTRB(24, 18, 24, 30),
    this.blurSigma = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isNightMode
                  ? [
                      const Color(0xFF1E2336).withValues(alpha: 0.76),
                      const Color(0xFF0E111C).withValues(alpha: 0.84),
                    ]
                  : [
                      Colors.white.withValues(alpha: 0.68),
                      const Color(0xFFF3EEFF).withValues(alpha: 0.54),
                    ],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(
              color: isNightMode
                  ? Colors.white.withValues(alpha: 0.22)
                  : Colors.white.withValues(alpha: 0.78),
              width: 1.2,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
