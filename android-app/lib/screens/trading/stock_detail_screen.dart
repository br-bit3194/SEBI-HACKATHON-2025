import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../utils/app_theme.dart';
import 'virtual_trading_screen.dart';

class StockDetailScreen extends StatefulWidget {
  final Stock stock;

  const StockDetailScreen({super.key, required this.stock});

  @override
  State<StockDetailScreen> createState() => _StockDetailScreenState();
}

class _StockDetailScreenState extends State<StockDetailScreen> {
  String selectedTimeframe = '1D';
  final List<String> timeframes = ['1D', '1W', '1M', '3M', '1Y'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(widget.stock.symbol),
        backgroundColor: _getSectorColor(widget.stock.sector),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.favorite_border),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildPriceHeader(),
            _buildChart(),
            _buildTimeframeSelector(),
            _buildStockInfo(),
            _buildKeyMetrics(),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceHeader() {
    final isPositive = widget.stock.change >= 0;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_getSectorColor(widget.stock.sector), _getSectorColor(widget.stock.sector).withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.stock.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '₹${widget.stock.currentPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: isPositive 
                          ? Colors.green.withOpacity(0.2)
                          : Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${isPositive ? '+' : ''}₹${widget.stock.change.toStringAsFixed(2)} (${isPositive ? '+' : ''}${widget.stock.changePercent.toStringAsFixed(2)}%)',
                      style: TextStyle(
                        color: isPositive ? Colors.greenAccent : Colors.redAccent,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getSectorIcon(widget.stock.sector),
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChart() {
    return Container(
      height: 250,
      margin: const EdgeInsets.all(16),
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
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: _generateChartData(),
              isCurved: true,
              color: _getSectorColor(widget.stock.sector),
              barWidth: 3,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: _getSectorColor(widget.stock.sector).withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeframeSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: timeframes.map((timeframe) {
          final isSelected = selectedTimeframe == timeframe;
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedTimeframe = timeframe;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected 
                    ? _getSectorColor(widget.stock.sector)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _getSectorColor(widget.stock.sector),
                ),
              ),
              child: Text(
                timeframe,
                style: TextStyle(
                  color: isSelected 
                      ? Colors.white
                      : _getSectorColor(widget.stock.sector),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStockInfo() {
    return Container(
      margin: const EdgeInsets.all(16),
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
          Text(
            'Stock Information',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem('Sector', widget.stock.sector),
              ),
              Expanded(
                child: _buildInfoItem('Market Cap', '₹${widget.stock.marketCap.toStringAsFixed(1)}T'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem('Volume', NumberFormat('#,##,###').format(widget.stock.volume)),
              ),
              Expanded(
                child: _buildInfoItem('52W High', '₹${(widget.stock.currentPrice * 1.2).toStringAsFixed(2)}'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem('52W Low', '₹${(widget.stock.currentPrice * 0.8).toStringAsFixed(2)}'),
              ),
              Expanded(
                child: _buildInfoItem('P/E Ratio', '${(widget.stock.currentPrice / 100).toStringAsFixed(1)}'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildKeyMetrics() {
    return Container(
      margin: const EdgeInsets.all(16),
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
          Text(
            'Key Metrics',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildMetricRow('EPS', '₹${(widget.stock.currentPrice / 20).toStringAsFixed(2)}'),
          _buildMetricRow('Book Value', '₹${(widget.stock.currentPrice * 0.6).toStringAsFixed(2)}'),
          _buildMetricRow('Dividend Yield', '${(widget.stock.changePercent.abs() * 2).toStringAsFixed(2)}%'),
          _buildMetricRow('ROE', '${(15 + widget.stock.changePercent).toStringAsFixed(1)}%'),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                _showTradeDialog(true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.successColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text('buy'.tr()),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                _showTradeDialog(false);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.errorColor,
                side: BorderSide(color: AppTheme.errorColor),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text('sell'.tr()),
            ),
          ),
        ],
      ),
    );
  }

  void _showTradeDialog(bool isBuy) {
    final quantityController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${isBuy ? 'Buy' : 'Sell'} ${widget.stock.symbol}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Current Price: ₹${widget.stock.currentPrice.toStringAsFixed(2)}'),
            const SizedBox(height: 16),
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'quantity'.tr(),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Total: ₹${_calculateTotal(quantityController.text)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
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
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${isBuy ? 'Buy' : 'Sell'} order placed for $quantity shares'),
                    backgroundColor: isBuy ? AppTheme.successColor : AppTheme.errorColor,
                  ),
                );
              }
            },
            child: Text(isBuy ? 'buy'.tr() : 'sell'.tr()),
          ),
        ],
      ),
    );
  }

  String _calculateTotal(String quantityText) {
    final quantity = int.tryParse(quantityText) ?? 0;
    final total = quantity * widget.stock.currentPrice;
    return NumberFormat('#,##,###').format(total);
  }

  List<FlSpot> _generateChartData() {
    final basePrice = widget.stock.currentPrice;
    final random = DateTime.now().millisecondsSinceEpoch;
    
    return List.generate(20, (index) {
      final variation = (random % 100 - 50) / 1000;
      final price = basePrice + (basePrice * variation * (index / 10));
      return FlSpot(index.toDouble(), price);
    });
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
