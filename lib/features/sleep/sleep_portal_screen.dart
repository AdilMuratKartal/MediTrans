import 'package:flutter/material.dart';
import '../../core/audio/universal_player_bar.dart';
import '../../core/data/seed_catalog.dart';
import '../../core/di/app_scope.dart';
import '../../core/theme/aura_theme.dart';
import 'nature_sounds_screen.dart';
import 'noise_player_screen.dart';
import 'sleep_stories_screen.dart';

/// Sleep Sanctuary Portal (`uyku_portal_kategoriler`)
/// Deep night mode (`#0E111C`) gateway to:
/// 1. Doğa Sesleri (`Gece Yağmuru`, `Derin Okyanus`)
/// 2. Gürültüler (`Beyaz Gürültü`, `Kahverengi Gürültü`)
/// 3. Uyku Hikayeleri (`Ay Işığında Gizli Orman`, `Yıldızların Altında Dağ Kulübesi`)
class SleepPortalScreen extends StatelessWidget {
  const SleepPortalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);

    return Scaffold(
      backgroundColor: AuraColors.nightBg,
      body: AuraBackground(
        imageAsset: 'assets/images/backgrounds/sleep_portal_bg.jpg',
        isNightMode: true,
        overlayOpacity: 0.76,
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
                        'Uyku Tapınağı',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AuraColors.nightText,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Uyku Zamanlayıcısı Kur',
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
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
                  children: [
                    const Text(
                      'GECE DİNGİNLİĞİ & DERİN UYKU',
                      style: TextStyle(
                        fontFamily: 'Segoe UI',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.8,
                        color: AuraColors.nightAccent,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Gece Ritüelinizi Seçin',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w500,
                        color: AuraColors.nightText,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Sinir sistemini yavaşlatan doğal akustik kayıtlar, ses izolasyonu sağlayan gürültü frekansları ve sesli uyku masalları.',
                      style: TextStyle(
                        fontFamily: 'Segoe UI',
                        fontSize: 13.5,
                        color: AuraColors.nightMuted,
                      ),
                    ),
                    const SizedBox(height: 22),

                    // 1. Doğa Sesleri Card
                    _SleepCategoryCard(
                      badge: 'DOĞAL AKUSTİK • 2 KAYIT',
                      title: 'Doğa Sesleri',
                      subtitle:
                          'Gece Yağmuru (5 Dk) ve Derin Okyanus dalgaları ile uykuya yumuşak geçiş.',
                      imageAsset:
                          'assets/images/backgrounds/nature_rain_bg.jpg',
                      icon: Icons.water_drop_outlined,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const NatureSoundsScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // 2. Gürültüler Card
                    _SleepCategoryCard(
                      badge: 'FREKANS İZOLASYONU • 2 SPEKTRUM',
                      title: 'Gürültüler (Beyaz & Kahverengi)',
                      subtitle:
                          'Dış ortam seslerini maskeleyen Beyaz Gürültü ve derin baslı Kahverengi Gürültü.',
                      imageAsset:
                          'assets/images/backgrounds/noise_brown_bg.jpg',
                      icon: Icons.graphic_eq_rounded,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const NoisePlayerScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // 3. Uyku Hikayeleri Card
                    _SleepCategoryCard(
                      badge: 'SESLİ ANLATIM & TAM METİN • 2 MASAL',
                      title: 'Uyku Hikayeleri',
                      subtitle:
                          'Ay Işığında Gizli Orman ve Yıldızların Altında Gizli Dağ Kulübesi.',
                      imageAsset: 'assets/images/backgrounds/story_1_bg.jpg',
                      icon: Icons.auto_stories_outlined,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const SleepStoriesScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    // Quick Play Night Ritual Banner
                    AuraGlassCard(
                      isNightMode: true,
                      padding: const EdgeInsets.all(18),
                      onTap: () {
                        scope.audio.playTrack(
                          SeedCatalog.fromSleepTrack(
                            SeedCatalog.storyTracks.first,
                          ),
                          playlist: SeedCatalog.storyTracks
                              .map(SeedCatalog.fromSleepTrack)
                              .toList(),
                          autoPlay: true,
                        );
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) =>
                                const SleepStoriesScreen(initialStoryIndex: 0),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AuraColors.nightAccent.withValues(
                                alpha: 0.22,
                              ),
                            ),
                            child: const Icon(
                              Icons.nights_stay_rounded,
                              color: AuraColors.nightGold,
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Önerilen Gece Masalı',
                                  style: TextStyle(
                                    fontFamily: 'Segoe UI',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AuraColors.nightGold,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Ay Işığında Gizli Orman ve Sakin Göl',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AuraColors.nightText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.play_circle_fill_rounded,
                            color: AuraColors.nightAccent,
                            size: 34,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SleepCategoryCard extends StatelessWidget {
  final String badge;
  final String title;
  final String subtitle;
  final String imageAsset;
  final IconData icon;
  final VoidCallback onTap;

  const _SleepCategoryCard({
    required this.badge,
    required this.title,
    required this.subtitle,
    required this.imageAsset,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AuraGlassCard(
      isNightMode: true,
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
                child: Image.asset(
                  imageAsset,
                  height: 125,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 12,
                left: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AuraColors.nightBg.withValues(alpha: 0.72),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      fontFamily: 'Segoe UI',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: AuraColors.nightAccent,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AuraColors.nightAccent.withValues(alpha: 0.16),
                  ),
                  child: Icon(icon, color: AuraColors.nightAccent),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w600,
                          color: AuraColors.nightText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontFamily: 'Segoe UI',
                          fontSize: 12.5,
                          color: AuraColors.nightMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AuraColors.nightAccent,
                  size: 18,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
