import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/app_language_service.dart';
import '../services/app_strings.dart';
import '../services/app_theme_service.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

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
  String _languageCode = AppLanguageService.currentCode.value;

  bool get _isEnglish => _languageCode != 'hi';
  String get _appearanceLabel => _isEnglish ? 'Appearance' : 'à¤¥à¥€à¤®';
  String get _darkModeLabel =>
      _isEnglish ? 'Dark mode' : 'à¤¡à¤¾à¤°à¥à¤• à¤®à¥‹à¤¡';
  String get _themeModeHint => _isEnglish
      ? 'Switch between light and dark app colors.'
      : 'à¤à¤ª à¤•à¥‡ à¤¹à¤²à¥à¤•à¥‡ à¤”à¤° à¤—à¤¹à¤°à¥‡ à¤°à¤‚à¤— à¤•à¥‡ à¤¬à¥€à¤š à¤¬à¤¦à¤²à¥‡à¤‚à¥¤';

  @override
  void initState() {
    super.initState();
    AppLanguageService.currentCode.addListener(_handleLanguageChanged);
    _loadUser();
  }

  @override
  void dispose() {
    AppLanguageService.currentCode.removeListener(_handleLanguageChanged);
    super.dispose();
  }

  String _t(String key) => AppStrings.t(_languageCode, key);

  void _handleLanguageChanged() {
    if (!mounted) return;
    setState(() {
      _languageCode = AppLanguageService.currentCode.value;
    });
  }

  Future<void> _loadUser() async {
    final profile = await AuthService.getUserProfile();
    if (profile != null && mounted) {
      setState(() {
        _name = profile['name'] ?? '';
        _email =
            profile['email'] ?? FirebaseAuth.instance.currentUser?.email ?? '';
        _state = profile['state'] ?? '';
        _country = profile['country'] ?? '';
      });
      return;
    }

    final fbUser = FirebaseAuth.instance.currentUser;
    if (fbUser != null && mounted) {
      setState(() {
        _name = fbUser.displayName ?? _t('farmerBrother');
        _email = fbUser.email ?? '';
      });
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_isEnglish ? 'Logout' : 'à¤²à¥‰à¤—à¤†à¤‰à¤Ÿ'),
        content: Text(
          _isEnglish
              ? 'Do you want to log out?'
              : 'à¤•à¥à¤¯à¤¾ à¤†à¤ª à¤²à¥‰à¤—à¤†à¤‰à¤Ÿ à¤•à¤°à¤¨à¤¾ à¤šà¤¾à¤¹à¤¤à¥‡ à¤¹à¥ˆà¤‚?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(_isEnglish ? 'No' : 'à¤¨à¤¹à¥€à¤‚'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              _isEnglish ? 'Yes' : 'à¤¹à¤¾à¤',
              style: const TextStyle(color: Colors.red),
            ),
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
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  String get _helplineSectionTitle => _isEnglish
      ? 'Important Farmer Helpline Numbers (India)'
      : 'महत्वपूर्ण किसान हेल्पलाइन नंबर (भारत)';

  String get _helplineSectionHint => _isEnglish
      ? 'Numbers are shown in priority order. Tap any row to call the main helpline number.'
      : 'नंबर प्राथमिक क्रम में दिए गए हैं। किसी भी पंक्ति पर टैप करके मुख्य हेल्पलाइन नंबर पर कॉल करें।';

  List<_HelplineContact> get _helplineContacts => [
        _HelplineContact(
          order: 1,
          emoji: '🌾',
          title:
              _isEnglish ? 'Kisan Call Center (KCC)' : 'किसान कॉल सेंटर (KCC)',
          numberLabel: '1800-180-1551',
          dialNumber: '18001801551',
          description: _isEnglish
              ? 'For crop advice, mandi guidance, weather updates, and common farming questions.'
              : 'फसल सलाह, मंडी मार्गदर्शन, मौसम अपडेट और सामान्य खेती सलाह के लिए।',
        ),
        _HelplineContact(
          order: 2,
          emoji: '💰',
          title: _isEnglish ? 'PM-KISAN Helpline' : 'PM-KISAN हेल्पलाइन',
          numberLabel: '155261 / 1800-115-526',
          dialNumber: '155261',
          description: _isEnglish
              ? 'For installment status, eKYC, beneficiary correction, and PM-KISAN payment issues.'
              : 'किस्त स्थिति, eKYC, लाभार्थी सुधार और PM-KISAN भुगतान समस्या के लिए।',
          extraDetail: _isEnglish
              ? 'The card dials the first number shown above.'
              : 'इस कार्ड पर टैप करने से ऊपर दिया गया पहला नंबर डायल होगा।',
        ),
        _HelplineContact(
          order: 3,
          emoji: '🏛️',
          title: _isEnglish
              ? 'Agriculture Ministry Helpline'
              : 'कृषि मंत्रालय हेल्पलाइन',
          numberLabel: '011-23381092',
          dialNumber: '01123381092',
          description: _isEnglish
              ? 'For ministry-level agriculture support, complaint escalation, and official guidance.'
              : 'मंत्रालय स्तर की कृषि सहायता, शिकायत आगे बढ़ाने और आधिकारिक मार्गदर्शन के लिए।',
        ),
        _HelplineContact(
          order: 4,
          emoji: '🧪',
          title: _isEnglish
              ? 'Soil Health Card Helpline'
              : 'सॉइल हेल्थ कार्ड हेल्पलाइन',
          numberLabel: '1800-180-1551',
          dialNumber: '18001801551',
          description: _isEnglish
              ? 'For soil health card details, nutrient suggestions, and soil record support.'
              : 'सॉइल हेल्थ कार्ड जानकारी, पोषक तत्व सलाह और मिट्टी रिकॉर्ड सहायता के लिए।',
        ),
        _HelplineContact(
          order: 5,
          emoji: '🌦️',
          title: _isEnglish
              ? 'Crop Insurance (PMFBY) Helpline'
              : 'फसल बीमा (PMFBY) हेल्पलाइन',
          numberLabel: '1800-200-7710',
          dialNumber: '18002007710',
          description: _isEnglish
              ? 'For crop insurance enrollment, policy support, and claim-related help.'
              : 'फसल बीमा पंजीकरण, पॉलिसी सहायता और दावा संबंधी मदद के लिए।',
        ),
        _HelplineContact(
          order: 6,
          emoji: '🛒',
          title: _isEnglish
              ? 'National Agriculture Market (e-NAM)'
              : 'राष्ट्रीय कृषि बाजार (e-NAM)',
          numberLabel: '1800-270-0224',
          dialNumber: '18002700224',
          description: _isEnglish
              ? 'For e-NAM registration, online trading, and mandi platform support.'
              : 'e-NAM पंजीकरण, ऑनलाइन ट्रेडिंग और मंडी प्लेटफॉर्म सहायता के लिए।',
        ),
        _HelplineContact(
          order: 7,
          emoji: '🧂',
          title: _isEnglish
              ? 'Fertilizer Complaint Helpline'
              : 'उर्वरक शिकायत हेल्पलाइन',
          numberLabel: '1800-233-3322',
          dialNumber: '18002333322',
          description: _isEnglish
              ? 'For fertilizer availability problems, supply complaints, and related support.'
              : 'उर्वरक उपलब्धता समस्या, सप्लाई शिकायत और संबंधित सहायता के लिए।',
        ),
        _HelplineContact(
          order: 8,
          emoji: '🧴',
          title: _isEnglish
              ? 'Pesticide Complaint Helpline'
              : 'कीटनाशक शिकायत हेल्पलाइन',
          numberLabel: '1800-180-1551',
          dialNumber: '18001801551',
          description: _isEnglish
              ? 'For pesticide complaints, safe usage guidance, and farming support.'
              : 'कीटनाशक शिकायत, सुरक्षित उपयोग मार्गदर्शन और खेती सहायता के लिए।',
        ),
        _HelplineContact(
          order: 9,
          emoji: '☁️',
          title: _isEnglish
              ? 'Weather Info (IMD Farmer Service)'
              : 'मौसम जानकारी (IMD किसान सेवा)',
          numberLabel: '1800-180-1717',
          dialNumber: '18001801717',
          description: _isEnglish
              ? 'For weather information, alerts, and forecast support for farmers.'
              : 'किसानों के लिए मौसम जानकारी, अलर्ट और पूर्वानुमान सहायता के लिए।',
        ),
        _HelplineContact(
          order: 10,
          emoji: '🐄',
          title: _isEnglish ? 'Animal Husbandry Helpline' : 'पशुपालन हेल्पलाइन',
          numberLabel: '1962',
          dialNumber: '1962',
          description: _isEnglish
              ? 'For cattle care, animal health, vaccination, and veterinary guidance.'
              : 'पशु देखभाल, पशु स्वास्थ्य, टीकाकरण और पशु चिकित्सा मार्गदर्शन के लिए।',
        ),
      ];

  void _showInfo(String title, String content) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
                _isEnglish ? 'Close' : 'à¤¬à¤‚à¤¦ à¤•à¤°à¥‡à¤‚'),
          ),
        ],
      ),
    );
  }

  Future<void> _changeLanguage(String code) async {
    final languageName = AppLanguageService.languageName(code);
    await AppLanguageService.setLanguage(code);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppStrings.languageChangedMessage(
            AppLanguageService.currentCode.value,
            languageName,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileLocation = [
      if (_state.isNotEmpty) _state,
      if (_country.isNotEmpty) _country,
    ].join(', ');
    final helplineContacts = _helplineContacts;

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                color: AppTheme.white,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Row(
                  children: [
                    Text(
                      _t('navMore'),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppTheme.accentGreen,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Text('🌾', style: TextStyle(fontSize: 14)),
                          const SizedBox(width: 4),
                          Text(
                            _isEnglish
                                ? 'Farmer'
                                : 'à¤•à¤¿à¤¸à¤¾à¤¨',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primaryGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.shadow,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryGreen,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          _name.isEmpty ? '👨‍🌾' : _name[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 26,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _name.isEmpty ? _t('farmerBrother') : _name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textDark,
                            ),
                          ),
                          if (_email.isNotEmpty)
                            Text(
                              _email,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textMid,
                              ),
                            ),
                          if (profileLocation.isNotEmpty)
                            Text(
                              profileLocation,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textMid,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.bgGreen,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _isEnglish
                            ? 'Verified'
                            : 'à¤¸à¤¤à¥à¤¯à¤¾à¤ªà¤¿à¤¤',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _sectionHeader(_helplineSectionTitle),
              Container(
                color: AppTheme.white,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _helplineSectionHint,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textMid,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 14),
                      ...helplineContacts.map(_helplineCard),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _sectionHeader(_t('myServices')),
              Container(
                color: AppTheme.white,
                child: Column(
                  children: [
                    _tile(
                      '📋',
                      _isEnglish
                          ? 'Government Schemes'
                          : 'à¤¸à¤°à¤•à¤¾à¤°à¥€ à¤¯à¥‹à¤œà¤¨à¤¾à¤à¤',
                      trailing: _isEnglish
                          ? '15 schemes'
                          : '15 à¤¯à¥‹à¤œà¤¨à¤¾à¤à¤',
                      onTap: () => _showInfo(
                        _isEnglish
                            ? 'Schemes'
                            : 'à¤¯à¥‹à¤œà¤¨à¤¾à¤à¤',
                        _isEnglish
                            ? 'PM-KISAN, PM Fasal Bima, RKVY and other schemes are available for you.'
                            : 'PM-KISAN, PM Fasal Bima, RKVY à¤”à¤° à¤…à¤¨à¥à¤¯ à¤¯à¥‹à¤œà¤¨à¤¾à¤à¤ à¤†à¤ªà¤•à¥‡ à¤²à¤¿à¤ à¤‰à¤ªà¤²à¤¬à¥à¤§ à¤¹à¥ˆà¤‚à¥¤',
                      ),
                    ),
                    _divider(),
                    _tile(
                      '❓',
                      _isEnglish
                          ? 'FAQ'
                          : 'à¤†à¤® à¤¸à¤µà¤¾à¤² (FAQ)',
                      onTap: () => _showInfo(
                        _isEnglish ? 'FAQ' : 'FAQ',
                        _isEnglish
                            ? 'For land disputes contact your nearest DLSA. For PM-KISAN payment issues call 155261.'
                            : 'à¤­à¥‚à¤®à¤¿ à¤µà¤¿à¤µà¤¾à¤¦ à¤®à¥‡à¤‚ à¤¨à¤œà¤¼à¤¦à¥€à¤•à¥€ DLSA à¤¸à¥‡ à¤¸à¤‚à¤ªà¤°à¥à¤• à¤•à¤°à¥‡à¤‚à¥¤ PM-KISAN à¤­à¥à¤—à¤¤à¤¾à¤¨ à¤¸à¤®à¤¸à¥à¤¯à¤¾ à¤•à¥‡ à¤²à¤¿à¤ 155261 à¤ªà¤° à¤•à¥‰à¤² à¤•à¤°à¥‡à¤‚à¥¤',
                      ),
                    ),
                    _divider(),
                    _tile(
                      '📖',
                      _isEnglish
                          ? 'Farmer Rights Guide'
                          : 'à¤•à¤¿à¤¸à¤¾à¤¨ à¤…à¤§à¤¿à¤•à¤¾à¤° à¤—à¤¾à¤‡à¤¡',
                      onTap: () => _showInfo(
                        _isEnglish
                            ? 'Farmer Rights'
                            : 'à¤•à¤¿à¤¸à¤¾à¤¨ à¤…à¤§à¤¿à¤•à¤¾à¤°',
                        _isEnglish
                            ? 'You have the right to access support schemes, crop insurance claims, legal aid, and land records.'
                            : 'à¤†à¤ªà¤•à¥‹ à¤¸à¤®à¤°à¥à¤¥à¤¨ à¤¯à¥‹à¤œà¤¨à¤¾à¤“à¤‚, à¤¬à¥€à¤®à¤¾ à¤•à¥à¤²à¥‡à¤®, à¤•à¤¾à¤¨à¥‚à¤¨à¥€ à¤¸à¤¹à¤¾à¤¯à¤¤à¤¾ à¤”à¤° à¤­à¥‚à¤®à¤¿ à¤°à¤¿à¤•à¥‰à¤°à¥à¤¡ à¤¦à¥‡à¤–à¤¨à¥‡ à¤•à¤¾ à¤…à¤§à¤¿à¤•à¤¾à¤° à¤¹à¥ˆà¥¤',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _sectionHeader(_t('language')),
              Container(
                color: AppTheme.white,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _t('selectedLanguage'),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textMid,
                              ),
                            ),
                          ),
                          Text(
                            AppLanguageService.languageName(_languageCode),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primaryGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                    for (var i = 0;
                        i < AppLanguageService.supportedLanguages.length;
                        i++) ...[
                      ListTile(
                        title:
                            Text(AppLanguageService.supportedLanguages[i].name),
                        trailing:
                            AppLanguageService.supportedLanguages[i].code ==
                                    _languageCode
                                ? const Icon(
                                    Icons.check_circle,
                                    color: AppTheme.primaryGreen,
                                  )
                                : const Icon(
                                    Icons.chevron_right,
                                    color: AppTheme.primaryGreen,
                                  ),
                        onTap: () => _changeLanguage(
                          AppLanguageService.supportedLanguages[i].code,
                        ),
                      ),
                      if (i != AppLanguageService.supportedLanguages.length - 1)
                        _divider(),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _sectionHeader(_appearanceLabel),
              Container(
                color: AppTheme.white,
                child: ValueListenableBuilder<ThemeMode>(
                  valueListenable: AppThemeService.currentMode,
                  builder: (context, mode, _) {
                    final isDarkMode = mode == ThemeMode.dark;
                    return SwitchListTile.adaptive(
                      contentPadding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                      secondary: Text(
                        isDarkMode ? '🌙' : '☀️',
                        style: const TextStyle(fontSize: 20),
                      ),
                      title: Text(
                        _darkModeLabel,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textDark,
                        ),
                      ),
                      subtitle: Text(
                        _themeModeHint,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textMid,
                          height: 1.35,
                        ),
                      ),
                      activeThumbColor: AppTheme.primaryGreen,
                      value: isDarkMode,
                      onChanged: (value) {
                        AppThemeService.setThemeMode(
                          value ? ThemeMode.dark : ThemeMode.light,
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              _sectionHeader(_t('appInfo')),
              Container(
                color: AppTheme.white,
                child: Column(
                  children: [
                    _tile(
                      '⭐',
                      _isEnglish
                          ? 'Rate App'
                          : 'à¤à¤ª à¤°à¥‡à¤Ÿ à¤•à¤°à¥‡à¤‚',
                      onTap: () => _showInfo(
                        _isEnglish
                            ? 'Thank you!'
                            : 'à¤§à¤¨à¥à¤¯à¤µà¤¾à¤¦!',
                        _isEnglish
                            ? 'Your support helps us improve the app.'
                            : 'à¤†à¤ªà¤•à¤¾ à¤¸à¤®à¤°à¥à¤¥à¤¨ à¤¹à¤®à¥‡à¤‚ à¤à¤ª à¤¬à¥‡à¤¹à¤¤à¤° à¤¬à¤¨à¤¾à¤¨à¥‡ à¤®à¥‡à¤‚ à¤®à¤¦à¤¦ à¤•à¤°à¤¤à¤¾ à¤¹à¥ˆà¥¤',
                      ),
                    ),
                    _divider(),
                    _tile(
                        '📱',
                        _isEnglish
                            ? 'App Version'
                            : 'à¤à¤ª à¤¸à¤‚à¤¸à¥à¤•à¤°à¤£',
                        trailing: 'v1.0.5+7'),
                    _divider(),
                    _tile(
                      '🔒',
                      _isEnglish
                          ? 'Privacy Policy'
                          : 'à¤—à¥‹à¤ªà¤¨à¥€à¤¯à¤¤à¤¾ à¤¨à¥€à¤¤à¤¿',
                      onTap: () => _showInfo(
                        _isEnglish
                            ? 'Privacy Policy'
                            : 'à¤—à¥‹à¤ªà¤¨à¥€à¤¯à¤¤à¤¾ à¤¨à¥€à¤¤à¤¿',
                        _isEnglish
                            ? 'Your data stays protected. We do not share your personal information with third parties.'
                            : 'à¤†à¤ªà¤•à¤¾ à¤¡à¥‡à¤Ÿà¤¾ à¤¸à¥à¤°à¤•à¥à¤·à¤¿à¤¤ à¤¹à¥ˆà¥¤ à¤¹à¤® à¤†à¤ªà¤•à¥€ à¤µà¥à¤¯à¤•à¥à¤¤à¤¿à¤—à¤¤ à¤œà¤¾à¤¨à¤•à¤¾à¤°à¥€ à¤•à¤¿à¤¸à¥€ à¤¤à¥€à¤¸à¤°à¥‡ à¤ªà¤•à¥à¤· à¤•à¥‹ à¤¸à¤¾à¤à¤¾ à¤¨à¤¹à¥€à¤‚ à¤•à¤°à¤¤à¥‡à¥¤',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout, color: Colors.red),
                    label: Text(
                      _t('logout'),
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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
        child: Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppTheme.textMid,
          ),
        ),
      );

  Widget _divider() => Divider(
        height: 1,
        indent: 56,
        color: AppTheme.divider,
      );

  Widget _helplineCard(_HelplineContact contact) {
    final orderLabel = contact.order.toString().padLeft(2, '0');

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppTheme.surfaceVariant(context),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _call(contact.dialNumber),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.surfaceVariant(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.divider),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.bgGreen,
                    shape: BoxShape.circle,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        orderLabel,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                      Text(
                        contact.emoji,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contact.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        contact.numberLabel,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        contact.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textMid,
                          height: 1.45,
                        ),
                      ),
                      if (contact.extraDetail != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          contact.extraDetail!,
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.textLight,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppTheme.bgGreen,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      '📞',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _tile(
    String emoji,
    String title, {
    String? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Text(emoji, style: const TextStyle(fontSize: 22)),
      title: Text(
        title,
        style: TextStyle(fontSize: 14, color: AppTheme.textDark),
      ),
      trailing: trailing != null
          ? Text(
              trailing,
              style: TextStyle(fontSize: 12, color: AppTheme.textMid),
            )
          : Icon(Icons.chevron_right, color: AppTheme.textLight, size: 20),
      onTap: onTap,
    );
  }
}

class _HelplineContact {
  final int order;
  final String emoji;
  final String title;
  final String numberLabel;
  final String dialNumber;
  final String description;
  final String? extraDetail;

  const _HelplineContact({
    required this.order,
    required this.emoji,
    required this.title,
    required this.numberLabel,
    required this.dialNumber,
    required this.description,
    this.extraDetail,
  });
}
