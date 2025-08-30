import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state_provider.dart';
import '../../utils/app_theme.dart';
import 'quiz_screen.dart';

class QuizHomeScreen extends StatelessWidget {
  const QuizHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text('quiz_title'.tr()),
        backgroundColor: AppTheme.accentColor,
        foregroundColor: Colors.white,
      ),
      body: Consumer<AppStateProvider>(
        builder: (context, appState, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildQuizStats(context, appState),
                const SizedBox(height: 24),
                _buildAchievements(context, appState),
                const SizedBox(height: 24),
                _buildAvailableQuizzes(context, appState),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuizStats(BuildContext context, AppStateProvider appState) {
    final averageScore = appState.getAverageQuizScore();
    final completedQuizzes = appState.quizScores.length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.accentColor, Colors.deepOrange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quiz Performance',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Average Score',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '${averageScore.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quizzes Completed',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '$completedQuizzes',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAchievements(BuildContext context, AppStateProvider appState) {
    final achievements = _getAchievements(appState);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Achievements',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: achievements.length,
            itemBuilder: (context, index) {
              final achievement = achievements[index];
              return Container(
                width: 80,
                margin: const EdgeInsets.only(right: 16),
                child: Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: achievement.isUnlocked 
                            ? achievement.color.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(30),
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
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      achievement.title,
                      style: TextStyle(
                        fontSize: 12,
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
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAvailableQuizzes(BuildContext context, AppStateProvider appState) {
    final quizzes = _getQuizzes();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Quizzes',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: quizzes.length,
          itemBuilder: (context, index) {
            final quiz = quizzes[index];
            final score = appState.quizScores[quiz.id] ?? 0.0;
            final hasCompleted = score > 0;
            final moduleProgress = appState.moduleProgress[quiz.moduleId] ?? 0;
            final isLocked = moduleProgress < 50; // Unlock after 50% module completion

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: isLocked ? null : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => QuizScreen(quiz: quiz),
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
                                : quiz.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            isLocked ? Icons.lock : quiz.icon,
                            color: isLocked ? Colors.grey : quiz.color,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                quiz.title,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: isLocked ? Colors.grey : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                quiz.description,
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
                                  Icon(
                                    Icons.quiz,
                                    size: 16,
                                    color: isLocked ? Colors.grey : Colors.black54,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${quiz.questions.length} Questions',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isLocked ? Colors.grey : Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Icon(
                                    Icons.timer,
                                    size: 16,
                                    color: isLocked ? Colors.grey : Colors.black54,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${quiz.timeLimit} min',
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
                        Column(
                          children: [
                            if (hasCompleted)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _getScoreColor(score).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${score.toInt()}%',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: _getScoreColor(score),
                                  ),
                                ),
                              )
                            else if (isLocked)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'locked'.tr(),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey,
                                  ),
                                ),
                              )
                            else
                              Icon(
                                Icons.play_arrow,
                                color: quiz.color,
                                size: 24,
                              ),
                          ],
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

  Color _getScoreColor(double score) {
    if (score >= 80) return AppTheme.successColor;
    if (score >= 60) return Colors.orange;
    return AppTheme.errorColor;
  }

  List<Achievement> _getAchievements(AppStateProvider appState) {
    final averageScore = appState.getAverageQuizScore();
    final completedQuizzes = appState.quizScores.length;

    return [
      Achievement(
        title: 'First Quiz',
        icon: Icons.play_arrow,
        color: AppTheme.primaryColor,
        isUnlocked: completedQuizzes >= 1,
      ),
      Achievement(
        title: 'Quiz Master',
        icon: Icons.school,
        color: AppTheme.accentColor,
        isUnlocked: completedQuizzes >= 5,
      ),
      Achievement(
        title: 'High Scorer',
        icon: Icons.star,
        color: Colors.amber,
        isUnlocked: averageScore >= 80,
      ),
      Achievement(
        title: 'Perfect Score',
        icon: Icons.emoji_events,
        color: Colors.amber,
        isUnlocked: appState.quizScores.values.any((score) => score >= 100),
      ),
    ];
  }

  List<Quiz> _getQuizzes() {
    return [
      Quiz(
        id: 'stock_basics_quiz',
        moduleId: 'stock_basics',
        title: 'Stock Market Basics Quiz',
        description: 'Test your knowledge of stock market fundamentals',
        icon: Icons.trending_up,
        color: AppTheme.primaryColor,
        timeLimit: 10,
        questions: _getStockBasicsQuestions(),
      ),
      Quiz(
        id: 'risk_management_quiz',
        moduleId: 'risk_management',
        title: 'Risk Management Quiz',
        description: 'Assess your understanding of investment risks',
        icon: Icons.security,
        color: AppTheme.accentColor,
        timeLimit: 8,
        questions: _getRiskManagementQuestions(),
      ),
      Quiz(
        id: 'technical_analysis_quiz',
        moduleId: 'technical_analysis',
        title: 'Technical Analysis Quiz',
        description: 'Test your chart reading skills',
        icon: Icons.analytics,
        color: Colors.purple,
        timeLimit: 12,
        questions: _getTechnicalAnalysisQuestions(),
      ),
    ];
  }

  List<QuizQuestion> _getStockBasicsQuestions() {
    return [
      QuizQuestion(
        question: 'What does IPO stand for?',
        options: [
          'Initial Public Offering',
          'International Private Organization',
          'Investment Portfolio Option',
          'Indian Public Offering'
        ],
        correctAnswer: 0,
      ),
      QuizQuestion(
        question: 'Which is the oldest stock exchange in Asia?',
        options: ['NSE', 'BSE', 'Tokyo Stock Exchange', 'Shanghai Stock Exchange'],
        correctAnswer: 1,
      ),
      QuizQuestion(
        question: 'What is a dividend?',
        options: [
          'A loan from the company',
          'A share of company profits paid to shareholders',
          'The price of a stock',
          'A type of bond'
        ],
        correctAnswer: 1,
      ),
      QuizQuestion(
        question: 'What does P/E ratio measure?',
        options: [
          'Price to Earnings ratio',
          'Profit to Expense ratio',
          'Price to Equity ratio',
          'Performance to Expectation ratio'
        ],
        correctAnswer: 0,
      ),
      QuizQuestion(
        question: 'Which regulates the Indian stock market?',
        options: ['RBI', 'SEBI', 'IRDA', 'TRAI'],
        correctAnswer: 1,
      ),
    ];
  }

  List<QuizQuestion> _getRiskManagementQuestions() {
    return [
      QuizQuestion(
        question: 'What is diversification?',
        options: [
          'Buying only one stock',
          'Spreading investments across different assets',
          'Selling all stocks',
          'Investing in foreign markets only'
        ],
        correctAnswer: 1,
      ),
      QuizQuestion(
        question: 'What is a stop-loss order?',
        options: [
          'An order to buy more stocks',
          'An order to sell when price reaches a certain level',
          'An order to hold stocks forever',
          'An order to cancel all trades'
        ],
        correctAnswer: 1,
      ),
      QuizQuestion(
        question: 'Which type of risk cannot be diversified away?',
        options: ['Company-specific risk', 'Industry risk', 'Market risk', 'Credit risk'],
        correctAnswer: 2,
      ),
      QuizQuestion(
        question: 'What is the recommended maximum investment in a single stock?',
        options: ['50%', '25%', '10%', '5%'],
        correctAnswer: 2,
      ),
    ];
  }

  List<QuizQuestion> _getTechnicalAnalysisQuestions() {
    return [
      QuizQuestion(
        question: 'What does a candlestick chart show?',
        options: [
          'Only closing prices',
          'Open, high, low, and close prices',
          'Only volume data',
          'Company fundamentals'
        ],
        correctAnswer: 1,
      ),
      QuizQuestion(
        question: 'What is a moving average?',
        options: [
          'The average price over a specific period',
          'The highest price in a day',
          'The lowest price in a day',
          'The opening price'
        ],
        correctAnswer: 0,
      ),
      QuizQuestion(
        question: 'What does RSI measure?',
        options: [
          'Price momentum',
          'Volume',
          'Market cap',
          'Dividend yield'
        ],
        correctAnswer: 0,
      ),
    ];
  }
}

class Quiz {
  final String id;
  final String moduleId;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final int timeLimit;
  final List<QuizQuestion> questions;

  Quiz({
    required this.id,
    required this.moduleId,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.timeLimit,
    required this.questions,
  });
}

class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctAnswer;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctAnswer,
  });
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
