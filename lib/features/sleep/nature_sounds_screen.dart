import 'package:flutter/material.dart';
import '../../core/audio/universal_player_bar.dart';
import '../../core/data/models/sleep_media_track_model.dart';
import '../../core/data/seed_catalog.dart';
import '../../core/di/app_scope.dart';
import '../../core/theme/aura_theme.dart';

/// Nature Sounds Player (`do_a_sesleri_ses_oynat_c`)
/// Switches between `Gece Yağmuru` (`sakin_yagmur_5dk.mp3`) and `Derin Okyanus` (`deep_ocean_shortened.m4a`)
/// while dynamically changing the night backdrop image.
class NatureSoundsScreen extends StatefulWidget {
  final int initialIndex;

  const NatureSoundsScreen({super.key, this.initialIndex = 0});

  @override
  State<NatureSoundsScreen> createState() => _NatureSoundsScreenState();
}

class _NatureSoundsScreenState extends State<NatureSoundsScreen> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex.clamp(
      0,
      SeedCatalog.natureTracks.length - 1,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _activateTrack(_selectedIndex);
    });
  }

  SleepMediaTrack get _current => SeedCatalog.natureTracks[_selectedIndex];

  void _activateTrack(int index) {
    final scope = AppScope.of(context);
    setState(() => _selectedIndex = index);
    final item = SeedCatalog.natureTracks[index];
    scope.audio.playTrack(
      SeedCatalog.fromSleepTrack(item),
      playlist: SeedCatalog.natureTracks
          .map(SeedCatalog.fromSleepTrack)
          .toList(),
      autoPlay: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final track = _current;

    return Scaffold(
      backgroundColor: AuraColors.nightBg,
      body: AuraBackground(
        imageAsset: track.backgroundAsset,
        isNightMode: true,
        overlayOpacity: 0.72,
        child: SafeArea(
          child: Column(
            children: [
              // Top bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: AuraColors.nightText,
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'Doğa Sesleri',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AuraColors.nightText,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Uyku Zamanlayıcısı',
                      onPressed: () => UniversalPlayerBar.showSleepTimerSheet(
                        context,
                        scope.audio,
                        isNightMode: true,
                      ),
                      icon: const Icon(
                        Icons.bedtime_outlined,
                        color: AuraColors.nightAccent,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Switcher Cards: Gece Yağmuru <-> Derin Okyanus
                      Row(
                        children: [
                          for (
                            var i = 0;
                            i < SeedCatalog.natureTracks.length;
                            i++
                          ) ...[
                            if (i > 0) const SizedBox(width: 12),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _activateTrack(i),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 260),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                    horizontal: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _selectedIndex == i
                                        ? AuraColors.nightAccent.withValues(
                                            alpha: 0.22,
                                          )
                                        : Colors.white.withValues(alpha: 0.07),
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: _selectedIndex == i
                                          ? AuraColors.nightAccent
                                          : Colors.white.withValues(
                                              alpha: 0.12,
                                            ),
                                      width: 1.4,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(
                                        i == 0
                                            ? Icons.water_drop_outlined
                                            : Icons.waves_rounded,
                                        color: _selectedIndex == i
                                            ? AuraColors.nightAccent
                                            : AuraColors.nightMuted,
                                        size: 28,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        SeedCatalog.natureTracks[i].titleTr,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: _selectedIndex == i
                                              ? AuraColors.nightText
                                              : AuraColors.nightMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Visual Sanctuary Orb
                      Container(
                        width: 210,
                        height: 210,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AuraColors.nightAccent.withValues(
                                alpha: 0.22,
                              ),
                              blurRadius: 42,
                              spreadRadius: 6,
                            ),
                          ],
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.22),
                            width: 1.5,
                          ),
                          image: DecorationImage(
                            image: AssetImage(track.backgroundAsset),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        track.titleTr,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                          color: AuraColors.nightText,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        track.subtitleTr,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Segoe UI',
                          fontSize: 13.5,
                          color: AuraColors.nightMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 22),
                child: UniversalPlayerBar(
                  audio: scope.audio,
                  localStore: scope.localStore,
                  isNightMode: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
