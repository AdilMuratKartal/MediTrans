import 'package:flutter/material.dart';
import '../../core/di/app_scope.dart';
import '../../core/theme/aura_theme.dart';
import 'anonymous_entry_screen.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';

/// Main Authentication Portal (`Giriş Yap`) Screen.
/// Provides Email/Password sign-in, navigation to `RegisterScreen` (Hesap Oluştur),
/// `ForgotPasswordScreen` (Şifremi Unuttum), `AnonymousEntryScreen` (Anonim Giriş Sayfası),
/// and a direct 1-tap "Giriş Yapmadan Direkt Uygulamaya Gir" action.
class LoginScreen extends StatefulWidget {
  final bool isModalRoute;

  const LoginScreen({super.key, this.isModalRoute = false});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailCtrl = TextEditingController(
    text: 'adilmuratkartal@gmail.com',
  );
  final TextEditingController _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;
  String? _statusMessage;
  bool _isError = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _completeEntryIfModal() {
    if (widget.isModalRoute && mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _handleEmailLogin(AppScope scope) async {
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _isError = true;
        _statusMessage = 'Lütfen e-posta adresinizi ve şifrenizi girin.';
      });
      return;
    }

    setState(() {
      _isError = false;
      _statusMessage = 'Firebase sunucusuna bağlanılıyor...';
    });

    final result = await scope.cloudSync.signInWithEmailOrAnonymous(
      email: email,
      password: password,
    );

    if (!mounted) return;

    final failed =
        result.contains('hatalı') ||
        result.contains('Hatası') ||
        result.contains('Geçersiz') ||
        result.contains('doğrulanamadı') ||
        result.contains('en az 6');

    setState(() {
      _isError = failed;
      _statusMessage = result;
    });

    if (!failed && scope.cloudSync.hasEnteredApp) {
      _completeEntryIfModal();
    }
  }

  Future<void> _handleDirectSkipToApp(AppScope scope) async {
    final msg = await scope.cloudSync.enterAppWithoutLogin(
      tryFirebaseAnonymous: false,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
    _completeEntryIfModal();
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);

    return ListenableBuilder(
      listenable: Listenable.merge([scope.cloudSync, scope.localStore]),
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
                        if (widget.isModalRoute)
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

                        // Brand Header
                        const Center(
                          child: Text(
                            'AURA MIND • MEDITRANS',
                            style: TextStyle(
                              fontFamily: 'Segoe UI',
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2.2,
                              color: AuraColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Center(
                          child: Text(
                            'İçsel Huzur Alanına Giriş',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w600,
                              color: AuraColors.onSurface,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Center(
                          child: Text(
                            'Duygu grafiğinizi, haftalık alışkanlıklarınızı ve son dinlediğiniz frekansları bulutla eşitleyin veya giriş yapmadan devam edin.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Segoe UI',
                              fontSize: 13,
                              color: AuraColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Status Banner Card (matches screenshot)
                        AuraGlassCard(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 14,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                scope.cloudSync.isFirebaseReady
                                    ? Icons.cloud_queue_rounded
                                    : Icons.cloud_off_rounded,
                                color: AuraColors.primary,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      scope.cloudSync.authLabel,
                                      style: const TextStyle(
                                        fontSize: 14,
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
                        ),
                        const SizedBox(height: 16),

                        // Main Login Form Card
                        AuraGlassCard(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                'E-posta ile Giriş Yap',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: AuraColors.onSurface,
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: _emailCtrl,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  labelText: 'E-posta Adresi',
                                  prefixIcon: const Icon(
                                    Icons.alternate_email_rounded,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white.withValues(
                                    alpha: 0.72,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              TextField(
                                controller: _passwordCtrl,
                                obscureText: _obscurePassword,
                                onSubmitted: (_) => _handleEmailLogin(scope),
                                decoration: InputDecoration(
                                  labelText: 'Şifre',
                                  prefixIcon: const Icon(
                                    Icons.lock_outline_rounded,
                                  ),
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white.withValues(
                                    alpha: 0.72,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute<void>(
                                        builder: (_) => ForgotPasswordScreen(
                                          initialEmail: _emailCtrl.text.trim(),
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Text('Şifremi Unuttum?'),
                                ),
                              ),

                              if (_statusMessage != null) ...[
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: _isError
                                        ? Colors.red.withValues(alpha: 0.12)
                                        : AuraColors.primaryContainer
                                              .withValues(alpha: 0.55),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Text(
                                    _statusMessage!,
                                    style: TextStyle(
                                      fontFamily: 'Segoe UI',
                                      fontSize: 12.5,
                                      color: _isError
                                          ? Colors.red.shade900
                                          : AuraColors.onSurface,
                                    ),
                                  ),
                                ),
                              ],

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
                                onPressed: isSyncing
                                    ? null
                                    : () => _handleEmailLogin(scope),
                                icon: isSyncing
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.login_rounded),
                                label: Text(
                                  isSyncing ? 'Giriş Yapılıyor...' : 'Giriş Yap',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),

                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(99),
                                  ),
                                ),
                                onPressed: () async {
                                  await Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => const RegisterScreen(),
                                    ),
                                  );
                                  if (scope.cloudSync.hasEnteredApp) {
                                    _completeEntryIfModal();
                                  }
                                },
                                icon: const Icon(Icons.person_add_alt_1_rounded),
                                label: const Text('Yeni Hesap Oluştur'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Anonymous & Direct Skip Card
                        AuraGlassCard(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Row(
                                children: [
                                  Icon(
                                    Icons.explore_outlined,
                                    color: AuraColors.primary,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Hesap Açmadan / Anonim Devam Et',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: AuraColors.onSurface,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'E-posta veya şifre girmeden doğrudan uygulamaya geçebilir ya da anonim oturum seçeneklerini inceleyebilirsiniz.',
                                style: TextStyle(
                                  fontFamily: 'Segoe UI',
                                  fontSize: 12.5,
                                  color: AuraColors.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () async {
                                        await Navigator.of(context).push(
                                          MaterialPageRoute<void>(
                                            builder: (_) =>
                                                const AnonymousEntryScreen(),
                                          ),
                                        );
                                        if (scope.cloudSync.hasEnteredApp) {
                                          _completeEntryIfModal();
                                        }
                                      },
                                      icon: const Icon(
                                        Icons.shield_moon_outlined,
                                        size: 18,
                                      ),
                                      label: const Text('Anonim Sayfası'),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: FilledButton.tonalIcon(
                                      onPressed: () =>
                                          _handleDirectSkipToApp(scope),
                                      icon: const Icon(
                                        Icons.arrow_forward_rounded,
                                        size: 18,
                                      ),
                                      label: const Text('Direkt Uygulamaya Gir'),
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
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

