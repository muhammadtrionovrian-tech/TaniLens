import 'package:flutter/material.dart';
import '../widgets/custom_bottom_nav.dart';
import '../theme/app_colors.dart';
import 'home_screen.dart';
import 'scan_screen.dart';
import 'history_screen.dart';
import 'about_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  bool _showAboutPage = false;

  void _navigateToTab(int index) {
    setState(() {
      _currentIndex = index;
      _showAboutPage = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Build the body depending on active tab or about page state
    Widget activeBody;
    if (_showAboutPage) {
      activeBody = const AboutScreen();
    } else {
      switch (_currentIndex) {
        case 0:
          activeBody = HomeScreen(
            onNavigateToScan: () => _navigateToTab(1),
            onNavigateToHistory: () => _navigateToTab(2),
          );
          break;
        case 1:
          activeBody = const ScanScreen();
          break;
        case 2:
          activeBody = const HistoryScreen();
          break;
        default:
          activeBody = HomeScreen(
            onNavigateToScan: () => _navigateToTab(1),
            onNavigateToHistory: () => _navigateToTab(2),
          );
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Image.asset(
          'assets/logo/TANI_LENS_splash_HD_nobg.png',
          height: 32,
          fit: BoxFit.contain,
        ),
        actions: [
          // Info icon button matching the design
          IconButton(
            onPressed: () {
              setState(() {
                _showAboutPage = true;
              });
            },
            icon: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: _showAboutPage 
                    ? AppColors.primary 
                    : AppColors.accent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.info_outline,
                size: 18,
                color: _showAboutPage ? Colors.white : AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: activeBody,
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _showAboutPage ? 0 : _currentIndex, // Highlight Home if on About page
        onTap: _navigateToTab,
      ),
    );
  }
}
