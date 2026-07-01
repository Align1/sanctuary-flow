# 🌍 Localization - Quick Reference

## 📱 Supported Languages

| Flag | Language | Code | Native Name | Speakers |
|------|----------|------|-------------|----------|
| 🇺🇸 | English | `en` | English | 1.5B |
| 🇪🇸 | Spanish | `es` | Español | 500M+ |
| 🇫🇷 | French | `fr` | Français | 300M+ |
| 🇧🇷 | Portuguese | `pt` | Português | 250M+ |
| 🇨🇳 | Chinese | `zh` | 中文 | 1.3B+ |

**Total Reach**: 3.8+ billion users! 🌍

---

## 🚀 Quick Usage

### 1. Import Localizations
```dart
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
```

### 2. Get Localization Instance
```dart
final l10n = AppLocalizations.of(context)!;
```

### 3. Use Localized Strings
```dart
// Simple text
Text(l10n.dailyVerse)
Text(l10n.prayer)
Text(l10n.goals)

// Buttons
ElevatedButton(
  child: Text(l10n.save),
  onPressed: () {},
)

// App bar
AppBar(title: Text(l10n.bibleTrackerTitle))

// Placeholders
Text(l10n.streakMessage(7)) // "7 day streak!"
```

---

## 📋 Common Keys

### Navigation
```dart
l10n.home
l10n.bibleReading
l10n.prayer
l10n.messages
l10n.books
l10n.goals
l10n.settings
```

### Actions
```dart
l10n.add
l10n.edit
l10n.delete
l10n.save
l10n.cancel
l10n.share
l10n.done
```

### Screen Titles
```dart
l10n.bibleTrackerTitle
l10n.prayerScheduleTitle
l10n.messageTrackerTitle
l10n.bookTrackerTitle
l10n.goalsTitle
l10n.achievementsTitle
l10n.readingPlansTitle
```

### Status
```dart
l10n.loading
l10n.noData
l10n.errorOccurred
l10n.workingOffline
l10n.allSynced
```

---

## 🔧 Change Language

### Programmatically:
```dart
import 'package:sanctuaryflow/services/language_service.dart';

// Change to Spanish
await LanguageService().changeLanguage('es');

// Get current language
final locale = await LanguageService().getCurrentLocale();
print(locale.languageCode); // 'en', 'es', etc.
```

### UI Component:
```dart
// Navigate to language settings screen
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => LanguageSettingsScreen(),
  ),
);
```

---

## ➕ Adding New Translation

### 1. Add to English ARB (`lib/l10n/app_en.arb`):
```json
{
  "newKey": "New Text",
  "@newKey": {
    "description": "Description here"
  }
}
```

### 2. Add to All Other Languages:
- `app_es.arb`: `"newKey": "Nuevo Texto"`
- `app_fr.arb`: `"newKey": "Nouveau Texte"`
- `app_pt.arb`: `"newKey": "Novo Texto"`
- `app_zh.arb`: `"newKey": "新文本"`

### 3. Regenerate:
```bash
flutter pub get
```

### 4. Use:
```dart
Text(l10n.newKey)
```

---

## 🌐 Adding New Language

### 1. Create ARB File:
`lib/l10n/app_XX.arb` (XX = language code)

### 2. Add All Translations:
Copy from `app_en.arb` and translate

### 3. Update `main.dart`:
```dart
supportedLocales: const [
  Locale('en'),
  Locale('es'),
  Locale('fr'),
  Locale('pt'),
  Locale('zh'),
  Locale('XX'), // New language
],
```

### 4. Update Language Service:
```dart
static const List<LanguageOption> supportedLanguages = [
  // ...existing
  LanguageOption(
    code: 'XX',
    name: 'Language',
    nativeName: 'Native',
    flag: '🏳️',
  ),
];
```

### 5. Regenerate:
```bash
flutter pub get
```

---

## 🐛 Quick Fixes

### Files Not Generated?
```bash
flutter clean
flutter pub get
flutter run
```

### Language Not Changing?
- Restart app
- Check SharedPreferences
- Verify locale in LanguageService

### Missing Translation?
- Check key exists in all ARB files
- Verify spelling matches exactly
- Run `flutter pub get`

---

## 📊 Translation Stats

- **Total Keys**: 120+
- **Languages**: 5
- **Total Translations**: 600+ (120 × 5)
- **Coverage**: All major features
- **Quality**: Professional

---

## 💡 Pro Tips

1. **Always use l10n** - Never hardcode strings
2. **Test all languages** - UI might overflow
3. **Use flexible layouts** - Accommodate longer text
4. **Keep keys descriptive** - Easy to understand
5. **Group related keys** - Better organization

---

## 🎯 Example Implementation

### Localizing a Feature Card:

```dart
// Before
FeatureCard(
  title: 'Bible Reading',
  subtitle: 'Track your daily reading',
  icon: Icons.menu_book,
)

// After
FeatureCard(
  title: l10n.bibleReading,
  subtitle: l10n.trackYourProgress,
  icon: Icons.menu_book,
)
```

### Localizing a Dialog:

```dart
// Before
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: Text('Confirm Delete'),
    content: Text('Are you sure?'),
    actions: [
      TextButton(
        child: Text('Cancel'),
        onPressed: () => Navigator.pop(context),
      ),
      TextButton(
        child: Text('Delete'),
        onPressed: () {},
      ),
    ],
  ),
)

// After
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: Text(l10n.confirmDelete),
    content: Text(l10n.deleteMessage),
    actions: [
      TextButton(
        child: Text(l10n.cancel),
        onPressed: () => Navigator.pop(context),
      ),
      TextButton(
        child: Text(l10n.delete),
        onPressed: () {},
      ),
    ],
  ),
)
```

---

## 🎊 You're Ready!

**Implementation**: ✅ Complete  
**Languages**: 5  
**Keys**: 120+  
**Ready for**: Global Users  

Start localizing your screens and watch your app speak to the world! 🌍✨

---

For detailed guide, see: [LOCALIZATION_GUIDE.md](LOCALIZATION_GUIDE.md)

