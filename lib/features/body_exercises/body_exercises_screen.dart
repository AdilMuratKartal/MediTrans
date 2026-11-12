import 'package:flutter/material.dart';
import '../../core/data/models/yoga_pose_item_model.dart';
import '../../core/data/seed_catalog.dart';
import '../../core/theme/aura_theme.dart';
import 'pose_detail_screen.dart';

/// Body Exercises & Yoga Portal (`beden_egzersizleri_yoga_portal`)
/// Displays 8 sequential yoga poses (`01 Virasana` .. `08 Savasana`), level filter,
/// summary chip (`8 Poz • ~8 Dk Akış`), and `Tüm Seriyi Başlat` CTA.
class BodyExercisesScreen extends StatefulWidget {
  const BodyExercisesScreen({super.key});

  @override
  State<BodyExercisesScreen> createState() => _BodyExercisesScreenState();
}

class _BodyExercisesScreenState extends State<BodyExercisesScreen> {
  String _selectedLevel = 'Tümü';

  List<YogaPoseItem> get _filteredPoses {
    if (_selectedLevel == 'Tümü') return SeedCatalog.yogaPoses;
    return SeedCatalog.yogaPoses
        .where((p) => p.levelBadgeTr == _selectedLevel)
        .toList();
  }

  void _openPoseDetail(YogaPoseItem pose) {
    final fullIndex = SeedCatalog.yogaPoses.indexWhere(
      (element) => element.id == pose.id,
    );
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            PoseDetailScreen(initialPoseIndex: fullIndex < 0 ? 0 : fullIndex),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const levels = ['Tümü', 'Başlangıç', 'Orta Düzey', 'Güç', 'Dinlenme'];
    final poses = _filteredPoses;

    return Scaffold(
      body: AuraBackground(
        imageAsset: 'assets/images/backgrounds/body_portal_bg.jpg',
        overlayOpacity: 0.80,
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
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    ),
                    const Expanded(
                      child: Text(
                        'Beden Egzersizleri',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AuraColors.onSurface,
                        ),
                      ),
                    ),
                    PopupMenuButton<String>(
                      tooltip: 'Seviye Filtresi',
                      icon: const Icon(
                        Icons.filter_list_rounded,
                        color: AuraColors.primary,
                      ),
                      onSelected: (val) => setState(() => _selectedLevel = val),
                      itemBuilder: (ctx) => [
                        for (final lvl in levels)
                          PopupMenuItem(value: lvl, child: Text(lvl)),
                      ],
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(22, 8, 22, 28),
                  children: [
                    // Hero Banner & Start Full Sequence CTA
                    AuraGlassCard(
                      padding: const EdgeInsets.all(22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AuraColors.primaryFixed,
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: const Text(
                              '8 POZ • ~8 DK BÜTÜNSEL AKIŞ',
                              style: TextStyle(
                                fontFamily: 'Segoe UI',
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.4,
                                color: AuraColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Beden ve Zihin Uyum Serisi',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w500,
                              color: AuraColors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Virasana oturuşundan Savasana derin dinlenmesine uzanan 8 aşamalı mindful hareket serisi.',
                            style: TextStyle(
                              fontFamily: 'Segoe UI',
                              fontSize: 13.5,
                              color: AuraColors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              style: FilledButton.styleFrom(
                                backgroundColor: AuraColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(99),
                                ),
                              ),
                              onPressed: () =>
                                  _openPoseDetail(SeedCatalog.yogaPoses.first),
                              icon: const Icon(Icons.play_arrow_rounded),
                              label: const Text(
                                'Tüm Seriyi Başlat (Poz 01 -> 08)',
                                style: TextStyle(
                                  fontFamily: 'Segoe UI',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Level filter chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (final lvl in levels)
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(lvl),
                                selected: _selectedLevel == lvl,
                                selectedColor: AuraColors.primary,
                                backgroundColor: Colors.white.withValues(
                                  alpha: 0.72,
                                ),
                                side: BorderSide.none,
                                labelStyle: TextStyle(
                                  fontFamily: 'Segoe UI',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _selectedLevel == lvl
                                      ? Colors.white
                                      : AuraColors.onSurface,
                                ),
                                onSelected: (_) =>
                                    setState(() => _selectedLevel = lvl),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 8 Yoga Pose Cards
                    for (final pose in poses)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: AuraGlassCard(
                          padding: const EdgeInsets.all(16),
                          onTap: () => _openPoseDetail(pose),
                          child: Row(
                            children: [
                              Hero(
                                tag: 'yoga_pose_${pose.id}',
                                child: Container(
                                  width: 82,
                                  height: 82,
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AuraColors.surfaceContainerLow,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Image.asset(
                                    pose.illustrationAsset,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          '0${pose.orderIndex}',
                                          style: const TextStyle(
                                            fontFamily: 'Segoe UI',
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: AuraColors.primary,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AuraColors.primaryFixed,
                                            borderRadius: BorderRadius.circular(
                                              99,
                                            ),
                                          ),
                                          child: Text(
                                            pose.levelBadgeTr,
                                            style: const TextStyle(
                                              fontFamily: 'Segoe UI',
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              color: AuraColors.primary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${pose.sanskritName} • ${pose.turkishName}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: AuraColors.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      pose.subtitleTr,
                                      style: const TextStyle(
                                        fontFamily: 'Segoe UI',
                                        fontSize: 12,
                                        color: AuraColors.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 38,
                                height: 38,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AuraColors.primaryFixed,
                                ),
                                child: const Icon(
                                  Icons.play_arrow_rounded,
                                  color: AuraColors.primary,
                                ),
                              ),
                            ],
                          ),
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
