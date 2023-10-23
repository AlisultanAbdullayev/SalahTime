//
//  SalahWidgetView.swift
//  SalahTimeWidgetExtension
//
//  Created by Alisultan Abdullah on 20.10.2023.
//

import SwiftUI

struct SalahTimeWidgetEntryView : View {
    
    @Environment(\.widgetFamily) var family
    var entry: WidgetProvider.Entry
    
    var body: some View {
        VStack {
            if let prayerTimes = entry.prayerTimes {
                switch family {
                case .systemSmall:
                    LeftTimeSection(prayers: prayerTimes)
                case .systemLarge:
                    PrayerTimesList(prayers: prayerTimes)
                        .environmentObject(LocationManager())
                default: Text("Not implemented!")
                }
            } else {
                Text("N/A")
            }
        }
    }
}
