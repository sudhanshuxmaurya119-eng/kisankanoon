import 'package:flutter/material.dart';

import '../services/app_language_service.dart';
import '../services/app_strings.dart';
import '../theme/app_theme.dart';
import 'documents_screen.dart';
import 'home_screen.dart';
import 'more_screen.dart';
import 'scan_screen.dart';
import 'schemes_screen.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;

  void _changeTab(int index) {
    if (!mounted) return;
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(onChangeTab: _changeTab),
      const ScanScreen(),
      const DocumentsScreen(),
      const SchemesScreen(),
      const MoreScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppTheme.divider, width: 0.5)),
        ),
        child: ValueListenableBuilder<String>(
          valueListenable: AppLanguageService.currentCode,
          builder: (context, languageCode, _) {
            return BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: (index) => setState(() => _selectedIndex = index),
              items: [
                BottomNavigationBarItem(
                  icon: const Icon(Icons.home_outlined),
                  activeIcon: const Icon(Icons.home),
                  label: AppStrings.t(languageCode, 'navHome'),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.camera_alt_outlined),
                  activeIcon: const Icon(Icons.camera_alt),
                  label: AppStrings.t(languageCode, 'navScan'),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.folder_outlined),
                  activeIcon: const Icon(Icons.folder),
                  label: AppStrings.t(languageCode, 'navDocuments'),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.account_balance_outlined),
                  activeIcon: const Icon(Icons.account_balance),
                  label: AppStrings.t(languageCode, 'navSchemes'),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.menu_outlined),
                  activeIcon: const Icon(Icons.menu),
                  label: AppStrings.t(languageCode, 'navMore'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
