import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../providers/app_state_provider.dart';
import '../../utils/app_theme.dart';
import 'quiz_home_screen.dart';

class QuizScreen extends StatefulWidget {
  final Quiz quiz;

  const QuizScreen({super.key, required this.quiz});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with TickerProviderStateMixin {
  int currentQuestionIndex = 0;
  int? selectedAnswer;
  List<int> userAnswers = [];
  Timer? timer;
  int timeRemaining = 0;
  bool isQuizCompleted = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    timeRemaining = widget.quiz.timeLimit * 60; // Convert to seconds
    userAnswers = List.filled(widget.quiz.questions.length, -1);
    _startTimer();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  void _startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeRemaining > 0) {
        setState(() {
          timeRemaining--;
        });
      } else {
        _completeQuiz();
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isQuizCompleted) {
      return _buildResultScreen();
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(widget.quiz.title),
        backgroundColor: widget.quiz.color,
        foregroundColor: Colors.white,
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.timer, size: 16),
                const SizedBox(width: 4),
                Text(
                  _formatTime(timeRemaining),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            _buildProgressHeader(),
            Expanded(
              child: _buildQuestionCard(),
            ),
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressHeader() {
    final progress = (currentQuestionIndex + 1) / widget.quiz.questions.length;
    
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${'question'.tr()} ${currentQuestionIndex + 1}/${widget.quiz.questions.length}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: widget.quiz.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(widget.quiz.color),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard() {
    final question = widget.quiz.questions[currentQuestionIndex];
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
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
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: widget.quiz.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.quiz,
                color: widget.quiz.color,
                size: 24,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              question.question,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            ...question.options.asMap().entries.map((entry) {
              final index = entry.key;
              final option = entry.value;
              final isSelected = selectedAnswer == index;
              
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        selectedAnswer = index;
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? widget.quiz.color.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected 
                              ? widget.quiz.color
                              : Colors.grey.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: isSelected 
                                  ? widget.quiz.color
                                  : Colors.transparent,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected 
                                    ? widget.quiz.color
                                    : Colors.grey,
                                width: 2,
                              ),
                            ),
                            child: isSelected
                                ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 16,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              option,
                              style: TextStyle(
                                fontSize: 16,
                                color: isSelected 
                                    ? widget.quiz.color
                                    : Colors.black87,
                                fontWeight: isSelected 
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          if (currentQuestionIndex > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    currentQuestionIndex--;
                    selectedAnswer = userAnswers[currentQuestionIndex] != -1 
                        ? userAnswers[currentQuestionIndex] 
                        : null;
                  });
                  _animationController.reset();
                  _animationController.forward();
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: widget.quiz.color,
                  side: BorderSide(color: widget.quiz.color),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text('previous'.tr()),
              ),
            ),
          if (currentQuestionIndex > 0) const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: selectedAnswer != null ? () {
                userAnswers[currentQuestionIndex] = selectedAnswer!;
                
                if (currentQuestionIndex < widget.quiz.questions.length - 1) {
                  setState(() {
                    currentQuestionIndex++;
                    selectedAnswer = userAnswers[currentQuestionIndex] != -1 
                        ? userAnswers[currentQuestionIndex] 
                        : null;
                  });
                  _animationController.reset();
                  _animationController.forward();
                } else {
                  _completeQuiz();
                }
              } : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.quiz.color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                currentQuestionIndex < widget.quiz.questions.length - 1 
                    ? 'next'.tr() 
                    : 'submit_answer'.tr(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultScreen() {
    final score = _calculateScore();
    final percentage = (score / widget.quiz.questions.length * 100).round();
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text('quiz_completed'.tr()),
        backgroundColor: widget.quiz.color,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: _getScoreColor(percentage.toDouble()).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getScoreIcon(percentage.toDouble()),
                  size: 60,
                  color: _getScoreColor(percentage.toDouble()),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'quiz_completed'.tr(),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'your_score'.tr(),
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$percentage%',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: _getScoreColor(percentage.toDouble()),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$score/${widget.quiz.questions.length} ${'correct'.tr()}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 32),
              Container(
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
                  children: [
                    Text(
                      _getScoreMessage(percentage.toDouble()),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: widget.quiz.color,
                              side: BorderSide(color: widget.quiz.color),
                            ),
                            child: Text('retake_quiz'.tr()),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).popUntil((route) => route.isFirst);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: widget.quiz.color,
                              foregroundColor: Colors.white,
                            ),
                            child: Text('continue'.tr()),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _completeQuiz() {
    timer?.cancel();
    final score = _calculateScore();
    final percentage = (score / widget.quiz.questions.length * 100);
    
    final appState = Provider.of<AppStateProvider>(context, listen: false);
    appState.updateQuizScore(widget.quiz.id, percentage);
    
    setState(() {
      isQuizCompleted = true;
    });
  }

  int _calculateScore() {
    int score = 0;
    for (int i = 0; i < widget.quiz.questions.length; i++) {
      if (userAnswers[i] == widget.quiz.questions[i].correctAnswer) {
        score++;
      }
    }
    return score;
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return AppTheme.successColor;
    if (score >= 60) return Colors.orange;
    return AppTheme.errorColor;
  }

  IconData _getScoreIcon(double score) {
    if (score >= 80) return Icons.emoji_events;
    if (score >= 60) return Icons.thumb_up;
    return Icons.refresh;
  }

  String _getScoreMessage(double score) {
    if (score >= 90) return 'Excellent! You have mastered this topic!';
    if (score >= 80) return 'Great job! You have a good understanding.';
    if (score >= 60) return 'Good effort! Review the material and try again.';
    return 'Keep learning! Practice makes perfect.';
  }
}
