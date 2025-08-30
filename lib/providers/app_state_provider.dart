import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppStateProvider extends ChangeNotifier {
  bool _isFirstTime = true;
  String _selectedLanguage = 'en';
  int _currentModuleIndex = 0;
  double _virtualBalance = 100000.0;
  Map<String, int> _moduleProgress = {};
  Map<String, double> _quizScores = {};
  List<Map<String, dynamic>> _portfolio = [];
  List<Map<String, dynamic>> _watchlist = [];

  // Getters
  bool get isFirstTime => _isFirstTime;
  String get selectedLanguage => _selectedLanguage;
  int get currentModuleIndex => _currentModuleIndex;
  double get virtualBalance => _virtualBalance;
  Map<String, int> get moduleProgress => _moduleProgress;
  Map<String, double> get quizScores => _quizScores;
  List<Map<String, dynamic>> get portfolio => _portfolio;
  List<Map<String, dynamic>> get watchlist => _watchlist;

  AppStateProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _isFirstTime = prefs.getBool('isFirstTime') ?? true;
    _selectedLanguage = prefs.getString('selectedLanguage') ?? 'en';
    _currentModuleIndex = prefs.getInt('currentModuleIndex') ?? 0;
    _virtualBalance = prefs.getDouble('virtualBalance') ?? 100000.0;
    
    // Load module progress
    final progressKeys = prefs.getKeys().where((key) => key.startsWith('module_'));
    for (String key in progressKeys) {
      _moduleProgress[key.replaceFirst('module_', '')] = prefs.getInt(key) ?? 0;
    }
    
    // Load quiz scores
    final quizKeys = prefs.getKeys().where((key) => key.startsWith('quiz_'));
    for (String key in quizKeys) {
      _quizScores[key.replaceFirst('quiz_', '')] = prefs.getDouble(key) ?? 0.0;
    }
    
    notifyListeners();
  }

  Future<void> setFirstTimeComplete() async {
    _isFirstTime = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstTime', false);
    notifyListeners();
  }

  Future<void> setLanguage(String language) async {
    _selectedLanguage = language;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedLanguage', language);
    notifyListeners();
  }

  Future<void> updateModuleProgress(String moduleId, int progress) async {
    _moduleProgress[moduleId] = progress;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('module_$moduleId', progress);
    notifyListeners();
  }

  Future<void> updateQuizScore(String quizId, double score) async {
    _quizScores[quizId] = score;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('quiz_$quizId', score);
    notifyListeners();
  }

  Future<void> updateVirtualBalance(double newBalance) async {
    _virtualBalance = newBalance;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('virtualBalance', newBalance);
    notifyListeners();
  }

  void addToPortfolio(Map<String, dynamic> stock) {
    _portfolio.add(stock);
    notifyListeners();
  }

  void removeFromPortfolio(int index) {
    if (index < _portfolio.length) {
      _portfolio.removeAt(index);
      notifyListeners();
    }
  }

  void addToWatchlist(Map<String, dynamic> stock) {
    _watchlist.add(stock);
    notifyListeners();
  }

  void removeFromWatchlist(int index) {
    if (index < _watchlist.length) {
      _watchlist.removeAt(index);
      notifyListeners();
    }
  }

  double getPortfolioValue() {
    double totalValue = 0;
    for (var stock in _portfolio) {
      totalValue += (stock['quantity'] ?? 0) * (stock['currentPrice'] ?? 0);
    }
    return totalValue;
  }

  double getTodaysPnL() {
    double pnl = 0;
    for (var stock in _portfolio) {
      double buyPrice = stock['buyPrice'] ?? 0;
      double currentPrice = stock['currentPrice'] ?? 0;
      int quantity = stock['quantity'] ?? 0;
      pnl += (currentPrice - buyPrice) * quantity;
    }
    return pnl;
  }

  int getCompletedModulesCount() {
    return _moduleProgress.values.where((progress) => progress >= 100).length;
  }

  double getAverageQuizScore() {
    if (_quizScores.isEmpty) return 0.0;
    double total = _quizScores.values.reduce((a, b) => a + b);
    return total / _quizScores.length;
  }
}
