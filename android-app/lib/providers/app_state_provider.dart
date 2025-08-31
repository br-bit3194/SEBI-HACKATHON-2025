import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class AppStateProvider extends ChangeNotifier {
  bool _isFirstTime = true;
  String _selectedLanguage = 'en';
  int _currentModuleIndex = 0;
  double _virtualBalance = 100000.0;
  final Map<String, int> _moduleProgress = {};
  final Map<String, double> _quizScores = {};
  final List<Map<String, dynamic>> _portfolio = [];
  final List<Map<String, dynamic>> _watchlist = [];

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
    _initializeBackendData();
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

  // Backend integration methods
  Future<void> _initializeBackendData() async {
    try {
      // Check backend health
      final isHealthy = await ApiService.healthCheck();
      if (isHealthy) {
        // Load user data from backend
        await _loadUserFromBackend();
        await _loadPortfolioFromBackend();
        await _loadWatchlistFromBackend();
      }
    } catch (e) {
      print('Backend initialization error: $e');
    }
  }

  Future<void> _loadUserFromBackend() async {
    try {
      const userId = 'demo_user_001'; // Default user for demo
      final userData = await ApiService.getUser(userId);
      if (userData != null) {
        _virtualBalance = userData['virtual_balance']?.toDouble() ?? _virtualBalance;
        notifyListeners();
      }
    } catch (e) {
      print('Error loading user from backend: $e');
    }
  }

  Future<void> _loadPortfolioFromBackend() async {
    try {
      const userId = 'demo_user_001';
      final portfolioData = await ApiService.getPortfolio(userId);
      if (portfolioData != null) {
        final holdings = portfolioData['holdings'] as List?;
        if (holdings != null) {
          _portfolio.clear();
          for (final holding in holdings) {
            _portfolio.add({
              'symbol': holding['symbol'],
              'quantity': holding['quantity'],
              'buyPrice': holding['buy_price']?.toDouble() ?? 0.0,
              'currentPrice': holding['current_price']?.toDouble() ?? 0.0,
            });
          }
          notifyListeners();
        }
      }
    } catch (e) {
      print('Error loading portfolio from backend: $e');
    }
  }

  Future<void> _loadWatchlistFromBackend() async {
    try {
      const userId = 'demo_user_001';
      final watchlistData = await ApiService.getWatchlist(userId);
      if (watchlistData != null) {
        final symbols = watchlistData['symbols'] as List?;
        if (symbols != null) {
          _watchlist.clear();
          for (final symbol in symbols) {
            _watchlist.add({
              'symbol': symbol,
              'name': symbol, // Will be updated with actual stock names
            });
          }
          notifyListeners();
        }
      }
    } catch (e) {
      print('Error loading watchlist from backend: $e');
    }
  }

  Future<void> refreshMarketData() async {
    try {
      final marketData = await ApiService.getMarketData();
      // Update portfolio with current prices
      for (int i = 0; i < _portfolio.length; i++) {
        final symbol = _portfolio[i]['symbol'];
        final stockData = marketData.firstWhere(
          (stock) => stock['symbol'] == symbol,
          orElse: () => {},
        );
        if (stockData.isNotEmpty) {
          _portfolio[i]['currentPrice'] = stockData['current_price']?.toDouble() ?? _portfolio[i]['currentPrice'];
        }
      }
      notifyListeners();
    } catch (e) {
      print('Error refreshing market data: $e');
    }
  }

  Future<bool> executeBackendTrade(String symbol, int quantity, bool isBuy) async {
    try {
      const userId = 'demo_user_001';
      final transactionType = isBuy ? 'BUY' : 'SELL';
      
      final result = await ApiService.executeTrade(userId, symbol, quantity, transactionType);
      
      if (result['success'] == true) {
        // Update local state with backend response
        _virtualBalance = result['new_balance']?.toDouble() ?? _virtualBalance;
        
        // Refresh portfolio from backend
        await _loadPortfolioFromBackend();
        
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Error executing backend trade: $e');
      return false;
    }
  }

  Future<bool> addToWatchlistBackend(String symbol) async {
    try {
      const userId = 'demo_user_001';
      final success = await ApiService.addToWatchlist(userId, symbol);
      if (success) {
        await _loadWatchlistFromBackend();
        return true;
      }
      return false;
    } catch (e) {
      print('Error adding to watchlist backend: $e');
      return false;
    }
  }

  Future<bool> removeFromWatchlistBackend(String symbol) async {
    try {
      const userId = 'demo_user_001';
      final success = await ApiService.removeFromWatchlist(userId, symbol);
      if (success) {
        await _loadWatchlistFromBackend();
        return true;
      }
      return false;
    } catch (e) {
      print('Error removing from watchlist backend: $e');
      return false;
    }
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
