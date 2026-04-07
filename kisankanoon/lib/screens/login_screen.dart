import 'package:flutter/material.dart';
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

  bool _isValidEmail(String value) {
    final email = value.trim();
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email);
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _errorMsg = null;
    });

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
    final resetCtrl = TextEditingController(text: _emailCtrl.text.trim());
    String? dialogError;
    bool submitting = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('à¤ªà¤¾à¤¸à¤µà¤°à¥à¤¡ à¤­à¥‚à¤² à¤—à¤?',
              style: TextStyle(fontWeight: FontWeight.w700)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'à¤…à¤ªà¤¨à¤¾ à¤ˆà¤®à¥‡à¤² à¤¡à¤¾à¤²à¥‡à¤‚ â€” à¤¹à¤® à¤†à¤ªà¤•à¥‹ à¤°à¥€à¤¸à¥‡à¤Ÿ à¤²à¤¿à¤‚à¤• à¤­à¥‡à¤œà¥‡à¤‚à¤—à¥‡à¥¤',
                style: TextStyle(fontSize: 13, color: AppTheme.textMid),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: resetCtrl,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                autocorrect: false,
                enableSuggestions: false,
                decoration: const InputDecoration(
                  hintText: 'à¤ˆà¤®à¥‡à¤² à¤ªà¤¤à¤¾',
                  prefixIcon:
                      Icon(Icons.email_outlined, color: AppTheme.primaryGreen),
                ),
              ),
              if (dialogError != null) ...[
                const SizedBox(height: 12),
                Text(
                  dialogError!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: submitting ? null : () => Navigator.pop(ctx),
              child: const Text('à¤°à¤¦à¥à¤¦ à¤•à¤°à¥‡à¤‚'),
            ),
            ElevatedButton(
              onPressed: submitting
                  ? null
                  : () async {
                      final email = resetCtrl.text.trim();
                      if (email.isEmpty) {
                        setDialogState(() =>
                            dialogError = 'Please enter your email address.');
                        return;
                      }
                      if (!_isValidEmail(email)) {
                        setDialogState(() => dialogError =
                            'Please enter a valid email address.');
                        return;
                      }

                      FocusScope.of(ctx).unfocus();
                      setDialogState(() {
                        submitting = true;
                        dialogError = null;
                      });

                      final err = await AuthService.sendPasswordReset(email);
                      if (!mounted) return;

                      if (err != null) {
                        setDialogState(() {
                          submitting = false;
                          dialogError = err;
                        });
                        return;
                      }

                      if (ctx.mounted) {
                        Navigator.pop(ctx);
                      }

                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          const SnackBar(
                            content: Text(
                              'If this email is registered, a reset link has been sent. Please check your inbox and spam folder.',
                            ),
                            backgroundColor: AppTheme.primaryGreen,
                          ),
                        );
                    },
              child: submitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('à¤­à¥‡à¤œà¥‡à¤‚'),
            ),
          ],
        ),
      ),
    ).whenComplete(resetCtrl.dispose);
    return;
/*

    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('à¤ªà¤¾à¤¸à¤µà¤°à¥à¤¡ à¤­à¥‚à¤² à¤—à¤?', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('अपना ईमेल डालें — हम आपको रीसेट लिंक भेजेंगे।',
                style: TextStyle(fontSize: 13, color: AppTheme.textMid)),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: 'à¤ˆà¤®à¥‡à¤² à¤ªà¤¤à¤¾',
                prefixIcon: Icon(Icons.email_outlined, color: AppTheme.primaryGreen),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('à¤°à¤¦à¥à¤¦ à¤•à¤°à¥‡à¤‚')),
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
            child: Text('à¤­à¥‡à¤œà¥‡à¤‚'),
          ),
        ],
      ),
    );
*/
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
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: AppTheme.bgGreen,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Center(
                      child: Text('⚖️', style: TextStyle(fontSize: 44))),
                ),
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text('Agri-Shield',
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.primaryGreen)),
              ),
              Center(
                child: Text('à¤•à¤¿à¤¸à¤¾à¤¨ à¤•à¤¾ à¤¸à¤¾à¤¥à¥€',
                    style: TextStyle(fontSize: 14, color: AppTheme.textMid)),
              ),
              const SizedBox(height: 36),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Email
                    Text('à¤ˆà¤®à¥‡à¤²',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textDark)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        hintText: 'à¤†à¤ªà¤•à¤¾ à¤ˆà¤®à¥‡à¤² à¤ªà¤¤à¤¾',
                        prefixIcon: Icon(Icons.email_outlined,
                            color: AppTheme.primaryGreen),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'à¤ˆà¤®à¥‡à¤² à¤¡à¤¾à¤²à¥‡à¤‚';
                        }
                        if (!v.contains('@')) {
                          return 'à¤¸à¤¹à¥€ à¤ˆà¤®à¥‡à¤² à¤¡à¤¾à¤²à¥‡à¤‚';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    // Password
                    Text('à¤ªà¤¾à¤¸à¤µà¤°à¥à¤¡',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textDark)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _passCtrl,
                      obscureText: _obscure,
                      decoration: InputDecoration(
                        hintText: '••••••••',
                        prefixIcon: const Icon(Icons.lock_outline,
                            color: AppTheme.primaryGreen),
                        suffixIcon: IconButton(
                          icon: Icon(
                              _obscure
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: AppTheme.textLight),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      validator: (v) => (v?.length ?? 0) < 6
                          ? 'à¤•à¤® à¤¸à¥‡ à¤•à¤® 6 à¤…à¤•à¥à¤·à¤°'
                          : null,
                    ),
                    // Forgot Password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _showForgotPassword,
                        child: const Text(
                            'à¤ªà¤¾à¤¸à¤µà¤°à¥à¤¡ à¤­à¥‚à¤² à¤—à¤?',
                            style: TextStyle(
                                color: AppTheme.primaryGreen,
                                fontSize: 13,
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                    // Error
                    if (_errorMsg != null) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(children: [
                          const Icon(Icons.error_outline,
                              color: Colors.red, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                              child: Text(_errorMsg!,
                                  style: const TextStyle(
                                      color: Colors.red, fontSize: 13))),
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
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2.5))
                            : const Text('à¤²à¥‰à¤—à¤¿à¤¨ à¤•à¤°à¥‡à¤‚',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w700)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Register link
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text('à¤¨à¤¯à¤¾ à¤–à¤¾à¤¤à¤¾ à¤¬à¤¨à¤¾à¤à¤‚? ',
                          style:
                              TextStyle(color: AppTheme.textMid, fontSize: 14)),
                      GestureDetector(
                        onTap: () =>
                            Navigator.of(context).pushNamed('/register'),
                        child: const Text('à¤°à¤œà¤¿à¤¸à¥à¤Ÿà¤° à¤•à¤°à¥‡à¤‚',
                            style: TextStyle(
                                color: AppTheme.primaryGreen,
                                fontWeight: FontWeight.w700,
                                fontSize: 14)),
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
                        decoration: BoxDecoration(
                            color: AppTheme.bgGreen,
                            borderRadius: BorderRadius.circular(12)),
                        child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.phone,
                                  color: AppTheme.primaryGreen, size: 20),
                              SizedBox(width: 8),
                              Text(
                                  'à¤®à¥à¤«à¥à¤¤ à¤•à¤¾à¤¨à¥‚à¤¨à¥€ à¤®à¤¦à¤¦: 15100 (DLSA)',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.primaryGreen)),
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
