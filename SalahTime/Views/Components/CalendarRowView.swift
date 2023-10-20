//
//  CalendarRowView.swift
//  SalahTime
//
//  Created by Alisultan Abdullah on 27.09.2023.
//

import SwiftUI
import Adhan

struct CalendarRowView: View {
    
    
    @StateObject private var prayerTimesManager = PrayerTimeManager.shared
    let index: Int
    let prayerTime: PrayerTimes
    
    var body: some View {
        HStack {
            Text("\(index).")
            Spacer()
            Text(prayerTime.fajr, style: .time)
                .foregroundStyle(Color(.label))
            Spacer()
            Text(prayerTime.sunrise, style: .time)
            Spacer()
            Text(prayerTime.dhuhr, style: .time)
            Spacer()
            Text(prayerTime.asr, style: .time)
            Spacer()
            Text(prayerTime.maghrib, style: .time)
                .foregroundStyle(Color(.label))
            Spacer()
            Text(prayerTime.isha, style: .time)
        }
    }
}
