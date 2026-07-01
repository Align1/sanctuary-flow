# SanctuaryFlow - Spiritual Growth App

A comprehensive Flutter mobile application designed to help users track and grow in their spiritual journey with a serene, peaceful design using blues, whites, and soft greens.

## Features

### 🏠 Dashboard
- Clean, card-based layout showing all 6 core features
- Daily verse widget with inspirational Bible verses
- Welcome message and quick overview
- Serene color palette for peaceful user experience

### 📖 Bible Reading Tracker
- Track daily Bible reading sessions
- Record book, chapter, verse, and reading time
- Add personal notes and reflections
- View reading statistics and progress
- Weekly and total reading metrics

### ⏰ Prayer Time Notifications
- Schedule prayer reminders for any time of day
- Set recurring prayer times for different days
- Track prayer sessions with duration and notes
- Multiple prayer types support
- Active/inactive schedule management

### 🎧 Message Listening Scheduler
- Track sermons, podcasts, and spiritual teachings
- Record speaker, source, duration, and ratings
- Add personal notes and key takeaways
- Organize by source type (Church, Podcast, YouTube, etc.)
- View listening statistics and progress

### 📚 Christian Book Reading Tracker
- Track multiple Christian books simultaneously
- Progress tracking with page numbers and percentages
- Book status management (Reading, Completed, Paused)
- Rating system and personal notes
- Reading statistics and completion tracking

### 🎯 Customizable Spiritual Goals Profile
- Set personal spiritual growth goals
- Multiple categories (Prayer, Bible Study, Service, Worship, etc.)
- Progress tracking with visual indicators
- Goal completion celebrations
- Flexible frequency settings (Daily, Weekly, Monthly, Custom)

### 📜 Daily Verse Widget
- New inspirational Bible verse each day
- Add personal reflections to verses
- Favorite verse system
- Multiple Bible translations support
- Verse archive for reviewing past verses

### 📅 Reading Plans
- Pre-built plans (Bible in a Year, Gospels, Psalms & Proverbs, etc.)
- Track progress through structured reading plans
- Daily reading suggestions
- Mark daily readings as complete
- Progress visualization and statistics

### 🔥 Streaks & Achievements
- Daily and weekly reading streaks
- 20+ achievements across categories
- Milestone celebrations
- Completion badges for books and goals
- Visual progress tracking

### 🔔 Smart Reminders
- Daily reading reminders (customizable time)
- Streak preservation alerts
- Missed activity notifications
- Weekly progress summaries
- Intelligent habit formation support

### 📱 Home Screen Widgets
- **Daily Verse Widget**: Display today's Bible verse on your home screen
- **Streak Counter Widget**: Track your reading streak without opening the app
- Quick action buttons for Prayer and Reading Plans
- Automatic updates every hour
- Beautiful, native designs for both Android and iOS
- See [HOME_WIDGETS_GUIDE.md](HOME_WIDGETS_GUIDE.md) for setup instructions

### 📡 Offline Mode
- **Offline-First Architecture**: All data stored locally, works without internet
- **15+ Pre-loaded Verses**: Ready to use immediately after install
- **Downloadable Content**: Expand verse library while online
- **Automatic Sync**: Changes sync automatically when connection restored
- **Sync Queue**: All offline changes tracked and synced reliably
- **Visual Indicators**: Always know if you're online or offline
- **Zero Data Loss**: Everything saved locally first
- See [OFFLINE_MODE_GUIDE.md](OFFLINE_MODE_GUIDE.md) for complete documentation

### 🌍 Multi-Language Support
- **5 Languages Supported**: English, Spanish, French, Portuguese, Chinese
- **3.8+ Billion Potential Users**: Global reach in major languages
- **120+ Translation Keys**: Comprehensive coverage of all features
- **Easy Language Switching**: Change language anytime in settings
- **Native Language Names**: Language selector shows flags and native names
- **Instant Updates**: App changes language immediately
- **Developer-Friendly**: Simple localization API for adding more languages
- See [LOCALIZATION_GUIDE.md](LOCALIZATION_GUIDE.md) for implementation guide

### 🎮 Gamification System
- **10 Unique Levels**: Progress from Seeker (🌱) to Saint (✨)
- **15+ Collectible Badges**: Common to Legendary rarity system
- **Daily & Weekly Challenges**: Fresh challenges that reset automatically
- **XP Rewards**: Earn experience points for all spiritual activities
- **Leaderboard**: Local rankings with podium display for top 3
- **Badge Collection**: Beautiful grid view with category filters
- **Level Progression**: Visual progress bars and celebration dialogs
- **Automatic Rewards**: XP awarded instantly for Bible reading, prayers, reflections, streaks
- See [GAMIFICATION_GUIDE.md](GAMIFICATION_GUIDE.md) for complete system overview

### 🎨 Splash & Onboarding (NEW!)
- **Animated Splash Screen**: Beautiful loading screen with fade-in and scale animations
- **5-Page Onboarding Flow**: Welcome, Features, Gamification, Language, Get Started
- **Feature Discovery**: Showcases widgets, offline mode, gamification, and languages
- **Language Selection**: Choose preferred language during onboarding
- **Skip Functionality**: Users can skip anytime (top-right button)
- **Smart Routing**: Onboarding shown once, then direct to home
- **Page Indicators**: Animated dots show progress
- **Smooth Transitions**: Professional animations throughout
- See [SPLASH_ONBOARDING_GUIDE.md](SPLASH_ONBOARDING_GUIDE.md) for details

## Technical Features

- **Offline-First Architecture**: SQLite database + SharedPreferences for reliable offline operation
- **Automatic Sync**: Background synchronization when connectivity restored
- **Home Screen Widgets**: Native Android and iOS widgets for at-a-glance information
- **Connectivity Monitoring**: Real-time network status detection
- **Local Notifications**: Prayer reminders and smart habit notifications
- **Material Design 3**: Modern, accessible UI components
- **Serene Theme**: Calming color palette with blues, whites, and soft greens
- **Responsive Design**: Works on all screen sizes
- **Sample Data**: Pre-loaded with example data for demonstration
- **Streak Tracking**: Automatic reading streak calculation
- **Achievement System**: 20+ unlockable achievements
- **Reading Plans**: 5 pre-built Bible reading plans
- **Background Updates**: Widgets and sync work automatically in background

## File Structure

```
lib/
├── main.dart                 # App entry point
├── theme.dart               # Serene theme configuration
├── models/                  # Data models
│   ├── bible_reading.dart
│   ├── prayer_schedule.dart
│   ├── message_session.dart
│   ├── book_reading.dart
│   ├── spiritual_goal.dart
│   └── daily_verse.dart
├── services/               # Business logic
│   ├── local_storage_service.dart
│   ├── verse_service.dart
│   └── sample_data_service.dart
├── screens/               # Main screens
│   ├── home_page.dart
│   ├── bible_tracker_screen.dart
│   ├── prayer_schedule_screen.dart
│   ├── message_tracker_screen.dart
│   ├── book_tracker_screen.dart
│   └── goals_profile_screen.dart
└── widgets/              # Reusable components
    ├── feature_card.dart
    ├── daily_verse_card.dart
    └── progress_indicator.dart
```

## Key Dependencies

- `flutter`: Core Flutter framework
- `flutter_localizations`: Multi-language support
- `intl`: Internationalization and formatting
- `shared_preferences`: Local key-value data persistence
- `sqflite`: SQLite database for offline-first storage
- `connectivity_plus`: Network connectivity monitoring
- `home_widget`: Home screen widgets for Android and iOS
- `flutter_local_notifications`: Prayer time and smart reminders
- `timezone`: Notification scheduling
- `google_fonts`: Beautiful typography
- `share_plus`: Sharing verses and progress
- `http`: Network requests for sync
- `path_provider`: File system access

## Design Philosophy

SanctuaryFlow is designed with a focus on:
- **Serenity**: Calming colors and peaceful interactions
- **Simplicity**: Intuitive navigation and clear information hierarchy
- **Spirituality**: Features that genuinely support spiritual growth
- **Sustainability**: Encouraging long-term habits and consistent growth

## Sample Data

The app comes pre-loaded with sample data including:
- Bible reading entries from Genesis, Psalms, and Matthew
- Prayer schedules for morning, evening, and Sunday worship
- Message sessions from various sources and speakers
- Christian books including "Mere Christianity" and "The Purpose Driven Life"
- Spiritual goals for Bible reading, prayer habits, and church attendance
- Daily verses with reflections and favorites

## Recent Enhancements ✨

- ✅ **Splash & Onboarding**: Animated splash screen + 5-page onboarding flow
- ✅ **User Onboarding**: Feature discovery, language selection, smart routing
- ✅ **Gamification System**: 10 levels, 15+ badges, daily/weekly challenges, leaderboards
- ✅ **XP & Progression**: Earn XP for all activities, level up, unlock perks
- ✅ **Badge Collection**: Collectible badges with 5 rarity tiers
- ✅ **Challenges**: Auto-generating daily & weekly challenges
- ✅ **Multi-Language Support**: 5 languages (English, Spanish, French, Portuguese, Chinese)
- ✅ **Global Reach**: 3.8+ billion potential users in their native language
- ✅ **120+ Translations**: Comprehensive localization coverage
- ✅ **Offline Mode**: Complete offline-first architecture with automatic sync
- ✅ **SQLite Database**: 15+ pre-loaded verses, expandable library
- ✅ **Connectivity Monitoring**: Real-time online/offline detection
- ✅ **Sync Service**: Automatic background sync when connection restored
- ✅ **Home Screen Widgets**: Daily verse and streak counter widgets for Android and iOS
- ✅ **Quick Actions**: Fast access to Prayer and Reading Plans from widgets
- ✅ **Visual Indicators**: Offline/sync status throughout the app

## Future Enhancements

- Cloud backup and multi-device sync
- More downloadable offline content
- Verse search (offline capable)
- Community features for sharing progress
- Advanced analytics and insights
- Integration with Bible APIs for more verses
- Export/import functionality for data management
- Additional widget styles and customization options
- Conflict resolution UI for sync

## Getting Started

1. Run `flutter pub get` to install dependencies
2. Run `flutter run` to start the app
3. Explore the features using the sample data provided
4. Start tracking your own spiritual journey!

The app automatically initializes with sample data on first launch to demonstrate all features.