import 'package:flutter/material.dart';
import '../../core/data/seed_catalog.dart';
import '../../core/di/app_scope.dart';
import '../../core/theme/aura_theme.dart';
import '../body_exercises/body_exercises_screen.dart';
import '../breathwork/breathwork_screen.dart';
import '../frequencies/frequencies_screen.dart';
import '../frequencies/frequency_player_screen.dart';
import '../sleep/sleep_portal_screen.dart';

/// Meditation Portal 4-Category Hub (`meditasyon_portali_4_kategori`)
/// Connects Breathwork, Hz Frequencies, Body Exercises (Yoga), and Sleep Sanctuary.
class MeditationPortalScreen extends StatefulWidget {
  final VoidCallback? onOpenNotifications;

  const MeditationPortalScreen({super.key, this.onOpenNotifications});

  @override
  State<MeditationPortalScreen> createState() => _MeditationPortalScreenState();
}

class _MeditationPortalScreenState extends State<MeditationPortalScreen> {
  String _selectedFilter =
      'Tümü'; // 'Tümü', 'Nefes', 'Frekans', 'Beden', 'Uyku'

  void _showQuickRecommendationSheet(BuildContext context, AppScope scope) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AuraColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
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
                    color: AuraColors.outlineVariant,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Sana Özel Akış Rehberi',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: AuraColors.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Şu anki ihtiyacına göre tek dokunuşla bir pratik başlat:',
                style: TextStyle(
                  fontFamily: 'Segoe UI',
                  fontSize: 13.5,
                  color: AuraColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(
                  backgroundColor: AuraColors.primaryFixed,
                  child: Icon(Icons.air_rounded, color: AuraColors.primary),
                ),
                title: const Text('3 Dakikada Zihni Sakinleştir'),
                subtitle: const Text('4-1-4 Dengeli Solunum Egzersizi'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const BreathworkScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(
                  backgroundColor: AuraColors.secondaryContainer,
                  child: Icon(
                    Icons.self_improvement_rounded,
                    color: AuraColors.primary,
                  ),
                ),
                title: const Text('Masa Başı Omurga Rahatlatma'),
                subtitle: const Text('Poz 03 Sasangasana & 8 Poz Yoga Akışı'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const BodyExercisesScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(
                  backgroundColor: AuraColors.tertiaryFixed,
                  child: Icon(
                    Icons.nights_stay_outlined,
                    color: AuraColors.tertiary,
                  ),
                ),
                title: const Text('Derin Gece Uykusuna Geçiş'),
                subtitle: const Text(
                  'Gece Yağmuru, Kahverengi Gürültü & Masal',
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const SleepPortalScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    const filters = ['Tümü', 'Nefes', 'Frekans', 'Beden', 'Uyku'];

    final allCards = <_PortalCardSpec>[
      _PortalCardSpec(
        categoryKey: 'Nefes',
        badge: '12 SEANS',
        title: 'Nefes\nEgzersizleri',
        subtitle: '4-1-4 & 4-7-8 Solunum',
        imageAsset: 'assets/images/backgrounds/breathwork_bg.jpg',
        icon: Icons.air_rounded,
        accentColor: const Color(0xFF4F5D95),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const BreathworkScreen()),
        ),
      ),
      _PortalCardSpec(
        categoryKey: 'Frekans',
        badge: '20 REZONANS',
        title: 'Hz\nFrekansları',
        subtitle: 'Solfeggio & Melek Tonları',
        imageAsset: 'assets/images/backgrounds/hz_styles_sheet.jpg',
        icon: Icons.graphic_eq_rounded,
        accentColor: AuraColors.primary,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const FrequenciesScreen()),
        ),
      ),
      _PortalCardSpec(
        categoryKey: 'Beden',
        badge: '8 POZ AKIŞI',
        title: 'Beden\nEgzersizleri',
        subtitle: 'Yoga & Sasangasana Sayaç',
        imageAsset: 'assets/images/backgrounds/body_portal_bg.jpg',
        icon: Icons.self_improvement_rounded,
        accentColor: AuraColors.tertiary,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const BodyExercisesScreen()),
        ),
      ),
      _PortalCardSpec(
        categoryKey: 'Uyku',
        badge: 'GECE TAPINAĞI',
        title: 'Uyku &\nMasallar',
        subtitle: 'Doğa, Gürültü & Hikaye',
        imageAsset: 'assets/images/backgrounds/sleep_portal_bg.jpg',
        icon: Icons.dark_mode_outlined,
        accentColor: const Color(0xFF283556),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const SleepPortalScreen()),
        ),
      ),
    ];

    final visibleCards = _selectedFilter == 'Tümü'
        ? allCards
        : allCards.where((c) => c.categoryKey == _selectedFilter).toList();

    return AuraBackground(
      imageAsset: 'assets/images/backgrounds/meditation_portal_bg.jpg',
      overlayOpacity: 0.80,
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 140),
          children: [
            // Top bar matching Stitch
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => scope.onSwitchTab(2),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: AuraColors.primaryFixed,
                        child: Text(
                          scope.localStore.profile.displayName.characters.first,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AuraColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Meditasyon',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: AuraColors.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      tooltip: 'Akış Rehberi & Filtre',
                      onPressed: () =>
                          _showQuickRecommendationSheet(context, scope),
                      icon: const Icon(
                        Icons.tune_rounded,
                        color: AuraColors.primary,
                      ),
                    ),
                    if (widget.onOpenNotifications != null)
                      IconButton(
                        tooltip: 'Bildirimler',
                        onPressed: widget.onOpenNotifications,
                        icon: const Icon(
                          Icons.notifications_none_rounded,
                          color: AuraColors.primary,
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Editorial Title Section
            const Text(
              'NEFES, FREKANS, EGZERSİZ VE UYKU',
              style: TextStyle(
                fontFamily: 'Segoe UI',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.8,
                color: AuraColors.primary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Derin Huzur Alanı',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w400,
                letterSpacing: -0.5,
                color: AuraColors.onSurface,
              ),
            ),
            const SizedBox(height: 16),

            // Filter Pills
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final f in filters)
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: ChoiceChip(
                        label: Text(f),
                        selected: _selectedFilter == f,
                        selectedColor: AuraColors.primary,
                        backgroundColor: Colors.white.withValues(alpha: 0.72),
                        side: BorderSide.none,
                        labelStyle: TextStyle(
                          fontFamily: 'Segoe UI',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _selectedFilter == f
                              ? Colors.white
                              : AuraColors.onSurfaceVariant,
                        ),
                        onSelected: (_) => setState(() => _selectedFilter = f),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 2x2 Bento Grid of Portal Categories
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: visibleCards.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.78,
              ),
              itemBuilder: (context, index) {
                final card = visibleCards[index];
                return _PortalCategoryTile(spec: card);
              },
            ),
            const SizedBox(height: 22),

            // Recommended 528 Hz Ritual Card (`Önerilen Ritüel • 528 Hz DNA Onarımı & Sevgi`)
            ListenableBuilder(
              listenable: scope.audio,
              builder: (context, _) {
                final idx528 = SeedCatalog.frequencies.indexWhere(
                  (f) => f.id == 'hz_528',
                );
                final safeIdx = idx528 < 0 ? 0 : idx528;
                final hz528 = SeedCatalog.frequencies[safeIdx];
                final isPlaying528 =
                    scope.audio.currentTrack.id == hz528.id &&
                    scope.audio.isPlaying;

                return AuraGlassCard(
                  padding: const EdgeInsets.all(20),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            FrequencyPlayerScreen(initialIndex: safeIdx),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              AuraColors.primary,
                              AuraColors.primaryContainer,
                            ],
                          ),
                        ),
                        child: const Icon(
                          Icons.auto_awesome_rounded,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ÖNERİLEN RİTÜEL',
                              style: TextStyle(
                                fontFamily: 'Segoe UI',
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.5,
                                color: AuraColors.primary,
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              '528 Hz • DNA Onarımı & Sevgi',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: AuraColors.onSurface,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              '15 dk • Frekans & İçsel Dönüşüm',
                              style: TextStyle(
                                fontFamily: 'Segoe UI',
                                fontSize: 12,
                                color: AuraColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: isPlaying528 ? 'Duraklat' : '528 Hz Başlat',
                        onPressed: () {
                          if (isPlaying528) {
                            scope.audio.pause();
                          } else {
                            scope.audio.playTrack(
                              SeedCatalog.fromFrequency(hz528),
                              playlist: SeedCatalog.frequencies
                                  .map(SeedCatalog.fromFrequency)
                                  .toList(),
                              autoPlay: true,
                            );
                          }
                        },
                        icon: Icon(
                          isPlaying528
                              ? Icons.pause_circle_filled_rounded
                              : Icons.play_circle_fill_rounded,
                          size: 40,
                          color: AuraColors.primary,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PortalCardSpec {
  final String categoryKey;
  final String badge;
  final String title;
  final String subtitle;
  final String imageAsset;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onTap;

  const _PortalCardSpec({
    required this.categoryKey,
    required this.badge,
    required this.title,
    required this.subtitle,
    required this.imageAsset,
    required this.icon,
    required this.accentColor,
    required this.onTap,
  });
}

class _PortalCategoryTile extends StatelessWidget {
  final _PortalCardSpec spec;

  const _PortalCategoryTile({required this.spec});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: spec.onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(spec.imageAsset, fit: BoxFit.cover),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    spec.accentColor.withValues(alpha: 0.35),
                    const Color(0xFF1A1829).withValues(alpha: 0.82),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text(
                          spec.badge,
                          style: const TextStyle(
                            fontFamily: 'Segoe UI',
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.20),
                        ),
                        child: Icon(spec.icon, color: Colors.white, size: 18),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        spec.title,
                        style: const TextStyle(
                          fontSize: 22,
                          height: 1.15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        spec.subtitle,
                        style: TextStyle(
                          fontFamily: 'Segoe UI',
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
