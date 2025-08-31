#!/usr/bin/env python3
"""
Test script for the Virtual Trading Backend API
Run this script to verify all endpoints are working correctly
"""

import requests
import json
from datetime import datetime

BASE_URL = "http://localhost:8000/api/trading"

def test_health_check():
    """Test the health check endpoint"""
    print("Testing health check...")
    try:
        response = requests.get(f"{BASE_URL}/health")
        if response.status_code == 200:
            print("✅ Health check passed")
            return True
        else:
            print(f"❌ Health check failed: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Health check error: {e}")
        return False

def test_available_stocks():
    """Test getting available stocks"""
    print("\nTesting available stocks...")
    try:
        response = requests.get(f"{BASE_URL}/available-stocks")
        if response.status_code == 200:
            data = response.json()
            stocks = data.get('stocks', [])
            print(f"✅ Available stocks: {len(stocks)} stocks found")
            for stock in stocks[:5]:  # Show first 5
                print(f"   - {stock}")
            return True
        else:
            print(f"❌ Available stocks failed: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Available stocks error: {e}")
        return False

def test_market_data():
    """Test getting market data"""
    print("\nTesting market data...")
    try:
        response = requests.get(f"{BASE_URL}/market")
        if response.status_code == 200:
            data = response.json()
            stocks = data.get('stocks', [])
            print(f"✅ Market data: {len(stocks)} stocks loaded")
            if stocks:
                sample_stock = stocks[0]
                print(f"   Sample stock: {sample_stock.get('symbol')} - ₹{sample_stock.get('current_price')}")
            return True
        else:
            print(f"❌ Market data failed: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Market data error: {e}")
        return False

def test_user_data():
    """Test getting user data"""
    print("\nTesting user data...")
    try:
        user_id = "demo_user_001"
        response = requests.get(f"{BASE_URL}/user/{user_id}")
        if response.status_code == 200:
            data = response.json()
            print(f"✅ User data: {data.get('username')} - Balance: ₹{data.get('virtual_balance')}")
            return True
        else:
            print(f"❌ User data failed: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ User data error: {e}")
        return False

def test_portfolio():
    """Test getting portfolio"""
    print("\nTesting portfolio...")
    try:
        user_id = "demo_user_001"
        response = requests.get(f"{BASE_URL}/portfolio/{user_id}")
        if response.status_code == 200:
            data = response.json()
            holdings = data.get('holdings', [])
            print(f"✅ Portfolio: {len(holdings)} holdings, Total Value: ₹{data.get('total_value')}")
            return True
        else:
            print(f"❌ Portfolio failed: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Portfolio error: {e}")
        return False

def test_watchlist():
    """Test watchlist operations"""
    print("\nTesting watchlist...")
    try:
        user_id = "demo_user_001"
        symbol = "RELIANCE.NS"
        
        # Get current watchlist
        response = requests.get(f"{BASE_URL}/watchlist/{user_id}")
        if response.status_code == 200:
            data = response.json()
            initial_count = len(data.get('symbols', []))
            print(f"✅ Watchlist loaded: {initial_count} symbols")
        
        # Add to watchlist
        response = requests.post(f"{BASE_URL}/watchlist/{user_id}/{symbol}")
        if response.status_code == 200:
            data = response.json()
            print(f"✅ Added to watchlist: {data.get('message')}")
        
        # Get updated watchlist
        response = requests.get(f"{BASE_URL}/watchlist/{user_id}")
        if response.status_code == 200:
            data = response.json()
            updated_count = len(data.get('symbols', []))
            print(f"✅ Watchlist updated: {updated_count} symbols")
        
        # Remove from watchlist
        response = requests.delete(f"{BASE_URL}/watchlist/{user_id}/{symbol}")
        if response.status_code == 200:
            data = response.json()
            print(f"✅ Removed from watchlist: {data.get('message')}")
        
        return True
    except Exception as e:
        print(f"❌ Watchlist error: {e}")
        return False

def test_trade_execution():
    """Test trade execution"""
    print("\nTesting trade execution...")
    try:
        user_id = "demo_user_001"
        symbol = "RELIANCE.NS"
        quantity = 1
        
        # Execute buy trade
        trade_data = {
            "symbol": symbol,
            "quantity": quantity,
            "transaction_type": "BUY"
        }
        
        response = requests.post(
            f"{BASE_URL}/trade/{user_id}",
            json=trade_data,
            headers={"Content-Type": "application/json"}
        )
        
        if response.status_code == 200:
            data = response.json()
            if data.get('success'):
                print(f"✅ Trade executed: {data.get('message')}")
                print(f"   New balance: ₹{data.get('new_balance')}")
                print(f"   Portfolio value: ₹{data.get('new_portfolio_value')}")
                return True
            else:
                print(f"❌ Trade failed: {data.get('message')}")
                return False
        else:
            print(f"❌ Trade request failed: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Trade execution error: {e}")
        return False

def test_stock_search():
    """Test stock search"""
    print("\nTesting stock search...")
    try:
        query = "RELIANCE"
        response = requests.get(f"{BASE_URL}/stocks/search/{query}")
        if response.status_code == 200:
            data = response.json()
            stocks = data.get('stocks', [])
            print(f"✅ Stock search: {len(stocks)} results for '{query}'")
            return True
        else:
            print(f"❌ Stock search failed: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Stock search error: {e}")
        return False

def main():
    """Run all tests"""
    print("🚀 Starting Virtual Trading API Tests")
    print("=" * 50)
    
    tests = [
        test_health_check,
        test_available_stocks,
        test_market_data,
        test_user_data,
        test_portfolio,
        test_watchlist,
        test_trade_execution,
        test_stock_search,
    ]
    
    passed = 0
    total = len(tests)
    
    for test in tests:
        try:
            if test():
                passed += 1
        except Exception as e:
            print(f"❌ Test {test.__name__} crashed: {e}")
    
    print("\n" + "=" * 50)
    print(f"📊 Test Results: {passed}/{total} tests passed")
    
    if passed == total:
        print("🎉 All tests passed! The API is working correctly.")
    else:
        print("⚠️  Some tests failed. Check the errors above.")
    
    print(f"\n⏰ Test completed at: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")

if __name__ == "__main__":
    main()
