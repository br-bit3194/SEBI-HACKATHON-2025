import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../utils/app_theme.dart';

class ContentManagementScreen extends StatefulWidget {
  const ContentManagementScreen({super.key});

  @override
  State<ContentManagementScreen> createState() => _ContentManagementScreenState();
}

class _ContentManagementScreenState extends State<ContentManagementScreen> {
  String selectedTab = 'modules';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Content Management',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddContentDialog(),
                icon: const Icon(Icons.add),
                label: const Text('Add Content'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildTabBar(),
          const SizedBox(height: 24),
          Expanded(
            child: _buildTabContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildTabButton('modules', 'Learning Modules'),
          _buildTabButton('quizzes', 'Quizzes'),
          _buildTabButton('translations', 'Translations'),
        ],
      ),
    );
  }

  Widget _buildTabButton(String tab, String label) {
    final isSelected = selectedTab == tab;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedTab = tab;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected ? AppTheme.primaryColor : Colors.black54,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (selectedTab) {
      case 'modules':
        return _buildModulesContent();
      case 'quizzes':
        return _buildQuizzesContent();
      case 'translations':
        return _buildTranslationsContent();
      default:
        return _buildModulesContent();
    }
  }

  Widget _buildModulesContent() {
    final modules = [
      {
        'title': 'Stock Market Basics',
        'lessons': 5,
        'status': 'Published',
        'lastUpdated': '2 days ago',
        'languages': ['English', 'Hindi'],
      },
      {
        'title': 'Risk Management',
        'lessons': 4,
        'status': 'Published',
        'lastUpdated': '1 week ago',
        'languages': ['English', 'Hindi'],
      },
      {
        'title': 'Technical Analysis',
        'lessons': 6,
        'status': 'Draft',
        'lastUpdated': '3 days ago',
        'languages': ['English'],
      },
      {
        'title': 'Fundamental Analysis',
        'lessons': 5,
        'status': 'Published',
        'lastUpdated': '5 days ago',
        'languages': ['English', 'Hindi'],
      },
    ];

    return ListView.builder(
      itemCount: modules.length,
      itemBuilder: (context, index) {
        final module = modules[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.school,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      module['title'] as String,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${module['lessons']} lessons • Updated ${module['lastUpdated']}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: module['status'] == 'Published'
                                ? AppTheme.successColor.withOpacity(0.1)
                                : Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            module['status'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: module['status'] == 'Published'
                                  ? AppTheme.successColor
                                  : Colors.orange,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ...((module['languages'] as List<String>).map((lang) => Container(
                          margin: const EdgeInsets.only(right: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.secondaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            lang,
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppTheme.secondaryColor,
                            ),
                          ),
                        ))),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) => _handleModuleAction(value, module),
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  const PopupMenuItem(value: 'translate', child: Text('Add Translation')),
                  const PopupMenuItem(value: 'duplicate', child: Text('Duplicate')),
                  const PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
                child: const Icon(Icons.more_vert),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuizzesContent() {
    final quizzes = [
      {
        'title': 'Stock Basics Quiz',
        'questions': 5,
        'module': 'Stock Market Basics',
        'attempts': 1247,
        'avgScore': 78.5,
      },
      {
        'title': 'Risk Management Quiz',
        'questions': 4,
        'module': 'Risk Management',
        'attempts': 892,
        'avgScore': 82.3,
      },
      {
        'title': 'Technical Analysis Quiz',
        'questions': 6,
        'module': 'Technical Analysis',
        'attempts': 634,
        'avgScore': 71.2,
      },
    ];

    return ListView.builder(
      itemCount: quizzes.length,
      itemBuilder: (context, index) {
        final quiz = quizzes[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.quiz,
                  color: AppTheme.accentColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quiz['title'] as String,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Module: ${quiz['module']} • ${quiz['questions']} questions',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '${quiz['attempts']} attempts',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'Avg Score: ${quiz['avgScore']}%',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.successColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) => _handleQuizAction(value, quiz),
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit Questions')),
                  const PopupMenuItem(value: 'analytics', child: Text('View Analytics')),
                  const PopupMenuItem(value: 'duplicate', child: Text('Duplicate')),
                  const PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
                child: const Icon(Icons.more_vert),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTranslationsContent() {
    final translations = [
      {
        'language': 'Hindi',
        'code': 'hi',
        'progress': 95,
        'lastUpdated': '1 day ago',
        'translator': 'Priya Sharma',
      },
      {
        'language': 'Tamil',
        'code': 'ta',
        'progress': 60,
        'lastUpdated': '1 week ago',
        'translator': 'Raj Kumar',
      },
      {
        'language': 'Telugu',
        'code': 'te',
        'progress': 30,
        'lastUpdated': '2 weeks ago',
        'translator': 'Sita Devi',
      },
    ];

    return ListView.builder(
      itemCount: translations.length,
      itemBuilder: (context, index) {
        final translation = translations[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.language,
                  color: AppTheme.secondaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      translation['language'] as String,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Translator: ${translation['translator']} • Updated ${translation['lastUpdated']}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value: (translation['progress'] as int) / 100,
                            backgroundColor: Colors.grey.withOpacity(0.2),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _getProgressColor(translation['progress'] as int),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${translation['progress']}%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: _getProgressColor(translation['progress'] as int),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) => _handleTranslationAction(value, translation),
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit Translation')),
                  const PopupMenuItem(value: 'assign', child: Text('Assign Translator')),
                  const PopupMenuItem(value: 'export', child: Text('Export')),
                  const PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
                child: const Icon(Icons.more_vert),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getProgressColor(int progress) {
    if (progress >= 80) return AppTheme.successColor;
    if (progress >= 50) return Colors.orange;
    return AppTheme.errorColor;
  }

  void _showAddContentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Content'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.school),
              title: const Text('Learning Module'),
              subtitle: const Text('Create a new learning module'),
              onTap: () {
                Navigator.pop(context);
                _showAddModuleDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.quiz),
              title: const Text('Quiz'),
              subtitle: const Text('Create a new quiz'),
              onTap: () {
                Navigator.pop(context);
                _showAddQuizDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('Translation'),
              subtitle: const Text('Add new language translation'),
              onTap: () {
                Navigator.pop(context);
                _showAddTranslationDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddModuleDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Learning Module'),
        content: const Text('Module creation form would be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showAddQuizDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Quiz'),
        content: const Text('Quiz creation form would be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showAddTranslationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Translation'),
        content: const Text('Translation setup form would be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _handleModuleAction(String action, Map<String, dynamic> module) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$action action for ${module['title']}')),
    );
  }

  void _handleQuizAction(String action, Map<String, dynamic> quiz) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$action action for ${quiz['title']}')),
    );
  }

  void _handleTranslationAction(String action, Map<String, dynamic> translation) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$action action for ${translation['language']}')),
    );
  }
}
