import 'package:flutter/material.dart';
import '../../core/audio/universal_player_bar.dart';
import '../../core/data/seed_catalog.dart';
import '../../core/di/app_scope.dart';
import '../../core/theme/aura_theme.dart';
import '../frequencies/frequency_player_screen.dart';

/// Home Mood Sanctuary (`ana_sayfa_duygu_durumu`)
/// Strictly aligned with Stitch design: NO mascot, weekly calendar strip (`P S Ç P C C P`),
/// emoji mood chips + `Duygu Ekle` modal bottom sheet, reflection note, and
/// `Frekansa devam et` audio player card.
class HomeMoodScreen extends StatefulWidget {
  final VoidCallback onOpenNotifications;

  const HomeMoodScreen({super.key, required this.onOpenNotifications});

  @override
  State<HomeMoodScreen> createState() => _HomeMoodScreenState();
}

class _HomeMoodScreenState extends State<HomeMoodScreen> {
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _openAddMoodBottomSheet(BuildContext context, AppScope scope) {
    final entry = scope.localStore.getMoodForDate(_selectedDate);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AuraColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AuraColors.outlineVariant,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Yeni Duygu Ekle',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: AuraColors.onSurface,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(sheetContext).pop(),
                    icon: const Icon(Icons.close, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Şu anki içsel frekansını en iyi yansıtan duyguyu seç:',
                style: TextStyle(
                  fontFamily: 'Segoe UI',
                  fontSize: 13.5,
                  color: AuraColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final option in SeedCatalog.moodCatalog)
                    InkWell(
                      borderRadius: BorderRadius.circular(999),
                      onTap: () async {
                        await scope.localStore.addMoodTagForDate(
                          _selectedDate,
                          option.code,
                        );
                        if (sheetContext.mounted) {
                          Navigator.of(sheetContext).pop();
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: entry.moodCodes.contains(option.code)
                              ? AuraColors.primaryFixed
                              : AuraColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              option.emoji,
                              style: const TextStyle(fontSize: 18),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              option.label,
                              style: const TextStyle(
                                fontFamily: 'Segoe UI',
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: AuraColors.onSurface,
                              ),
                            ),
                          ],
                        ),
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

  Future<void> _submitNote(AppScope scope) async {
    final trimmed = _noteController.text.trim();
    if (trimmed.isEmpty) return;
    await scope.localStore.saveReflectionNoteForDate(_selectedDate, trimmed);
    _noteController.clear();
    if (!mounted) return;
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Duygu notunuz kaydedildi ✨'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    const dayLetters = ['P', 'S', 'Ç', 'P', 'C', 'C', 'P'];
    const monthNames = [
      '',
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık',
    ];

    return ListenableBuilder(
      listenable: Listenable.merge([
        scope.localStore,
        scope.audio,
        scope.notifications,
      ]),
      builder: (context, _) {
        final selectedEntry = scope.localStore.getMoodForDate(_selectedDate);
        final unreadCount = scope.notifications.unreadCount;

        return AuraBackground(
          imageAsset: 'assets/images/backgrounds/home_bg.jpg',
          overlayOpacity: 0.78,
          child: SafeArea(
            bottom: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 140),
              children: [
                // Top Header Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.78),
                          ),
                          child: const Icon(
                            Icons.spa_outlined,
                            color: AuraColors.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Aura Mind',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                            color: AuraColors.primary,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          tooltip: 'Bildirimler & Hatırlatıcılar',
                          onPressed: widget.onOpenNotifications,
                          icon: Badge(
                            isLabelVisible: unreadCount > 0,
                            label: Text('$unreadCount'),
                            child: const Icon(
                              Icons.notifications_none_rounded,
                              color: AuraColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () => scope.onSwitchTab(2),
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: AuraColors.primaryFixed,
                            child: Text(
                              scope
                                  .localStore
                                  .profile
                                  .displayName
                                  .characters
                                  .first
                                  .toUpperCase(),
                              style: const TextStyle(
                                fontFamily: 'Segoe UI',
                                fontWeight: FontWeight.w700,
                                color: AuraColors.primary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Weekly Rhythm Strip (`Haftalık Ritim • P S Ç P C C P`)
                AuraGlassCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'HAFTALIK RİTİM',
                            style: TextStyle(
                              fontFamily: 'Segoe UI',
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.6,
                              color: AuraColors.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            '${monthNames[_selectedDate.month]} ${_selectedDate.year}',
                            style: const TextStyle(
                              fontFamily: 'Segoe UI',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AuraColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(7, (idx) {
                          final dayDate = monday.add(Duration(days: idx));
                          final isSelected =
                              dayDate.year == _selectedDate.year &&
                              dayDate.month == _selectedDate.month &&
                              dayDate.day == _selectedDate.day;
                          final dayMood = scope.localStore.getMoodForDate(
                            dayDate,
                          );
                          final topEmoji = SeedCatalog.findMood(
                            dayMood.moodCodes.first,
                          ).emoji;

                          return GestureDetector(
                            onTap: () =>
                                setState(() => _selectedDate = dayDate),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AuraColors.primary
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: AuraColors.primary.withValues(
                                            alpha: 0.25,
                                          ),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    dayLetters[idx],
                                    style: TextStyle(
                                      fontFamily: 'Segoe UI',
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? Colors.white.withValues(alpha: 0.85)
                                          : AuraColors.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${dayDate.day}',
                                    style: TextStyle(
                                      fontFamily: 'Segoe UI',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: isSelected
                                          ? Colors.white
                                          : AuraColors.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    topEmoji,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Mood Check-In Card (`Bugün nasıl hissediyorsun?`)
                AuraGlassCard(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'BUGÜN NASIL HİSSEDİYORSUN?',
                        style: TextStyle(
                          fontFamily: 'Segoe UI',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.6,
                          color: AuraColors.primary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'İçsel Frekansını Kaydet',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w500,
                          color: AuraColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Emoji Mood Chips + `Duygu Ekle` Pill
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          for (final code in selectedEntry.moodCodes)
                            Builder(
                              builder: (context) {
                                final mood = SeedCatalog.findMood(code);
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.85),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        mood.emoji,
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        mood.label,
                                        style: const TextStyle(
                                          fontFamily: 'Segoe UI',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AuraColors.onSurface,
                                        ),
                                      ),
                                      if (selectedEntry.moodCodes.length >
                                          1) ...[
                                        const SizedBox(width: 6),
                                        GestureDetector(
                                          onTap: () => scope.localStore
                                              .removeMoodTagForDate(
                                                _selectedDate,
                                                code,
                                              ),
                                          child: const Icon(
                                            Icons.close_rounded,
                                            size: 16,
                                            color: AuraColors.outline,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                );
                              },
                            ),
                          InkWell(
                            borderRadius: BorderRadius.circular(999),
                            onTap: () =>
                                _openAddMoodBottomSheet(context, scope),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: AuraColors.primaryFixed.withValues(
                                  alpha: 0.75,
                                ),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.add_circle_outline_rounded,
                                    size: 18,
                                    color: AuraColors.primary,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'Duygu Ekle',
                                    style: TextStyle(
                                      fontFamily: 'Segoe UI',
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w700,
                                      color: AuraColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Quick Reflection Note Input (`+ Eklemek istediklerim...`)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.72),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.edit_note_rounded,
                              color: AuraColors.primary,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: _noteController,
                                onSubmitted: (_) => _submitNote(scope),
                                decoration: const InputDecoration(
                                  hintText: '+ Eklemek istediklerim...',
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                                style: const TextStyle(
                                  fontFamily: 'Segoe UI',
                                  fontSize: 14,
                                  color: AuraColors.onSurface,
                                ),
                              ),
                            ),
                            IconButton(
                              tooltip: 'Notu Kaydet',
                              onPressed: () => _submitNote(scope),
                              icon: const Icon(
                                Icons.arrow_forward_rounded,
                                color: AuraColors.primary,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (selectedEntry.reflectionNote != null &&
                          selectedEntry.reflectionNote!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: AuraColors.primaryFixed.withValues(
                              alpha: 0.45,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.auto_awesome_rounded,
                                size: 16,
                                color: AuraColors.primary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  selectedEntry.reflectionNote!,
                                  style: const TextStyle(
                                    fontFamily: 'Segoe UI',
                                    fontSize: 13,
                                    color: AuraColors.onSurface,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // `Frekansa devam et` Section Header + Universal Player Card
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'FREKANSA DEVAM ET',
                      style: TextStyle(
                        fontFamily: 'Segoe UI',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.6,
                        color: AuraColors.primary,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        final activeIdx = SeedCatalog.frequencies.indexWhere(
                          (f) => f.id == scope.audio.currentTrack.id,
                        );
                        final fallbackIdx = SeedCatalog.frequencies.indexWhere(
                          (f) => f.id == 'hz_432',
                        );
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => FrequencyPlayerScreen(
                              initialIndex: activeIdx < 0
                                  ? (fallbackIdx < 0 ? 0 : fallbackIdx)
                                  : activeIdx,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.open_in_new_rounded, size: 16),
                      label: const Text('Tam Oynatıcı'),
                    ),
                  ],
                ),
                UniversalPlayerBar(
                  audio: scope.audio,
                  localStore: scope.localStore,
                  onOpenFullScreen: () {
                    final activeIdx = SeedCatalog.frequencies.indexWhere(
                      (f) => f.id == scope.audio.currentTrack.id,
                    );
                    final fallbackIdx = SeedCatalog.frequencies.indexWhere(
                      (f) => f.id == 'hz_432',
                    );
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => FrequencyPlayerScreen(
                          initialIndex: activeIdx < 0
                              ? (fallbackIdx < 0 ? 0 : fallbackIdx)
                              : activeIdx,
                          startFullScreenResonance: true,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
