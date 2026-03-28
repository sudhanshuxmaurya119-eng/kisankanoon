import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  String _name = '';
  String _email = '';
  String _state = '';
  String _country = '';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    // Try Firebase profile first
    final profile = await AuthService.getUserProfile();
    if (profile != null && mounted) {
      setState(() {
        _name = profile['name'] ?? '';
        _email = profile['email'] ?? FirebaseAuth.instance.currentUser?.email ?? '';
        _state = profile['state'] ?? '';
        _country = profile['country'] ?? '';
      });
      return;
    }
    // Fallback to Firebase user object
    final fbUser = FirebaseAuth.instance.currentUser;
    if (fbUser != null && mounted) {
      setState(() {
        _name = fbUser.displayName ?? 'किसान भाई';
        _email = fbUser.email ?? '';
      });
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('लॉगआउट'),
        content: const Text('क्या आप लॉगआउट करना चाहते हैं?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('नहीं')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('हाँ', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await AuthService.logout();
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  Future<void> _call(String number) async {
    final uri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(uri)) launchUrl(uri);
  }

  void _showInfo(String title, String content) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('बंद करें')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                color: AppTheme.white,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Row(
                  children: [
                    const Text('अधिक', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.accentGreen, width: 1.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Text('🌾', style: TextStyle(fontSize: 14)),
                          SizedBox(width: 4),
                          Text('किसान', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.primaryGreen)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // User Profile Card
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: AppTheme.shadow, blurRadius: 8, offset: const Offset(0, 2))],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56, height: 56,
                      decoration: const BoxDecoration(color: AppTheme.primaryGreen, shape: BoxShape.circle),
                      child: Center(
                        child: Text(
                          _name.isEmpty ? '👨‍🌾' : _name[0].toUpperCase(),
                          style: const TextStyle(fontSize: 26, color: Colors.white, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_name.isEmpty ? 'किसान भाई' : _name,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
                          if (_email.isNotEmpty) Text(_email, style: const TextStyle(fontSize: 12, color: AppTheme.textMid)),
                          if (_state.isNotEmpty || _country.isNotEmpty)
                            Text('$_state${_state.isNotEmpty && _country.isNotEmpty ? ', ' : ''}$_country',
                                style: const TextStyle(fontSize: 12, color: AppTheme.textMid)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: AppTheme.bgGreen, borderRadius: BorderRadius.circular(12)),
                      child: const Text('✓ सत्यापित', style: TextStyle(fontSize: 12, color: AppTheme.primaryGreen, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),

              // Quick Links
              _sectionHeader('त्वरित लिंक'),
              Container(
                color: AppTheme.white,
                child: Column(children: [
                  _tile('📞', 'किसान हेल्पलाइन (15100)', onTap: () => _call('15100')),
                  _divider(),
                  _tile('⚖️', 'कानूनी सहायता (DLSA)', onTap: () => _call('15100')),
                  _divider(),
                  _tile('🏦', 'बैंक हेल्पलाइन (1800-180-1111)', onTap: () => _call('18001801111')),
                  _divider(),
                  _tile('🌾', 'PM-Kisan Helpline (155261)', onTap: () => _call('155261')),
                ]),
              ),

              const SizedBox(height: 12),

              // My Services
              _sectionHeader('मेरी सेवाएं'),
              Container(
                color: AppTheme.white,
                child: Column(children: [
                  _tile('📋', 'सरकारी योजनाएं', trailing: '15 योजनाएं',
                      onTap: () => _showInfo('योजनाएं', 'PM-KISAN, PM Fasal Bima, RKVY और 12 अन्य योजनाएं आपके लिए उपलब्ध हैं।')),
                  _divider(),
                  _tile('❓', 'आम सवाल (FAQ)', onTap: () => _showInfo('FAQ',
                      'Q: भूमि विवाद में क्या करें?\nA: नजदीकी DLSA में संपर्क करें।\n\nQ: PM-KISAN के पैसे नहीं आए?\nA: 155261 पर कॉल करें।')),
                  _divider(),
                  _tile('📖', 'किसान अधिकार गाइड', onTap: () => _showInfo('किसान अधिकार',
                      '1. न्यूनतम समर्थन मूल्य (MSP) पर फसल बेचने का अधिकार\n2. बीमा क्लेम का अधिकार\n3. मुफ्त कानूनी सहायता का अधिकार\n4. भूमि रिकॉर्ड देखने का अधिकार')),
                ]),
              ),

              const SizedBox(height: 12),

              // Language
              _sectionHeader('भाषा'),
              Container(
                color: AppTheme.white,
                child: Column(
                  children: [
                    for (final lang in [
                      {'name': 'हिंदी', 'code': 'hi'},
                      {'name': 'English', 'code': 'en'},
                      {'name': 'मराठी', 'code': 'mr'},
                      {'name': 'ਪੰਜਾਬੀ', 'code': 'pa'},
                    ]) ...[
                      ListTile(
                        title: Text(lang['name']!),
                        trailing: const Icon(Icons.chevron_right, color: AppTheme.primaryGreen),
                        onTap: () async {
                          await StorageService.setLang(lang['code']!);
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('भाषा बदल दी गई: ${lang['name']}')),
                          );
                        },
                      ),
                      if (lang != {'name': 'ਪੰਜਾਬੀ', 'code': 'pa'}) _divider(),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // App Info
              _sectionHeader('ऐप जानकारी'),
              Container(
                color: AppTheme.white,
                child: Column(children: [
                  _tile('⭐', 'ऐप रेट करें', onTap: () => _showInfo('धन्यवाद!', 'आपका समर्थन हमें बेहतर बनाने में मदद करता है।')),
                  _divider(),
                  _tile('📱', 'ऐप संस्करण', trailing: 'v1.0.0'),
                  _divider(),
                  _tile('🔒', 'गोपनीयता नीति', onTap: () => _showInfo('गोपनीयता नीति', 'आपका डेटा सुरक्षित है। हम कोई भी व्यक्तिगत जानकारी तीसरे पक्ष को नहीं देते।')),
                ]),
              ),

              const SizedBox(height: 20),

              // Logout
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout, color: Colors.red),
                    label: const Text('लॉगआउट', style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
    child: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textMid)),
  );

  Widget _divider() => const Divider(height: 1, indent: 56, endIndent: 0, color: AppTheme.divider);

  Widget _tile(String emoji, String title, {String? trailing, VoidCallback? onTap}) {
    return ListTile(
      leading: Text(emoji, style: const TextStyle(fontSize: 22)),
      title: Text(title, style: const TextStyle(fontSize: 14, color: AppTheme.textDark)),
      trailing: trailing != null
          ? Text(trailing, style: const TextStyle(fontSize: 12, color: AppTheme.textMid))
          : const Icon(Icons.chevron_right, color: AppTheme.textLight, size: 20),
      onTap: onTap,
    );
  }
}
