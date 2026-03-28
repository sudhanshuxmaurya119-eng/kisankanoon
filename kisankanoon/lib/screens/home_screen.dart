import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../services/weather_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UserModel? _user;
  Map<String, dynamic>? _weather;
  bool _weatherLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadWeather();
  }

  Future<void> _loadUser() async {
    // Try Firestore profile first
    final profile = await AuthService.getUserProfile();
    if (mounted && profile != null) {
      setState(() => _user = UserModel(
        name: profile['name'] ?? 'किसान भाई',
        mobile: profile['mobile'] ?? '',
        state: profile['state'] ?? '',
        joined: DateTime.now().year.toString(),
      ));
      return;
    }
    // Fallback: use Firebase Auth display name
    final fbUser = FirebaseAuth.instance.currentUser;
    if (mounted && fbUser != null) {
      setState(() => _user = UserModel(
        name: fbUser.displayName ?? 'किसान भाई',
        mobile: '',
        state: '',
        joined: DateTime.now().year.toString(),
      ));
    }
  }

  Future<void> _loadWeather() async {
    final w = await WeatherService.getWeather();
    if (mounted) setState(() { _weather = w; _weatherLoading = false; });
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'सुप्रभात';
    if (hour < 17) return 'नमस्ते';
    return 'शुभ संध्या';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
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
                    child: const Center(child: Text('⚖️', style: TextStyle(fontSize: 20))),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$_greeting 🙏 ${_user?.name ?? 'किसान भाई'}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const Text(
                        'KisanKanoon',
                        style: TextStyle(fontSize: 11, color: AppTheme.primaryGreen),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.accentGreen, width: 1.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Text('🌾', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 4),
                      const Text(
                        'किसान',
                        style: TextStyle(
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

            SliverToBoxAdapter(
              child: Column(
                children: [
                  // Weather Banner (LIVE)
                  Container(
                    color: AppTheme.white,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.bgGreen,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: _weatherLoading
                          ? const Center(child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)))
                          : Row(
                              children: [
                                Text(_weather?['emoji'] ?? '☀️', style: const TextStyle(fontSize: 28)),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('आज का मौसम', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.primaryGreen)),
                                      Text(
                                        '${_weather?['description'] ?? 'साफ आसमान'} | नमी: ${_weather?['humidity'] ?? '--'}%',
                                        style: const TextStyle(fontSize: 12, color: AppTheme.textMid),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '${_weather?['temp']?.toStringAsFixed(0) ?? '--'}°',
                                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppTheme.primaryGreen),
                                ),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // WhatsApp Banner
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppTheme.white,
                      borderRadius: BorderRadius.circular(14),
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
                        const Text('💬', style: TextStyle(fontSize: 24)),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'WhatsApp अपडेट पाएं',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textDark,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text('चालू करें', style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Feature Grid
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'सेवाएं',
                          style: TextStyle(
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
                          children: _buildFeatureItems(context),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // AI Recommendations (TigerGraph Hackathon Track)
                  Container(
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
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(color: Colors.orange.shade100, shape: BoxShape.circle),
                              child: const Text('✨', style: TextStyle(fontSize: 14)),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'स्मार्ट AI सुझाव (TigerGraph)',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFFE65100), // Deep orange
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(fontSize: 13, color: AppTheme.textMid, height: 1.4, fontFamily: 'GoogleFonts.inter'),
                            children: [
                              const TextSpan(text: 'चूंकि आप '),
                              TextSpan(text: '"${_user?.state ?? 'उत्तर प्रदेश'}"', style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.textDark)),
                              const TextSpan(text: ' में रहते हैं और '),
                              const TextSpan(text: '"गन्ने"', style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.textDark)),
                              const TextSpan(text: ' की खेती करते हैं, आपके लिए सबसे उपयुक्त योजना:'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppTheme.divider),
                          ),
                          child: Row(
                            children: [
                              const Text('🏛️', style: TextStyle(fontSize: 28)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text('राष्ट्रीय कृषि विकास योजना', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
                                    SizedBox(height: 4),
                                    Text('सब्सिडी और ऋण सहायता', style: TextStyle(fontSize: 12, color: AppTheme.primaryGreen, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.textLight),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Quick News Section
                  Container(
                    color: AppTheme.white,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'किसान समाचार',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textDark,
                              ),
                            ),
                            Text(
                              'सभी देखें',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppTheme.primaryGreen,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildNewsCard('PM-KISAN: 20वीं किस्त जल्द', 'सरकारी योजनाएं', '🏛️'),
                        const Divider(height: 1, color: AppTheme.divider),
                        _buildNewsCard('मानसून 2025 — जून में समय पर', 'मौसम', '🌧️'),
                        const Divider(height: 1, color: AppTheme.divider),
                        _buildNewsCard('फसल बीमा: अंतिम तारीख 31 मार्च', 'बीमा', '📋'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Rating Card
                  _buildRatingCard(),

                  // Trusted Section
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

  List<Widget> _buildFeatureItems(BuildContext context) {
    final items = [
      {'emoji': '📷', 'label': 'स्कैन करें', 'tab': 1},
      {'emoji': '🏛️', 'label': 'सरकारी योजनाएं', 'tab': 3},
      {'emoji': '📁', 'label': 'मेरे दस्तावेज़', 'tab': 2},
      {'emoji': '⚖️', 'label': 'क़ानूनी मदद', 'tab': null, 'action': 'helpline'},
      {'emoji': '☀️', 'label': 'मौसम', 'tab': null, 'action': 'weather'},
      {'emoji': '📰', 'label': 'समाचार', 'tab': null, 'action': 'news'},
      {'emoji': '🌐', 'label': 'भाषा', 'tab': null, 'action': 'lang'},
      {'emoji': '📞', 'label': 'हेल्पलाइन', 'tab': null, 'action': 'helpline'},
    ];
    return items.map((item) => _FeatureGridItem(
      emoji: item['emoji'] as String,
      label: item['label'] as String,
      onTap: () {
        final tab = item['tab'] as int?;
        final action = item['action'] as String?;
        if (tab != null) {
          // Navigate to the correct bottom tab via the scaffold
          final scaffold = context.findAncestorStateOfType<_HomeScreenState>();
          // find main scaffold to switch tab
          DefaultTabController.maybeOf(context);
          _switchTab(context, tab);
        } else if (action == 'helpline') {
          launchUrl(Uri.parse('tel:15100'));
        } else if (action == 'weather') {
          _showInfoDialog(
            context,
            'आज का मौसम ☀️',
            'धूप, बारिश नहीं\nतापमान: 25°C\nनमी: 40%\nहवा: 12 km/h',
          );
        } else if (action == 'news') {
          _showInfoDialog(
            context,
            'किसान समाचार 📰',
            '• PM-KISAN: 20वीं किस्त जल्द आ रही है।\n• मानसून 2025 — जून में समय पर आने की उम्मीद।\n• फसल बीमा: अंतिम तारीख 31 मार्च।',
          );
        } else if (action == 'lang') {
          _showLangDialog(context);
        }
      },
    )).toList();
  }

  void _switchTab(BuildContext context, int tab) {
    // Walk up the widget tree to find MainScaffold state
    final state = context.findRootAncestorStateOfType<State>();
    // Use a global key approach via Navigator
    Navigator.of(context).pushNamed('/main', arguments: tab);
  }

  void _showInfoDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        content: Text(content, style: const TextStyle(fontSize: 14, height: 1.6)),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('ठीक है'))],
      ),
    );
  }

  void _showLangDialog(BuildContext context) {
    final langs = [
      {'code': 'hi', 'name': 'हिंदी'},
      {'code': 'mr', 'name': 'मराठी'},
      {'code': 'pa', 'name': 'ਪੰਜਾਬੀ'},
      {'code': 'te', 'name': 'తెలుగు'},
      {'code': 'bn', 'name': 'বাংলা'},
    ];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40, height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(color: AppTheme.divider, borderRadius: BorderRadius.circular(2)),
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('भाषा चुनें', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          ),
          ...langs.map((l) => ListTile(
            title: Text(l['name']!),
            trailing: const Icon(Icons.chevron_right, color: AppTheme.primaryGreen),
            onTap: () async {
              await StorageService.setLang(l['code']!);
              if (ctx.mounted) Navigator.pop(ctx);
            },
          )),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildNewsCard(String title, String tag, String emoji) {
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
            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 22))),
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
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
          const Icon(Icons.chevron_right, color: AppTheme.primaryGreen, size: 20),
        ],
      ),
    );
  }

  Widget _buildRatingCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'How would you rate\nKisanKanoon app?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textDark,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'We\'d love to hear your feedback so that we can serve you better',
                      style: TextStyle(fontSize: 12, color: AppTheme.textMid, height: 1.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.bgLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('📲', style: TextStyle(fontSize: 28)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: List.generate(
              5,
              (index) => const Padding(
                padding: EdgeInsets.only(right: 8),
                child: Icon(Icons.star_rate_rounded, color: Colors.black26, size: 40),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrustedSection() {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF0F2F0), // Light grey matching screenshot
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 80),
      margin: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Trusted by lakhs of\nfarmers!',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: Colors.black26,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Farm smartly with KisanKanoon',
            style: TextStyle(
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
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
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
              boxShadow: [
                BoxShadow(
                  color: AppTheme.shadow,
                  blurRadius: 6,
                  offset: const Offset(0, 2),
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
