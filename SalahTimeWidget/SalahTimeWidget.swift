//
//  SalahTimeWidget.swift
//  SalahTimeWidget
//
//  Created by Alisultan Abdullah on 20.10.2023.
//

import WidgetKit
import SwiftUI

struct SalahTimeWidget: Widget {
    let kind: String = "SalahTimeWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind,
                            provider: WidgetProvider()) { entry in
            if #available(iOS 17.0, *) {
                SalahTimeWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                SalahTimeWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
                            .supportedFamilies([.systemSmall, .systemLarge])
                            .configurationDisplayName("My Widget")
                            .description("This is an example widget.")
    }
}

#Preview(as: .systemSmall) {
    SalahTimeWidget()
} timeline: {
    WidgetEntry(date: .now, prayerTimes: PrayerTimeManager.shared.prayerTimes)
    WidgetEntry(date: .now, prayerTimes: PrayerTimeManager.shared.prayerTimes)
}
