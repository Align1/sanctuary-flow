import WidgetKit
import SwiftUI

struct DailyVerseEntry: TimelineEntry {
    let date: Date
    let verse: String
    let reference: String
}

struct DailyVerseProvider: TimelineProvider {
    func placeholder(in context: Context) -> DailyVerseEntry {
        DailyVerseEntry(
            date: Date(),
            verse: "Trust in the Lord with all your heart",
            reference: "Proverbs 3:5-6"
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (DailyVerseEntry) -> ()) {
        let entry = DailyVerseEntry(
            date: Date(),
            verse: UserDefaults(suiteName: "group.com.mycompany.sanctuaryflow")?.string(forKey: "widget_verse") ?? "Trust in the Lord with all your heart",
            reference: UserDefaults(suiteName: "group.com.mycompany.sanctuaryflow")?.string(forKey: "widget_reference") ?? "Proverbs 3:5-6"
        )
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entry = DailyVerseEntry(
            date: Date(),
            verse: UserDefaults(suiteName: "group.com.mycompany.sanctuaryflow")?.string(forKey: "widget_verse") ?? "Trust in the Lord with all your heart",
            reference: UserDefaults(suiteName: "group.com.mycompany.sanctuaryflow")?.string(forKey: "widget_reference") ?? "Proverbs 3:5-6"
        )
        
        // Update every hour
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

struct DailyVerseWidgetView : View {
    var entry: DailyVerseProvider.Entry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Daily Verse")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(red: 0.17, green: 0.24, blue: 0.31))
                Spacer()
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 12))
                    .foregroundColor(Color(red: 0.5, green: 0.55, blue: 0.55))
            }
            
            Text(entry.verse)
                .font(.system(size: 14))
                .foregroundColor(Color(red: 0.20, green: 0.29, blue: 0.37))
                .lineSpacing(4)
                .lineLimit(6)
            
            Spacer()
            
            Text(entry.reference)
                .font(.system(size: 12))
                .italic()
                .foregroundColor(Color(red: 0.5, green: 0.55, blue: 0.55))
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
    }
}

@main
struct DailyVerseWidget: Widget {
    let kind: String = "DailyVerseWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DailyVerseProvider()) { entry in
            DailyVerseWidgetView(entry: entry)
        }
        .configurationDisplayName("Daily Verse")
        .description("Display today's Bible verse on your home screen")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

struct DailyVerseWidget_Previews: PreviewProvider {
    static var previews: some View {
        DailyVerseWidgetView(entry: DailyVerseEntry(
            date: Date(),
            verse: "Trust in the Lord with all your heart and lean not on your own understanding",
            reference: "Proverbs 3:5-6"
        ))
        .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}

