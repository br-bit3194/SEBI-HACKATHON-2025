import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../utils/app_theme.dart';

class NewsScreen extends StatefulWidget {
  final String languageCode;
  final String languageName;
  
  const NewsScreen({
    Key? key, 
    required this.languageCode,
    required this.languageName,
  }) : super(key: key);

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  bool isLoading = true;
  Map<String, List<String>> updates = {};
  String error = '';

  @override
  void initState() {
    super.initState();
    fetchNews();
  }

  Future<void> fetchNews() async {
    setState(() {
      isLoading = true;
      error = '';
    });
    
    try {
      // Replace with your backend URL
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/updates?language=${widget.languageCode}'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          updates = Map<String, List<String>>.from(
            (data['updates'] as Map).map((k, v) => MapEntry(k, List<String>.from(v)))
          );
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Failed to fetch news. Status: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error connecting to server: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text('${widget.languageName} News'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchNews,
          ),
        ],
      ),
      body: Column(
        children: [
          // Header with language info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.newspaper,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Latest Market Updates',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Language: ${widget.languageName}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          // Content area
          Expanded(
            child: isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Fetching latest news...'),
                      ],
                    ),
                  )
                : error.isNotEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 64,
                                color: Colors.red.withOpacity(0.6),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Error',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red.withOpacity(0.8),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                error,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: fetchNews,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryColor,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.all(16),
                        children: updates.entries.map((entry) {
                          return _buildNewsSection(entry.key, entry.value);
                        }).toList(),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsSection(String source, List<String> newsList) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
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
          // Section header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getSourceColor(source).withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getSourceColor(source),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    source,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${newsList.length} updates',
                  style: TextStyle(
                    color: _getSourceColor(source),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // News items
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: newsList.asMap().entries.map((entry) {
                final index = entry.key;
                final news = entry.value;
                return Padding(
                  padding: EdgeInsets.only(bottom: index < newsList.length - 1 ? 12 : 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.only(top: 6, right: 12),
                        decoration: BoxDecoration(
                          color: _getSourceColor(source),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          news,
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.4,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Color _getSourceColor(String source) {
    switch (source.toUpperCase()) {
      case 'SEBI':
        return AppTheme.primaryColor;
      case 'NSE':
        return AppTheme.secondaryColor;
      case 'BSE':
        return AppTheme.accentColor;
      case 'NISM':
        return AppTheme.successColor;
      default:
        return Colors.blue;
    }
  }
}
