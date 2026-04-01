import 'package:flutter/material.dart';

import '../services/app_language_service.dart';
import '../theme/app_theme.dart';

class SchemesScreen extends StatefulWidget {
  const SchemesScreen({super.key});

  @override
  State<SchemesScreen> createState() => _SchemesScreenState();
}

class _SchemesScreenState extends State<SchemesScreen> {
  String _searchQuery = '';
  String _languageCode = AppLanguageService.currentCode.value;

  static const List<Map<String, String>> _schemes = [
    {
      'nameHi': 'पीएम-किसान',
      'nameEn': 'PM-KISAN',
      'fullHi': 'प्रधानमंत्री किसान सम्मान निधि',
      'fullEn': 'Pradhan Mantri Kisan Samman Nidhi',
      'emoji': '💰',
      'amountHi': '₹6,000/वर्ष',
      'amountEn': '₹6,000/year',
      'descHi':
          'छोटे और सीमांत किसानों को प्रति वर्ष ₹6,000 तीन किस्तों में दिए जाते हैं।',
      'descEn':
          'Small and marginal farmers receive ₹6,000 per year in three installments.',
      'tagHi': 'केंद्र सरकार',
      'tagEn': 'Central',
    },
    {
      'nameHi': 'फसल बीमा',
      'nameEn': 'Crop Insurance',
      'fullHi': 'प्रधानमंत्री फसल बीमा योजना (PMFBY)',
      'fullEn': 'Pradhan Mantri Fasal Bima Yojana (PMFBY)',
      'emoji': '🌾',
      'amountHi': 'प्रीमियम 2%',
      'amountEn': '2% premium',
      'descHi':
          'प्राकृतिक आपदाओं, बारिश या नुकसान के समय फसल सुरक्षा के लिए बीमा कवर।',
      'descEn':
          'Insurance cover to protect crops against natural disasters, rain, and damage.',
      'tagHi': 'केंद्र सरकार',
      'tagEn': 'Central',
    },
    {
      'nameHi': 'किसान क्रेडिट कार्ड',
      'nameEn': 'Kisan Credit Card',
      'fullHi': 'किसान क्रेडिट कार्ड (KCC)',
      'fullEn': 'Kisan Credit Card (KCC)',
      'emoji': '💳',
      'amountHi': '₹3 लाख तक',
      'amountEn': 'Up to ₹3 lakh',
      'descHi':
          'कम ब्याज दर पर कृषि ऋण। समय पर भुगतान पर ब्याज में अतिरिक्त राहत मिलती है।',
      'descEn':
          'Low-interest farm credit with additional interest relief for timely repayment.',
      'tagHi': 'बैंक',
      'tagEn': 'Bank',
    },
    {
      'nameHi': 'किसान मान-धन',
      'nameEn': 'Kisan Maan Dhan',
      'fullHi': 'प्रधानमंत्री किसान मान-धन योजना',
      'fullEn': 'Pradhan Mantri Kisan Maan Dhan Yojana',
      'emoji': '👴',
      'amountHi': '₹3,000/माह',
      'amountEn': '₹3,000/month',
      'descHi': '60 वर्ष की आयु के बाद योग्य किसानों को मासिक पेंशन सहायता।',
      'descEn':
          'Monthly pension support for eligible farmers after the age of 60.',
      'tagHi': 'केंद्र सरकार',
      'tagEn': 'Pension',
    },
    {
      'nameHi': 'सॉइल हेल्थ कार्ड',
      'nameEn': 'Soil Health Card',
      'fullHi': 'सॉइल हेल्थ कार्ड योजना',
      'fullEn': 'Soil Health Card Scheme',
      'emoji': '🌱',
      'amountHi': 'मुफ़्त',
      'amountEn': 'Free',
      'descHi':
          'मिट्टी की जांच के आधार पर उर्वरक और पोषण संबंधी सही सलाह दी जाती है।',
      'descEn':
          'Provides fertilizer and nutrient guidance based on soil testing.',
      'tagHi': 'मुफ़्त सेवा',
      'tagEn': 'Free service',
    },
    {
      'nameHi': 'पीएम-कुसुम',
      'nameEn': 'PM Kusum',
      'fullHi': 'प्रधानमंत्री किसान ऊर्जा सुरक्षा एवं उत्थान महाभियान',
      'fullEn': 'Pradhan Mantri Kisan Urja Suraksha Evam Utthaan Mahabhiyan',
      'emoji': '☀️',
      'amountHi': '90% सब्सिडी तक',
      'amountEn': 'Up to 90% subsidy',
      'descHi':
          'सोलर पंप और कृषि ऊर्जा समाधान के लिए वित्तीय सहायता उपलब्ध है।',
      'descEn':
          'Financial support for solar pumps and clean energy solutions for farming.',
      'tagHi': 'सोलर',
      'tagEn': 'Solar',
    },
    {
      'nameHi': 'ई-नाम',
      'nameEn': 'e-NAM',
      'fullHi': 'राष्ट्रीय कृषि बाजार',
      'fullEn': 'National Agriculture Market',
      'emoji': '🏪',
      'amountHi': 'मुफ़्त पंजीकरण',
      'amountEn': 'Free registration',
      'descHi':
          'किसान ऑनलाइन मंडी प्लेटफॉर्म पर अपनी फसल बेहतर दाम में बेच सकते हैं।',
      'descEn':
          'Farmers can sell produce on the online mandi platform for better price discovery.',
      'tagHi': 'डिजिटल',
      'tagEn': 'Digital',
    },
    {
      'nameHi': 'एग्री इन्फ्रास्ट्रक्चर',
      'nameEn': 'Agri Infrastructure',
      'fullHi': 'एग्रीकल्चर इन्फ्रास्ट्रक्चर फंड',
      'fullEn': 'Agriculture Infrastructure Fund',
      'emoji': '🏭',
      'amountHi': '₹1 करोड़ तक',
      'amountEn': 'Up to ₹1 crore',
      'descHi':
          'कोल्ड स्टोरेज, वेयरहाउस और कृषि प्रसंस्करण इकाइयों के लिए सहायता।',
      'descEn':
          'Support for cold storage, warehousing, and farm processing infrastructure.',
      'tagHi': 'इन्फ्रा',
      'tagEn': 'Infra',
    },
    {
      'nameHi': 'आरकेवीवाई',
      'nameEn': 'RKVY',
      'fullHi': 'राष्ट्रीय कृषि विकास योजना',
      'fullEn': 'Rashtriya Krishi Vikas Yojana',
      'emoji': '📈',
      'amountHi': 'अनुदान',
      'amountEn': 'Grant support',
      'descHi':
          'कृषि और संबंधित क्षेत्रों के विकास के लिए राज्यों और किसानों को सहायता।',
      'descEn':
          'Supports states and farmers in agriculture and allied sector development.',
      'tagHi': 'राज्य + केंद्र',
      'tagEn': 'State + Central',
    },
    {
      'nameHi': 'परंपरागत कृषि',
      'nameEn': 'Organic Farming',
      'fullHi': 'परंपरागत कृषि विकास योजना (PKVY)',
      'fullEn': 'Paramparagat Krishi Vikas Yojana (PKVY)',
      'emoji': '🌿',
      'amountHi': '₹50,000/हेक्टेयर',
      'amountEn': '₹50,000/hectare',
      'descHi':
          'जैविक खेती को बढ़ावा देने के लिए किसानों को समूह आधारित सहायता मिलती है।',
      'descEn':
          'Group-based support is provided to encourage organic farming practices.',
      'tagHi': 'ऑर्गेनिक',
      'tagEn': 'Organic',
    },
    {
      'nameHi': 'मधुमक्खी पालन',
      'nameEn': 'Bee Keeping',
      'fullHi': 'नेशनल बी कीपिंग एंड हनी मिशन',
      'fullEn': 'National Bee Keeping and Honey Mission',
      'emoji': '🐝',
      'amountHi': '75% सब्सिडी तक',
      'amountEn': 'Up to 75% subsidy',
      'descHi':
          'मधुमक्खी पालन, शहद उत्पादन और संबंधित उपकरणों पर सहायता मिलती है।',
      'descEn':
          'Support is available for bee keeping, honey production, and related equipment.',
      'tagHi': 'उद्यम',
      'tagEn': 'Enterprise',
    },
    {
      'nameHi': 'मत्स्य संपदा',
      'nameEn': 'Matsya Sampada',
      'fullHi': 'प्रधानमंत्री मत्स्य संपदा योजना',
      'fullEn': 'Pradhan Mantri Matsya Sampada Yojana',
      'emoji': '🐟',
      'amountHi': '₹20,050 करोड़',
      'amountEn': '₹20,050 crore',
      'descHi':
          'मत्स्य पालन और जलीय कृषि क्षेत्र के विकास के लिए वित्तीय सहायता।',
      'descEn':
          'Financial support for fisheries and aquaculture sector development.',
      'tagHi': 'मत्स्य',
      'tagEn': 'Fisheries',
    },
    {
      'nameHi': 'पशुधन विकास',
      'nameEn': 'Livestock Development',
      'fullHi': 'राष्ट्रीय गोकुल मिशन',
      'fullEn': 'Rashtriya Gokul Mission',
      'emoji': '🐄',
      'amountHi': 'सब्सिडी',
      'amountEn': 'Subsidy',
      'descHi':
          'देशी नस्ल सुधार, दुग्ध उत्पादन और पशुपालन विकास के लिए सहायता।',
      'descEn':
          'Support for indigenous breed improvement, dairy production, and livestock growth.',
      'tagHi': 'पशुपालन',
      'tagEn': 'Livestock',
    },
    {
      'nameHi': 'डीएलएसए कानूनी मदद',
      'nameEn': 'DLSA Legal Help',
      'fullHi': 'जिला विधिक सेवा प्राधिकरण',
      'fullEn': 'District Legal Services Authority',
      'emoji': '⚖️',
      'amountHi': 'मुफ़्त',
      'amountEn': 'Free',
      'descHi':
          'जमीन विवाद, ऋण समस्या और कानूनी मामलों के लिए मुफ्त सहायता। 15100 पर कॉल करें।',
      'descEn':
          'Free legal support for land disputes, loan issues, and related matters. Call 15100.',
      'tagHi': 'कानूनी',
      'tagEn': 'Legal',
    },
  ];

  bool get _isEnglish => _languageCode == 'en';

  @override
  void initState() {
    super.initState();
    AppLanguageService.currentCode.addListener(_handleLanguageChanged);
  }

  @override
  void dispose() {
    AppLanguageService.currentCode.removeListener(_handleLanguageChanged);
    super.dispose();
  }

  void _handleLanguageChanged() {
    if (!mounted) {
      return;
    }
    setState(() {
      _languageCode = AppLanguageService.currentCode.value;
    });
  }

  String _screenText(String english, String hindi) {
    return _isEnglish ? english : hindi;
  }

  String _schemeText(Map<String, String> scheme, String prefix) {
    return _isEnglish ? scheme['${prefix}En']! : scheme['${prefix}Hi']!;
  }

  List<Map<String, String>> get _filteredSchemes {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) {
      return _schemes;
    }

    return _schemes.where((scheme) {
      final name = _schemeText(scheme, 'name').toLowerCase();
      final full = _schemeText(scheme, 'full').toLowerCase();
      final desc = _schemeText(scheme, 'desc').toLowerCase();
      return name.contains(query) ||
          full.contains(query) ||
          desc.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        title: Text(
          _screenText('Government Schemes', 'सरकारी योजनाएं'),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: _screenText(
                  'Search schemes...',
                  'योजनाएं खोजें...',
                ),
                prefixIcon:
                    const Icon(Icons.search, color: AppTheme.primaryGreen),
                filled: true,
                fillColor: AppTheme.bgLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              ),
            ),
          ),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredSchemes.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final scheme = _filteredSchemes[index];
          return GestureDetector(
            onTap: () => _showDetail(scheme),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: AppTheme.shadow,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppTheme.bgGreen,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        scheme['emoji']!,
                        style: const TextStyle(fontSize: 26),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _schemeText(scheme, 'name'),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _schemeText(scheme, 'full'),
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.textMid,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
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
                                _schemeText(scheme, 'amount'),
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppTheme.primaryGreen,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF3E0),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                _schemeText(scheme, 'tag'),
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFFE65100),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: AppTheme.primaryGreen,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showDetail(Map<String, String> scheme) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.55,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (_, controller) => SingleChildScrollView(
          controller: controller,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  scheme['emoji']!,
                  style: const TextStyle(fontSize: 52),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _schemeText(scheme, 'full'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textDark,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.bgGreen,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Text(
                            _schemeText(scheme, 'amount'),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primaryGreen,
                            ),
                          ),
                          Text(
                            _screenText('Benefit', 'लाभ'),
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.textMid,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Text(
                            _schemeText(scheme, 'tag'),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFE65100),
                            ),
                          ),
                          Text(
                            _screenText('Category', 'श्रेणी'),
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.textMid,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                _screenText('Details', 'विवरण'),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _schemeText(scheme, 'desc'),
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textMid,
                  height: 1.7,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {},
                  child: Text(
                    _screenText('Apply now', 'अभी आवेदन करें'),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
