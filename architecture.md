# SanctuaryFlow - Spiritual Growth App Architecture

## Overview
A Flutter mobile app for spiritual growth tracking with 6 core features presented in a dashboard layout.

## Core Features
1. **Bible Reading Tracker** - Track daily Bible reading with progress metrics
2. **Prayer Time Notifications** - Schedule and manage prayer time reminders
3. **Message Listening Scheduler** - Track spiritual messages/sermons listened to
4. **Christian Book Reading Tracker** - Track Christian books being read
5. **Customizable Spiritual Goals Profile** - Set and manage personal spiritual goals
6. **Daily Verse Widget** - Display inspirational Bible verses

## Technical Architecture

### File Structure
```
lib/
├── main.dart                 # App entry point
├── theme.dart               # Theme configuration (updated with serene colors)
├── models/                  # Data models
│   ├── bible_reading.dart
│   ├── prayer_schedule.dart
│   ├── message_session.dart
│   ├── book_reading.dart
│   ├── spiritual_goal.dart
│   └── daily_verse.dart
├── services/               # Business logic services
│   ├── local_storage_service.dart
│   ├── notification_service.dart
│   └── verse_service.dart
├── screens/               # Main screens
│   ├── home_page.dart
│   ├── bible_tracker_screen.dart
│   ├── prayer_schedule_screen.dart
│   ├── message_tracker_screen.dart
│   ├── book_tracker_screen.dart
│   └── goals_profile_screen.dart
└── widgets/              # Reusable widgets
    ├── feature_card.dart
    ├── progress_indicator.dart
    ├── daily_verse_card.dart
    └── goal_progress_card.dart
```

### Key Implementation Details
- **Local Storage**: Using SharedPreferences for data persistence
- **Notifications**: Local notifications for prayer reminders
- **Theme**: Serene color palette with blues, whites, and soft greens
- **UI Pattern**: Card-based dashboard layout with Material Design 3
- **Data Models**: Structured models for each feature with JSON serialization

### MVP Features Priority
1. Dashboard with 6 feature cards
2. Basic Bible reading tracker
3. Prayer time scheduler
4. Daily verse display
5. Spiritual goals setting
6. Book and message tracking

## Implementation Steps
1. Update theme with serene colors
2. Create data models
3. Implement local storage service
4. Build dashboard home page
5. Create individual feature screens
6. Add notification service
7. Implement progress tracking
8. Add sample data for demonstration
9. Polish UI and UX
10. Test and debug complete app