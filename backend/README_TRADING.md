# Virtual Trading Backend API

This backend provides real-time stock market data and virtual trading functionality for the Flutter investor education app.

## Features

- **Real-time Stock Data**: Fetches live stock prices from Yahoo Finance API
- **Portfolio Management**: Track virtual investments and calculate P&L
- **Trading Operations**: Execute buy/sell trades with real-time pricing
- **Watchlist Management**: Add/remove stocks to personal watchlist
- **Transaction History**: Complete audit trail of all trading activities

## API Endpoints

### Market Data
- `GET /api/trading/market` - Get current market data for all available stocks
- `GET /api/trading/stocks/{symbol}` - Get detailed data for a specific stock
- `GET /api/trading/stocks/search/{query}` - Search stocks by name or sector
- `GET /api/trading/quote/{symbol}` - Get quick stock quote

### Portfolio Management
- `GET /api/trading/portfolio/{user_id}` - Get user portfolio with current values
- `GET /api/trading/user/{user_id}` - Get user information and balance
- `GET /api/trading/transactions/{user_id}` - Get transaction history

### Trading Operations
- `POST /api/trading/trade/{user_id}` - Execute buy/sell trade

### Watchlist Management
- `GET /api/trading/watchlist/{user_id}` - Get user's watchlist
- `POST /api/trading/watchlist/{user_id}/{symbol}` - Add stock to watchlist
- `DELETE /api/trading/watchlist/{user_id}/{symbol}` - Remove stock from watchlist

### Utility
- `GET /api/trading/health` - Health check endpoint
- `GET /api/trading/available-stocks` - List of available stocks for trading

## Setup Instructions

### 1. Install Dependencies

```bash
cd backend
pip install -r requirements.txt
```

### 2. Run the Backend

```bash
cd src
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

The API will be available at:
- Main API: http://localhost:8000/api/trading
- API Documentation: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc

### 3. Test the API

```bash
# Test health endpoint
curl http://localhost:8000/api/trading/health

# Get market data
curl http://localhost:8000/api/trading/market

# Get available stocks
curl http://localhost:8000/api/trading/available-stocks
```

## Flutter App Integration

### 1. Update API Service

The Flutter app includes an `ApiService` class that handles all backend communication. The service automatically detects the platform and uses the appropriate base URL:

- **Web**: `http://localhost:8000/api/trading`
- **Android Emulator**: `http://10.0.2.2:8000/api/trading`

### 2. Default User

The system includes a demo user with ID `demo_user_001` and initial virtual balance of ₹100,000.

### 3. Stock Symbols

The backend supports the following Indian stock symbols:
- RELIANCE.NS (Reliance Industries)
- TCS.NS (Tata Consultancy Services)
- HDFCBANK.NS (HDFC Bank)
- INFY.NS (Infosys)
- ICICIBANK.NS (ICICI Bank)
- HINDUNILVR.NS (Hindustan Unilever)
- ITC.NS (ITC)
- SBIN.NS (State Bank of India)
- BHARTIARTL.NS (Bharti Airtel)
- AXISBANK.NS (Axis Bank)
- KOTAKBANK.NS (Kotak Mahindra Bank)
- ASIANPAINT.NS (Asian Paints)

## Data Flow

1. **Market Data**: Backend fetches real-time data from Yahoo Finance every time an API is called
2. **Portfolio Updates**: When trades are executed, portfolio values are recalculated with current market prices
3. **Real-time P&L**: Profit/loss calculations are performed using live market data
4. **Transaction Recording**: All trades are recorded with timestamps and current market prices

## Error Handling

- **Network Errors**: Graceful fallback to cached data when available
- **Invalid Symbols**: Proper error responses for unsupported stock symbols
- **Insufficient Balance**: Validation before trade execution
- **API Rate Limits**: Built-in error handling for external API failures

## Security Considerations

- **Input Validation**: All API inputs are validated using Pydantic models
- **Error Logging**: Comprehensive logging for debugging and monitoring
- **CORS Enabled**: Configured for cross-origin requests from Flutter app

## Performance Notes

- **Caching**: Consider implementing Redis for caching frequently accessed data
- **Rate Limiting**: Yahoo Finance API calls are made on-demand
- **Async Operations**: All API endpoints are asynchronous for better performance

## Troubleshooting

### Common Issues

1. **Port Already in Use**: Change the port in the uvicorn command
2. **Network Errors**: Ensure firewall allows connections on port 8000
3. **Yahoo Finance API Issues**: Check internet connectivity and API availability

### Debug Mode

Enable debug logging by setting the log level in the main.py file.

## Future Enhancements

- **Database Integration**: Replace in-memory storage with PostgreSQL/MySQL
- **Real-time Updates**: WebSocket support for live price updates
- **Advanced Analytics**: Technical indicators and chart data
- **User Authentication**: JWT-based user management system
- **Market Indices**: Support for Nifty, Sensex, and sector indices
