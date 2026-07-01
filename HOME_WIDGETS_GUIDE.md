# Home Screen Widgets - Implementation Guide

This guide explains how to use and configure the home screen widgets for the SanctuaryFlow app.

## Overview

The app now includes two powerful home screen widgets:

1. **Daily Verse Widget** - Displays today's Bible verse on your home screen
2. **Streak Counter Widget** - Shows your reading streak with quick action buttons

## Features

### Daily Verse Widget
- 📖 Shows today's inspirational Bible verse
- 🔄 Tap the refresh button to manually update
- 📱 Tap anywhere on the widget to open the app
- ⏰ Automatically updates every hour

### Streak Counter Widget
- 🔥 Displays your current reading streak
- 🏆 Shows your best (longest) streak
- ✅ Visual indicator when you've read today
- 🚀 Quick action buttons for Prayer and Reading Plans
- ⏰ Automatically updates every hour

## Setup Instructions

### Android Setup

1. **Install Dependencies**
   ```bash
   flutter pub get
   ```

2. **Build and Run**
   ```bash
   flutter run
   ```

3. **Add Widgets to Home Screen**
   - Long press on your Android home screen
   - Tap "Widgets"
   - Find "SanctuaryFlow" widgets
   - Drag "Daily Verse" or "Reading Streak" to your home screen
   - Resize as needed

### iOS Setup

1. **Configure App Groups in Xcode**
   - Open `ios/Runner.xcworkspace` in Xcode
   - Select the Runner target
   - Go to "Signing & Capabilities"
   - Click "+ Capability" and add "App Groups"
   - Add the group: `group.com.mycompany.sanctuaryflow`
   - Repeat for DailyVerseWidget and StreakWidget targets

2. **Add Widget Extensions to Xcode Project**
   - In Xcode, go to File → New → Target
   - Choose "Widget Extension"
   - Name it "DailyVerseWidget"
   - Repeat for "StreakWidget"
   - Copy the Swift files from `ios/DailyVerseWidget/` and `ios/StreakWidget/`

3. **Build and Run**
   ```bash
   flutter run
   ```

4. **Add Widgets to Home Screen**
   - Long press on your iOS home screen
   - Tap the "+" icon in the top left
   - Search for "SanctuaryFlow"
   - Choose "Daily Verse" or "Reading Streak"
   - Select your preferred size
   - Tap "Add Widget"

## Widget Update Behavior

The widgets automatically update when:
- The app is opened
- A new daily verse is fetched
- Your reading streak changes
- You complete a Bible reading
- Every hour (automatic refresh)

## Manual Widget Updates

To manually refresh the widgets at any time:
```dart
import 'package:sanctuaryflow/services/home_widget_service.dart';

// Update all widgets
await HomeWidgetService.updateAllWidgets();

// Update only the daily verse widget
await HomeWidgetService.updateDailyVerseWidget();

// Update only the streak widget
await HomeWidgetService.updateStreakWidget();
```

## Quick Actions

The Streak Widget includes two quick action buttons:

1. **Prayer Button** 🙏
   - Taps open the app and navigate to the Prayer Schedule screen
   - Quick access to start your prayer time

2. **Reading Button** 📖
   - Taps open the app and navigate to Reading Plans
   - Jump straight into your Bible reading

## Widget Sizes

### Android
- **Daily Verse Widget**: 250dp × 180dp (resizable)
- **Streak Widget**: 250dp × 120dp (resizable)

### iOS
- **Daily Verse Widget**: Medium (2×2) or Large (2×4)
- **Streak Widget**: Medium (2×2)

## Customization

### Changing Widget Appearance

#### Android
Edit the layout files in `android/app/src/main/res/layout/`:
- `daily_verse_widget.xml` - Daily verse layout
- `streak_widget.xml` - Streak counter layout

Edit the drawable files in `android/app/src/main/res/drawable/`:
- `widget_background.xml` - Widget background style
- Icon files for buttons and indicators

#### iOS
Edit the Swift files:
- `ios/DailyVerseWidget/DailyVerseWidget.swift`
- `ios/StreakWidget/StreakWidget.swift`

### Changing Update Frequency

In `lib/services/home_widget_service.dart`, modify the update period:
```dart
// For Android (in widget info XML files)
android:updatePeriodMillis="3600000"  // 1 hour in milliseconds

// For iOS (in Swift files)
let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
```

## Troubleshooting

### Widgets Not Updating

1. **Check permissions**: Ensure the app has necessary permissions
2. **Restart the app**: Close and reopen the app to trigger an update
3. **Remove and re-add widget**: Delete the widget and add it again
4. **Check background refresh** (iOS): Settings → General → Background App Refresh

### iOS Widgets Not Appearing

1. **Verify App Groups**: Ensure the App Group ID matches in:
   - Runner target
   - Widget extension targets
   - `HomeWidgetService.initialize()` method

2. **Clean build**:
   ```bash
   flutter clean
   cd ios
   pod install
   cd ..
   flutter run
   ```

### Android Widgets Not Responding to Taps

1. **Check AndroidManifest.xml**: Ensure widget receivers are properly registered
2. **Verify PendingIntent flags**: Make sure `FLAG_IMMUTABLE` is set for Android 12+

## Files Structure

```
lib/
├── services/
│   └── home_widget_service.dart    # Main widget service
├── main.dart                        # Widget initialization

android/
├── app/src/main/
│   ├── kotlin/com/mycompany/
│   │   ├── DailyVerseWidgetProvider.kt
│   │   └── StreakWidgetProvider.kt
│   ├── res/
│   │   ├── layout/
│   │   │   ├── daily_verse_widget.xml
│   │   │   └── streak_widget.xml
│   │   ├── drawable/
│   │   │   ├── widget_background.xml
│   │   │   └── ic_*.xml (icons)
│   │   ├── values/
│   │   │   └── strings.xml
│   │   └── xml/
│   │       ├── daily_verse_widget_info.xml
│   │       └── streak_widget_info.xml
│   └── AndroidManifest.xml

ios/
├── DailyVerseWidget/
│   ├── DailyVerseWidget.swift
│   └── Info.plist
└── StreakWidget/
    ├── StreakWidget.swift
    └── Info.plist
```

## Best Practices

1. **Regular Updates**: The widgets update automatically, but manual updates can be triggered when important data changes
2. **Battery Efficiency**: Update frequency is set to 1 hour to balance freshness with battery life
3. **User Experience**: Widgets provide quick glances; tap to open the app for full details
4. **Error Handling**: All widget operations include error handling to prevent crashes
5. **Data Persistence**: Widget data is stored using SharedPreferences (Android) and App Groups (iOS)

## Support

For issues or questions:
- Check the troubleshooting section above
- Review the implementation in `lib/services/home_widget_service.dart`
- Consult the [home_widget package documentation](https://pub.dev/packages/home_widget)

---

**Note**: Widgets enhance the user experience by providing at-a-glance information without opening the app. They are automatically updated throughout the day to keep users engaged with their spiritual growth journey.

