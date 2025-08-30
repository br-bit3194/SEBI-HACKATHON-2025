import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state_provider.dart';
import '../../utils/app_theme.dart';
import 'learning_modules_screen.dart';

class ModuleDetailScreen extends StatefulWidget {
  final LearningModule module;

  const ModuleDetailScreen({super.key, required this.module});

  @override
  State<ModuleDetailScreen> createState() => _ModuleDetailScreenState();
}

class _ModuleDetailScreenState extends State<ModuleDetailScreen> {
  int currentLessonIndex = 0;
  
  @override
  Widget build(BuildContext context) {
    final lessons = _getLessonsForModule(widget.module.id);
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(widget.module.title),
        backgroundColor: widget.module.color,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildProgressHeader(context, lessons),
          Expanded(
            child: _buildLessonContent(context, lessons[currentLessonIndex]),
          ),
          _buildNavigationButtons(context, lessons),
        ],
      ),
    );
  }

  Widget _buildProgressHeader(BuildContext context, List<Lesson> lessons) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Lesson ${currentLessonIndex + 1} of ${lessons.length}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${((currentLessonIndex + 1) / lessons.length * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: widget.module.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (currentLessonIndex + 1) / lessons.length,
            backgroundColor: Colors.grey.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(widget.module.color),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonContent(BuildContext context, Lesson lesson) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
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
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: widget.module.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        lesson.icon,
                        color: widget.module.color,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        lesson.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  lesson.content,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.6,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),
                if (lesson.keyPoints.isNotEmpty) ...[
                  Text(
                    'Key Points:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: widget.module.color,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...lesson.keyPoints.map((point) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 6),
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: widget.module.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            point,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (lesson.example.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: widget.module.color.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: widget.module.color.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: widget.module.color,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Example',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: widget.module.color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    lesson.example,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(BuildContext context, List<Lesson> lessons) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          if (currentLessonIndex > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    currentLessonIndex--;
                  });
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: widget.module.color,
                  side: BorderSide(color: widget.module.color),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text('previous'.tr()),
              ),
            ),
          if (currentLessonIndex > 0) const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                if (currentLessonIndex < lessons.length - 1) {
                  setState(() {
                    currentLessonIndex++;
                  });
                } else {
                  _completeModule(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.module.color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                currentLessonIndex < lessons.length - 1 
                    ? 'next'.tr() 
                    : 'Complete Module',
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _completeModule(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context, listen: false);
    appState.updateModuleProgress(widget.module.id, 100);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🎉 Congratulations!'),
        content: Text('You have completed the ${widget.module.title} module!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Continue Learning'),
          ),
        ],
      ),
    );
  }

  List<Lesson> _getLessonsForModule(String moduleId) {
    switch (moduleId) {
      case 'stock_basics':
        return [
          Lesson(
            title: 'What is Stock Market?',
            icon: Icons.store,
            content: 'The stock market is a platform where shares of publicly traded companies are bought and sold. It serves as a marketplace for investors to trade ownership stakes in companies.',
            keyPoints: [
              'Stock market facilitates buying and selling of company shares',
              'It provides liquidity to investors',
              'Companies raise capital by issuing shares',
              'Stock prices reflect company performance and market sentiment',
            ],
            example: 'If you buy 100 shares of Reliance Industries at ₹2,500 per share, you own a small portion of the company worth ₹2,50,000.',
          ),
          Lesson(
            title: 'Types of Stocks',
            icon: Icons.category,
            content: 'Stocks can be categorized in various ways based on market capitalization, dividend policy, and growth potential.',
            keyPoints: [
              'Large-cap: Companies with market cap > ₹20,000 crores',
              'Mid-cap: Companies with market cap ₹5,000-20,000 crores',
              'Small-cap: Companies with market cap < ₹5,000 crores',
              'Growth stocks vs Value stocks',
            ],
            example: 'TCS is a large-cap stock, while a regional bank might be a small-cap stock.',
          ),
          Lesson(
            title: 'How Stock Prices Move',
            icon: Icons.trending_up,
            content: 'Stock prices are determined by supply and demand in the market, influenced by various factors including company performance, economic conditions, and investor sentiment.',
            keyPoints: [
              'Supply and demand determine prices',
              'Company earnings affect stock prices',
              'Market sentiment plays a crucial role',
              'Economic indicators influence overall market',
            ],
            example: 'If a company reports better-than-expected quarterly results, demand for its stock increases, pushing the price up.',
          ),
          Lesson(
            title: 'Stock Exchanges in India',
            icon: Icons.business,
            content: 'India has two major stock exchanges: BSE (Bombay Stock Exchange) and NSE (National Stock Exchange), which facilitate trading of stocks.',
            keyPoints: [
              'BSE is the oldest stock exchange in Asia',
              'NSE has the highest trading volume',
              'Both are regulated by SEBI',
              'Sensex and Nifty are major indices',
            ],
            example: 'Sensex tracks 30 large companies on BSE, while Nifty 50 tracks 50 companies on NSE.',
          ),
          Lesson(
            title: 'Getting Started with Trading',
            icon: Icons.play_arrow,
            content: 'To start trading, you need a demat account, trading account, and bank account. Choose a reliable broker and understand the trading process.',
            keyPoints: [
              'Open demat and trading accounts',
              'Complete KYC process',
              'Link your bank account',
              'Start with small investments',
            ],
            example: 'You can open accounts with brokers like Zerodha, Upstox, or traditional banks like ICICI Direct.',
          ),
        ];
      case 'risk_management':
        return [
          Lesson(
            title: 'Understanding Investment Risk',
            icon: Icons.warning,
            content: 'Investment risk is the possibility of losing money or not achieving expected returns. Different investments carry different levels of risk.',
            keyPoints: [
              'Risk and return are directly related',
              'Higher risk investments offer higher potential returns',
              'Risk tolerance varies by individual',
              'Time horizon affects risk capacity',
            ],
            example: 'Fixed deposits are low-risk but offer lower returns, while stocks are higher-risk but can provide better long-term returns.',
          ),
          Lesson(
            title: 'Types of Investment Risks',
            icon: Icons.category,
            content: 'There are various types of risks in investing including market risk, credit risk, inflation risk, and liquidity risk.',
            keyPoints: [
              'Market risk: Overall market decline',
              'Credit risk: Company default risk',
              'Inflation risk: Purchasing power erosion',
              'Liquidity risk: Difficulty in selling',
            ],
            example: 'During 2008 financial crisis, market risk affected all stocks regardless of individual company performance.',
          ),
          Lesson(
            title: 'Risk Management Strategies',
            icon: Icons.shield,
            content: 'Effective risk management involves diversification, asset allocation, stop-loss orders, and regular portfolio review.',
            keyPoints: [
              'Diversify across sectors and asset classes',
              'Set stop-loss limits',
              'Regular portfolio rebalancing',
              'Invest only what you can afford to lose',
            ],
            example: 'Instead of investing all money in tech stocks, spread it across banking, pharma, FMCG, and other sectors.',
          ),
          Lesson(
            title: 'Position Sizing and Money Management',
            icon: Icons.calculate,
            content: 'Position sizing determines how much money to invest in each stock or trade, which is crucial for managing overall portfolio risk.',
            keyPoints: [
              'Never invest more than 5-10% in a single stock',
              'Use the 1% rule for trading',
              'Maintain emergency fund separately',
              'Regular savings and systematic investing',
            ],
            example: 'If your portfolio is ₹1,00,000, don\'t invest more than ₹10,000 in any single stock.',
          ),
        ];
      default:
        return [
          Lesson(
            title: 'Coming Soon',
            icon: Icons.construction,
            content: 'This module content is being prepared and will be available soon.',
            keyPoints: [],
            example: '',
          ),
        ];
    }
  }
}

class Lesson {
  final String title;
  final IconData icon;
  final String content;
  final List<String> keyPoints;
  final String example;

  Lesson({
    required this.title,
    required this.icon,
    required this.content,
    required this.keyPoints,
    required this.example,
  });
}
