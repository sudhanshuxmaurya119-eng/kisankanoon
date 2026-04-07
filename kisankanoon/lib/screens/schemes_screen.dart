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
      'nameHi': 'à¤ªà¥€à¤à¤®-à¤•à¤¿à¤¸à¤¾à¤¨',
      'nameEn': 'PM-KISAN',
      'fullHi':
          'à¤ªà¥à¤°à¤§à¤¾à¤¨à¤®à¤‚à¤¤à¥à¤°à¥€ à¤•à¤¿à¤¸à¤¾à¤¨ à¤¸à¤®à¥à¤®à¤¾à¤¨ à¤¨à¤¿à¤§à¤¿',
      'fullEn': 'Pradhan Mantri Kisan Samman Nidhi',
      'emoji': '💰',
      'amountHi': '₹6,000/वर्ष',
      'amountEn': '₹6,000/year',
      'descHi':
          'छोटे और सीमांत किसानों को प्रति वर्ष ₹6,000 तीन किस्तों में दिए जाते हैं।',
      'descEn':
          'Small and marginal farmers receive ₹6,000 per year in three installments.',
      'tagHi': 'à¤•à¥‡à¤‚à¤¦à¥à¤° à¤¸à¤°à¤•à¤¾à¤°',
      'tagEn': 'Central',
    },
    {
      'nameHi': 'à¤«à¤¸à¤² à¤¬à¥€à¤®à¤¾',
      'nameEn': 'Crop Insurance',
      'fullHi':
          'à¤ªà¥à¤°à¤§à¤¾à¤¨à¤®à¤‚à¤¤à¥à¤°à¥€ à¤«à¤¸à¤² à¤¬à¥€à¤®à¤¾ à¤¯à¥‹à¤œà¤¨à¤¾ (PMFBY)',
      'fullEn': 'Pradhan Mantri Fasal Bima Yojana (PMFBY)',
      'emoji': '🌾',
      'amountHi': 'à¤ªà¥à¤°à¥€à¤®à¤¿à¤¯à¤® 2%',
      'amountEn': '2% premium',
      'descHi':
          'à¤ªà¥à¤°à¤¾à¤•à¥ƒà¤¤à¤¿à¤• à¤†à¤ªà¤¦à¤¾à¤“à¤‚, à¤¬à¤¾à¤°à¤¿à¤¶ à¤¯à¤¾ à¤¨à¥à¤•à¤¸à¤¾à¤¨ à¤•à¥‡ à¤¸à¤®à¤¯ à¤«à¤¸à¤² à¤¸à¥à¤°à¤•à¥à¤·à¤¾ à¤•à¥‡ à¤²à¤¿à¤ à¤¬à¥€à¤®à¤¾ à¤•à¤µà¤°à¥¤',
      'descEn':
          'Insurance cover to protect crops against natural disasters, rain, and damage.',
      'tagHi': 'à¤•à¥‡à¤‚à¤¦à¥à¤° à¤¸à¤°à¤•à¤¾à¤°',
      'tagEn': 'Central',
    },
    {
      'nameHi': 'à¤•à¤¿à¤¸à¤¾à¤¨ à¤•à¥à¤°à¥‡à¤¡à¤¿à¤Ÿ à¤•à¤¾à¤°à¥à¤¡',
      'nameEn': 'Kisan Credit Card',
      'fullHi': 'à¤•à¤¿à¤¸à¤¾à¤¨ à¤•à¥à¤°à¥‡à¤¡à¤¿à¤Ÿ à¤•à¤¾à¤°à¥à¤¡ (KCC)',
      'fullEn': 'Kisan Credit Card (KCC)',
      'emoji': '💳',
      'amountHi': '₹3 लाख तक',
      'amountEn': 'Up to ₹3 lakh',
      'descHi':
          'à¤•à¤® à¤¬à¥à¤¯à¤¾à¤œ à¤¦à¤° à¤ªà¤° à¤•à¥ƒà¤·à¤¿ à¤‹à¤£à¥¤ à¤¸à¤®à¤¯ à¤ªà¤° à¤­à¥à¤—à¤¤à¤¾à¤¨ à¤ªà¤° à¤¬à¥à¤¯à¤¾à¤œ à¤®à¥‡à¤‚ à¤…à¤¤à¤¿à¤°à¤¿à¤•à¥à¤¤ à¤°à¤¾à¤¹à¤¤ à¤®à¤¿à¤²à¤¤à¥€ à¤¹à¥ˆà¥¤',
      'descEn':
          'Low-interest farm credit with additional interest relief for timely repayment.',
      'tagHi': 'à¤¬à¥ˆà¤‚à¤•',
      'tagEn': 'Bank',
    },
    {
      'nameHi': 'à¤•à¤¿à¤¸à¤¾à¤¨ à¤®à¤¾à¤¨-à¤§à¤¨',
      'nameEn': 'Kisan Maan Dhan',
      'fullHi':
          'à¤ªà¥à¤°à¤§à¤¾à¤¨à¤®à¤‚à¤¤à¥à¤°à¥€ à¤•à¤¿à¤¸à¤¾à¤¨ à¤®à¤¾à¤¨-à¤§à¤¨ à¤¯à¥‹à¤œà¤¨à¤¾',
      'fullEn': 'Pradhan Mantri Kisan Maan Dhan Yojana',
      'emoji': '👴',
      'amountHi': '₹3,000/माह',
      'amountEn': '₹3,000/month',
      'descHi':
          '60 à¤µà¤°à¥à¤· à¤•à¥€ à¤†à¤¯à¥ à¤•à¥‡ à¤¬à¤¾à¤¦ à¤¯à¥‹à¤—à¥à¤¯ à¤•à¤¿à¤¸à¤¾à¤¨à¥‹à¤‚ à¤•à¥‹ à¤®à¤¾à¤¸à¤¿à¤• à¤ªà¥‡à¤‚à¤¶à¤¨ à¤¸à¤¹à¤¾à¤¯à¤¤à¤¾à¥¤',
      'descEn':
          'Monthly pension support for eligible farmers after the age of 60.',
      'tagHi': 'à¤•à¥‡à¤‚à¤¦à¥à¤° à¤¸à¤°à¤•à¤¾à¤°',
      'tagEn': 'Pension',
    },
    {
      'nameHi': 'à¤¸à¥‰à¤‡à¤² à¤¹à¥‡à¤²à¥à¤¥ à¤•à¤¾à¤°à¥à¤¡',
      'nameEn': 'Soil Health Card',
      'fullHi': 'à¤¸à¥‰à¤‡à¤² à¤¹à¥‡à¤²à¥à¤¥ à¤•à¤¾à¤°à¥à¤¡ à¤¯à¥‹à¤œà¤¨à¤¾',
      'fullEn': 'Soil Health Card Scheme',
      'emoji': '🌱',
      'amountHi': 'à¤®à¥à¤«à¤¼à¥à¤¤',
      'amountEn': 'Free',
      'descHi':
          'à¤®à¤¿à¤Ÿà¥à¤Ÿà¥€ à¤•à¥€ à¤œà¤¾à¤‚à¤š à¤•à¥‡ à¤†à¤§à¤¾à¤° à¤ªà¤° à¤‰à¤°à¥à¤µà¤°à¤• à¤”à¤° à¤ªà¥‹à¤·à¤£ à¤¸à¤‚à¤¬à¤‚à¤§à¥€ à¤¸à¤¹à¥€ à¤¸à¤²à¤¾à¤¹ à¤¦à¥€ à¤œà¤¾à¤¤à¥€ à¤¹à¥ˆà¥¤',
      'descEn':
          'Provides fertilizer and nutrient guidance based on soil testing.',
      'tagHi': 'à¤®à¥à¤«à¤¼à¥à¤¤ à¤¸à¥‡à¤µà¤¾',
      'tagEn': 'Free service',
    },
    {
      'nameHi': 'à¤ªà¥€à¤à¤®-à¤•à¥à¤¸à¥à¤®',
      'nameEn': 'PM Kusum',
      'fullHi':
          'à¤ªà¥à¤°à¤§à¤¾à¤¨à¤®à¤‚à¤¤à¥à¤°à¥€ à¤•à¤¿à¤¸à¤¾à¤¨ à¤Šà¤°à¥à¤œà¤¾ à¤¸à¥à¤°à¤•à¥à¤·à¤¾ à¤à¤µà¤‚ à¤‰à¤¤à¥à¤¥à¤¾à¤¨ à¤®à¤¹à¤¾à¤­à¤¿à¤¯à¤¾à¤¨',
      'fullEn': 'Pradhan Mantri Kisan Urja Suraksha Evam Utthaan Mahabhiyan',
      'emoji': '☀️',
      'amountHi': '90% à¤¸à¤¬à¥à¤¸à¤¿à¤¡à¥€ à¤¤à¤•',
      'amountEn': 'Up to 90% subsidy',
      'descHi':
          'à¤¸à¥‹à¤²à¤° à¤ªà¤‚à¤ª à¤”à¤° à¤•à¥ƒà¤·à¤¿ à¤Šà¤°à¥à¤œà¤¾ à¤¸à¤®à¤¾à¤§à¤¾à¤¨ à¤•à¥‡ à¤²à¤¿à¤ à¤µà¤¿à¤¤à¥à¤¤à¥€à¤¯ à¤¸à¤¹à¤¾à¤¯à¤¤à¤¾ à¤‰à¤ªà¤²à¤¬à¥à¤§ à¤¹à¥ˆà¥¤',
      'descEn':
          'Financial support for solar pumps and clean energy solutions for farming.',
      'tagHi': 'à¤¸à¥‹à¤²à¤°',
      'tagEn': 'Solar',
    },
    {
      'nameHi': 'à¤ˆ-à¤¨à¤¾à¤®',
      'nameEn': 'e-NAM',
      'fullHi': 'à¤°à¤¾à¤·à¥à¤Ÿà¥à¤°à¥€à¤¯ à¤•à¥ƒà¤·à¤¿ à¤¬à¤¾à¤œà¤¾à¤°',
      'fullEn': 'National Agriculture Market',
      'emoji': '🏪',
      'amountHi': 'à¤®à¥à¤«à¤¼à¥à¤¤ à¤ªà¤‚à¤œà¥€à¤•à¤°à¤£',
      'amountEn': 'Free registration',
      'descHi':
          'à¤•à¤¿à¤¸à¤¾à¤¨ à¤‘à¤¨à¤²à¤¾à¤‡à¤¨ à¤®à¤‚à¤¡à¥€ à¤ªà¥à¤²à¥‡à¤Ÿà¤«à¥‰à¤°à¥à¤® à¤ªà¤° à¤…à¤ªà¤¨à¥€ à¤«à¤¸à¤² à¤¬à¥‡à¤¹à¤¤à¤° à¤¦à¤¾à¤® à¤®à¥‡à¤‚ à¤¬à¥‡à¤š à¤¸à¤•à¤¤à¥‡ à¤¹à¥ˆà¤‚à¥¤',
      'descEn':
          'Farmers can sell produce on the online mandi platform for better price discovery.',
      'tagHi': 'à¤¡à¤¿à¤œà¤¿à¤Ÿà¤²',
      'tagEn': 'Digital',
    },
    {
      'nameHi':
          'à¤à¤—à¥à¤°à¥€ à¤‡à¤¨à¥à¤«à¥à¤°à¤¾à¤¸à¥à¤Ÿà¥à¤°à¤•à¥à¤šà¤°',
      'nameEn': 'Agri Infrastructure',
      'fullHi':
          'à¤à¤—à¥à¤°à¥€à¤•à¤²à¥à¤šà¤° à¤‡à¤¨à¥à¤«à¥à¤°à¤¾à¤¸à¥à¤Ÿà¥à¤°à¤•à¥à¤šà¤° à¤«à¤‚à¤¡',
      'fullEn': 'Agriculture Infrastructure Fund',
      'emoji': '🏭',
      'amountHi': '₹1 करोड़ तक',
      'amountEn': 'Up to ₹1 crore',
      'descHi':
          'à¤•à¥‹à¤²à¥à¤¡ à¤¸à¥à¤Ÿà¥‹à¤°à¥‡à¤œ, à¤µà¥‡à¤¯à¤°à¤¹à¤¾à¤‰à¤¸ à¤”à¤° à¤•à¥ƒà¤·à¤¿ à¤ªà¥à¤°à¤¸à¤‚à¤¸à¥à¤•à¤°à¤£ à¤‡à¤•à¤¾à¤‡à¤¯à¥‹à¤‚ à¤•à¥‡ à¤²à¤¿à¤ à¤¸à¤¹à¤¾à¤¯à¤¤à¤¾à¥¤',
      'descEn':
          'Support for cold storage, warehousing, and farm processing infrastructure.',
      'tagHi': 'à¤‡à¤¨à¥à¤«à¥à¤°à¤¾',
      'tagEn': 'Infra',
    },
    {
      'nameHi': 'à¤†à¤°à¤•à¥‡à¤µà¥€à¤µà¤¾à¤ˆ',
      'nameEn': 'RKVY',
      'fullHi':
          'à¤°à¤¾à¤·à¥à¤Ÿà¥à¤°à¥€à¤¯ à¤•à¥ƒà¤·à¤¿ à¤µà¤¿à¤•à¤¾à¤¸ à¤¯à¥‹à¤œà¤¨à¤¾',
      'fullEn': 'Rashtriya Krishi Vikas Yojana',
      'emoji': '📈',
      'amountHi': 'à¤…à¤¨à¥à¤¦à¤¾à¤¨',
      'amountEn': 'Grant support',
      'descHi':
          'à¤•à¥ƒà¤·à¤¿ à¤”à¤° à¤¸à¤‚à¤¬à¤‚à¤§à¤¿à¤¤ à¤•à¥à¤·à¥‡à¤¤à¥à¤°à¥‹à¤‚ à¤•à¥‡ à¤µà¤¿à¤•à¤¾à¤¸ à¤•à¥‡ à¤²à¤¿à¤ à¤°à¤¾à¤œà¥à¤¯à¥‹à¤‚ à¤”à¤° à¤•à¤¿à¤¸à¤¾à¤¨à¥‹à¤‚ à¤•à¥‹ à¤¸à¤¹à¤¾à¤¯à¤¤à¤¾à¥¤',
      'descEn':
          'Supports states and farmers in agriculture and allied sector development.',
      'tagHi': 'à¤°à¤¾à¤œà¥à¤¯ + à¤•à¥‡à¤‚à¤¦à¥à¤°',
      'tagEn': 'State + Central',
    },
    {
      'nameHi': 'à¤ªà¤°à¤‚à¤ªà¤°à¤¾à¤—à¤¤ à¤•à¥ƒà¤·à¤¿',
      'nameEn': 'Organic Farming',
      'fullHi':
          'à¤ªà¤°à¤‚à¤ªà¤°à¤¾à¤—à¤¤ à¤•à¥ƒà¤·à¤¿ à¤µà¤¿à¤•à¤¾à¤¸ à¤¯à¥‹à¤œà¤¨à¤¾ (PKVY)',
      'fullEn': 'Paramparagat Krishi Vikas Yojana (PKVY)',
      'emoji': '🌿',
      'amountHi': '₹50,000/हेक्टेयर',
      'amountEn': '₹50,000/hectare',
      'descHi':
          'à¤œà¥ˆà¤µà¤¿à¤• à¤–à¥‡à¤¤à¥€ à¤•à¥‹ à¤¬à¤¢à¤¼à¤¾à¤µà¤¾ à¤¦à¥‡à¤¨à¥‡ à¤•à¥‡ à¤²à¤¿à¤ à¤•à¤¿à¤¸à¤¾à¤¨à¥‹à¤‚ à¤•à¥‹ à¤¸à¤®à¥‚à¤¹ à¤†à¤§à¤¾à¤°à¤¿à¤¤ à¤¸à¤¹à¤¾à¤¯à¤¤à¤¾ à¤®à¤¿à¤²à¤¤à¥€ à¤¹à¥ˆà¥¤',
      'descEn':
          'Group-based support is provided to encourage organic farming practices.',
      'tagHi': 'à¤‘à¤°à¥à¤—à¥‡à¤¨à¤¿à¤•',
      'tagEn': 'Organic',
    },
    {
      'nameHi': 'à¤®à¤§à¥à¤®à¤•à¥à¤–à¥€ à¤ªà¤¾à¤²à¤¨',
      'nameEn': 'Bee Keeping',
      'fullHi':
          'à¤¨à¥‡à¤¶à¤¨à¤² à¤¬à¥€ à¤•à¥€à¤ªà¤¿à¤‚à¤— à¤à¤‚à¤¡ à¤¹à¤¨à¥€ à¤®à¤¿à¤¶à¤¨',
      'fullEn': 'National Bee Keeping and Honey Mission',
      'emoji': '🐝',
      'amountHi': '75% à¤¸à¤¬à¥à¤¸à¤¿à¤¡à¥€ à¤¤à¤•',
      'amountEn': 'Up to 75% subsidy',
      'descHi':
          'à¤®à¤§à¥à¤®à¤•à¥à¤–à¥€ à¤ªà¤¾à¤²à¤¨, à¤¶à¤¹à¤¦ à¤‰à¤¤à¥à¤ªà¤¾à¤¦à¤¨ à¤”à¤° à¤¸à¤‚à¤¬à¤‚à¤§à¤¿à¤¤ à¤‰à¤ªà¤•à¤°à¤£à¥‹à¤‚ à¤ªà¤° à¤¸à¤¹à¤¾à¤¯à¤¤à¤¾ à¤®à¤¿à¤²à¤¤à¥€ à¤¹à¥ˆà¥¤',
      'descEn':
          'Support is available for bee keeping, honey production, and related equipment.',
      'tagHi': 'à¤‰à¤¦à¥à¤¯à¤®',
      'tagEn': 'Enterprise',
    },
    {
      'nameHi': 'à¤®à¤¤à¥à¤¸à¥à¤¯ à¤¸à¤‚à¤ªà¤¦à¤¾',
      'nameEn': 'Matsya Sampada',
      'fullHi':
          'à¤ªà¥à¤°à¤§à¤¾à¤¨à¤®à¤‚à¤¤à¥à¤°à¥€ à¤®à¤¤à¥à¤¸à¥à¤¯ à¤¸à¤‚à¤ªà¤¦à¤¾ à¤¯à¥‹à¤œà¤¨à¤¾',
      'fullEn': 'Pradhan Mantri Matsya Sampada Yojana',
      'emoji': '🐟',
      'amountHi': '₹20,050 करोड़',
      'amountEn': '₹20,050 crore',
      'descHi':
          'à¤®à¤¤à¥à¤¸à¥à¤¯ à¤ªà¤¾à¤²à¤¨ à¤”à¤° à¤œà¤²à¥€à¤¯ à¤•à¥ƒà¤·à¤¿ à¤•à¥à¤·à¥‡à¤¤à¥à¤° à¤•à¥‡ à¤µà¤¿à¤•à¤¾à¤¸ à¤•à¥‡ à¤²à¤¿à¤ à¤µà¤¿à¤¤à¥à¤¤à¥€à¤¯ à¤¸à¤¹à¤¾à¤¯à¤¤à¤¾à¥¤',
      'descEn':
          'Financial support for fisheries and aquaculture sector development.',
      'tagHi': 'à¤®à¤¤à¥à¤¸à¥à¤¯',
      'tagEn': 'Fisheries',
    },
    {
      'nameHi': 'à¤ªà¤¶à¥à¤§à¤¨ à¤µà¤¿à¤•à¤¾à¤¸',
      'nameEn': 'Livestock Development',
      'fullHi': 'à¤°à¤¾à¤·à¥à¤Ÿà¥à¤°à¥€à¤¯ à¤—à¥‹à¤•à¥à¤² à¤®à¤¿à¤¶à¤¨',
      'fullEn': 'Rashtriya Gokul Mission',
      'emoji': '🐄',
      'amountHi': 'à¤¸à¤¬à¥à¤¸à¤¿à¤¡à¥€',
      'amountEn': 'Subsidy',
      'descHi':
          'à¤¦à¥‡à¤¶à¥€ à¤¨à¤¸à¥à¤² à¤¸à¥à¤§à¤¾à¤°, à¤¦à¥à¤—à¥à¤§ à¤‰à¤¤à¥à¤ªà¤¾à¤¦à¤¨ à¤”à¤° à¤ªà¤¶à¥à¤ªà¤¾à¤²à¤¨ à¤µà¤¿à¤•à¤¾à¤¸ à¤•à¥‡ à¤²à¤¿à¤ à¤¸à¤¹à¤¾à¤¯à¤¤à¤¾à¥¤',
      'descEn':
          'Support for indigenous breed improvement, dairy production, and livestock growth.',
      'tagHi': 'à¤ªà¤¶à¥à¤ªà¤¾à¤²à¤¨',
      'tagEn': 'Livestock',
    },
    {
      'nameHi': 'à¤¡à¥€à¤à¤²à¤à¤¸à¤ à¤•à¤¾à¤¨à¥‚à¤¨à¥€ à¤®à¤¦à¤¦',
      'nameEn': 'DLSA Legal Help',
      'fullHi':
          'à¤œà¤¿à¤²à¤¾ à¤µà¤¿à¤§à¤¿à¤• à¤¸à¥‡à¤µà¤¾ à¤ªà¥à¤°à¤¾à¤§à¤¿à¤•à¤°à¤£',
      'fullEn': 'District Legal Services Authority',
      'emoji': '⚖️',
      'amountHi': 'à¤®à¥à¤«à¤¼à¥à¤¤',
      'amountEn': 'Free',
      'descHi':
          'à¤œà¤®à¥€à¤¨ à¤µà¤¿à¤µà¤¾à¤¦, à¤‹à¤£ à¤¸à¤®à¤¸à¥à¤¯à¤¾ à¤”à¤° à¤•à¤¾à¤¨à¥‚à¤¨à¥€ à¤®à¤¾à¤®à¤²à¥‹à¤‚ à¤•à¥‡ à¤²à¤¿à¤ à¤®à¥à¤«à¥à¤¤ à¤¸à¤¹à¤¾à¤¯à¤¤à¤¾à¥¤ 15100 à¤ªà¤° à¤•à¥‰à¤² à¤•à¤°à¥‡à¤‚à¥¤',
      'descEn':
          'Free legal support for land disputes, loan issues, and related matters. Call 15100.',
      'tagHi': 'à¤•à¤¾à¤¨à¥‚à¤¨à¥€',
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
          _screenText(
              'Government Schemes', 'à¤¸à¤°à¤•à¤¾à¤°à¥€ à¤¯à¥‹à¤œà¤¨à¤¾à¤à¤‚'),
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
                  'à¤¯à¥‹à¤œà¤¨à¤¾à¤à¤‚ à¤–à¥‹à¤œà¥‡à¤‚...',
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
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _schemeText(scheme, 'full'),
                          style: TextStyle(
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
                style: TextStyle(
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
                            _screenText('Benefit', 'à¤²à¤¾à¤­'),
                            style: TextStyle(
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
                            _screenText('Category', 'à¤¶à¥à¤°à¥‡à¤£à¥€'),
                            style: TextStyle(
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
                _screenText('Details', 'à¤µà¤¿à¤µà¤°à¤£'),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _schemeText(scheme, 'desc'),
                style: TextStyle(
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
                    _screenText(
                        'Apply now', 'à¤…à¤­à¥€ à¤†à¤µà¥‡à¤¦à¤¨ à¤•à¤°à¥‡à¤‚'),
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


