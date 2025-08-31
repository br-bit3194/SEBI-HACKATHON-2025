import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/app_state_provider.dart';
import '../../utils/app_theme.dart';
import '../../services/api_service.dart';
import 'stock_detail_screen.dart';

class VirtualTradingScreen extends StatefulWidget {
  const VirtualTradingScreen({super.key});

  @override
  State<VirtualTradingScreen> createState() => _VirtualTradingScreenState();
}

class _VirtualTradingScreenState extends State<VirtualTradingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Stock> stocks = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadMarketData();
  }

  Future<void> _loadMarketData() async {
    try {
      final appState = Provider.of<AppStateProvider>(context, listen: false);
      await appState.refreshMarketData();
      
      // Load market data from backend
      final marketData = await ApiService.getMarketData();
      setState(() {
        stocks = marketData.map((data) => Stock(
          symbol: data['symbol'] ?? '',
          name: data['name'] ?? '',
          currentPrice: data['current_price']?.toDouble() ?? 0.0,
          change: data['change']?.toDouble() ?? 0.0,
          changePercent: data['change_percent']?.toDouble() ?? 0.0,
          volume: data['volume']?.toInt() ?? 0,
          marketCap: data['market_cap']?.toDouble() ?? 0.0,
          sector: data['sector'] ?? '',
        )).toList();
      });
    } catch (e) {
      print('Error loading market data: $e');
      // Fallback to static data if backend fails
      _initializeStaticStocks();
    }
  }

  void _initializeStaticStocks() {
    stocks = [
      Stock(
        symbol: 'RELIANCE.NS',
        name: 'Reliance Industries Ltd',
        currentPrice: 2456.75,
        change: 23.45,
        changePercent: 0.96,
        volume: 1234567,
        marketCap: 16.6,
        sector: 'Energy',
      ),
      Stock(
        symbol: 'TCS.NS',
        name: 'Tata Consultancy Services',
        currentPrice: 3789.20,
        change: -45.30,
        changePercent: -1.18,
        volume: 987654,
        marketCap: 13.8,
        sector: 'IT',
      ),
      Stock(
        symbol: 'HDFCBANK.NS',
        name: 'HDFC Bank Ltd',
        currentPrice: 1654.85,
        change: 12.75,
        changePercent: 0.78,
        volume: 2345678,
        marketCap: 12.2,
        sector: 'Banking',
      ),
      Stock(
        symbol: 'INFY.NS',
        name: 'Infosys Ltd',
        currentPrice: 1456.30,
        change: 18.90,
        changePercent: 1.31,
        volume: 1876543,
        marketCap: 6.1,
        sector: 'IT',
      ),
      Stock(
        symbol: 'ICICIBANK.NS',
        name: 'ICICI Bank Ltd',
        currentPrice: 987.45,
        change: -8.25,
        changePercent: -0.83,
        volume: 3456789,
        marketCap: 6.9,
        sector: 'Banking',
      ),
      Stock(
        symbol: 'HINDUNILVR.NS',
        name: 'Hindustan Unilever Ltd',
        currentPrice: 2234.60,
        change: 34.80,
        changePercent: 1.58,
        volume: 567890,
        marketCap: 5.2,
        sector: 'FMCG',
      ),
    ];
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text('virtual_trading'.tr()),
        backgroundColor: AppTheme.secondaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(text: 'Portfolio'),
            Tab(text: 'Market'),
            Tab(text: 'Watchlist'),
          ],
        ),
      ),
      body: Consumer<AppStateProvider>(
        builder: (context, appState, child) {
          return Column(
            children: [
              _buildAccountSummary(appState),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPortfolioTab(appState),
                    _buildMarketTab(appState),
                    _buildWatchlistTab(appState),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAccountSummary(AppStateProvider appState) {
    final portfolioValue = appState.getPortfolioValue();
    final totalValue = appState.virtualBalance + portfolioValue;
    final todaysPnL = appState.getTodaysPnL();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.secondaryColor, AppTheme.primaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Value',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '₹${NumberFormat('#,##,###').format(totalValue)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Today\'s P&L',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '${todaysPnL >= 0 ? '+' : ''}₹${NumberFormat('#,##,###').format(todaysPnL)}',
                    style: TextStyle(
                      color: todaysPnL >= 0 ? Colors.greenAccent : Colors.redAccent,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Available Cash',
                  '₹${NumberFormat('#,##,###').format(appState.virtualBalance)}',
                  Icons.account_balance_wallet,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  'Invested',
                  '₹${NumberFormat('#,##,###').format(portfolioValue)}',
                  Icons.trending_up,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioTab(AppStateProvider appState) {
    if (appState.portfolio.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pie_chart_outline,
              size: 80,
              color: Colors.grey.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No Holdings Yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start investing to build your portfolio',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _tabController.animateTo(1),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.secondaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Explore Market'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: appState.portfolio.length,
      itemBuilder: (context, index) {
        final holding = appState.portfolio[index];
        return _buildHoldingCard(holding, appState, index);
      },
    );
  }

  Widget _buildHoldingCard(Map<String, dynamic> holding, AppStateProvider appState, int index) {
    final symbol = holding['symbol'] ?? '';
    final quantity = holding['quantity'] ?? 0;
    final buyPrice = holding['buyPrice'] ?? 0.0;
    final currentPrice = holding['currentPrice'] ?? 0.0;
    final totalValue = quantity * currentPrice;
    final pnl = (currentPrice - buyPrice) * quantity;
    final pnlPercent = ((currentPrice - buyPrice) / buyPrice) * 100;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    symbol,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '$quantity shares',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹${NumberFormat('#,##,###').format(totalValue)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '₹${currentPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Avg: ₹${buyPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: pnl >= 0 
                      ? AppTheme.successColor.withOpacity(0.1)
                      : AppTheme.errorColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${pnl >= 0 ? '+' : ''}₹${pnl.toStringAsFixed(2)} (${pnlPercent >= 0 ? '+' : ''}${pnlPercent.toStringAsFixed(2)}%)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: pnl >= 0 ? AppTheme.successColor : AppTheme.errorColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showTradeDialog(context, symbol, false, appState),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.errorColor,
                    side: BorderSide(color: AppTheme.errorColor),
                  ),
                  child: const Text('Sell'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _showTradeDialog(context, symbol, true, appState),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.successColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Buy More'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMarketTab(AppStateProvider appState) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: stocks.length,
      itemBuilder: (context, index) {
        final stock = stocks[index];
        return _buildStockCard(stock, appState);
      },
    );
  }

  Widget _buildStockCard(Stock stock, AppStateProvider appState) {
    final isPositive = stock.change >= 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => StockDetailScreen(stock: stock),
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
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: _getSectorColor(stock.sector).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getSectorIcon(stock.sector),
                    color: _getSectorColor(stock.sector),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stock.symbol,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        stock.name,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        stock.sector,
                        style: TextStyle(
                          fontSize: 12,
                          color: _getSectorColor(stock.sector),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${stock.currentPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isPositive 
                            ? AppTheme.successColor.withOpacity(0.1)
                            : AppTheme.errorColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${isPositive ? '+' : ''}${stock.change.toStringAsFixed(2)} (${isPositive ? '+' : ''}${stock.changePercent.toStringAsFixed(2)}%)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isPositive ? AppTheme.successColor : AppTheme.errorColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => _showTradeDialog(context, stock.symbol, true, appState),
                          icon: const Icon(Icons.add_circle, color: AppTheme.successColor),
                          iconSize: 20,
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () => _addToWatchlist(stock, appState),
                          icon: Icon(
                            appState.watchlist.any((item) => item['symbol'] == stock.symbol)
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: AppTheme.accentColor,
                          ),
                          iconSize: 20,
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWatchlistTab(AppStateProvider appState) {
    if (appState.watchlist.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 80,
              color: Colors.grey.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No Stocks in Watchlist',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add stocks to track their performance',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.withOpacity(0.5),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: appState.watchlist.length,
      itemBuilder: (context, index) {
        final watchlistItem = appState.watchlist[index];
        final stock = stocks.firstWhere(
          (s) => s.symbol == watchlistItem['symbol'],
          orElse: () => stocks.first,
        );
        return _buildStockCard(stock, appState);
      },
    );
  }

  void _showTradeDialog(BuildContext context, String symbol, bool isBuy, AppStateProvider appState) {
    final stock = stocks.firstWhere((s) => s.symbol == symbol);
    final quantityController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${isBuy ? 'Buy' : 'Sell'} $symbol'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Current Price: ₹${stock.currentPrice.toStringAsFixed(2)}'),
            const SizedBox(height: 16),
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Quantity',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final quantity = int.tryParse(quantityController.text) ?? 0;
              if (quantity > 0) {
                _executeTrade(symbol, quantity, stock.currentPrice, isBuy, appState);
                Navigator.pop(context);
              }
            },
            child: Text(isBuy ? 'Buy' : 'Sell'),
          ),
        ],
      ),
    );
  }

  Future<void> _executeTrade(String symbol, int quantity, double price, bool isBuy, AppStateProvider appState) async {
    try {
      // Execute trade through backend
      final success = await appState.executeBackendTrade(symbol, quantity, isBuy);
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully ${isBuy ? 'bought' : 'sold'} $quantity shares of $symbol'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        
        // Refresh market data
        await _loadMarketData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Trade execution failed'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  Future<void> _addToWatchlist(Stock stock, AppStateProvider appState) async {
    try {
      final isInWatchlist = appState.watchlist.any((item) => item['symbol'] == stock.symbol);
      
      if (isInWatchlist) {
        // Remove from backend
        final success = await appState.removeFromWatchlistBackend(stock.symbol);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${stock.symbol} removed from watchlist')),
          );
        }
      } else {
        // Add to backend
        final success = await appState.addToWatchlistBackend(stock.symbol);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${stock.symbol} added to watchlist')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error managing watchlist: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  Color _getSectorColor(String sector) {
    switch (sector) {
      case 'IT': return Colors.blue;
      case 'Banking': return Colors.green;
      case 'Energy': return Colors.orange;
      case 'FMCG': return Colors.purple;
      default: return AppTheme.primaryColor;
    }
  }

  IconData _getSectorIcon(String sector) {
    switch (sector) {
      case 'IT': return Icons.computer;
      case 'Banking': return Icons.account_balance;
      case 'Energy': return Icons.local_gas_station;
      case 'FMCG': return Icons.shopping_basket;
      default: return Icons.business;
    }
  }
}

class Stock {
  final String symbol;
  final String name;
  final double currentPrice;
  final double change;
  final double changePercent;
  final int volume;
  final double marketCap;
  final String sector;

  Stock({
    required this.symbol,
    required this.name,
    required this.currentPrice,
    required this.change,
    required this.changePercent,
    required this.volume,
    required this.marketCap,
    required this.sector,
  });
}
