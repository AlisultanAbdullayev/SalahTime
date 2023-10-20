//
//  EventsView.swift
//  SalahTime
//
//  Created by Alisultan Abdullah on 13.08.2023.
//

import SwiftUI

struct EventsView: View {
    
    @StateObject private var prayerTimesManager = PrayerTimeManager.shared
    @EnvironmentObject private var locationManager: LocationManager

    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Spacer()
                    Spacer()
                    Text("Fajr")
                    Spacer()
                    Text("Sunrise")
                    Spacer()
                    Text("Dhuhr")
                    Spacer()
                    Text("Asr")
                    Spacer()
                    Text("Maghrib")
                    Spacer()
                    Text("Isha")
                    Spacer()
                }
                .font(.subheadline)
                List(prayerTimesManager.prayerTimesArr, id: \.date) { prayerTime in
                    if prayerTimesManager.getPrayerTimeWithDateComponents(dateComponents: prayerTime.date) != prayerTimesManager.prayerTimesArr.count - 1 {
                        CalendarRowView(index: prayerTimesManager.getPrayerTimeWithDateComponents(dateComponents: prayerTime.date) + 1,
                                        prayerTime: prayerTime)
                        .listRowBackground(prayerTimesManager.getPrayerTimeWithDateComponents(dateComponents: prayerTime.date) == prayerTimesManager.prayerTimeIndex ? Color.accentColor.opacity(0.5) : nil)
                    }
                }
                .listStyle(.grouped)
            }
            .task {
                prayerTimesManager.fetchPrayerTimesForMonth(tempLocation: locationManager.userLocation, madhab: prayerTimesManager.madhab, method: prayerTimesManager.method)
            }
            .font(.callout)
            .foregroundStyle(.secondary)
            .navigationTitle("Monthly view")
        }
    }
}

#Preview {
    EventsView()
}
