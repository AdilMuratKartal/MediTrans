import 'package:flutter/material.dart';
import '../../core/di/app_scope.dart';
import '../../core/theme/aura_theme.dart';

/// Dedicated Account Creation Screen (`Hesap Oluştur`).
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  final TextEditingController _confirmCtrl = TextEditingController();
  bool _obscurePassword = true;
  String? _feedbackMessage;
  bool _isError = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleRegister(AppScope scope) async {
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;
    final confirm = _confirmCtrl.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() {
        _isError = true;
        _feedbackMessage = 'Lütfen ad soyad, e-posta ve şifre alanlarını doldurun.';
      });
      return;
    }

    if (password.length < 6) {
      setState(() {
        _isError = true;
        _feedbackMessage = 'Şifreniz en az 6 karakter olmalıdır.';
      });
      return;
    }

    if (password != confirm) {
      setState(() {
        _isError = true;
        _feedbackMessage = 'Girdiğiniz şifreler birbiriyle eşleşmiyor.';
      });
      return;
    }

    setState(() {
      _isError = false;
      _feedbackMessage = 'Hesabınız oluşturuluyor...';
    });

    final msg = await scope.cloudSync.registerWithEmail(
      displayName: name,
      email: email,
      password: password,
    );

    if (!mounted) return;

    final failed =
        msg.contains('Hatası') ||
        msg.contains('zaten kayıtlı') ||
        msg.contains('Geçersiz') ||
        msg.contains('en az 6');

    setState(() {
      _isError = failed;
      _feedbackMessage = msg;
    });

    if (!failed && scope.cloudSync.hasEnteredApp) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
      );
      Navigator.of(context).pop();
    }
  }

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
                            'YENİ HESAP OLUŞTUR',
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
                            'Aura Mind Yolculuğuna Başla',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w600,
                              color: AuraColors.onSurface,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        AuraGlassCard(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TextField(
                                controller: _nameCtrl,
                                decoration: InputDecoration(
                                  labelText: 'Ad Soyad',
                                  prefixIcon: const Icon(
                                    Icons.person_outline_rounded,
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
                                decoration: InputDecoration(
                                  labelText: 'Şifre (En az 6 karakter)',
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
                              const SizedBox(height: 14),
                              TextField(
                                controller: _confirmCtrl,
                                obscureText: _obscurePassword,
                                onSubmitted: (_) => _handleRegister(scope),
                                decoration: InputDecoration(
                                  labelText: 'Şifre Tekrar',
                                  prefixIcon: const Icon(
                                    Icons.verified_user_outlined,
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
                              const SizedBox(height: 18),

                              if (_feedbackMessage != null) ...[
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  margin: const EdgeInsets.only(bottom: 14),
                                  decoration: BoxDecoration(
                                    color: _isError
                                        ? Colors.red.withValues(alpha: 0.12)
                                        : AuraColors.primaryContainer
                                              .withValues(alpha: 0.55),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Text(
                                    _feedbackMessage!,
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
                                    : () => _handleRegister(scope),
                                icon: isSyncing
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.check_circle_outline),
                                label: Text(
                                  isSyncing
                                      ? 'Oluşturuluyor...'
                                      : 'Hesap Oluştur ve Başla',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text(
                                  'Zaten hesabınız var mı? Giriş Yapın',
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

