import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SchemesScreen extends StatefulWidget {
  const SchemesScreen({super.key});

  @override
  State<SchemesScreen> createState() => _SchemesScreenState();
}

class _SchemesScreenState extends State<SchemesScreen> {
  String _searchQuery = '';

  final List<Map<String, dynamic>> _schemes = [
    {
      'name': 'PM-KISAN',
      'full': 'प्रधानमंत्री किसान सम्मान निधि',
      'emoji': '💰',
      'amount': '₹6,000/वर्ष',
      'desc': 'छोटे और सीमान्त किसानों को प्रति वर्ष ₹6,000 तीन किस्तों में दिए जाते हैं।',
      'tag': 'केंद्र सरकार',
    },
    {
      'name': 'फसल बीमा',
      'full': 'प्रधानमंत्री फसल बीमा योजना (PMFBY)',
      'emoji': '🌾',
      'amount': 'प्रीमियम 2%',
      'desc': 'किसानों की फसल को प्राकृतिक आपदाओं से बचाने के लिए बीमा कवर।',
      'tag': 'केंद्र सरकार',
    },
    {
      'name': 'किसान क्रेडिट कार्ड',
      'full': 'Kisan Credit Card (KCC)',
      'emoji': '💳',
      'amount': '₹3 लाख तक',
      'desc': 'कम ब्याज दर पर कृषि ऋण। 4% ब्याज दर पर ₹3 लाख तक का ऋण।',
      'tag': 'बैंक',
    },
    {
      'name': 'PM Kisan Maan Dhan',
      'full': 'प्रधानमंत्री किसान मान-धन योजना',
      'emoji': '👴',
      'amount': '₹3,000/माह',
      'desc': '60 वर्ष की आयु के बाद ₹3,000 मासिक पेंशन।',
      'tag': 'केंद्र सरकार',
    },
    {
      'name': 'सॉयल हेल्थ कार्ड',
      'full': 'Soil Health Card Scheme',
      'emoji': '🌱',
      'amount': 'मुफ़्त',
      'desc': 'मिट्टी की जांच और उर्वरक सिफारिश कार्ड मुफ़्त में।',
      'tag': 'केंद्र सरकार',
    },
    {
      'name': 'PM Kusum',
      'full': 'Pradhan Mantri Kisan Urja Suraksha evam Utthaan Mahabhiyan',
      'emoji': '☀️',
      'amount': '90% सब्सिडी',
      'desc': 'सोलर पंप पर 90% तक की सब्सिडी। सिंचाई के लिए सोलर ऊर्जा।',
      'tag': 'केंद्र सरकार',
    },
    {
      'name': 'National Agriculture Market',
      'full': 'e-NAM (एकीकृत बाज़ार)',
      'emoji': '🏪',
      'amount': 'मुफ़्त पंजीकरण',
      'desc': 'किसान ऑनलाइन मंडी में अपनी फसल बेच सकते हैं।',
      'tag': 'डिजिटल',
    },
    {
      'name': 'एग्री इन्फ्रास्ट्रक्चर',
      'full': 'Agriculture Infrastructure Fund',
      'emoji': '🏭',
      'amount': '₹1 करोड़ तक',
      'desc': 'कोल्ड स्टोरेज और प्रसंस्करण के लिए ऋण पर ब्याज छूट।',
      'tag': 'केंद्र सरकार',
    },
    {
      'name': 'RKVY',
      'full': 'राष्ट्रीय कृषि विकास योजना',
      'emoji': '📈',
      'amount': 'अनुदान',
      'desc': 'कृषि और संबद्ध क्षेत्रों में समग्र विकास के लिए राज्यों को अनुदान।',
      'tag': 'राज्य + केंद्र',
    },
    {
      'name': 'Paramparagat Krishi',
      'full': 'Paramparagat Krishi Vikas Yojana (PKVY)',
      'emoji': '🌿',
      'amount': '₹50,000/हेक्टेयर',
      'desc': 'जैविक खेती को बढ़ावा देने के लिए किसानों को प्रति हेक्टेयर सहायता।',
      'tag': 'केंद्र सरकार',
    },
    {
      'name': 'मधुमक्खी पालन',
      'full': 'National Bee Keeping & Honey Mission',
      'emoji': '🐝',
      'amount': '75% सब्सिडी',
      'desc': 'मधुमक्खी पालन उपकरण पर 75% तक की सब्सिडी।',
      'tag': 'केंद्र सरकार',
    },
    {
      'name': 'मत्स्य संपदा योजना',
      'full': 'Pradhan Mantri Matsya Sampada Yojana',
      'emoji': '🐟',
      'amount': '₹20,050 करोड़',
      'desc': 'मत्स्य पालन क्षेत्र के विकास के लिए सहायता और अनुदान।',
      'tag': 'केंद्र सरकार',
    },
    {
      'name': 'पशुधन विकास',
      'full': 'Rashtriya Gokul Mission',
      'emoji': '🐄',
      'amount': 'सब्सिडी',
      'desc': 'देशी नस्ल के गोवंश संरक्षण और विकास के लिए सहायता।',
      'tag': 'केंद्र सरकार',
    },
    {
      'name': 'DBT Agriculture',
      'full': 'Direct Benefit Transfer for Agriculture',
      'emoji': '🏦',
      'amount': 'सीधा भुगतान',
      'desc': 'सभी सब्सिडी और लाभ सीधे बैंक खाते में।',
      'tag': 'केंद्र सरकार',
    },
    {
      'name': 'DLSA क़ानूनी मदद',
      'full': 'District Legal Services Authority',
      'emoji': '⚖️',
      'amount': 'मुफ़्त',
      'desc': 'ज़मीन विवाद, ऋण समस्या के लिए मुफ़्त क़ानूनी सहायता। 15100 पर कॉल करें।',
      'tag': 'क़ानूनी',
    },
  ];

  List<Map<String, dynamic>> get _filtered {
    if (_searchQuery.isEmpty) return _schemes;
    return _schemes.where((s) =>
      s['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
      s['full'].toString().toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        title: const Text('सरकारी योजनाएं'),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'योजना खोजें...',
                prefixIcon: const Icon(Icons.search, color: AppTheme.primaryGreen),
                filled: true,
                fillColor: AppTheme.bgLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              ),
            ),
          ),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _filtered.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final s = _filtered[index];
          return GestureDetector(
            onTap: () => _showDetail(s),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.shadow,
                    blurRadius: 6,
                    offset: const Offset(0, 2),
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
                    child: Center(child: Text(s['emoji'], style: const TextStyle(fontSize: 26))),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s['name'],
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          s['full'],
                          style: const TextStyle(fontSize: 11, color: AppTheme.textMid),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.bgGreen,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                s['amount'],
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppTheme.primaryGreen,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF3E0),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                s['tag'],
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
                  const Icon(Icons.chevron_right, color: AppTheme.primaryGreen),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showDetail(Map<String, dynamic> scheme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (_, ctrl) => SingleChildScrollView(
          controller: ctrl,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(child: Text(scheme['emoji'], style: const TextStyle(fontSize: 52))),
              const SizedBox(height: 12),
              Text(
                scheme['full'],
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textDark),
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
                          Text(scheme['amount'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.primaryGreen)),
                          const Text('लाभ', style: TextStyle(fontSize: 11, color: AppTheme.textMid)),
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
                          Text(scheme['tag'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFFE65100))),
                          const Text('श्रेणी', style: TextStyle(fontSize: 11, color: AppTheme.textMid)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('विवरण', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
              const SizedBox(height: 8),
              Text(scheme['desc'], style: const TextStyle(fontSize: 14, color: AppTheme.textMid, height: 1.7)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {},
                  child: const Text('अभी आवेदन करें'),
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
