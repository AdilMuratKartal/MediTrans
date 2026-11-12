import 'package:flutter/material.dart';
import '../data/local_store.dart';
import '../theme/aura_theme.dart';
import 'global_audio_controller.dart';

/// Interactive Volume & Sleep Timer Modal Dialogs + Compact/Expanded Player Controls
/// ensuring every transport button (`-10s`, `Play/Pause`, `+10s`, `Prev/Next`, `Favorite`,
/// `Sleep Timer`, `Volume`, `Loop`, and `Slider`) works with live feedback.
class UniversalPlayerBar extends StatelessWidget {
  final GlobalAudioController audio;
  final LocalStore localStore;
  final bool isNightMode;
  final bool showPrevNext;
  final bool showHeaderInfo;
  final VoidCallback? onOpenFullScreen;

  const UniversalPlayerBar({
    super.key,
    required this.audio,
    required this.localStore,
    this.isNightMode = false,
    this.showPrevNext = true,
    this.showHeaderInfo = true,
    this.onOpenFullScreen,
  });

  static void showSleepTimerSheet(
    BuildContext context,
    GlobalAudioController audio, {
    bool isNightMode = false,
  }) {
    final bgColor = isNightMode ? AuraColors.nightCard : AuraColors.surface;
    final textColor = isNightMode ? AuraColors.nightText : AuraColors.onSurface;
    final accent = isNightMode ? AuraColors.nightAccent : AuraColors.primary;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: bgColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return ListenableBuilder(
          listenable: audio,
          builder: (context, _) {
            final activeTimer = audio.formattedSleepTimer;
            final presets = [15, 30, 45, 60, 90];
            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: textColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Icon(Icons.bedtime_outlined, color: accent),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Uyku Zamanlayıcısı',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                      ),
                      if (activeTimer != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Text(
                            'Kalan: $activeTimer',
                            style: TextStyle(
                              fontFamily: 'Segoe UI',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: accent,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Belirlediğiniz süre sonunda ses yumuşakça durdurulur.',
                    style: TextStyle(
                      fontFamily: 'Segoe UI',
                      fontSize: 13,
                      color: textColor.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      for (final mins in presets)
                        ActionChip(
                          label: Text('$mins Dakika'),
                          backgroundColor: accent.withValues(alpha: 0.12),
                          side: BorderSide.none,
                          labelStyle: TextStyle(
                            fontFamily: 'Segoe UI',
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                          onPressed: () {
                            audio.setSleepTimerMinutes(mins);
                            Navigator.of(ctx).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Uyku zamanlayıcısı $mins dakika olarak ayarlandı.',
                                ),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        ),
                      if (activeTimer != null)
                        ActionChip(
                          avatar: const Icon(Icons.close, size: 16),
                          label: const Text('Zamanlayıcıyı Kapat'),
                          backgroundColor: Colors.redAccent.withValues(
                            alpha: 0.15,
                          ),
                          side: BorderSide.none,
                          labelStyle: TextStyle(
                            fontFamily: 'Segoe UI',
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                          onPressed: () {
                            audio.setSleepTimerMinutes(null);
                            Navigator.of(ctx).pop();
                          },
                        ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static void showVolumeSheet(
    BuildContext context,
    GlobalAudioController audio, {
    bool isNightMode = false,
  }) {
    final bgColor = isNightMode ? AuraColors.nightCard : AuraColors.surface;
    final textColor = isNightMode ? AuraColors.nightText : AuraColors.onSurface;
    final accent = isNightMode ? AuraColors.nightAccent : AuraColors.primary;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: bgColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return ListenableBuilder(
          listenable: audio,
          builder: (context, _) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(
                        audio.volume == 0
                            ? Icons.volume_off_rounded
                            : Icons.volume_up_rounded,
                        color: accent,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Ses Seviyesi & Akustik Denge',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                      ),
                      Text(
                        '%${(audio.volume * 100).round()}',
                        style: TextStyle(
                          fontFamily: 'Segoe UI',
                          fontWeight: FontWeight.w700,
                          color: accent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: accent,
                      thumbColor: accent,
                      inactiveTrackColor: accent.withValues(alpha: 0.2),
                    ),
                    child: Slider(
                      value: audio.volume,
                      onChanged: (v) => audio.setVolume(v),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton.icon(
                        onPressed: () => audio.setVolume(0.0),
                        icon: const Icon(Icons.volume_mute_rounded, size: 18),
                        label: const Text('Sessiz'),
                      ),
                      TextButton.icon(
                        onPressed: () => audio.setVolume(0.5),
                        icon: const Icon(Icons.graphic_eq_rounded, size: 18),
                        label: const Text('%50 Dengeli'),
                      ),
                      TextButton.icon(
                        onPressed: () => audio.setVolume(1.0),
                        icon: const Icon(Icons.volume_up_rounded, size: 18),
                        label: const Text('%100 Tam'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([audio, localStore]),
      builder: (context, _) {
        final track = audio.currentTrack;
        final isFav = localStore.isFavorite(track.id);
        final textColor = isNightMode
            ? AuraColors.nightText
            : AuraColors.onSurface;
        final subColor = isNightMode
            ? AuraColors.nightMuted
            : AuraColors.onSurfaceVariant;
        final accent = isNightMode
            ? AuraColors.nightAccent
            : AuraColors.primary;

        return AuraGlassCard(
          isNightMode: isNightMode,
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
          borderRadius: 28,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showHeaderInfo) ...[
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [accent, accent.withValues(alpha: 0.65)],
                        ),
                      ),
                      child: Icon(
                        audio.isPlaying
                            ? Icons.graphic_eq_rounded
                            : Icons.spa_outlined,
                        color: isNightMode ? AuraColors.nightBg : Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            track.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            track.subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Segoe UI',
                              fontSize: 12,
                              color: subColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: isFav ? 'Favorilerden Çıkar' : 'Favorilere Ekle',
                      onPressed: () => localStore.toggleFavorite(track.id),
                      icon: Icon(
                        isFav
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: isFav ? const Color(0xFFD86C8C) : subColor,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Uyku Zamanlayıcısı',
                      onPressed: () => showSleepTimerSheet(
                        context,
                        audio,
                        isNightMode: isNightMode,
                      ),
                      icon: Badge(
                        isLabelVisible:
                            audio.sleepTimerRemainingSeconds != null,
                        label: Text(audio.formattedSleepTimer ?? ''),
                        child: Icon(
                          Icons.timer_outlined,
                          color: audio.sleepTimerRemainingSeconds != null
                              ? accent
                              : subColor,
                        ),
                      ),
                    ),
                    if (onOpenFullScreen != null)
                      IconButton(
                        tooltip: 'Tam Ekran Rezonans',
                        onPressed: onOpenFullScreen,
                        icon: Icon(
                          Icons.open_in_full_rounded,
                          color: subColor,
                          size: 20,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 4,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 6,
                  ),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 12,
                  ),
                  activeTrackColor: accent,
                  inactiveTrackColor: accent.withValues(alpha: 0.20),
                  thumbColor: accent,
                ),
                child: Slider(
                  value: audio.progress,
                  onChanged: (val) => audio.seekToFraction(val),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      audio.formattedPosition,
                      style: TextStyle(
                        fontFamily: 'Segoe UI',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: subColor,
                      ),
                    ),
                    if (audio.formattedSleepTimer != null)
                      Text(
                        'Uyku: ${audio.formattedSleepTimer}',
                        style: TextStyle(
                          fontFamily: 'Segoe UI',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: accent,
                        ),
                      ),
                    Text(
                      audio.formattedDuration,
                      style: TextStyle(
                        fontFamily: 'Segoe UI',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: subColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    tooltip: 'Ses Seviyesi',
                    onPressed: () => showVolumeSheet(
                      context,
                      audio,
                      isNightMode: isNightMode,
                    ),
                    icon: Icon(
                      audio.volume == 0
                          ? Icons.volume_off_outlined
                          : Icons.volume_up_outlined,
                      color: subColor,
                      size: 21,
                    ),
                  ),
                  if (showPrevNext)
                    IconButton(
                      tooltip: 'Önceki Frekans / Ses',
                      onPressed: audio.previousTrack,
                      icon: Icon(
                        Icons.skip_previous_rounded,
                        color: textColor,
                        size: 26,
                      ),
                    ),
                  IconButton(
                    tooltip: '10 Saniye Geri',
                    onPressed: () => audio.seekRelative(-10),
                    icon: Icon(
                      Icons.replay_10_rounded,
                      color: textColor,
                      size: 26,
                    ),
                  ),
                  GestureDetector(
                    onTap: audio.togglePlayPause,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isNightMode
                              ? [
                                  AuraColors.nightAccent,
                                  const Color(0xFF9C8EE0),
                                ]
                              : [
                                  AuraColors.primary,
                                  AuraColors.primaryContainer,
                                ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: accent.withValues(alpha: 0.32),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Icon(
                        audio.isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: isNightMode ? AuraColors.nightBg : Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: '10 Saniye İleri',
                    onPressed: () => audio.seekRelative(10),
                    icon: Icon(
                      Icons.forward_10_rounded,
                      color: textColor,
                      size: 26,
                    ),
                  ),
                  if (showPrevNext)
                    IconButton(
                      tooltip: 'Sonraki Frekans / Ses',
                      onPressed: audio.nextTrack,
                      icon: Icon(
                        Icons.skip_next_rounded,
                        color: textColor,
                        size: 26,
                      ),
                    ),
                  IconButton(
                    tooltip: audio.isLooping ? 'Döngü Aktif' : 'Tek Sefer Çal',
                    onPressed: audio.toggleLoop,
                    icon: Icon(
                      Icons.repeat_rounded,
                      color: audio.isLooping ? accent : subColor,
                      size: 21,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
