//
//  PrayerTimesList.swift
//  SalahTime
//
//  Created by Alisultan Abdullah on 20.10.2023.
//

import SwiftUI
import Adhan

struct PrayerTimesList: View {
    
    let prayers: PrayerTimes
    @StateObject private var prayerTimeManager = PrayerTimeManager.shared
    @EnvironmentObject private var locationManager: LocationManager
    
    var body: some View {
            Section {
                SalahTimeRowView(imageName: "sunrise",
                                 salahTime: prayerTimeManager.formattedPrayerTime(prayers.fajr),
                                 salahName: "Fajr")
                .foregroundColor(prayers.currentPrayer() ?? .fajr == .fajr ? .green : .none)
                SalahTimeRowView(imageName: "sun.and.horizon",
                                 salahTime: prayerTimeManager.formattedPrayerTime(prayers.sunrise),
                                 salahName: "Sunrise")
                .foregroundColor(prayers.currentPrayer() ?? .fajr == .sunrise ? .green : .none)
                SalahTimeRowView(imageName: "sun.max",
                                 salahTime: prayerTimeManager.formattedPrayerTime(prayers.dhuhr),
                                 salahName: "Dhuhr")
                .foregroundColor(prayers.currentPrayer() ?? .fajr == .dhuhr ? .green : .none)
                SalahTimeRowView(imageName: "sunset",
                                 salahTime: prayerTimeManager.formattedPrayerTime(prayers.asr),
                                 salahName: "Asr")
                .foregroundColor(prayers.currentPrayer() ?? .fajr == .asr ? .green : .none)
                SalahTimeRowView(imageName: "moon",
                                 salahTime: prayerTimeManager.formattedPrayerTime(prayers.maghrib),
                                 salahName: "Maghrib")
                .foregroundColor(prayers.currentPrayer() ?? .fajr == .maghrib ? .green : .none)
                SalahTimeRowView(imageName: "moon.stars",
                                 salahTime: prayerTimeManager.formattedPrayerTime(prayers.isha),
                                 salahName: "Isha")
                .foregroundColor(prayers.currentPrayer() ?? .fajr == .isha ? .green : .none)
            } header: {
                Button {
                    locationManager.startUpdatingLocation()
                } label: {
                    Label(locationManager.locationName,
                          systemImage: locationManager.isLocationActive ? "location.circle.fill" : "location.slash")
                    .foregroundColor(.accentColor)
                }
            }
    }
}

//#Preview {
//    PrayerTimesList(prayers: PrayerTimeManager.shared.prayerTimes)
//}
