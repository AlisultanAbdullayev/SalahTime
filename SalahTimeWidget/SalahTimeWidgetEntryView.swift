//
//  SalahWidgetView.swift
//  SalahTimeWidgetExtension
//
//  Created by Alisultan Abdullah on 20.10.2023.
//

import SwiftUI

struct SalahTimeWidgetEntryView : View {
    
    var entry: WidgetProvider.Entry
    
    var body: some View {
        VStack {
            if let prayerTimes = entry.prayerTimes {
                PrayerTimesList(prayers: prayerTimes)
                    .environmentObject(LocationManager())
            } else {
                Text("N/A")
            }
        }
    }
}
