import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8000/api/trading';
  
  // For Android emulator, use 10.0.2.2 instead of localhost
  static const String androidBaseUrl = 'http://10.0.2.2:8000/api/trading';
  
  static String get _baseUrl {
    if (kIsWeb) {
      return baseUrl;
    } else {
      // Check if running on Android
      return androidBaseUrl;
    }
  }

  // Headers for API requests
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Market Data APIs
  static Future<List<Map<String, dynamic>>> getMarketData() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/market'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['stocks']);
      } else {
        throw Exception('Failed to load market data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching market data: $e');
    }
  }

  static Future<Map<String, dynamic>?> getStockData(String symbol) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/stocks/$symbol'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to load stock data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching stock data: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> searchStocks(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/stocks/search/$query'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['stocks']);
      } else {
        throw Exception('Failed to search stocks: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching stocks: $e');
    }
  }

  static Future<Map<String, dynamic>?> getStockQuote(String symbol) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/quote/$symbol'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to get stock quote: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting stock quote: $e');
    }
  }

  // Portfolio Management APIs
  static Future<Map<String, dynamic>?> getPortfolio(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/portfolio/$userId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to load portfolio: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching portfolio: $e');
    }
  }

  static Future<Map<String, dynamic>?> getUser(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/user/$userId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to load user: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching user: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getTransactionHistory(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/transactions/$userId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['transactions']);
      } else {
        throw Exception('Failed to load transactions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching transactions: $e');
    }
  }

  // Trading APIs
  static Future<Map<String, dynamic>> executeTrade(
    String userId,
    String symbol,
    int quantity,
    String transactionType,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/trade/$userId'),
        headers: _headers,
        body: json.encode({
          'symbol': symbol,
          'quantity': quantity,
          'transaction_type': transactionType,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['detail'] ?? 'Failed to execute trade');
      }
    } catch (e) {
      throw Exception('Error executing trade: $e');
    }
  }

  // Watchlist APIs
  static Future<Map<String, dynamic>> getWatchlist(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/watchlist/$userId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load watchlist: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching watchlist: $e');
    }
  }

  static Future<bool> addToWatchlist(String userId, String symbol) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/watchlist/$userId/$symbol'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] ?? false;
      } else {
        throw Exception('Failed to add to watchlist: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error adding to watchlist: $e');
    }
  }

  static Future<bool> removeFromWatchlist(String userId, String symbol) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/watchlist/$userId/$symbol'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] ?? false;
      } else {
        throw Exception('Failed to remove from watchlist: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error removing from watchlist: $e');
    }
  }

  // Utility APIs
  static Future<List<String>> getAvailableStocks() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/available-stocks'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<String>.from(data['stocks']);
      } else {
        throw Exception('Failed to get available stocks: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting available stocks: $e');
    }
  }

  static Future<bool> healthCheck() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/health'),
        headers: _headers,
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
