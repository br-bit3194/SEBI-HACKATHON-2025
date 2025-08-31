from fastapi import APIRouter, HTTPException, Query, Path
from fastapi.responses import JSONResponse
from typing import List, Optional
from datetime import datetime
import logging

from .models import (
    Stock, Portfolio, Transaction, User, TradeRequest, 
    TradeResponse, MarketDataResponse, PortfolioHolding
)
from .services.stock_service import StockService
from .services.portfolio_service import PortfolioService

logger = logging.getLogger(__name__)

# Initialize services
stock_service = StockService()
portfolio_service = PortfolioService()

# Create router
trading_router = APIRouter(prefix="/trading", tags=["Virtual Trading"])

# Market Data Endpoints
@trading_router.get("/market", response_model=MarketDataResponse)
async def get_market_data():
    """Get current market data for default stocks"""
    try:
        stocks = stock_service.get_default_market_data()
        return MarketDataResponse(
            stocks=stocks,
            indices=[],  # Can be extended with market indices
            last_updated=datetime.now()
        )
    except Exception as e:
        logger.error(f"Error fetching market data: {str(e)}")
        raise HTTPException(status_code=500, detail="Failed to fetch market data")

@trading_router.get("/stocks/{symbol}", response_model=Stock)
async def get_stock_data(symbol: str = Path(..., description="Stock symbol")):
    """Get detailed data for a specific stock"""
    try:
        stock_data = stock_service.get_stock_data(symbol)
        if not stock_data:
            raise HTTPException(status_code=404, detail="Stock not found")
        return stock_data
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error fetching stock data for {symbol}: {str(e)}")
        raise HTTPException(status_code=500, detail="Failed to fetch stock data")

@trading_router.get("/stocks/search/{query}")
async def search_stocks(query: str = Path(..., description="Search query")):
    """Search for stocks based on query"""
    try:
        stocks = stock_service.search_stocks(query)
        return {"stocks": [stock.dict() for stock in stocks]}
    except Exception as e:
        logger.error(f"Error searching stocks: {str(e)}")
        raise HTTPException(status_code=500, detail="Failed to search stocks")

@trading_router.get("/quote/{symbol}")
async def get_stock_quote(symbol: str = Path(..., description="Stock symbol")):
    """Get quick stock quote"""
    try:
        quote = stock_service.get_stock_quote(symbol)
        if not quote:
            raise HTTPException(status_code=404, detail="Stock quote not available")
        return quote
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error getting quote for {symbol}: {str(e)}")
        raise HTTPException(status_code=500, detail="Failed to get stock quote")

# Portfolio Management Endpoints
@trading_router.get("/portfolio/{user_id}", response_model=Portfolio)
async def get_portfolio(user_id: str = Path(..., description="User ID")):
    """Get user portfolio with current market values"""
    try:
        portfolio = portfolio_service.get_portfolio(user_id)
        if not portfolio:
            raise HTTPException(status_code=404, detail="Portfolio not found")
        return portfolio
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error fetching portfolio for {user_id}: {str(e)}")
        raise HTTPException(status_code=500, detail="Failed to fetch portfolio")

@trading_router.get("/user/{user_id}", response_model=User)
async def get_user(user_id: str = Path(..., description="User ID")):
    """Get user information"""
    try:
        user = portfolio_service.get_user(user_id)
        if not user:
            raise HTTPException(status_code=404, detail="User not found")
        return user
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error fetching user {user_id}: {str(e)}")
        raise HTTPException(status_code=500, detail="Failed to fetch user")

@trading_router.get("/transactions/{user_id}")
async def get_transaction_history(user_id: str = Path(..., description="User ID")):
    """Get user transaction history"""
    try:
        transactions = portfolio_service.get_transaction_history(user_id)
        return {"transactions": [t.dict() for t in transactions]}
    except Exception as e:
        logger.error(f"Error fetching transactions for {user_id}: {str(e)}")
        raise HTTPException(status_code=500, detail="Failed to fetch transactions")

# Trading Endpoints
@trading_router.post("/trade/{user_id}", response_model=TradeResponse)
async def execute_trade(
    user_id: str = Path(..., description="User ID"),
    trade_request: TradeRequest = None
):
    """Execute a buy or sell trade"""
    try:
        if not trade_request:
            raise HTTPException(status_code=400, detail="Trade request is required")
        
        response = portfolio_service.execute_trade(user_id, trade_request.dict())
        if not response.success:
            raise HTTPException(status_code=400, detail=response.message)
        
        return response
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error executing trade for {user_id}: {str(e)}")
        raise HTTPException(status_code=500, detail="Failed to execute trade")

# Watchlist Endpoints
@trading_router.get("/watchlist/{user_id}")
async def get_watchlist(user_id: str = Path(..., description="User ID")):
    """Get user's watchlist"""
    try:
        watchlist_symbols = portfolio_service.get_watchlist(user_id)
        watchlist_stocks = portfolio_service.get_watchlist_stocks(user_id)
        return {
            "symbols": watchlist_symbols,
            "stocks": watchlist_stocks
        }
    except Exception as e:
        logger.error(f"Error fetching watchlist for {user_id}: {str(e)}")
        raise HTTPException(status_code=500, detail="Failed to fetch watchlist")

@trading_router.post("/watchlist/{user_id}/{symbol}")
async def add_to_watchlist(
    user_id: str = Path(..., description="User ID"),
    symbol: str = Path(..., description="Stock symbol")
):
    """Add stock to user's watchlist"""
    try:
        success = portfolio_service.add_to_watchlist(user_id, symbol)
        if success:
            return {"message": f"{symbol} added to watchlist", "success": True}
        else:
            return {"message": f"{symbol} already in watchlist", "success": False}
    except Exception as e:
        logger.error(f"Error adding {symbol} to watchlist for {user_id}: {str(e)}")
        raise HTTPException(status_code=500, detail="Failed to add to watchlist")

@trading_router.delete("/watchlist/{user_id}/{symbol}")
async def remove_from_watchlist(
    user_id: str = Path(..., description="User ID"),
    symbol: str = Path(..., description="Stock symbol")
):
    """Remove stock from user's watchlist"""
    try:
        success = portfolio_service.remove_from_watchlist(user_id, symbol)
        if success:
            return {"message": f"{symbol} removed from watchlist", "success": True}
        else:
            return {"message": f"{symbol} not found in watchlist", "success": False}
    except Exception as e:
        logger.error(f"Error removing {symbol} from watchlist for {user_id}: {str(e)}")
        raise HTTPException(status_code=500, detail="Failed to remove from watchlist")

# Utility Endpoints
@trading_router.get("/health")
async def health_check():
    """Health check endpoint"""
    return {"status": "healthy", "timestamp": datetime.now().isoformat()}

@trading_router.get("/available-stocks")
async def get_available_stocks():
    """Get list of available stocks for trading"""
    try:
        return {"stocks": stock_service.default_stocks}
    except Exception as e:
        logger.error(f"Error getting available stocks: {str(e)}")
        raise HTTPException(status_code=500, detail="Failed to get available stocks")
