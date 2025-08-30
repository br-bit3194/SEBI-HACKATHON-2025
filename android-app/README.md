# InvestEd - Investor Education & Virtual Trading App

A comprehensive Flutter application for investor education with multi-language support, interactive learning modules, gamified quizzes, virtual trading simulator, and admin panel.

## 🚀 Features

### User App Features
- **Multi-language Support**: English and Hindi with easy expansion
- **Interactive Learning Modules**: Comprehensive investment education content
- **Gamified Quiz System**: Timed quizzes with scoring and achievements
- **Virtual Trading Simulator**: Practice trading with ₹1,00,000 virtual money
- **Progress Tracking**: User profiles with learning progress and statistics
- **News & Updates**: Latest financial news and market updates
- **Beautiful UI/UX**: Modern Material Design 3 with smooth animations

### Admin Panel Features
- **Content Management**: Create and manage learning modules, quizzes, and translations
- **User Analytics**: Comprehensive user engagement and performance analytics
- **News Management**: Publish and manage news articles with categorization
- **Dashboard Overview**: Real-time statistics and system monitoring

## 🏗️ Architecture

The app is structured with two separate entry points:

### User App (`lib/main.dart`)
- Main consumer-facing application
- Full feature set for learning and trading
- Multi-language support with localization

### Admin Panel (`lib/admin_main.dart`)
- Separate admin interface
- Content management and analytics
- User management and system oversight

## 📱 Running the Applications

### User App
```bash
flutter run -t lib/main.dart
```

### Admin Panel
```bash
flutter run -t lib/admin_main.dart
```

## 🛠️ Setup Instructions

1. **Install Flutter SDK** (version 3.8.1+)
2. **Clone the repository**
3. **Install dependencies**:
   ```bash
   flutter pub get
   ```
4. **Run the app**:
   ```bash
   # For user app
   flutter run -t lib/main.dart
   
   # For admin panel
   flutter run -t lib/admin_main.dart
   ```

## 📦 Dependencies

- **UI & Navigation**: cupertino_icons, http, flutter_svg, lottie, intl
- **Localization**: easy_localization
- **State Management**: provider, shared_preferences
- **Charts & Animations**: fl_chart, animated_text_kit, smooth_page_indicator, percent_indicator

## 🎯 Target Audience

- Retail investors in India
- Students learning about financial markets
- Non-English speakers seeking investment education
- Anyone interested in virtual trading practice

## 🔐 Admin Credentials (Demo)

- **Email**: admin@invested.com
- **Password**: admin123

## 🌐 Supported Languages

- English (en)
- Hindi (hi)
- Easy to add more languages via translation files

## 📊 Key Screens

### User App
- Splash & Onboarding
- Language Selection
- Home Dashboard
- Learning Modules
- Quiz System
- Virtual Trading
- User Profile

### Admin Panel
- Admin Login
- Dashboard Overview
- Content Management
- User Analytics
- News Management

## 🚀 Future Enhancements

- Real-time market data integration
- Voice-based learning modules
- AI-powered investment recommendations
- Community forums and discussions
- Push notifications
- Advanced analytics and reporting

## 📱 Project Overview

InvestEd is a hackathon project designed to democratize financial education in India by providing:
- **Interactive Learning Modules** in multiple Indian languages
- **Gamified Quiz System** with achievements and progress tracking  
- **Virtual Trading Simulator** with ₹1,00,000 demo money
- **Real-time Market Data** and educational content
- **Multi-language Support** (English & Hindi, expandable to Tamil, Telugu, etc.)

## 🎯 Problem Statement

- Retail investors lack proper financial education
- Most content is only available in English
- No safe environment to practice trading
- Difficulty understanding complex financial concepts

## 💡 Solution Features

### 🎓 Learning Modules
- **Stock Market Basics** - Fundamentals of investing
- **Risk Management** - Understanding and managing investment risks
- **Technical Analysis** - Chart reading and indicators
- **Fundamental Analysis** - Company and market analysis
- **Portfolio Diversification** - Building balanced portfolios
- **Algorithmic Trading** - Introduction to automated strategies

### 🧠 Interactive Quiz System
- Module-based quizzes with timer
- Achievement system with badges
- Progress tracking and scoring
- Gamified learning experience

### 📈 Virtual Trading Simulator
- ₹1,00,000 virtual money to start
- Real-time stock prices simulation
- Portfolio management and tracking
- Buy/Sell functionality with P&L calculation
- Watchlist feature

### 🌐 Multi-language Support
- English and Hindi (implemented)
- Easy expansion to other Indian languages
- Localized content and UI

### 👤 User Profile & Progress
- Learning progress tracking
- Achievement system
- Portfolio performance analytics
- Level-based progression

## 🛠 Technical Stack

- **Frontend**: Flutter (Cross-platform)
- **State Management**: Provider
- **Localization**: EasyLocalization
- **Charts**: FL Chart
- **Storage**: SharedPreferences
- **UI Components**: Material Design 3

## 📁 Project Structure

```
lib/
├── main.dart                    # App entry point
├── providers/
│   └── app_state_provider.dart  # State management
├── screens/
│   ├── splash_screen.dart       # App splash screen
│   ├── onboarding/              # Language selection & onboarding
│   ├── home/                    # Dashboard and home screen
│   ├── learning/                # Learning modules
│   ├── quiz/                    # Quiz system
│   ├── trading/                 # Virtual trading simulator
│   └── profile/                 # User profile and settings
├── utils/
│   └── app_theme.dart          # App theming
└── assets/
    ├── translations/           # Multi-language JSON files
    ├── images/                 # App images
    └── icons/                  # App icons
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.8.1+)
- Android Studio / VS Code
- Android Emulator or Physical Device

### Installation

1. **Clone the repository**
   ```bash
   cd investor_education_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## 📱 App Flow

1. **Splash Screen** → Language Selection → Onboarding
2. **Home Dashboard** → Shows progress, quick actions, recent activity
3. **Learning Modules** → Interactive lessons with progress tracking
4. **Quiz System** → Test knowledge with gamified experience
5. **Virtual Trading** → Practice trading with virtual money
6. **Profile** → Track achievements and manage settings

## 🎨 Key Features Implemented

### ✅ Completed Features
- [x] Multi-language onboarding flow
- [x] Interactive learning modules with detailed content
- [x] Comprehensive quiz system with timer and scoring
- [x] Virtual trading simulator with portfolio management
- [x] Achievement and progress tracking system
- [x] Beautiful, responsive UI with animations
- [x] State persistence across app sessions
- [x] Real-time P&L calculation
- [x] Stock watchlist functionality

### 🔮 Future Enhancements
- [ ] AI-powered personalized learning paths
- [ ] Voice-based learning for accessibility
- [ ] Community forums and discussions
- [ ] Advanced charting tools
- [ ] Push notifications for market updates
- [ ] Integration with real market data APIs

## 🏆 Hackathon Highlights

### What Makes This Special?
1. **Inclusive Design** - Multi-language support for Indian users
2. **Practical Learning** - Virtual trading with real market simulation
3. **Gamification** - Achievement system keeps users engaged
4. **Comprehensive Content** - Covers all aspects of investing
5. **Beautiful UI** - Modern, intuitive design with smooth animations

### Demo Flow for Judges
1. **Language Selection** - Show multi-language capability
2. **Learning Module** - Complete a lesson on stock basics
3. **Quiz** - Take a quiz and show scoring system
4. **Virtual Trading** - Buy/sell stocks and show P&L
5. **Profile** - Display achievements and progress

## 📊 Impact & Scalability

### Target Users
- **New Investors** - People new to stock markets
- **Students** - College students learning finance
- **Regional Users** - Non-English speakers across India
- **Educational Institutions** - For investor awareness programs

### Scalability
- Easy addition of new languages
- Modular architecture for new features
- Cloud-ready for user data sync
- API integration ready for real market data

## 🎯 Pitch Points for Judges

1. **Problem-Solution Fit** - Addresses real need for financial literacy
2. **Technical Excellence** - Clean code, modern architecture
3. **User Experience** - Intuitive, engaging, accessible
4. **Market Potential** - Huge addressable market in India
5. **Social Impact** - Democratizing financial education

---

**Built with ❤️ for Hackathon 2024**
*Empowering the next generation of informed investors*

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
