//
//  ContentView.swift
//  SalahTime
//
//  Created by Alisultan Abdullah on 13.08.2023.
//

import SwiftUI
import Adhan

struct ContentView: View {
    
    @EnvironmentObject private var locationManager: LocationManager
    @ObservedObject private var prayerTimeManager = PrayerTimeManager.shared
    @ObservedObject private var notificationManager = NotificationManager.shared
    @State private var isSheetShowing = false
    @State private var isLoadFailed = false
    let currentDate = Date()
    let gregorianCalendar = Calendar(identifier: .gregorian)
    let hijriCalendar = Calendar(identifier: .islamicUmmAlQura)
    
    var body: some View {
        Group {
            if locationManager.userLocation == nil {
                VStack {}
                    .onAppear {
                        self.isSheetShowing = true
                    }
                    .onDisappear {
                        self.isSheetShowing = false
                    }
            } else {
                Form {
                    dateAndHijriSection
                    if let prayerTimes = prayerTimeManager.prayerTimes {
                        leftTimeSection(prayers: prayerTimes)
                        prayerTimesList(prayers: prayerTimes)
                    } else {
                        progressView
                    }
                }
                .task {
                    self.locationManager.startUpdatingHeading()
                }
                .onChange(of: prayerTimeManager.madhab) { _, _ in
                    self.prayerTimeManager.fetchPrayerTimesForMonth(tempLocation: locationManager.userLocation,
                                                                    madhab: prayerTimeManager.madhab,
                                                                    method: prayerTimeManager.method)
                    self.notificationManager.schedulePrayerTimeNotifications()
                }
                .onChange(of: prayerTimeManager.method) { _, _ in
                    self.prayerTimeManager.fetchPrayerTimesForMonth(tempLocation: locationManager.userLocation,
                                                                    madhab: prayerTimeManager.madhab,
                                                                    method: prayerTimeManager.method)
                    self.notificationManager.schedulePrayerTimeNotifications()
                }
            }
        }
        .navigationTitle("Salah time")
        .sheet(isPresented: $isSheetShowing, content: {
            LocationNotFoundView()
                .interactiveDismissDisabled()
        })
    }
    
    private var dateAndHijriSection: some View {
        Section {
            VStack {
                Text("\(prayerTimeManager.getFormattedDate(date: currentDate, calendar: hijriCalendar))")
                    .font(.title2)
                    .foregroundStyle(.green)
                Text(Date(), style: .date)
                    .foregroundStyle(.secondary)
                    .font(.title3)
            }
            .fontDesign(.rounded)
            .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
    
    private var progressView: some View {
        Group {
            if !isLoadFailed {
                ProgressView("Try to load the data...")
                    .frame(maxWidth: .infinity)
                    .task {
                        try? await Task.sleep(nanoseconds: 5_000_000_000)
                        self.isLoadFailed = true
                    }
            } else {
                Text("Data can not be loaded!")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
    }
    
    @ViewBuilder
    private func leftTimeSection(prayers: PrayerTimes) -> some View {
        Section {
            if let nextPrayer = prayers.nextPrayer() {
                Text(prayers.time(for: nextPrayer), style: .timer)
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                Text(prayers.fajr.addingTimeInterval(86400), style: .timer)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        } header: {
            Text("Left time")
                .foregroundColor(.accentColor)
                .font(.body)
                .fontWeight(.regular)
        }
        .font(.largeTitle)
        .fontWeight(.bold)
        .fontDesign(.rounded)
    }
    
    @ViewBuilder
    private func prayerTimesList(prayers: PrayerTimes) -> some View {
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

#Preview {
    ContentView()
        .environmentObject(LocationManager())
}
