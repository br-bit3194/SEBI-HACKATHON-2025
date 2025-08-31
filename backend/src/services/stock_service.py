import yfinance as yf
from typing import List, Optional
from datetime import datetime
import logging
from ..models import Stock

logger = logging.getLogger(__name__)

class StockService:
    def __init__(self):
        # Popular Indian stocks for virtual trading
        self.default_stocks = [
            'RELIANCE.NS', 'TCS.NS', 'HDFCBANK.NS', 'INFY.NS', 
            'ICICIBANK.NS', 'HINDUNILVR.NS', 'ITC.NS', 'SBIN.NS',
            'BHARTIARTL.NS', 'AXISBANK.NS', 'KOTAKBANK.NS', 'ASIANPAINT.NS'
        ]
        
        # Stock sector mapping
        self.sector_mapping = {
            'RELIANCE.NS': 'Energy',
            'TCS.NS': 'IT',
            'HDFCBANK.NS': 'Banking',
            'INFY.NS': 'IT',
            'ICICIBANK.NS': 'Banking',
            'HINDUNILVR.NS': 'FMCG',
            'ITC.NS': 'FMCG',
            'SBIN.NS': 'Banking',
            'BHARTIARTL.NS': 'Telecom',
            'AXISBANK.NS': 'Banking',
            'KOTAKBANK.NS': 'Banking',
            'ASIANPAINT.NS': 'Manufacturing'
        }

    def get_stock_data(self, symbol: str) -> Optional[Stock]:
        """Get real-time stock data for a given symbol"""
        try:
            # Remove .NS suffix if present for yfinance
            clean_symbol = symbol.replace('.NS', '')
            ticker = yf.Ticker(f"{clean_symbol}.NS")
            
            # Get current stock info
            info = ticker.info
            hist = ticker.history(period="2d")
            
            if hist.empty:
                return None
                
            current_price = float(hist['Close'].iloc[-1])
            previous_close = float(hist['Close'].iloc[-2]) if len(hist) > 1 else current_price
            change = current_price - previous_close
            change_percent = (change / previous_close) * 100 if previous_close > 0 else 0
            
            # Get additional data
            volume = int(hist['Volume'].iloc[-1]) if 'Volume' in hist.columns else 0
            open_price = float(hist['Open'].iloc[-1]) if 'Open' in hist.columns else current_price
            day_high = float(hist['High'].iloc[-1]) if 'High' in hist.columns else current_price
            day_low = float(hist['Low'].iloc[-1]) if 'Low' in hist.columns else current_price
            
            # Market cap (in billions)
            market_cap = float(info.get('marketCap', 0)) / 1e9 if info.get('marketCap') else 0
            
            return Stock(
                symbol=symbol,
                name=info.get('longName', symbol),
                current_price=current_price,
                change=change,
                change_percent=change_percent,
                volume=volume,
                market_cap=market_cap,
                sector=self.sector_mapping.get(symbol, 'Other'),
                previous_close=previous_close,
                open_price=open_price,
                day_high=day_high,
                day_low=day_low
            )
            
        except Exception as e:
            logger.error(f"Error fetching stock data for {symbol}: {str(e)}")
            return None

    def get_multiple_stocks(self, symbols: List[str]) -> List[Stock]:
        """Get data for multiple stocks"""
        stocks = []
        for symbol in symbols:
            stock_data = self.get_stock_data(symbol)
            if stock_data:
                stocks.append(stock_data)
        return stocks

    def get_default_market_data(self) -> List[Stock]:
        """Get data for default stocks"""
        return self.get_multiple_stocks(self.default_stocks)

    def search_stocks(self, query: str) -> List[Stock]:
        """Search for stocks based on query"""
        try:
            # Simple search implementation - can be enhanced
            matching_stocks = []
            for symbol in self.default_stocks:
                if query.upper() in symbol.replace('.NS', '') or query.upper() in self.sector_mapping.get(symbol, ''):
                    stock_data = self.get_stock_data(symbol)
                    if stock_data:
                        matching_stocks.append(stock_data)
            return matching_stocks
        except Exception as e:
            logger.error(f"Error searching stocks: {str(e)}")
            return []

    def get_stock_quote(self, symbol: str) -> Optional[dict]:
        """Get quick stock quote"""
        try:
            clean_symbol = symbol.replace('.NS', '')
            ticker = yf.Ticker(f"{clean_symbol}.NS")
            hist = ticker.history(period="1d")
            
            if hist.empty:
                return None
                
            return {
                'symbol': symbol,
                'price': float(hist['Close'].iloc[-1]),
                'volume': int(hist['Volume'].iloc[-1]) if 'Volume' in hist.columns else 0,
                'timestamp': datetime.now().isoformat()
            }
        except Exception as e:
            logger.error(f"Error getting stock quote for {symbol}: {str(e)}")
            return None
