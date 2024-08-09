//
//  ExWidget.swift
//  ExWidget
//
//  Created by Akshit on 02/07/24.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), message1: "Stay active!", emoji1: "🏋️‍♂️", message2: "Eat healthy!", emoji2: "🥗")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), message1: "Stay active!", emoji1: "🏋️‍♂️", message2: "Eat healthy!", emoji2: "🥗")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, message1: "Stay active!", emoji1: "🏋️‍♂️", message2: "Eat healthy!", emoji2: "🥗")
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let message1: String
    let emoji1: String
    let message2: String
    let emoji2: String
}

struct ExWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.blue, Color.purple]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea(edges: .all)

            VStack {
                Spacer()
                
                VStack {
                    HStack {
                        Text(entry.message1)
                        Text(entry.emoji1)
                    }
                    HStack {
                        Text(entry.message2)
                        Text(entry.emoji2)
                    }
                }
                .font(.title2)
                .foregroundColor(.white)
                .padding()
                
                Spacer()
            }
        }
    }
}

struct ExWidget: Widget {
    let kind: String = "ExWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                ExWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                ExWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Diet & Exercise Widget")
        .description("This widget shows diet and exercise tips.")
    }
}

#Preview(as: .systemSmall) {
    ExWidget()
} timeline: {
    SimpleEntry(date: .now, message1: "Stay active!", emoji1: "🏋️‍♂️", message2: "Eat healthy!", emoji2: "🥗")
    SimpleEntry(date: .now, message1: "Stay active!", emoji1: "🏋️‍♂️", message2: "Eat healthy!", emoji2: "🥗")
}
