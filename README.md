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

## Technical Features

- **Local Storage**: All data stored locally using SharedPreferences
- **Material Design 3**: Modern, accessible UI components
- **Serene Theme**: Calming color palette with blues, whites, and soft greens
- **Responsive Design**: Works on all screen sizes
- **Sample Data**: Pre-loaded with example data for demonstration

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
- `shared_preferences`: Local data persistence
- `flutter_local_notifications`: Prayer time reminders
- `google_fonts`: Beautiful typography

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

## Future Enhancements

- Push notifications for prayer reminders
- Cloud sync for data backup
- Community features for sharing progress
- Advanced analytics and insights
- Integration with Bible APIs for more verses
- Export/import functionality for data management

## Getting Started

1. Run `flutter pub get` to install dependencies
2. Run `flutter run` to start the app
3. Explore the features using the sample data provided
4. Start tracking your own spiritual journey!

The app automatically initializes with sample data on first launch to demonstrate all features.