import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/user_model.dart';
import '../services/app_language_service.dart';
import '../services/app_strings.dart';
import '../services/auth_service.dart';
import '../services/weather_service.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.onChangeTab});

  final ValueChanged<int>? onChangeTab;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UserModel? _user;
  Map<String, dynamic>? _weather;
  bool _weatherLoading = true;
  String _languageCode = AppLanguageService.currentCode.value;

  @override
  void initState() {
    super.initState();
    AppLanguageService.currentCode.addListener(_handleLanguageChanged);
    _loadUser();
    _loadWeather();
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
    _loadWeather();
  }

  Future<void> _loadUser() async {
    final profile = await AuthService.getUserProfile();
    if (mounted && profile != null) {
      setState(
        () => _user = UserModel(
          name: (profile['name'] ?? _t('farmerBrother')).toString(),
          mobile: (profile['mobile'] ?? '').toString(),
          state: (profile['state'] ?? '').toString(),
          joined: DateTime.now().year.toString(),
        ),
      );
      return;
    }

    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (mounted && firebaseUser != null) {
      setState(
        () => _user = UserModel(
          name: firebaseUser.displayName ?? _t('farmerBrother'),
          mobile: '',
          state: '',
          joined: DateTime.now().year.toString(),
        ),
      );
    }
  }

  Future<void> _loadWeather({bool showError = false}) async {
    if (mounted) {
      setState(() => _weatherLoading = true);
    }

    final weather = await WeatherService.getWeatherForCurrentLocation(
      languageCode: _languageCode,
    );
    if (!mounted) return;

    setState(() {
      _weather = weather;
      _weatherLoading = false;
    });

    if (showError && weather == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_t('weatherUnavailable')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _openWhatsAppUpdates() async {
    final message = Uri.encodeComponent(
      _languageCode == 'en'
          ? 'Hello! I want KisanKanoon WhatsApp updates.'
          : 'नमस्ते! मुझे KisanKanoon के WhatsApp अपडेट चाहिए।',
    );
    final uri = Uri.parse('https://wa.me/?text=$message');
    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('WhatsApp अभी नहीं खुल पाया।'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _showWeatherDetails() async {
    await _loadWeather(showError: true);
    if (!mounted || _weather == null) return;

    _showInfoDialog(
      _t('todayWeather'),
      '${_weather?['locationLabel'] ?? _t('yourLocation')}\n'
      '${_weather?['description'] ?? '--'}\n'
      '${_t('temperature')}: ${_weather?['temp']?.toStringAsFixed(0) ?? '--'}°C\n'
      '${_t('humidity')}: ${_weather?['humidity'] ?? '--'}%\n'
      '${_t('wind')}: ${_weather?['windspeed']?.toStringAsFixed(0) ?? '--'} km/h',
    );
  }

  Future<void> _callHelpline() async {
    await launchUrl(Uri.parse('tel:15100'));
  }

  bool get _isEnglish => _languageCode == 'en';

  String get _websitesTileLabel =>
      _isEnglish ? 'Govt Websites' : 'सरकारी वेबसाइटें';

  String get _websitesSheetTitle => _isEnglish
      ? 'Important Government Websites'
      : 'महत्वपूर्ण सरकारी वेबसाइटें';

  String get _websitesSheetHint => _isEnglish
      ? 'Tap any website to open it in your browser.'
      : 'किसी भी वेबसाइट को अपने ब्राउज़र में खोलने के लिए उस पर टैप करें।';

  String get _websiteOpenFailedMessage => _isEnglish
      ? 'The website could not be opened right now.'
      : 'वेबसाइट अभी नहीं खुल सकी।';

  List<_WebsiteCategory> _websiteCategories() {
    return [
      _WebsiteCategory(
        emoji: '🌾',
        title: _isEnglish
            ? 'Important Farmer Websites (India)'
            : 'महत्वपूर्ण किसान वेबसाइटें (भारत)',
        entries: [
          _WebsiteEntry(
            name: 'eNAM Portal',
            url: 'https://enam.gov.in',
            description: _isEnglish
                ? 'National agriculture market portal for mandi prices and trading.'
                : 'मंडी भाव और कृषि व्यापार के लिए राष्ट्रीय कृषि बाजार पोर्टल।',
          ),
          _WebsiteEntry(
            name: 'Farmers Portal',
            url: 'https://farmersportal.gov.in',
            description: _isEnglish
                ? 'Central portal for agriculture services, advisories, and schemes.'
                : 'कृषि सेवाओं, सलाह और योजनाओं की जानकारी के लिए केंद्रीय पोर्टल।',
          ),
          _WebsiteEntry(
            name: 'Kisan Suvidha',
            url: 'https://kisansuvidha.gov.in',
            description: _isEnglish
                ? 'Weather, mandi rates, plant protection, and advisory tools.'
                : 'मौसम, मंडी भाव, फसल सुरक्षा और किसान सलाह की उपयोगी जानकारी।',
          ),
          _WebsiteEntry(
            name: 'mKisan Portal',
            url: 'https://mkisan.gov.in',
            description: _isEnglish
                ? 'Mobile and SMS based farming advisories from government sources.'
                : 'सरकारी स्रोतों से मोबाइल और SMS आधारित खेती संबंधी सलाह।',
          ),
          _WebsiteEntry(
            name: 'Kisan Sarathi',
            url: 'https://kisansarathi.in',
            description: _isEnglish
                ? 'Digital agriculture helpdesk for farmer guidance and support.'
                : 'किसानों के मार्गदर्शन और सहायता के लिए डिजिटल कृषि हेल्पडेस्क।',
          ),
          _WebsiteEntry(
            name: 'Agmarknet',
            url: 'https://agmarknet.gov.in',
            description: _isEnglish
                ? 'Daily mandi arrivals and market price information.'
                : 'दैनिक मंडी आवक और बाजार भाव देखने का पोर्टल।',
          ),
          _WebsiteEntry(
            name: 'TNAU Agritech Portal',
            url: 'https://agritech.tnau.ac.in',
            description: _isEnglish
                ? 'Crop-wise technical farming guidance from TNAU.'
                : 'TNAU से फसलवार तकनीकी खेती मार्गदर्शन और जानकारी।',
          ),
          _WebsiteEntry(
            name: 'Access Agriculture',
            url: 'https://www.accessagriculture.org',
            description: _isEnglish
                ? 'Practical agriculture training videos and knowledge resources.'
                : 'कृषि प्रशिक्षण वीडियो और व्यावहारिक जानकारी का संग्रह।',
          ),
        ],
      ),
      _WebsiteCategory(
        emoji: '🧾',
        title: _isEnglish
            ? 'Land Record & Checking Websites'
            : 'भूमि अभिलेख और जांच वेबसाइटें',
        entries: [
          _WebsiteEntry(
            name: 'UP Bhulekh Portal',
            url: 'https://upbhulekh.gov.in',
            description: _isEnglish
                ? 'Check khatauni, khasra, and land ownership records in Uttar Pradesh.'
                : 'उत्तर प्रदेश में खसरा, खतौनी और भूमि स्वामित्व रिकॉर्ड देखने के लिए।',
          ),
          _WebsiteEntry(
            name: 'BhuNaksha UP',
            url: 'https://upbhunaksha.gov.in',
            description: _isEnglish
                ? 'View land maps and plot boundaries for Uttar Pradesh.'
                : 'उत्तर प्रदेश के भूमि नक्शे और प्लॉट सीमाएं देखने के लिए।',
          ),
          _WebsiteEntry(
            name: 'IGRS UP',
            url: 'https://igrsup.gov.in',
            description: _isEnglish
                ? 'UP registration, deed details, and property related checks.'
                : 'उत्तर प्रदेश में रजिस्ट्री, दस्तावेज़ और संपत्ति जांच सेवाओं के लिए।',
          ),
          _WebsiteEntry(
            name: 'PM-KISAN Portal',
            url: 'https://pmkisan.gov.in',
            description: _isEnglish
                ? 'Check beneficiary status, eKYC, and scheme payment details.'
                : 'लाभार्थी स्थिति, eKYC और योजना भुगतान की जानकारी देखने के लिए।',
          ),
          _WebsiteEntry(
            name: 'DILRMP',
            url: 'https://dilrmp.gov.in',
            description: _isEnglish
                ? 'National land records modernization and digital reform portal.'
                : 'भूमि अभिलेख आधुनिकीकरण और डिजिटल सुधार का राष्ट्रीय पोर्टल।',
          ),
          _WebsiteEntry(
            name: 'Mahabhulekh',
            url: 'https://mahabhulekh.maharashtra.gov.in',
            description: _isEnglish
                ? 'Maharashtra land records including 7/12 extract services.'
                : 'महाराष्ट्र के 7/12 और अन्य भूमि अभिलेख सेवाओं के लिए।',
          ),
          _WebsiteEntry(
            name: 'Bhoomi Portal',
            url: 'https://landrecords.karnataka.gov.in',
            description: _isEnglish
                ? 'Karnataka RTC, land record, and mutation related services.'
                : 'कर्नाटक RTC, भूमि रिकॉर्ड और म्यूटेशन सेवाओं के लिए।',
          ),
          _WebsiteEntry(
            name: 'MeeBhoomi',
            url: 'https://meebhoomi.ap.gov.in',
            description: _isEnglish
                ? 'Andhra Pradesh land records, passbook, and ownership details.'
                : 'आंध्र प्रदेश में भूमि रिकॉर्ड, पासबुक और स्वामित्व जानकारी के लिए।',
          ),
        ],
      ),
    ];
  }

  Future<void> _openWebsite(String url) async {
    final launched = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );

    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_websiteOpenFailedMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showImportantWebsitesSheet() {
    final categories = _websiteCategories();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SafeArea(
        top: false,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.85,
          ),
          decoration: const BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                width: 42,
                height: 4,
                margin: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  color: AppTheme.divider,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _websitesSheetTitle,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _websitesSheetHint,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textMid,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    8,
                    20,
                    MediaQuery.of(ctx).padding.bottom + 20,
                  ),
                  child: Column(
                    children: categories
                        .map((category) => _buildWebsiteCategory(category))
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWebsiteCategory(_WebsiteCategory category) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(category.emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  category.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...category.entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Material(
                color: const Color(0xFFF8FAF8),
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _openWebsite(entry.url),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.divider),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.name,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textDark,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                entry.description,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textMid,
                                  height: 1.45,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                entry.url,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.primaryGreen,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Icon(
                          Icons.chevron_right,
                          color: AppTheme.primaryGreen,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (_languageCode == 'en') {
      if (hour < 12) return 'Good morning';
      if (hour < 17) return 'Hello';
      return 'Good evening';
    }

    if (hour < 12) return 'सुप्रभात';
    if (hour < 17) return 'नमस्ते';
    return 'शुभ संध्या';
  }

  void _showInfoDialog(String title, String content) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        content: Text(
          content,
          style: const TextStyle(fontSize: 14, height: 1.6),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(_t('ok')),
          ),
        ],
      ),
    );
  }

  void _showLangDialog() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: AppTheme.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              _t('chooseLanguage'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
          ...AppLanguageService.supportedLanguages.map(
            (language) => ListTile(
              title: Text(language.name),
              subtitle: language.code == _languageCode
                  ? Text(
                      _t('selectedLanguage'),
                      style: const TextStyle(
                        color: AppTheme.primaryGreen,
                        fontSize: 12,
                      ),
                    )
                  : null,
              trailing: language.code == _languageCode
                  ? const Icon(
                      Icons.check_circle,
                      color: AppTheme.primaryGreen,
                    )
                  : const Icon(
                      Icons.chevron_right,
                      color: AppTheme.primaryGreen,
                    ),
              onTap: () async {
                await AppLanguageService.setLanguage(language.code);
                if (ctx.mounted) Navigator.pop(ctx);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      AppStrings.languageChangedMessage(
                        AppLanguageService.currentCode.value,
                        language.name,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  List<_FeatureItem> _featureItems() {
    return [
      _FeatureItem(emoji: '📷', label: _t('scanDoc'), tab: 1),
      _FeatureItem(emoji: '🏛️', label: _t('navSchemes'), tab: 3),
      _FeatureItem(emoji: '📁', label: _t('myDocuments'), tab: 2),
      _FeatureItem(emoji: '🌾', label: _websitesTileLabel, action: 'websites'),
      _FeatureItem(emoji: '💬', label: _t('whatsapp'), action: 'whatsapp'),
      _FeatureItem(emoji: '☀️', label: _t('weather'), action: 'weather'),
      _FeatureItem(emoji: '📰', label: _t('news'), action: 'news'),
      _FeatureItem(emoji: '🌐', label: _t('language'), action: 'lang'),
      _FeatureItem(emoji: '📞', label: _t('helpline'), action: 'helpline'),
    ];
  }

  Future<void> _handleFeatureTap(_FeatureItem item) async {
    if (item.tab != null) {
      widget.onChangeTab?.call(item.tab!);
      return;
    }

    switch (item.action) {
      case 'websites':
        _showImportantWebsitesSheet();
        break;
      case 'whatsapp':
        await _openWhatsAppUpdates();
        break;
      case 'weather':
        await _showWeatherDetails();
        break;
      case 'news':
        _showInfoDialog(
          _t('farmerNews'),
          _languageCode == 'en'
              ? 'PM-KISAN updates, weather changes, and your saved documents can all be tracked here.'
              : 'PM-KISAN अपडेट, मौसम बदलाव और आपके सेव किए गए दस्तावेज़ यहां एक साथ देखे जा सकते हैं।',
        );
        break;
      case 'lang':
        _showLangDialog();
        break;
      case 'helpline':
        await _callHelpline();
        break;
    }
  }

  Widget _buildWeatherBanner() {
    return Container(
      color: AppTheme.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.bgGreen,
          borderRadius: BorderRadius.circular(12),
        ),
        child: _weatherLoading
            ? const Center(
                child: SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : Row(
                children: [
                  Text(
                    (_weather?['emoji'] ?? '☀️').toString(),
                    style: const TextStyle(fontSize: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _t('todayWeather'),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                        Text(
                          '${_weather?['locationLabel'] ?? _t('yourLocation')} | ${_weather?['description'] ?? AppStrings.weatherDescription(_languageCode, 0)} | ${_t('humidity')}: ${_weather?['humidity'] ?? '--'}%',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textMid,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        '${_weather?['temp']?.toStringAsFixed(0) ?? '--'}°',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                      IconButton(
                        onPressed: _loadWeather,
                        icon: const Icon(
                          Icons.refresh,
                          size: 18,
                          color: AppTheme.primaryGreen,
                        ),
                        tooltip: _t('refreshWeather'),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildWhatsAppBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(14),
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
          const Text('💬', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _t('whatsappUpdates'),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textDark,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _openWhatsAppUpdates,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(_t('enable'), style: const TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureGrid() {
    final items = _featureItems();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _t('services'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 8,
            mainAxisSpacing: 12,
            children: items
                .map(
                  (item) => _FeatureGridItem(
                    emoji: item.emoji,
                    label: item.label,
                    onTap: () => _handleFeatureTap(item),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionCard() {
    final stateName =
        _user?.state.isNotEmpty == true ? _user!.state : 'आपके राज्य';
    final content = _languageCode == 'en'
        ? 'Since you are in $stateName, keep your documents safe, track weather updates, and follow government schemes from one place.'
        : 'चूंकि आप $stateName में हैं, आपके लिए दस्तावेज़ सुरक्षित रखना, मौसम अपडेट देखना और सरकारी योजनाओं की जानकारी एक ही जगह उपलब्ध है।';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade50, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  shape: BoxShape.circle,
                ),
                child: const Text('✨', style: TextStyle(fontSize: 14)),
              ),
              const SizedBox(width: 8),
              Text(
                _t('smartSuggestion'),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFE65100),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.textMid,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsSection() {
    return Container(
      color: AppTheme.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _t('farmerNews'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 12),
          _NewsCard(
            emoji: '🏛️',
            title: _languageCode == 'en'
                ? 'Check PM-KISAN and other scheme updates'
                : 'PM-KISAN और अन्य योजनाओं के अपडेट देखें',
            tag: _t('navSchemes'),
          ),
          const Divider(height: 1, color: AppTheme.divider),
          _NewsCard(
            emoji: '🌦️',
            title: _languageCode == 'en'
                ? 'Weather card now updates from your real location'
                : 'मौसम कार्ड अब आपकी लोकेशन से अपडेट होता है',
            tag: _t('weather'),
          ),
          const Divider(height: 1, color: AppTheme.divider),
          _NewsCard(
            emoji: '📂',
            title: _languageCode == 'en'
                ? 'Scanned and uploaded documents are saved in your folder'
                : 'स्कैन और अपलोड किए गए दस्तावेज़ अब फ़ोल्डर में सेव होंगे',
            tag: _t('myDocuments'),
          ),
        ],
      ),
    );
  }

  Widget _buildTrustedSection() {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF0F2F0),
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 80),
      margin: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _t('trustedByFarmers'),
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: Colors.black26,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _t('farmSmartly'),
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black38,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppTheme.bgGreen,
                    shape: BoxShape.circle,
                  ),
                  child: const Text('⚖️', style: TextStyle(fontSize: 14)),
                ),
                const SizedBox(width: 8),
                const Text(
                  'KISAN.KANOON',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.primaryGreen,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              snap: true,
              backgroundColor: AppTheme.white,
              surfaceTintColor: AppTheme.white,
              elevation: 0,
              title: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppTheme.bgGreen,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Text('⚖️', style: TextStyle(fontSize: 20)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$_greeting 🙏 ${_user?.name ?? _t('farmerBrother')}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const Text(
                        'KisanKanoon',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  _buildWeatherBanner(),
                  const SizedBox(height: 8),
                  _buildWhatsAppBanner(),
                  const SizedBox(height: 20),
                  _buildFeatureGrid(),
                  const SizedBox(height: 24),
                  _buildSuggestionCard(),
                  const SizedBox(height: 24),
                  _buildNewsSection(),
                  _buildTrustedSection(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureItem {
  final String emoji;
  final String label;
  final int? tab;
  final String? action;

  const _FeatureItem({
    required this.emoji,
    required this.label,
    this.tab,
    this.action,
  });
}

class _WebsiteCategory {
  final String emoji;
  final String title;
  final List<_WebsiteEntry> entries;

  const _WebsiteCategory({
    required this.emoji,
    required this.title,
    required this.entries,
  });
}

class _WebsiteEntry {
  final String name;
  final String description;
  final String url;

  const _WebsiteEntry({
    required this.name,
    required this.description,
    required this.url,
  });
}

class _FeatureGridItem extends StatelessWidget {
  final String emoji;
  final String label;
  final VoidCallback onTap;

  const _FeatureGridItem({
    required this.emoji,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(
                  color: AppTheme.shadow,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 26)),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppTheme.textDark,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _NewsCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String tag;

  const _NewsCard({
    required this.emoji,
    required this.title,
    required this.tag,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.bgGreen,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.bgGreen,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    tag,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppTheme.primaryGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: AppTheme.primaryGreen,
            size: 20,
          ),
        ],
      ),
    );
  }
}
