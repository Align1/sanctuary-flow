import WidgetKit
import SwiftUI

struct StreakEntry: TimelineEntry {
    let date: Date
    let currentStreak: Int
    let longestStreak: Int
    let hasReadToday: Bool
}

struct StreakProvider: TimelineProvider {
    func placeholder(in context: Context) -> StreakEntry {
        StreakEntry(
            date: Date(),
            currentStreak: 0,
            longestStreak: 0,
            hasReadToday: false
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (StreakEntry) -> ()) {
        let defaults = UserDefaults(suiteName: "group.com.mycompany.sanctuaryflow")
        let entry = StreakEntry(
            date: Date(),
            currentStreak: defaults?.integer(forKey: "widget_streak") ?? 0,
            longestStreak: defaults?.integer(forKey: "widget_longest_streak") ?? 0,
            hasReadToday: defaults?.bool(forKey: "widget_has_read_today") ?? false
        )
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let defaults = UserDefaults(suiteName: "group.com.mycompany.sanctuaryflow")
        let entry = StreakEntry(
            date: Date(),
            currentStreak: defaults?.integer(forKey: "widget_streak") ?? 0,
            longestStreak: defaults?.integer(forKey: "widget_longest_streak") ?? 0,
            hasReadToday: defaults?.bool(forKey: "widget_has_read_today") ?? false
        )
        
        // Update every hour
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

struct StreakWidgetView : View {
    var entry: StreakProvider.Entry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Reading Streak")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color(red: 0.17, green: 0.24, blue: 0.31))
            
            HStack(spacing: 12) {
                Image(systemName: entry.hasReadToday ? "checkmark.circle.fill" : "book.fill")
                    .font(.system(size: 28))
                    .foregroundColor(entry.hasReadToday ? Color(red: 0.15, green: 0.68, blue: 0.38) : Color(red: 0.20, green: 0.60, blue: 0.86))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(entry.currentStreak)")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Color(red: 0.20, green: 0.60, blue: 0.86))
                    Text("Days")
                        .font(.system(size: 12))
                        .foregroundColor(Color(red: 0.5, green: 0.55, blue: 0.55))
                }
                
                Spacer()
                
                Text("Best: \(entry.longestStreak)")
                    .font(.system(size: 12))
                    .foregroundColor(Color(red: 0.58, green: 0.65, blue: 0.65))
            }
            
            Divider()
                .background(Color(red: 0.88, green: 0.88, blue: 0.88))
            
            HStack(spacing: 16) {
                Button(action: {}) {
                    VStack(spacing: 4) {
                        Image(systemName: "hands.sparkles.fill")
                            .font(.system(size: 20))
                        Text("Prayer")
                            .font(.system(size: 10))
                    }
                    .foregroundColor(Color(red: 0.20, green: 0.29, blue: 0.37))
                    .frame(maxWidth: .infinity)
                }
                
                Button(action: {}) {
                    VStack(spacing: 4) {
                        Image(systemName: "book.fill")
                            .font(.system(size: 20))
                        Text("Reading")
                            .font(.system(size: 10))
                    }
                    .foregroundColor(Color(red: 0.20, green: 0.29, blue: 0.37))
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
    }
}

@main
struct StreakWidget: Widget {
    let kind: String = "StreakWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StreakProvider()) { entry in
            StreakWidgetView(entry: entry)
        }
        .configurationDisplayName("Reading Streak")
        .description("Track your daily reading streak with quick actions")
        .supportedFamilies([.systemMedium])
    }
}

struct StreakWidget_Previews: PreviewProvider {
    static var previews: some View {
        StreakWidgetView(entry: StreakEntry(
            date: Date(),
            currentStreak: 7,
            longestStreak: 14,
            hasReadToday: true
        ))
        .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}

