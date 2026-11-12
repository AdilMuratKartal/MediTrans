import 'package:flutter/material.dart';
import '../../core/di/app_scope.dart';
import '../../core/theme/aura_theme.dart';

/// Dedicated Password Reset Screen (`Şifremi Unuttum`).
class ForgotPasswordScreen extends StatefulWidget {
  final String initialEmail;

  const ForgotPasswordScreen({super.key, this.initialEmail = ''});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  late final TextEditingController _emailCtrl;
  String? _statusMessage;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _emailCtrl = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword(AppScope scope) async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      setState(() {
        _isError = true;
        _statusMessage = 'Lütfen kayıtlı e-posta adresinizi girin.';
      });
      return;
    }

    final result = await scope.cloudSync.sendPasswordReset(email: email);
    if (!mounted) return;

    final failed =
        result.contains('Hatası') ||
        result.contains('bulunamadı') ||
        result.contains('Geçersiz') ||
        result.contains('gönderilemez');

    setState(() {
      _isError = failed;
      _statusMessage = result;
    });
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
                            'ŞİFRE SIFIRLAMA',
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
                            'Şifrenizi mi Unuttunuz?',
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
                            'Kayıtlı e-posta adresinizi girin; Firebase üzerinden şifre sıfırlama bağlantısını hemen gönderelim.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Segoe UI',
                              fontSize: 13,
                              color: AuraColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        AuraGlassCard(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TextField(
                                controller: _emailCtrl,
                                keyboardType: TextInputType.emailAddress,
                                onSubmitted: (_) => _handleResetPassword(scope),
                                decoration: InputDecoration(
                                  labelText: 'E-posta Adresi',
                                  prefixIcon: const Icon(
                                    Icons.mark_email_read_outlined,
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
                              const SizedBox(height: 16),

                              if (_statusMessage != null) ...[
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
                                    : () => _handleResetPassword(scope),
                                icon: const Icon(Icons.send_rounded),
                                label: Text(
                                  isSyncing
                                      ? 'Gönderiliyor...'
                                      : 'Sıfırlama Bağlantısı Gönder',
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Giriş Ekranına Dön'),
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

