import 'package:flutter/material.dart';
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
  String _selectedCountry = 'भारत (India)';
  String _selectedState = 'उत्तर प्रदेश';
  bool _loading = false;
  bool _obscure = true;
  String? _errorMsg;

  final List<String> _countries = [
    'भारत (India)', 'नेपाल (Nepal)', 'बांग्लादेश (Bangladesh)', 'अन्य (Other)'
  ];

  final List<String> _states = [
    'उत्तर प्रदेश', 'मध्य प्रदेश', 'राजस्थान', 'बिहार', 'महाराष्ट्र',
    'पंजाब', 'हरियाणा', 'गुजरात', 'कर्नाटक', 'आंध्र प्रदेश',
    'तेलंगाना', 'ओडिशा', 'पश्चिम बंगाल', 'छत्तीसगढ़', 'झारखंड',
    'उत्तराखंड', 'हिमाचल प्रदेश', 'दिल्ली', 'असम', 'अन्य',
  ];

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _errorMsg = null; });

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
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _mobileCtrl.dispose();
    _emailCtrl.dispose(); _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        title: const Text('नया खाता बनाएं'),
        backgroundColor: AppTheme.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textDark),
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
                    width: 72, height: 72,
                    decoration: BoxDecoration(color: AppTheme.bgGreen, shape: BoxShape.circle),
                    child: const Center(child: Text('👨‍🌾', style: TextStyle(fontSize: 36))),
                  ),
                ),
                const SizedBox(height: 24),
                _label('आपका नाम'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    hintText: 'पूरा नाम', prefixIcon: Icon(Icons.person, color: AppTheme.primaryGreen),
                  ),
                  validator: (v) => (v?.isEmpty ?? true) ? 'नाम डालें' : null,
                ),
                const SizedBox(height: 16),
                _label('मोबाइल नंबर'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _mobileCtrl,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  decoration: const InputDecoration(
                    hintText: '10 अंकों का नंबर',
                    prefixIcon: Icon(Icons.phone, color: AppTheme.primaryGreen),
                    counterText: '',
                  ),
                  validator: (v) => (v?.length ?? 0) < 10 ? 'सही नंबर डालें' : null,
                ),
                const SizedBox(height: 16),
                _label('ईमेल'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'आपका ईमेल पता',
                    prefixIcon: Icon(Icons.email_outlined, color: AppTheme.primaryGreen),
                  ),
                  validator: (v) => (v?.isEmpty ?? true) ? 'ईमेल डालें' : null,
                ),
                const SizedBox(height: 16),
                _label('देश'),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedCountry,
                  decoration: const InputDecoration(prefixIcon: Icon(Icons.public, color: AppTheme.primaryGreen)),
                  items: _countries.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (v) => setState(() => _selectedCountry = v!),
                ),
                const SizedBox(height: 16),
                _label('राज्य'),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedState,
                  decoration: const InputDecoration(prefixIcon: Icon(Icons.location_on, color: AppTheme.primaryGreen)),
                  items: _states.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (v) => setState(() => _selectedState = v!),
                ),
                const SizedBox(height: 16),
                _label('पासवर्ड'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    hintText: 'कम से कम 6 अक्षर',
                    prefixIcon: const Icon(Icons.lock, color: AppTheme.primaryGreen),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, color: AppTheme.textLight),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: (v) => (v?.length ?? 0) < 6 ? 'पासवर्ड कम से कम 6 अक्षर' : null,
                ),
                if (_errorMsg != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50, borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 18),
                        const SizedBox(width: 8),
                        Expanded(child: Text(_errorMsg!, style: const TextStyle(color: Colors.red, fontSize: 13))),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _register,
                    child: _loading
                        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                        : const Text('खाता बनाएं', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
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
    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textDark),
  );
}
