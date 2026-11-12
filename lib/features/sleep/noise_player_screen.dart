import 'package:flutter/material.dart';
import '../../core/audio/universal_player_bar.dart';
import '../../core/data/models/sleep_media_track_model.dart';
import '../../core/data/seed_catalog.dart';
import '../../core/di/app_scope.dart';
import '../../core/theme/aura_theme.dart';

/// White & Brown Noise Player (`g_r_lt_mikseri_beyaz_kahverengi_g_r_lt`)
/// Switches between `Beyaz Gürültü` and `Kahverengi Gürültü` with distinct backgrounds and real audio.
class NoisePlayerScreen extends StatefulWidget {
  final int initialIndex;

  const NoisePlayerScreen({super.key, this.initialIndex = 0});

  @override
  State<NoisePlayerScreen> createState() => _NoisePlayerScreenState();
}

class _NoisePlayerScreenState extends State<NoisePlayerScreen> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex.clamp(
      0,
      SeedCatalog.noiseTracks.length - 1,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _selectNoise(_selectedIndex);
    });
  }

  SleepMediaTrack get _current => SeedCatalog.noiseTracks[_selectedIndex];

  void _selectNoise(int index) {
    final scope = AppScope.of(context);
    setState(() => _selectedIndex = index);
    final item = SeedCatalog.noiseTracks[index];
    scope.audio.playTrack(
      SeedCatalog.fromSleepTrack(item),
      playlist: SeedCatalog.noiseTracks
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
        overlayOpacity: 0.74,
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
                        'Gürültü Frekansları',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AuraColors.nightText,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Ses Dengesi',
                      onPressed: () => UniversalPlayerBar.showVolumeSheet(
                        context,
                        scope.audio,
                        isNightMode: true,
                      ),
                      icon: const Icon(
                        Icons.tune_rounded,
                        color: AuraColors.nightAccent,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // White vs Brown Noise Selector Cards
                      Row(
                        children: [
                          for (
                            var i = 0;
                            i < SeedCatalog.noiseTracks.length;
                            i++
                          ) ...[
                            if (i > 0) const SizedBox(width: 12),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _selectNoise(i),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 260),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 18,
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
                                            ? Icons.blur_on_rounded
                                            : Icons.graphic_eq_rounded,
                                        color: _selectedIndex == i
                                            ? AuraColors.nightAccent
                                            : AuraColors.nightMuted,
                                        size: 30,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        SeedCatalog.noiseTracks[i].titleTr,
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

                      // Acoustic Spectrum Card
                      AuraGlassCard(
                        isNightMode: true,
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.asset(
                                track.backgroundAsset,
                                height: 150,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              track.titleTr,
                              style: const TextStyle(
                                fontSize: 24,
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
