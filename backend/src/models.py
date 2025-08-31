from pydantic import BaseModel, Field
from typing import List, Optional
from datetime import datetime
from decimal import Decimal

class Stock(BaseModel):
    symbol: str
    name: str
    current_price: float
    change: float
    change_percent: float
    volume: int
    market_cap: float
    sector: str
    previous_close: Optional[float] = None
    open_price: Optional[float] = None
    day_high: Optional[float] = None
    day_low: Optional[float] = None

class PortfolioHolding(BaseModel):
    symbol: str
    quantity: int
    buy_price: float
    current_price: float
    total_value: float
    pnl: float
    pnl_percent: float

class Transaction(BaseModel):
    id: str
    user_id: str
    symbol: str
    transaction_type: str  # "BUY" or "SELL"
    quantity: int
    price: float
    total_amount: float
    timestamp: datetime
    status: str = "COMPLETED"

class User(BaseModel):
    user_id: str
    username: str
    virtual_balance: float
    total_invested: float
    created_at: datetime
    last_login: Optional[datetime] = None

class Portfolio(BaseModel):
    user_id: str
    total_value: float
    total_invested: float
    total_pnl: float
    total_pnl_percent: float
    holdings: List[PortfolioHolding]

class WatchlistItem(BaseModel):
    user_id: str
    symbol: str
    added_at: datetime

class TradeRequest(BaseModel):
    symbol: str
    quantity: int
    transaction_type: str  # "BUY" or "SELL"

class TradeResponse(BaseModel):
    success: bool
    message: str
    transaction_id: Optional[str] = None
    new_balance: Optional[float] = None
    new_portfolio_value: Optional[float] = None

class MarketDataResponse(BaseModel):
    stocks: List[Stock]
    indices: Optional[List[dict]] = None
    last_updated: datetime
