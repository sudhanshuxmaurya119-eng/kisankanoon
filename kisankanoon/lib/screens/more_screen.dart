import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/app_language_service.dart';
import '../services/app_strings.dart';
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

  bool get _isEnglish => _languageCode == 'en';

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
        title: Text(_languageCode == 'en' ? 'Logout' : 'लॉगआउट'),
        content: Text(
          _languageCode == 'en'
              ? 'Do you want to log out?'
              : 'क्या आप लॉगआउट करना चाहते हैं?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(_languageCode == 'en' ? 'No' : 'नहीं'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              _languageCode == 'en' ? 'Yes' : 'हाँ',
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

  List<_HelplineContact> get _helplineContacts => [
        _HelplineContact(
          emoji: '🌾',
          title:
              _isEnglish ? 'Kisan Call Center (KCC)' : 'किसान कॉल सेंटर (KCC)',
          numberLabel: '1800-180-1551',
          dialNumber: '18001801551',
          description: _isEnglish
              ? 'For crop advice, weather, pest control, mandi and farming guidance.'
              : 'फसल सलाह, मौसम, कीट नियंत्रण, मंडी और खेती मार्गदर्शन के लिए।',
        ),
        _HelplineContact(
          emoji: '💰',
          title: _isEnglish ? 'PM-KISAN Helpline' : 'PM-KISAN हेल्पलाइन',
          numberLabel: '155261 / 1800-115-526',
          dialNumber: '155261',
          description: _isEnglish
              ? 'For installment, eKYC, beneficiary status and scheme payment issues.'
              : 'किस्त, eKYC, लाभार्थी स्थिति और योजना भुगतान समस्या के लिए।',
          extraDetail: _isEnglish
              ? 'Tap to call the first number shown above.'
              : 'ऊपर दिए गए पहले नंबर पर टैप करने से कॉल लगेगी।',
        ),
        _HelplineContact(
          emoji: '🏛️',
          title: _isEnglish
              ? 'Agriculture Ministry Helpline'
              : 'कृषि मंत्रालय हेल्पलाइन',
          numberLabel: '011-23381092',
          dialNumber: '01123381092',
          description: _isEnglish
              ? 'For ministry support, agriculture guidance and complaint routing.'
              : 'मंत्रालय सहायता, कृषि मार्गदर्शन और शिकायत मार्गदर्शन के लिए।',
        ),
        _HelplineContact(
          emoji: '🧪',
          title: _isEnglish
              ? 'Soil Health Card Helpline'
              : 'सॉइल हेल्थ कार्ड हेल्पलाइन',
          numberLabel: '1800-180-1551',
          dialNumber: '18001801551',
          description: _isEnglish
              ? 'For soil health card details, nutrient advice and soil record help.'
              : 'सॉइल हेल्थ कार्ड, पोषक तत्व सलाह और मिट्टी रिकॉर्ड सहायता के लिए।',
        ),
        _HelplineContact(
          emoji: '🌦️',
          title: _isEnglish
              ? 'Crop Insurance (PMFBY) Helpline'
              : 'फसल बीमा (PMFBY) हेल्पलाइन',
          numberLabel: '1800-200-7710',
          dialNumber: '18002007710',
          description: _isEnglish
              ? 'For crop insurance enrollment, claim and policy support.'
              : 'फसल बीमा पंजीकरण, दावा और पॉलिसी सहायता के लिए।',
        ),
        _HelplineContact(
          emoji: '🛒',
          title: _isEnglish
              ? 'National Agriculture Market (e-NAM)'
              : 'राष्ट्रीय कृषि बाजार (e-NAM)',
          numberLabel: '1800-270-0224',
          dialNumber: '18002700224',
          description: _isEnglish
              ? 'For e-NAM registration, trading and mandi platform support.'
              : 'e-NAM पंजीकरण, ट्रेडिंग और मंडी प्लेटफॉर्म सहायता के लिए।',
        ),
        _HelplineContact(
          emoji: '🧂',
          title: _isEnglish
              ? 'Fertilizer Complaint Helpline'
              : 'उर्वरक शिकायत हेल्पलाइन',
          numberLabel: '1800-233-3322',
          dialNumber: '18002333322',
          description: _isEnglish
              ? 'For fertilizer availability issues and complaint support.'
              : 'उर्वरक उपलब्धता की समस्या और शिकायत सहायता के लिए।',
        ),
        _HelplineContact(
          emoji: '🧴',
          title: _isEnglish
              ? 'Pesticide Complaint Helpline'
              : 'कीटनाशक शिकायत हेल्पलाइन',
          numberLabel: '1800-180-1551',
          dialNumber: '18001801551',
          description: _isEnglish
              ? 'For pesticide complaint, usage guidance and farming support.'
              : 'कीटनाशक शिकायत, उपयोग मार्गदर्शन और खेती सहायता के लिए।',
        ),
        _HelplineContact(
          emoji: '☁️',
          title: _isEnglish
              ? 'Weather Info (IMD Farmer Service)'
              : 'मौसम जानकारी (IMD किसान सेवा)',
          numberLabel: '1800-180-1717',
          dialNumber: '18001801717',
          description: _isEnglish
              ? 'For weather information, alerts and forecast support.'
              : 'मौसम जानकारी, अलर्ट और पूर्वानुमान सहायता के लिए।',
        ),
        _HelplineContact(
          emoji: '🐄',
          title: _isEnglish ? 'Animal Husbandry Helpline' : 'पशुपालन हेल्पलाइन',
          numberLabel: '1962',
          dialNumber: '1962',
          description: _isEnglish
              ? 'For cattle care, animal health and veterinary guidance.'
              : 'पशु देखभाल, पशु स्वास्थ्य और पशु चिकित्सकीय मार्गदर्शन के लिए।',
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
            child: Text(_languageCode == 'en' ? 'Close' : 'बंद करें'),
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
                      style: const TextStyle(
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
                            _languageCode == 'en' ? 'Farmer' : 'किसान',
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
                  boxShadow: const [
                    BoxShadow(
                      color: AppTheme.shadow,
                      blurRadius: 8,
                      offset: Offset(0, 2),
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
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textDark,
                            ),
                          ),
                          if (_email.isNotEmpty)
                            Text(
                              _email,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textMid,
                              ),
                            ),
                          if (profileLocation.isNotEmpty)
                            Text(
                              profileLocation,
                              style: const TextStyle(
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
                        _languageCode == 'en' ? 'Verified' : 'सत्यापित',
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
              _sectionHeader(_isEnglish
                  ? 'Farmer Helpline Numbers (India)'
                  : 'किसान हेल्पलाइन नंबर (भारत)'),
              Container(
                color: AppTheme.white,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                      child: Text(
                        _isEnglish
                            ? 'Call the number that matches your issue. If two numbers are shown, tapping the row calls the first number.'
                            : 'अपनी समस्या के अनुसार सही नंबर पर कॉल करें। यदि दो नंबर दिए हों, तो पंक्ति पर टैप करने से पहला नंबर कॉल होगा।',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textMid,
                          height: 1.4,
                        ),
                      ),
                    ),
                    for (var i = 0; i < helplineContacts.length; i++) ...[
                      _helplineTile(helplineContacts[i]),
                      if (i != helplineContacts.length - 1) _divider(),
                    ],
                  ],
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
                      _languageCode == 'en'
                          ? 'Government Schemes'
                          : 'सरकारी योजनाएँ',
                      trailing:
                          _languageCode == 'en' ? '15 schemes' : '15 योजनाएँ',
                      onTap: () => _showInfo(
                        _languageCode == 'en' ? 'Schemes' : 'योजनाएँ',
                        _languageCode == 'en'
                            ? 'PM-KISAN, PM Fasal Bima, RKVY and other schemes are available for you.'
                            : 'PM-KISAN, PM Fasal Bima, RKVY और अन्य योजनाएँ आपके लिए उपलब्ध हैं।',
                      ),
                    ),
                    _divider(),
                    _tile(
                      '❓',
                      _languageCode == 'en' ? 'FAQ' : 'आम सवाल (FAQ)',
                      onTap: () => _showInfo(
                        _languageCode == 'en' ? 'FAQ' : 'FAQ',
                        _languageCode == 'en'
                            ? 'For land disputes contact your nearest DLSA. For PM-KISAN payment issues call 155261.'
                            : 'भूमि विवाद में नज़दीकी DLSA से संपर्क करें। PM-KISAN भुगतान समस्या के लिए 155261 पर कॉल करें।',
                      ),
                    ),
                    _divider(),
                    _tile(
                      '📖',
                      _languageCode == 'en'
                          ? 'Farmer Rights Guide'
                          : 'किसान अधिकार गाइड',
                      onTap: () => _showInfo(
                        _languageCode == 'en'
                            ? 'Farmer Rights'
                            : 'किसान अधिकार',
                        _languageCode == 'en'
                            ? 'You have the right to access support schemes, crop insurance claims, legal aid, and land records.'
                            : 'आपको समर्थन योजनाओं, बीमा क्लेम, कानूनी सहायता और भूमि रिकॉर्ड देखने का अधिकार है।',
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
                              style: const TextStyle(
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
              _sectionHeader(_t('appInfo')),
              Container(
                color: AppTheme.white,
                child: Column(
                  children: [
                    _tile(
                      '⭐',
                      _languageCode == 'en' ? 'Rate App' : 'ऐप रेट करें',
                      onTap: () => _showInfo(
                        _languageCode == 'en' ? 'Thank you!' : 'धन्यवाद!',
                        _languageCode == 'en'
                            ? 'Your support helps us improve the app.'
                            : 'आपका समर्थन हमें ऐप बेहतर बनाने में मदद करता है।',
                      ),
                    ),
                    _divider(),
                    _tile('📱',
                        _languageCode == 'en' ? 'App Version' : 'ऐप संस्करण',
                        trailing: 'v1.0.4+6'),
                    _divider(),
                    _tile(
                      '🔒',
                      _languageCode == 'en'
                          ? 'Privacy Policy'
                          : 'गोपनीयता नीति',
                      onTap: () => _showInfo(
                        _languageCode == 'en'
                            ? 'Privacy Policy'
                            : 'गोपनीयता नीति',
                        _languageCode == 'en'
                            ? 'Your data stays protected. We do not share your personal information with third parties.'
                            : 'आपका डेटा सुरक्षित है। हम आपकी व्यक्तिगत जानकारी किसी तीसरे पक्ष को साझा नहीं करते।',
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
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppTheme.textMid,
          ),
        ),
      );

  Widget _divider() => const Divider(
        height: 1,
        indent: 56,
        color: AppTheme.divider,
      );

  Widget _helplineTile(_HelplineContact contact) {
    return ListTile(
      onTap: () => _call(contact.dialNumber),
      leading: Text(contact.emoji, style: const TextStyle(fontSize: 22)),
      title: Text(
        contact.title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppTheme.textDark,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              contact.numberLabel,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryGreen,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              contact.description,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textMid,
                height: 1.35,
              ),
            ),
            if (contact.extraDetail != null) ...[
              const SizedBox(height: 3),
              Text(
                contact.extraDetail!,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.textLight,
                  height: 1.3,
                ),
              ),
            ],
          ],
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: AppTheme.primaryGreen,
        size: 20,
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
        style: const TextStyle(fontSize: 14, color: AppTheme.textDark),
      ),
      trailing: trailing != null
          ? Text(
              trailing,
              style: const TextStyle(fontSize: 12, color: AppTheme.textMid),
            )
          : const Icon(Icons.chevron_right,
              color: AppTheme.textLight, size: 20),
      onTap: onTap,
    );
  }
}

class _HelplineContact {
  final String emoji;
  final String title;
  final String numberLabel;
  final String dialNumber;
  final String description;
  final String? extraDetail;

  const _HelplineContact({
    required this.emoji,
    required this.title,
    required this.numberLabel,
    required this.dialNumber,
    required this.description,
    this.extraDetail,
  });
}
