import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state_provider.dart';
import '../../utils/app_theme.dart';
import 'module_detail_screen.dart';

class LearningModulesScreen extends StatelessWidget {
  const LearningModulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text('learning_modules'.tr()),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Consumer<AppStateProvider>(
        builder: (context, appState, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProgressOverview(context, appState),
                const SizedBox(height: 24),
                _buildModulesList(context, appState),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProgressOverview(BuildContext context, AppStateProvider appState) {
    final completedModules = appState.getCompletedModulesCount();
    final totalModules = _getModules().length;
    final progressPercentage = completedModules / totalModules;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Learning Progress',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$completedModules/$totalModules Modules',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              Text(
                '${(progressPercentage * 100).toInt()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progressPercentage,
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildModulesList(BuildContext context, AppStateProvider appState) {
    final modules = _getModules();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Modules',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: modules.length,
          itemBuilder: (context, index) {
            final module = modules[index];
            final progress = appState.moduleProgress[module.id] ?? 0;
            final isCompleted = progress >= 100;
            final isLocked = index > 0 && (appState.moduleProgress[modules[index - 1].id] ?? 0) < 100;
            
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: isLocked ? null : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ModuleDetailScreen(module: module),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
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
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: isLocked 
                                ? Colors.grey.withOpacity(0.3)
                                : module.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            isLocked ? Icons.lock : module.icon,
                            color: isLocked ? Colors.grey : module.color,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                module.title,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: isLocked ? Colors.grey : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                module.description,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isLocked ? Colors.grey : Colors.black54,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: LinearProgressIndicator(
                                      value: progress / 100,
                                      backgroundColor: Colors.grey.withOpacity(0.2),
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        isLocked ? Colors.grey : module.color,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '$progress%',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isLocked ? Colors.grey : Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isCompleted 
                                ? AppTheme.successColor.withOpacity(0.1)
                                : isLocked
                                    ? Colors.grey.withOpacity(0.1)
                                    : AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isCompleted 
                                ? 'completed'.tr()
                                : isLocked
                                    ? 'locked'.tr()
                                    : 'in_progress'.tr(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isCompleted 
                                  ? AppTheme.successColor
                                  : isLocked
                                      ? Colors.grey
                                      : AppTheme.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  List<LearningModule> _getModules() {
    return [
      LearningModule(
        id: 'stock_basics',
        title: 'stock_basics'.tr(),
        description: 'Learn the fundamentals of stock market, shares, and how trading works.',
        icon: Icons.trending_up,
        color: AppTheme.primaryColor,
        duration: '30 min',
        lessons: 5,
      ),
      LearningModule(
        id: 'risk_management',
        title: 'risk_management'.tr(),
        description: 'Understand different types of risks and how to manage them effectively.',
        icon: Icons.security,
        color: AppTheme.accentColor,
        duration: '25 min',
        lessons: 4,
      ),
      LearningModule(
        id: 'technical_analysis',
        title: 'technical_analysis'.tr(),
        description: 'Learn to read charts, patterns, and technical indicators.',
        icon: Icons.analytics,
        color: Colors.purple,
        duration: '45 min',
        lessons: 6,
      ),
      LearningModule(
        id: 'fundamental_analysis',
        title: 'fundamental_analysis'.tr(),
        description: 'Analyze company financials and market conditions.',
        icon: Icons.assessment,
        color: Colors.green,
        duration: '40 min',
        lessons: 5,
      ),
      LearningModule(
        id: 'portfolio_diversification',
        title: 'portfolio_diversification'.tr(),
        description: 'Build a balanced portfolio to minimize risks and maximize returns.',
        icon: Icons.pie_chart,
        color: AppTheme.secondaryColor,
        duration: '35 min',
        lessons: 4,
      ),
      LearningModule(
        id: 'algo_trading',
        title: 'algo_trading'.tr(),
        description: 'Introduction to algorithmic trading and automated strategies.',
        icon: Icons.smart_toy,
        color: Colors.indigo,
        duration: '50 min',
        lessons: 7,
      ),
    ];
  }
}

class LearningModule {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String duration;
  final int lessons;

  LearningModule({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.duration,
    required this.lessons,
  });
}
