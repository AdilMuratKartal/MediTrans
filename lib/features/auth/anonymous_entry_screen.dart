import 'package:flutter/material.dart';
import '../../core/di/app_scope.dart';
import '../../core/theme/aura_theme.dart';

/// Dedicated Anonymous & Direct Local Entry Screen (`Anonim / Girişsiz Giriş Sayfası`).
/// Allows the user to either:
/// 1. Enter directly without any login (`Direkt Uygulamaya Gir — Yerel Depo`), or
/// 2. Start a Firebase Anonymous Cloud session (`Firebase Anonim Bulut Oturumu`).
class AnonymousEntryScreen extends StatelessWidget {
  const AnonymousEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);

    return ListenableBuilder(
      listenable: scope.cloudSync,
      builder: (context, _) {
        final isSyncing = scope.cloudSync.isSyncing;

        return Scaffold(
          body: AuraBackground(
            imageAsset: 'assets/images/backgrounds/meditation_portal_bg.jpg',
            overlayOpacity: 0.85,
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 460),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: AuraColors.onSurface,
                            ),
                          ),
                        ),
                        const Center(
                          child: Text(
                            'ANONİM & GİRİŞSİZ ERİŞİM',
                            style: TextStyle(
                              fontFamily: 'Segoe UI',
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2.0,
                              color: AuraColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Center(
                          child: Text(
                            'Giriş Yapmadan Uygulamaya Gir',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w600,
                              color: AuraColors.onSurface,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Center(
                          child: Text(
                            'E-posta veya parola paylaşmadan tüm nefes egzersizlerine, Hz frekanslarına, uyku hikayelerine ve duygu grafiğine anında erişebilirsiniz.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Segoe UI',
                              fontSize: 13,
                              color: AuraColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Option 1: Direct Local / Offline Entry without login
                        AuraGlassCard(
                          padding: const EdgeInsets.all(22),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Row(
                                children: [
                                  Icon(
                                    Icons.rocket_launch_rounded,
                                    color: AuraColors.primary,
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Giriş Yapmadan Direkt Başla',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: AuraColors.onSurface,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Hiçbir hesap açmadan doğrudan uygulamaya girer. Verileriniz cihazınızın yerel veritabanında (Drift SQLite & SharedPreferences) güvenle saklanır.',
                                style: TextStyle(
                                  fontFamily: 'Segoe UI',
                                  fontSize: 12.5,
                                  color: AuraColors.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 16),
                              FilledButton.icon(
                                style: FilledButton.styleFrom(
                                  backgroundColor: AuraColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 15,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(99),
                                  ),
                                ),
                                onPressed: () async {
                                  final msg = await scope.cloudSync
                                      .enterAppWithoutLogin(
                                        tryFirebaseAnonymous: false,
                                      );
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(msg),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                    Navigator.of(context).pop();
                                  }
                                },
                                icon: const Icon(Icons.arrow_forward_rounded),
                                label: const Text(
                                  'Giriş Yapmadan Direkt Uygulamaya Gir',
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Option 2: Firebase Anonymous Auth Session
                        AuraGlassCard(
                          padding: const EdgeInsets.all(22),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Row(
                                children: [
                                  Icon(
                                    Icons.shield_moon_outlined,
                                    color: AuraColors.primary,
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Firebase Anonim Bulut Oturumu',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: AuraColors.onSurface,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Kişisel bilgi vermeden Firebase üzerinde geçici bir anonim kimlik (UID) oluşturur ve verilerinizi Firestore koleksiyonlarıyla eşitler.',
                                style: TextStyle(
                                  fontFamily: 'Segoe UI',
                                  fontSize: 12.5,
                                  color: AuraColors.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 16),
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(99),
                                  ),
                                ),
                                onPressed: isSyncing
                                    ? null
                                    : () async {
                                        final msg = await scope.cloudSync
                                            .enterAppWithoutLogin(
                                              tryFirebaseAnonymous: true,
                                            );
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(msg),
                                              behavior:
                                                  SnackBarBehavior.floating,
                                            ),
                                          );
                                          Navigator.of(context).pop();
                                        }
                                      },
                                icon: const Icon(Icons.bolt_rounded),
                                label: Text(
                                  isSyncing
                                      ? 'Anonim Oturum Açılıyor...'
                                      : 'Firebase Anonim Oturum ile Gir',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

