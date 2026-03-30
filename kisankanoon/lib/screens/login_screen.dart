import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  String? _errorMsg;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _errorMsg = null; });

    final error = await AuthService.loginWithEmail(
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (error != null) {
      setState(() => _errorMsg = error);
    } else {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  void _showForgotPassword() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('पासवर्ड भूल गए?', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('अपना ईमेल डालें — हम आपको रीसेट लिंक भेजेंगे।',
                style: TextStyle(fontSize: 13, color: AppTheme.textMid)),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: 'ईमेल पता',
                prefixIcon: Icon(Icons.email_outlined, color: AppTheme.primaryGreen),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('रद्द करें')),
          ElevatedButton(
            onPressed: () async {
              final email = ctrl.text.trim();
              if (email.isEmpty) return;
              Navigator.pop(ctx);
              final err = await AuthService.sendPasswordReset(email);
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(err ?? '✅ रीसेट लिंक आपके ईमेल पर भेज दिया गया!'),
                backgroundColor: err != null ? Colors.red : AppTheme.primaryGreen,
              ));
            },
            child: const Text('भेजें'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),
              // Logo
              Center(
                child: Container(
                  width: 88, height: 88,
                  decoration: BoxDecoration(
                    color: AppTheme.bgGreen,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Center(child: Text('⚖️', style: TextStyle(fontSize: 44))),
                ),
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text('KisanKanoon',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppTheme.primaryGreen)),
              ),
              const Center(
                child: Text('किसान का साथी', style: TextStyle(fontSize: 14, color: AppTheme.textMid)),
              ),
              const SizedBox(height: 36),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Email
                    const Text('ईमेल', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        hintText: 'आपका ईमेल पता',
                        prefixIcon: Icon(Icons.email_outlined, color: AppTheme.primaryGreen),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'ईमेल डालें';
                        if (!v.contains('@')) return 'सही ईमेल डालें';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    // Password
                    const Text('पासवर्ड', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _passCtrl,
                      obscureText: _obscure,
                      decoration: InputDecoration(
                        hintText: '••••••••',
                        prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.primaryGreen),
                        suffixIcon: IconButton(
                          icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, color: AppTheme.textLight),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      validator: (v) => (v?.length ?? 0) < 6 ? 'कम से कम 6 अक्षर' : null,
                    ),
                    // Forgot Password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _showForgotPassword,
                        child: const Text('पासवर्ड भूल गए?',
                            style: TextStyle(color: AppTheme.primaryGreen, fontSize: 13, fontWeight: FontWeight.w600)),
                      ),
                    ),
                    // Error
                    if (_errorMsg != null) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50, borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(children: [
                          const Icon(Icons.error_outline, color: Colors.red, size: 18),
                          const SizedBox(width: 8),
                          Expanded(child: Text(_errorMsg!, style: const TextStyle(color: Colors.red, fontSize: 13))),
                        ]),
                      ),
                    ],
                    const SizedBox(height: 24),
                    // Login Button
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _login,
                        child: _loading
                            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                            : const Text('लॉगिन करें', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Register link
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Text('नया खाता बनाएं? ', style: TextStyle(color: AppTheme.textMid, fontSize: 14)),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pushNamed('/register'),
                        child: const Text('रजिस्टर करें',
                            style: TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.w700, fontSize: 14)),
                      ),
                    ]),
                    const SizedBox(height: 32),
                    // Helpline
                    GestureDetector(
                      onTap: () async {
                        final uri = Uri(scheme: 'tel', path: '15100');
                        if (await canLaunchUrl(uri)) launchUrl(uri);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: AppTheme.bgGreen, borderRadius: BorderRadius.circular(12)),
                        child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Icon(Icons.phone, color: AppTheme.primaryGreen, size: 20),
                          SizedBox(width: 8),
                          Text('मुफ्त कानूनी मदद: 15100 (DLSA)',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.primaryGreen)),
                        ]),
                      ),
                    ),
                    const SizedBox(height: 32),
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
