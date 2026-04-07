import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  String _selectedCountry = 'à¤­à¤¾à¤°à¤¤ (India)';
  String _selectedState = 'à¤‰à¤¤à¥à¤¤à¤° à¤ªà¥à¤°à¤¦à¥‡à¤¶';
  bool _loading = false;
  bool _obscure = true;
  String? _errorMsg;

  // Password strength
  String _passStrength = '';
  Color _strengthColor = Colors.transparent;
  double _strengthValue = 0;
  List<String> _strengthTips = [];

  final List<String> _countries = [
    'à¤­à¤¾à¤°à¤¤ (India)',
    'à¤¨à¥‡à¤ªà¤¾à¤² (Nepal)',
    'à¤¬à¤¾à¤‚à¤—à¥à¤²à¤¾à¤¦à¥‡à¤¶ (Bangladesh)',
    'à¤…à¤¨à¥à¤¯ (Other)'
  ];

  final List<String> _states = [
    'à¤‰à¤¤à¥à¤¤à¤° à¤ªà¥à¤°à¤¦à¥‡à¤¶',
    'à¤®à¤§à¥à¤¯ à¤ªà¥à¤°à¤¦à¥‡à¤¶',
    'à¤°à¤¾à¤œà¤¸à¥à¤¥à¤¾à¤¨',
    'à¤¬à¤¿à¤¹à¤¾à¤°',
    'à¤®à¤¹à¤¾à¤°à¤¾à¤·à¥à¤Ÿà¥à¤°',
    'à¤ªà¤‚à¤œà¤¾à¤¬',
    'à¤¹à¤°à¤¿à¤¯à¤¾à¤£à¤¾',
    'à¤—à¥à¤œà¤°à¤¾à¤¤',
    'à¤•à¤°à¥à¤¨à¤¾à¤Ÿà¤•',
    'à¤†à¤‚à¤§à¥à¤° à¤ªà¥à¤°à¤¦à¥‡à¤¶',
    'à¤¤à¥‡à¤²à¤‚à¤—à¤¾à¤¨à¤¾',
    'à¤“à¤¡à¤¿à¤¶à¤¾',
    'à¤ªà¤¶à¥à¤šà¤¿à¤® à¤¬à¤‚à¤—à¤¾à¤²',
    'à¤›à¤¤à¥à¤¤à¥€à¤¸à¤—à¤¢à¤¼',
    'à¤à¤¾à¤°à¤–à¤‚à¤¡',
    'à¤‰à¤¤à¥à¤¤à¤°à¤¾à¤–à¤‚à¤¡',
    'à¤¹à¤¿à¤®à¤¾à¤šà¤² à¤ªà¥à¤°à¤¦à¥‡à¤¶',
    'à¤¦à¤¿à¤²à¥à¤²à¥€',
    'à¤…à¤¸à¤®',
    'à¤…à¤¨à¥à¤¯',
  ];

  void _checkStrength(String val) {
    int score = 0;
    List<String> tips = [];

    if (val.length >= 8) {
      score++;
    } else {
      tips.add('• कम से कम 8 अक्षर रखें');
    }
    if (val.contains(RegExp(r'[A-Z]'))) {
      score++;
    } else {
      tips.add('• एक बड़ा अक्षर (A-Z) जोड़ें');
    }
    if (val.contains(RegExp(r'[0-9]'))) {
      score++;
    } else {
      tips.add('• एक नंबर (0-9) जोड़ें');
    }
    if (val.contains(RegExp(r'[!@#\$%^&*]'))) {
      score++;
    } else {
      tips.add('• एक चिह्न (!@#\$) जोड़ें');
    }

    setState(() {
      _strengthTips = tips;
      if (val.isEmpty) {
        _passStrength = '';
        _strengthColor = Colors.transparent;
        _strengthValue = 0;
      } else if (score <= 1) {
        _passStrength = '🔴 बहुत कमज़ोर';
        _strengthColor = Colors.red;
        _strengthValue = 0.25;
      } else if (score == 2) {
        _passStrength = '🟠 कमज़ोर (Weak)';
        _strengthColor = Colors.orange;
        _strengthValue = 0.5;
      } else if (score == 3) {
        _passStrength = '🟡 ठीक है (Fair)';
        _strengthColor = Colors.amber;
        _strengthValue = 0.75;
      } else {
        _passStrength = '🟢 मज़बूत (Strong)';
        _strengthColor = AppTheme.primaryGreen;
        _strengthValue = 1.0;
        _strengthTips = [];
      }
    });
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _errorMsg = null;
    });

    final error = await AuthService.registerWithEmail(
      name: _nameCtrl.text.trim(),
      mobile: _mobileCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
      country: _selectedCountry,
      state: _selectedState,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (error != null) {
      setState(() => _errorMsg = error);
    } else {
      // Registration successful â€” show OTP verification prompt
      _showOtpVerificationDialog();
    }
  }

  void _showOtpVerificationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _OtpVerificationDialog(
        email: _emailCtrl.text.trim(),
        onVerified: () {
          Navigator.of(ctx).pop();
          Navigator.of(context).pushReplacementNamed('/home');
        },
        onSkip: () {
          Navigator.of(ctx).pop();
          Navigator.of(context).pushReplacementNamed('/home');
        },
      ),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _mobileCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        title: const Text('à¤¨à¤¯à¤¾ à¤–à¤¾à¤¤à¤¾ à¤¬à¤¨à¤¾à¤à¤‚'),
        backgroundColor: AppTheme.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.textDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                        color: AppTheme.bgGreen, shape: BoxShape.circle),
                    child: const Center(
                        child: Text('👨‍🌾', style: TextStyle(fontSize: 36))),
                  ),
                ),
                const SizedBox(height: 24),

                // Name
                _label('à¤†à¤ªà¤•à¤¾ à¤¨à¤¾à¤®'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    hintText: 'à¤ªà¥‚à¤°à¤¾ à¤¨à¤¾à¤®',
                    prefixIcon:
                        Icon(Icons.person, color: AppTheme.primaryGreen),
                  ),
                  validator: (v) =>
                      (v?.isEmpty ?? true) ? 'à¤¨à¤¾à¤® à¤¡à¤¾à¤²à¥‡à¤‚' : null,
                ),
                const SizedBox(height: 16),

                // Mobile
                _label('à¤®à¥‹à¤¬à¤¾à¤‡à¤² à¤¨à¤‚à¤¬à¤°'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _mobileCtrl,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    hintText: '10 à¤…à¤‚à¤•à¥‹à¤‚ à¤•à¤¾ à¤¨à¤‚à¤¬à¤°',
                    prefixIcon: Icon(Icons.phone, color: AppTheme.primaryGreen),
                    counterText: '',
                  ),
                  validator: (v) => (v?.length ?? 0) < 10
                      ? 'à¤¸à¤¹à¥€ à¤¨à¤‚à¤¬à¤° à¤¡à¤¾à¤²à¥‡à¤‚'
                      : null,
                ),
                const SizedBox(height: 16),

                // Email
                _label('à¤ˆà¤®à¥‡à¤²'),
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
                const SizedBox(height: 16),

                // Country
                _label('à¤¦à¥‡à¤¶'),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _selectedCountry,
                  decoration: const InputDecoration(
                      prefixIcon:
                          Icon(Icons.public, color: AppTheme.primaryGreen)),
                  items: _countries
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedCountry = v!),
                ),
                const SizedBox(height: 16),

                // State
                _label('à¤°à¤¾à¤œà¥à¤¯'),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _selectedState,
                  decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.location_on,
                          color: AppTheme.primaryGreen)),
                  items: _states
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedState = v!),
                ),
                const SizedBox(height: 16),

                // Password
                _label('à¤ªà¤¾à¤¸à¤µà¤°à¥à¤¡'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscure,
                  onChanged: _checkStrength,
                  decoration: InputDecoration(
                    hintText: 'à¤•à¤® à¤¸à¥‡ à¤•à¤® 8 à¤…à¤•à¥à¤·à¤°',
                    prefixIcon:
                        const Icon(Icons.lock, color: AppTheme.primaryGreen),
                    suffixIcon: IconButton(
                      icon: Icon(
                          _obscure ? Icons.visibility_off : Icons.visibility,
                          color: AppTheme.textLight),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: (v) => (v?.length ?? 0) < 6
                      ? 'à¤ªà¤¾à¤¸à¤µà¤°à¥à¤¡ à¤•à¤® à¤¸à¥‡ à¤•à¤® 6 à¤…à¤•à¥à¤·à¤°'
                      : null,
                ),

                // Password Strength Indicator
                if (_passStrength.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _strengthValue,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(_strengthColor),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(_passStrength,
                      style: TextStyle(
                          fontSize: 12,
                          color: _strengthColor,
                          fontWeight: FontWeight.w700)),
                  if (_strengthTips.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('💡 मज़बूत पासवर्ड के लिए:',
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.orange)),
                          ..._strengthTips.map((t) => Text(t,
                              style: const TextStyle(
                                  fontSize: 11, color: Colors.orange))),
                        ],
                      ),
                    ),
                  ],
                ],

                // Error
                if (_errorMsg != null) ...[
                  const SizedBox(height: 12),
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
                const SizedBox(height: 28),

                // Register Button
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _register,
                    child: _loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2.5))
                        : const Text('à¤–à¤¾à¤¤à¤¾ à¤¬à¤¨à¤¾à¤à¤‚',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.textDark),
      );
}

// â”€â”€â”€ OTP Verification Dialog â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _OtpVerificationDialog extends StatefulWidget {
  final String email;
  final VoidCallback onVerified;
  final VoidCallback onSkip;

  const _OtpVerificationDialog({
    required this.email,
    required this.onVerified,
    required this.onSkip,
  });

  @override
  State<_OtpVerificationDialog> createState() => _OtpVerificationDialogState();
}

class _OtpVerificationDialogState extends State<_OtpVerificationDialog> {
  bool _sending = false;
  bool _sent = false;
  bool _verifying = false;
  String? _msg;
  final _otpCtrls = List.generate(6, (_) => TextEditingController());
  final _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    _sendVerificationEmail();
  }

  Future<void> _sendVerificationEmail() async {
    setState(() {
      _sending = true;
      _msg = null;
    });
    final err = await AuthService.sendEmailVerification();
    if (!mounted) return;
    setState(() {
      _sending = false;
      _sent = err == null;
      _msg = err ?? '✅ वेरिफिकेशन ईमेल भेजा गया!\n${widget.email} चेक करें।';
    });
  }

  Future<void> _checkVerified() async {
    setState(() {
      _verifying = true;
    });
    final verified = await AuthService.isEmailVerified();
    if (!mounted) return;
    setState(() => _verifying = false);
    if (verified) {
      widget.onVerified();
    } else {
      setState(() => _msg =
          '⚠️ अभी verify नहीं हुआ। ईमेल में link पर click करें, फिर दोबारा try करें।');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: const EdgeInsets.all(24),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration:
                BoxDecoration(color: AppTheme.bgGreen, shape: BoxShape.circle),
            child:
                const Center(child: Text('📧', style: TextStyle(fontSize: 32))),
          ),
          const SizedBox(height: 16),
          Text('à¤ˆà¤®à¥‡à¤² à¤µà¥‡à¤°à¤¿à¤«à¤¾à¤ˆ à¤•à¤°à¥‡à¤‚',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textDark)),
          const SizedBox(height: 8),
          Text(
            'à¤†à¤ªà¤•à¥‡ à¤–à¤¾à¤¤à¥‡ à¤•à¥€ à¤¸à¥à¤°à¤•à¥à¤·à¤¾ à¤•à¥‡ à¤²à¤¿à¤ à¤ˆà¤®à¥‡à¤² à¤µà¥‡à¤°à¤¿à¤«à¤¿à¤•à¥‡à¤¶à¤¨ à¤œà¤¼à¤°à¥‚à¤°à¥€ à¤¹à¥ˆà¥¤',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppTheme.textMid),
          ),
          const SizedBox(height: 16),
          if (_sending)
            const CircularProgressIndicator(color: AppTheme.primaryGreen)
          else if (_msg != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _sent ? AppTheme.bgGreen : Colors.orange.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(_msg!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color:
                        _sent ? AppTheme.primaryGreen : Colors.orange.shade800,
                  )),
            ),
          const SizedBox(height: 20),
          // Verify button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _verifying ? null : _checkVerified,
              child: _verifying
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Text('✅ मैंने verify कर दिया',
                      style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: 8),
          // Resend
          TextButton(
            onPressed: _sending ? null : _sendVerificationEmail,
            child: const Text('📨 दोबारा ईमेल भेजें',
                style: TextStyle(color: AppTheme.primaryGreen, fontSize: 13)),
          ),
          // Skip
          TextButton(
            onPressed: widget.onSkip,
            child: Text('अभी नहीं, बाद में करूंगा →',
                style: TextStyle(color: AppTheme.textLight, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    for (final c in _otpCtrls) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }
}
