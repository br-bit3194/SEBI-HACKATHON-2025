import uuid
from typing import List, Optional, Dict
from datetime import datetime
import logging
from ..models import Portfolio, PortfolioHolding, Transaction, User, TradeResponse
from .stock_service import StockService

logger = logging.getLogger(__name__)

class PortfolioService:
    def __init__(self):
        # In-memory storage for demo purposes
        # In production, this should be replaced with a proper database
        self.users: Dict[str, User] = {}
        self.portfolios: Dict[str, Portfolio] = {}
        self.transactions: Dict[str, Transaction] = {}
        self.holdings: Dict[str, List[Dict]] = {}  # user_id -> list of holdings
        self.watchlists: Dict[str, List[str]] = {}  # user_id -> list of symbols
        
        # Initialize default user for demo
        self._initialize_default_user()
        
        self.stock_service = StockService()

    def _initialize_default_user(self):
        """Initialize a default user for demo purposes"""
        default_user_id = "demo_user_001"
        default_user = User(
            user_id=default_user_id,
            username="demo_user",
            virtual_balance=100000.0,
            total_invested=0.0,
            created_at=datetime.now(),
            last_login=datetime.now()
        )
        
        self.users[default_user_id] = default_user
        self.portfolios[default_user_id] = Portfolio(
            user_id=default_user_id,
            total_value=0.0,
            total_invested=0.0,
            total_pnl=0.0,
            total_pnl_percent=0.0,
            holdings=[]
        )
        self.holdings[default_user_id] = []
        self.watchlists[default_user_id] = []

    def get_user(self, user_id: str) -> Optional[User]:
        """Get user by ID"""
        return self.users.get(user_id)

    def get_portfolio(self, user_id: str) -> Optional[Portfolio]:
        """Get user portfolio with current market values"""
        if user_id not in self.portfolios:
            return None
            
        portfolio = self.portfolios[user_id]
        holdings = self.holdings.get(user_id, [])
        
        # Update current prices and calculate P&L
        updated_holdings = []
        total_value = 0.0
        total_pnl = 0.0
        
        for holding in holdings:
            symbol = holding['symbol']
            quantity = holding['quantity']
            buy_price = holding['buy_price']
            
            # Get current stock price
            stock_data = self.stock_service.get_stock_data(symbol)
            current_price = stock_data.current_price if stock_data else buy_price
            
            total_value += quantity * current_price
            pnl = (current_price - buy_price) * quantity
            pnl_percent = ((current_price - buy_price) / buy_price) * 100 if buy_price > 0 else 0
            
            updated_holding = PortfolioHolding(
                symbol=symbol,
                quantity=quantity,
                buy_price=buy_price,
                current_price=current_price,
                total_value=quantity * current_price,
                pnl=pnl,
                pnl_percent=pnl_percent
            )
            updated_holdings.append(updated_holding)
            total_pnl += pnl
        
        # Update portfolio totals
        portfolio.total_value = total_value
        portfolio.total_pnl = total_pnl
        portfolio.total_pnl_percent = (total_pnl / portfolio.total_invested * 100) if portfolio.total_invested > 0 else 0
        portfolio.holdings = updated_holdings
        
        return portfolio

    def execute_trade(self, user_id: str, trade_request: Dict) -> TradeResponse:
        """Execute a buy or sell trade"""
        try:
            symbol = trade_request['symbol']
            quantity = trade_request['quantity']
            transaction_type = trade_request['transaction_type']
            
            if user_id not in self.users:
                return TradeResponse(
                    success=False,
                    message="User not found"
                )
            
            user = self.users[user_id]
            portfolio = self.portfolios[user_id]
            
            # Get current stock price
            stock_data = self.stock_service.get_stock_data(symbol)
            if not stock_data:
                return TradeResponse(
                    success=False,
                    message="Unable to get current stock price"
                )
            
            current_price = stock_data.current_price
            total_amount = quantity * current_price
            
            if transaction_type == "BUY":
                # Check if user has sufficient balance
                if user.virtual_balance < total_amount:
                    return TradeResponse(
                        success=False,
                        message="Insufficient balance"
                    )
                
                # Execute buy transaction
                user.virtual_balance -= total_amount
                portfolio.total_invested += total_amount
                
                # Add to holdings or update existing
                self._add_to_holdings(user_id, symbol, quantity, current_price)
                
                message = f"Successfully bought {quantity} shares of {symbol} at ₹{current_price:.2f}"
                
            elif transaction_type == "SELL":
                # Check if user has sufficient shares
                current_holdings = self.holdings.get(user_id, [])
                user_holding = next((h for h in current_holdings if h['symbol'] == symbol), None)
                
                if not user_holding or user_holding['quantity'] < quantity:
                    return TradeResponse(
                        success=False,
                        message="Insufficient shares to sell"
                    )
                
                # Execute sell transaction
                user.virtual_balance += total_amount
                portfolio.total_invested -= (user_holding['buy_price'] * quantity)
                
                # Update holdings
                self._update_holdings(user_id, symbol, quantity, current_price)
                
                message = f"Successfully sold {quantity} shares of {symbol} at ₹{current_price:.2f}"
            else:
                return TradeResponse(
                    success=False,
                    message="Invalid transaction type"
                )
            
            # Record transaction
            transaction_id = str(uuid.uuid4())
            transaction = Transaction(
                id=transaction_id,
                user_id=user_id,
                symbol=symbol,
                transaction_type=transaction_type,
                quantity=quantity,
                price=current_price,
                total_amount=total_amount,
                timestamp=datetime.now()
            )
            self.transactions[transaction_id] = transaction
            
            # Update portfolio
            updated_portfolio = self.get_portfolio(user_id)
            
            return TradeResponse(
                success=True,
                message=message,
                transaction_id=transaction_id,
                new_balance=user.virtual_balance,
                new_portfolio_value=updated_portfolio.total_value if updated_portfolio else 0
            )
            
        except Exception as e:
            logger.error(f"Error executing trade: {str(e)}")
            return TradeResponse(
                success=False,
                message=f"Error executing trade: {str(e)}"
            )

    def _add_to_holdings(self, user_id: str, symbol: str, quantity: int, price: float):
        """Add or update holdings for a user"""
        if user_id not in self.holdings:
            self.holdings[user_id] = []
        
        current_holdings = self.holdings[user_id]
        existing_holding = next((h for h in current_holdings if h['symbol'] == symbol), None)
        
        if existing_holding:
            # Update existing holding with weighted average price
            total_quantity = existing_holding['quantity'] + quantity
            total_cost = (existing_holding['quantity'] * existing_holding['buy_price']) + (quantity * price)
            weighted_avg_price = total_cost / total_quantity
            
            existing_holding['quantity'] = total_quantity
            existing_holding['buy_price'] = weighted_avg_price
        else:
            # Add new holding
            current_holdings.append({
                'symbol': symbol,
                'quantity': quantity,
                'buy_price': price
            })

    def _update_holdings(self, user_id: str, symbol: str, quantity: int, price: float):
        """Update holdings after selling"""
        current_holdings = self.holdings.get(user_id, [])
        existing_holding = next((h for h in current_holdings if h['symbol'] == symbol), None)
        
        if existing_holding:
            remaining_quantity = existing_holding['quantity'] - quantity
            if remaining_quantity <= 0:
                # Remove holding if all shares sold
                current_holdings.remove(existing_holding)
            else:
                existing_holding['quantity'] = remaining_quantity

    def get_transaction_history(self, user_id: str) -> List[Transaction]:
        """Get transaction history for a user"""
        user_transactions = [
            t for t in self.transactions.values() 
            if t.user_id == user_id
        ]
        return sorted(user_transactions, key=lambda x: x.timestamp, reverse=True)

    def add_to_watchlist(self, user_id: str, symbol: str) -> bool:
        """Add stock to user's watchlist"""
        if user_id not in self.watchlists:
            self.watchlists[user_id] = []
        
        if symbol not in self.watchlists[user_id]:
            self.watchlists[user_id].append(symbol)
            return True
        return False

    def remove_from_watchlist(self, user_id: str, symbol: str) -> bool:
        """Remove stock from user's watchlist"""
        if user_id in self.watchlists and symbol in self.watchlists[user_id]:
            self.watchlists[user_id].remove(symbol)
            return True
        return False

    def get_watchlist(self, user_id: str) -> List[str]:
        """Get user's watchlist"""
        return self.watchlists.get(user_id, [])

    def get_watchlist_stocks(self, user_id: str) -> List[Dict]:
        """Get watchlist stocks with current data"""
        watchlist_symbols = self.watchlists.get(user_id, [])
        stocks = []
        
        for symbol in watchlist_symbols:
            stock_data = self.stock_service.get_stock_data(symbol)
            if stock_data:
                stocks.append(stock_data.dict())
        
        return stocks
