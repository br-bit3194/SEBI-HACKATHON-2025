import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state_provider.dart';
import '../../utils/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text('profile'.tr()),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => _showLanguageDialog(context),
            icon: const Icon(Icons.language),
          ),
        ],
      ),
      body: Consumer<AppStateProvider>(
        builder: (context, appState, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildProfileHeader(context, appState),
                const SizedBox(height: 24),
                _buildStatsCards(context, appState),
                const SizedBox(height: 24),
                _buildAchievements(context, appState),
                const SizedBox(height: 24),
                _buildSettingsSection(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, AppStateProvider appState) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Icon(
              Icons.person,
              size: 40,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Investor Learner',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Learning since ${DateFormat('MMM yyyy').format(DateTime.now())}',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Level ${_calculateLevel(appState)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(BuildContext context, AppStateProvider appState) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Modules Completed',
                '${appState.getCompletedModulesCount()}/6',
                Icons.school,
                AppTheme.primaryColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Average Quiz Score',
                '${appState.getAverageQuizScore().toStringAsFixed(1)}%',
                Icons.quiz,
                AppTheme.accentColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Virtual Balance',
                '₹${NumberFormat('#,##,###').format(appState.virtualBalance)}',
                Icons.account_balance_wallet,
                AppTheme.successColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Portfolio Value',
                '₹${NumberFormat('#,##,###').format(appState.getPortfolioValue())}',
                Icons.trending_up,
                AppTheme.secondaryColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievements(BuildContext context, AppStateProvider appState) {
    final achievements = _getAchievements(appState);
    final unlockedCount = achievements.where((a) => a.isUnlocked).length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Achievements',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$unlockedCount/${achievements.length}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: achievements.length,
            itemBuilder: (context, index) {
              final achievement = achievements[index];
              return Column(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: achievement.isUnlocked 
                          ? achievement.color.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: achievement.isUnlocked 
                            ? achievement.color
                            : Colors.grey,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      achievement.icon,
                      color: achievement.isUnlocked 
                          ? achievement.color
                          : Colors.grey,
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    achievement.title,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: achievement.isUnlocked 
                          ? Colors.black87
                          : Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Settings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildSettingsItem(
            Icons.language,
            'Language',
            'Change app language',
            () => _showLanguageDialog(context),
          ),
          _buildSettingsItem(
            Icons.notifications,
            'Notifications',
            'Manage notifications',
            () => _showComingSoonDialog(context),
          ),
          _buildSettingsItem(
            Icons.security,
            'Privacy & Security',
            'Privacy settings',
            () => _showComingSoonDialog(context),
          ),
          _buildSettingsItem(
            Icons.help,
            'Help & Support',
            'Get help and support',
            () => _showComingSoonDialog(context),
          ),
          _buildSettingsItem(
            Icons.info,
            'About',
            'App information',
            () => _showAboutDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.black54,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('select_language'.tr()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('English'),
              onTap: () {
                context.setLocale(const Locale('en'));
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('हिंदी'),
              onTap: () {
                context.setLocale(const Locale('hi'));
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoonDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Coming Soon'),
        content: const Text('This feature will be available in the next update.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('app_name'.tr()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('tagline'.tr()),
            const SizedBox(height: 16),
            const Text('Version: 1.0.0'),
            const SizedBox(height: 8),
            const Text('Built for Hackathon 2024'),
            const SizedBox(height: 8),
            const Text('Empowering retail investors with education and practice tools.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  int _calculateLevel(AppStateProvider appState) {
    final completedModules = appState.getCompletedModulesCount();
    final averageScore = appState.getAverageQuizScore();
    final portfolioValue = appState.getPortfolioValue();
    
    int level = 1;
    level += completedModules;
    level += (averageScore / 20).floor();
    level += (portfolioValue / 50000).floor();
    
    return level.clamp(1, 20);
  }

  List<Achievement> _getAchievements(AppStateProvider appState) {
    final completedModules = appState.getCompletedModulesCount();
    final averageScore = appState.getAverageQuizScore();
    final completedQuizzes = appState.quizScores.length;
    final portfolioValue = appState.getPortfolioValue();

    return [
      Achievement(
        title: 'First Steps',
        icon: Icons.play_arrow,
        color: AppTheme.primaryColor,
        isUnlocked: completedModules >= 1,
      ),
      Achievement(
        title: 'Quiz Master',
        icon: Icons.quiz,
        color: AppTheme.accentColor,
        isUnlocked: completedQuizzes >= 3,
      ),
      Achievement(
        title: 'High Scorer',
        icon: Icons.star,
        color: Colors.amber,
        isUnlocked: averageScore >= 80,
      ),
      Achievement(
        title: 'Investor',
        icon: Icons.trending_up,
        color: AppTheme.successColor,
        isUnlocked: portfolioValue > 0,
      ),
      Achievement(
        title: 'Scholar',
        icon: Icons.school,
        color: Colors.purple,
        isUnlocked: completedModules >= 3,
      ),
      Achievement(
        title: 'Expert',
        icon: Icons.emoji_events,
        color: Colors.amber,
        isUnlocked: completedModules >= 6 && averageScore >= 90,
      ),
      Achievement(
        title: 'Trader',
        icon: Icons.account_balance,
        color: AppTheme.secondaryColor,
        isUnlocked: portfolioValue >= 50000,
      ),
      Achievement(
        title: 'Champion',
        icon: Icons.military_tech,
        color: Colors.red,
        isUnlocked: _calculateLevel(appState) >= 15,
      ),
    ];
  }
}

class Achievement {
  final String title;
  final IconData icon;
  final Color color;
  final bool isUnlocked;

  Achievement({
    required this.title,
    required this.icon,
    required this.color,
    required this.isUnlocked,
  });
}
