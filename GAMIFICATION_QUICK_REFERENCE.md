# 🎮 Gamification - Quick Reference

## 🎯 Quick Overview

### Features:
- 🎖️ **10 Levels** (Seeker → Saint)
- 🏆 **15+ Badges** (Common → Legendary)
- 🎯 **5+ Challenges** (Daily & Weekly)
- 📊 **Leaderboard** (Local rankings)

---

## ⚡ Quick Commands

### Award XP:
```dart
await GamificationService.awardXPForAction(GameAction.bibleReading);
```

### Get Current Level:
```dart
final level = await GamificationService.getCurrentLevel();
print('Level ${level.level}: ${level.title}');
```

### Check Badges:
```dart
final badges = await GamificationService.getAllBadges();
final unlocked = badges.where((b) => b.isUnlocked).toList();
```

### Update Challenge:
```dart
await GamificationService.updateChallengeProgress(challengeId, 1);
```

---

## 🎖️ Levels

| Level | Title | XP | Icon |
|-------|-------|-----|------|
| 1 | Seeker | 0 | 🌱 |
| 2 | Believer | 100 | ✝️ |
| 3 | Disciple | 250 | 📖 |
| 4 | Follower | 500 | 🙏 |
| 5 | Servant | 1K | 💫 |
| 6 | Teacher | 2K | 📚 |
| 7 | Leader | 4K | 👑 |
| 8 | Shepherd | 8K | 🕊️ |
| 9 | Warrior | 15K | ⚔️ |
| 10 | Saint | 30K | ✨ |

---

## 🏆 XP Rewards

| Action | XP |
|--------|-----|
| Bible Reading | +10 |
| Prayer Session | +8 |
| Add Reflection | +5 |
| Complete Goal | +20 |
| Streak Day | +15 |
| Share Verse | +10 |
| Reading Plan | +50 |

---

## 🎯 Challenges

### Daily (24h):
- 📖 Daily Reading (+25 XP)
- 🙏 Prayer Time (+20 XP)
- 💭 Reflection (+15 XP)

### Weekly (7d):
- 🔥 7 Readings (+150 XP)
- ⚡ 7-Day Streak (+250 XP)

---

## 🏆 Badge Categories

- **Reading**: First Steps, Devoted Reader, Scholar, Master
- **Streak**: Week Warrior, Monthly Champion, Consistency King
- **Prayer**: Novice, Warrior
- **Goals**: Goal Getter, Achiever
- **Milestones**: Week Strong, Monthly, Yearly
- **Social**: Word Spreader, Evangelist

---

## 📱 UI Widgets

### Level Progress:
```dart
LevelProgressWidget() // Full
LevelProgressWidget(compact: true) // Compact
```

### XP Indicator:
```dart
XPIndicator(xp: 25)
```

### Level Up:
```dart
showDialog(
  context: context,
  builder: (context) => LevelUpDialog(...),
)
```

---

## 🚀 Quick Start

1. **Add to Navigation**:
```dart
ListTile(
  leading: Icon(Icons.emoji_events),
  title: Text('Badges'),
  onTap: () => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => BadgesScreen(),
    ),
  ),
)
```

2. **Show Level on Home**:
```dart
LevelProgressWidget()
```

3. **Award XP**:
```dart
await GamificationService.awardXPForAction(
  GameAction.bibleReading
);
```

---

## 🎨 Colors

### Rarity Colors:
- Common: Gray
- Uncommon: Green
- Rare: Blue
- Epic: Purple
- Legendary: Gold

### Difficulty Colors:
- Easy: Green
- Medium: Blue
- Hard: Orange
- Expert: Red

### Rank Colors:
- 🥇 1st: Gold
- 🥈 2nd: Silver
- 🥉 3rd: Bronze

---

## 📊 Stats API

```dart
final stats = await GamificationService.getStats();

// Access properties:
stats.level.level          // Current level
stats.totalXP              // Total XP earned
stats.unlockedBadges       // Badges unlocked
stats.totalBadges          // Total badges
stats.activeChallenges     // Active challenges
stats.completedChallenges  // Completed
stats.daysActive           // Days using app
```

---

## 💡 Pro Tips

1. **Daily Challenges** - Easy XP daily
2. **Maintain Streaks** - Consistent rewards
3. **Complete All Activities** - More XP sources
4. **Check Badges** - Know what to aim for
5. **Compete** - Check leaderboard

---

## 🔧 Integration

### In Existing Services:

**Bible Reading:**
```dart
await LocalStorageService.saveBibleReading(reading);
// Automatically awards +10 XP
```

**Streaks:**
```dart
await StreakService.updateStreak(reading);
// Awards +15 XP if streak continues
```

**Reflections:**
```dart
await VerseService.addReflection(id, text);
// Awards +5 XP
```

---

## 🎊 Success!

**Status**: ✅ Complete  
**Levels**: 10  
**Badges**: 15+  
**Challenges**: 5+  
**Ready**: 🚀 Production  

Let the games begin! 🎮✨

