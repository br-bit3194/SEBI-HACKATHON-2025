import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'home/home_screen.dart';
import 'learning/learning_modules_screen.dart';
import 'quiz/quiz_home_screen.dart';
import 'trading/virtual_trading_screen.dart';
import 'profile/profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const LearningModulesScreen(),
    const QuizHomeScreen(),
    const VirtualTradingScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: 'home'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.school),
            label: 'learn'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.quiz),
            label: 'quiz'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.trending_up),
            label: 'trade'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: 'profile'.tr(),
          ),
        ],
      ),
    );
  }
}
