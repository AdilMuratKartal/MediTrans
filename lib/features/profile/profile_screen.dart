import 'package:flutter/material.dart';
import '../../core/data/models.dart';
import '../../core/data/seed_catalog.dart';
import '../../core/di/app_scope.dart';
import '../../core/theme/aura_theme.dart';

/// Profile & Weekly Emotion Analysis Screen (`profil_ve_duygu_analizi`)
/// Includes Vitals (`Yaş`, `Kilo`), Edit Profile sheet, Habits & Routines editor,
/// Smooth Cubic Spline Weekly Emotion Chart (`Haftalık Analiz — Duygu Grafiği`),
/// Settings/Cache/Reminders sheet, and Firebase Auth Sign In / Sign Out.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final Set<String> _completedTodayHabits = {'Sabah Nefesi'};

  void _showEditProfileSheet(BuildContext context, AppScope scope) {
    final profile = scope.localStore.profile;
    final nameCtrl = TextEditingController(text: profile.displayName);
    final levelCtrl = TextEditingController(text: profile.levelTitleTr);
    final ageCtrl = TextEditingController(text: '${profile.ageYears}');
    final weightCtrl = TextEditingController(
      text: profile.weightKg.toStringAsFixed(0),
    );

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AuraColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            20,
            24,
            MediaQuery.of(ctx).viewInsets.bottom + 28,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Profili Düzenle',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: AuraColors.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Ad Soyad',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: levelCtrl,
                decoration: const InputDecoration(
                  labelText: 'Unvan / Farkındalık Seviyesi',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: ageCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Yaş (yıl)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: weightCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Kilo (kg)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AuraColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () async {
                    final newName = nameCtrl.text.trim().isEmpty
                        ? profile.displayName
                        : nameCtrl.text.trim();
                    final newAge =
                        int.tryParse(ageCtrl.text.trim()) ?? profile.ageYears;
                    final newWeight =
                        double.tryParse(weightCtrl.text.trim()) ??
                        profile.weightKg;
                    await scope.localStore.updateProfile(
                      profile.copyWith(
                        displayName: newName,
                        levelTitleTr: levelCtrl.text.trim().isEmpty
                            ? profile.levelTitleTr
                            : levelCtrl.text.trim(),
                        ageYears: newAge,
                        weightKg: newWeight,
                      ),
                    );
                    if (ctx.mounted) Navigator.of(ctx).pop();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Profil bilgileri güncellendi ✨'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  child: const Text('Değişiklikleri Kaydet'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddHabitDialog(BuildContext context, AppScope scope) {
    final habitCtrl = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Yeni Alışkanlık & Rutin Ekle'),
          content: TextField(
            controller: habitCtrl,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Örn: Akşam Şükür Günlüğü',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('İptal'),
            ),
            FilledButton(
              onPressed: () async {
                final text = habitCtrl.text.trim();
                if (text.isNotEmpty) {
                  final current = List<String>.from(
                    scope.localStore.profile.habitsTr,
                  );
                  if (!current.contains(text)) {
                    current.add(text);
                    await scope.localStore.updateProfile(
                      scope.localStore.profile.copyWith(habitsTr: current),
                    );
                  }
                }
                if (ctx.mounted) Navigator.of(ctx).pop();
              },
              child: const Text('Ekle'),
            ),
          ],
        );
      },
    );
  }

  void _showAuthSheet(BuildContext context, AppScope scope) {
    final emailCtrl = TextEditingController(
      text: scope.localStore.profile.email ?? 'adil.murat@meditrans.app',
    );
    final passCtrl = TextEditingController(text: 'MediTrans2026!');

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AuraColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            20,
            24,
            MediaQuery.of(ctx).viewInsets.bottom + 28,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Firebase Hesap & Bulut Eşitleme',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: AuraColors.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Ücretsiz Firebase Spark katmanı ile duygu kayıtlarınızı ve alışkanlıklarınızı eşitleyin.',
                style: TextStyle(
                  fontFamily: 'Segoe UI',
                  fontSize: 13,
                  color: AuraColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: emailCtrl,
                decoration: const InputDecoration(
                  labelText: 'E-posta Adresi',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Parola',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final msg = await scope.cloudSync
                            .signInWithEmailOrAnonymous();
                        if (ctx.mounted) Navigator.of(ctx).pop();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(msg),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.bolt_rounded),
                      label: const Text('Anonim Bağlan'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: AuraColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        final msg = await scope.cloudSync
                            .signInWithEmailOrAnonymous(
                              email: emailCtrl.text,
                              password: passCtrl.text,
                            );
                        if (ctx.mounted) Navigator.of(ctx).pop();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(msg),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.login_rounded),
                      label: const Text('Giriş Yap'),
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

  void _showSystemSettingsSheet(BuildContext context, AppScope scope) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AuraColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return ListenableBuilder(
          listenable: Listenable.merge([
            scope.mediaGateway,
            scope.notifications,
            scope.localStore,
          ]),
          builder: (context, _) {
            final cacheKb = (scope.mediaGateway.cachedBytes / 1024)
                .toStringAsFixed(1);
            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sistem, Bildirim & Depolama Ayarları',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AuraColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 14),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Günlük Farkındalık Hatırlatıcısı'),
                    subtitle: Text(
                      'Her akşam ${scope.notifications.reminderTime} (${scope.notifications.fcmTokenStatus})',
                    ),
                    value: scope.notifications.dailyReminderEnabled,
                    onChanged: (val) {
                      scope.notifications.updateSchedule(
                        enabled: val,
                        timeHm: scope.notifications.reminderTime,
                      );
                    },
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Yoga & Nefes Çan Sesi'),
                    subtitle: const Text(
                      'Sayaç tamamlandığında 528 Hz kristal çan sesi çal',
                    ),
                    value: scope.localStore.yogaBellEnabled,
                    onChanged: (val) =>
                        scope.localStore.setYogaBellEnabled(val),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.storage_rounded,
                      color: AuraColors.primary,
                    ),
                    title: const Text('Yerel & Bulut Medya Önbelleği'),
                    subtitle: Text(
                      scope.mediaGateway.isSupabaseReady
                          ? 'Supabase Storage Bağlı • Önbellek: $cacheKb KB'
                          : 'Yerel Asset Modu Aktif • Önbellek: $cacheKb KB',
                    ),
                    trailing: TextButton(
                      onPressed: () async {
                        await scope.mediaGateway.clearAllCachedMedia();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Medya önbelleği temizlendi.'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      child: const Text('Temizle'),
                    ),
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
    final scope = AppScope.of(context);

    return ListenableBuilder(
      listenable: Listenable.merge([
        scope.localStore,
        scope.cloudSync,
        scope.notifications,
      ]),
      builder: (context, _) {
        final profile = scope.localStore.profile;
        final weekMoods = scope.localStore.getCurrentWeekMoods();
        const dayShortLabels = ['P', 'S', 'Ç', 'P', 'C', 'C', 'P'];

        return AuraBackground(
          imageAsset: 'assets/images/backgrounds/profile_bg.jpg',
          overlayOpacity: 0.82,
          child: SafeArea(
            bottom: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 140),
              children: [
                // Top Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Profil & Analiz',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: AuraColors.onSurface,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Ayarlar & Önbellek',
                      onPressed: () => _showSystemSettingsSheet(context, scope),
                      icon: const Icon(
                        Icons.settings_outlined,
                        color: AuraColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Identity Header Card (`Adil Murat`, `Mindful Gezgin • Seviye 3`, `Profili Düzenle`)
                AuraGlassCard(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 68,
                            height: 68,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  AuraColors.primary,
                                  AuraColors.primaryContainer,
                                ],
                              ),
                            ),
                            child: Text(
                              profile.displayName.characters.first
                                  .toUpperCase(),
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  profile.displayName,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                    color: AuraColors.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  profile.levelTitleTr,
                                  style: const TextStyle(
                                    fontFamily: 'Segoe UI',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AuraColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          FilledButton.tonalIcon(
                            style: FilledButton.styleFrom(
                              backgroundColor: AuraColors.primaryFixed,
                              foregroundColor: AuraColors.primary,
                            ),
                            onPressed: () =>
                                _showEditProfileSheet(context, scope),
                            icon: const Icon(Icons.edit_outlined, size: 16),
                            label: const Text(
                              'Profili Düzenle',
                              style: TextStyle(
                                fontFamily: 'Segoe UI',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Vitals Grid (`Yaş: 28 yıl`, `Kilo: 74 kg`)
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AuraColors.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'YAŞ',
                                    style: TextStyle(
                                      fontFamily: 'Segoe UI',
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.4,
                                      color: AuraColors.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${profile.ageYears} yıl',
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w600,
                                      color: AuraColors.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AuraColors.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'KİLO',
                                    style: TextStyle(
                                      fontFamily: 'Segoe UI',
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.4,
                                      color: AuraColors.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${profile.weightKg.toStringAsFixed(0)} kg',
                                    style: const TextStyle(
                                      fontSize: 22,
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
                ),
                const SizedBox(height: 18),

                // Habits & Routines (`Alışkanlıklar & Rutinler`)
                AuraGlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Alışkanlıklar & Rutinler',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AuraColors.onSurface,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () =>
                                _showAddHabitDialog(context, scope),
                            icon: const Icon(Icons.add_rounded, size: 18),
                            label: const Text('Ekle'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          for (final habit in profile.habitsTr)
                            FilterChip(
                              label: Text(habit),
                              selected: _completedTodayHabits.contains(habit),
                              selectedColor: AuraColors.primaryFixed,
                              checkmarkColor: AuraColors.primary,
                              backgroundColor: AuraColors.surfaceContainerLow,
                              side: BorderSide.none,
                              labelStyle: TextStyle(
                                fontFamily: 'Segoe UI',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _completedTodayHabits.contains(habit)
                                    ? AuraColors.primary
                                    : AuraColors.onSurface,
                              ),
                              onSelected: (val) {
                                setState(() {
                                  if (val) {
                                    _completedTodayHabits.add(habit);
                                  } else {
                                    _completedTodayHabits.remove(habit);
                                  }
                                });
                              },
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Weekly Emotion Analysis (`Haftalık Analiz — Duygu Grafiği`)
                AuraGlassCard(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'HAFTALIK ANALİZ',
                                style: TextStyle(
                                  fontFamily: 'Segoe UI',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.6,
                                  color: AuraColors.primary,
                                ),
                              ),
                              SizedBox(height: 3),
                              Text(
                                'Duygu Grafiği',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                  color: AuraColors.onSurface,
                                ),
                              ),
                            ],
                          ),
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
                              'Son 7 Gün',
                              style: TextStyle(
                                fontFamily: 'Segoe UI',
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AuraColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        height: 150,
                        width: double.infinity,
                        child: CustomPaint(
                          painter: _WeeklyMoodSplinePainter(entries: weekMoods),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          for (var i = 0; i < weekMoods.length; i++)
                            Column(
                              children: [
                                Text(
                                  SeedCatalog.findMood(
                                    weekMoods[i].moodCodes.first,
                                  ).emoji,
                                  style: const TextStyle(fontSize: 18),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  dayShortLabels[i],
                                  style: const TextStyle(
                                    fontFamily: 'Segoe UI',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AuraColors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Cloud Sync & Account Management Card (`Giriş Yap / Çıkış Yap`)
                AuraGlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            scope.cloudSync.isSignedIn
                                ? Icons.cloud_done_outlined
                                : Icons.cloud_queue_rounded,
                            color: AuraColors.primary,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  scope.cloudSync.authLabel,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AuraColors.onSurface,
                                  ),
                                ),
                                Text(
                                  'Bekleyen senkron kaydı: ${scope.localStore.outbox.length} • Tamamlanan seans: ${scope.localStore.sessions.length}',
                                  style: const TextStyle(
                                    fontFamily: 'Segoe UI',
                                    fontSize: 12,
                                    color: AuraColors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                final msg = await scope.cloudSync
                                    .flushOutboxToFirestore();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(msg),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(Icons.sync_rounded, size: 18),
                              label: const Text('Şimdi Senkronize Et'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: FilledButton.icon(
                              style: FilledButton.styleFrom(
                                backgroundColor: scope.cloudSync.isSignedIn
                                    ? AuraColors.tertiary
                                    : AuraColors.primary,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () async {
                                if (scope.cloudSync.isSignedIn) {
                                  await scope.cloudSync.signOut();
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Oturum kapatıldı. Yerel mod aktif.',
                                        ),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  }
                                } else {
                                  _showAuthSheet(context, scope);
                                }
                              },
                              icon: Icon(
                                scope.cloudSync.isSignedIn
                                    ? Icons.logout_rounded
                                    : Icons.login_rounded,
                                size: 18,
                              ),
                              label: Text(
                                scope.cloudSync.isSignedIn
                                    ? 'Çıkış Yap'
                                    : 'Giriş Yap',
                              ),
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
      },
    );
  }
}

class _WeeklyMoodSplinePainter extends CustomPainter {
  final List<MoodEntry> entries;

  const _WeeklyMoodSplinePainter({required this.entries});

  @override
  void paint(Canvas canvas, Size size) {
    if (entries.isEmpty) return;

    final gridPaint = Paint()
      ..color = AuraColors.outlineVariant.withValues(alpha: 0.35)
      ..strokeWidth = 1;

    for (var i = 1; i <= 3; i++) {
      final y = size.height * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final points = <Offset>[];
    final stepX = entries.length > 1
        ? size.width / (entries.length - 1)
        : size.width;
    for (var i = 0; i < entries.length; i++) {
      final normalized = ((entries[i].averageScore - 1) / 4.0).clamp(0.0, 1.0);
      final x = i * stepX;
      final y = size.height - (normalized * (size.height - 28)) - 14;
      points.add(Offset(x, y));
    }

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final midX = (p0.dx + p1.dx) / 2;
      path.cubicTo(midX, p0.dy, midX, p1.dy, p1.dx, p1.dy);
    }

    final fillPath = Path.from(path)
      ..lineTo(points.last.dx, size.height)
      ..lineTo(points.first.dx, size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AuraColors.primary.withValues(alpha: 0.28),
          AuraColors.primary.withValues(alpha: 0.02),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final strokePaint = Paint()
      ..color = AuraColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, strokePaint);

    final dotFill = Paint()..color = AuraColors.primary;
    final dotHalo = Paint()..color = Colors.white;
    for (final pt in points) {
      canvas.drawCircle(pt, 6, dotHalo);
      canvas.drawCircle(pt, 4, dotFill);
    }
  }

  @override
  bool shouldRepaint(covariant _WeeklyMoodSplinePainter oldDelegate) => true;
}
