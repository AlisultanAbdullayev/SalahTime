//
//  Provider.swift
//  SalahTime
//
//  Created by Alisultan Abdullah on 20.10.2023.
//

import WidgetKit
import SwiftUI
import Adhan

struct WidgetProvider: TimelineProvider {
    
    let locationManager = LocationManager()

    func placeholder(in context: Context) -> WidgetEntry {
        return WidgetEntry(date: Date(), prayerTimes: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (WidgetEntry) -> ()) {
             fetchPrayerTimeData(date: Date(),
                                      prayerManager: PrayerTimeManager.shared,
                                      locationManager: locationManager,
                                      completion: completion)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WidgetEntry>) -> ()) {
             createPrayerTimeLine(date: Date(),
                                       prayerManager: PrayerTimeManager.shared,
                                       locationManager: locationManager,
                                       completion: completion)
    }
    
    private func fetchPrayerTimeData(date: Date,
                             prayerManager: PrayerTimeManager = PrayerTimeManager.shared,
                             locationManager: LocationManager,
                             completion: @escaping (WidgetEntry) -> Void) {
        locationManager.startUpdatingLocation()
        
        if let userLocation = locationManager.userLocation {
            Task {
                await prayerManager.fetchPrayerTime(tempLocation: userLocation,
                                                    madhab: prayerManager.madhab,
                                                    method: prayerManager.method)
            }
            let prayerTimes = prayerManager.prayerTimes
            let entry = WidgetEntry(date: date, prayerTimes: prayerTimes)
            completion(entry)
        }
    }
    
    private func createPrayerTimeLine(date: Date,
                             prayerManager: PrayerTimeManager = PrayerTimeManager.shared,
                             locationManager: LocationManager,
                             completion: @escaping (Timeline<WidgetEntry>) -> Void) {
        locationManager.startUpdatingLocation()
        if let userLocation = locationManager.userLocation {
            Task {
                await prayerManager.fetchPrayerTime(tempLocation: userLocation,
                                                    madhab: prayerManager.madhab,
                                                    method: prayerManager.method)
            }
            guard let prayerTimes = prayerManager.prayerTimes else { print("Prayer times is null"); return }
            let nextRefresh = nextRefreshTime(after: Date(),
                                              prayerTimes: [prayerTimes.fajr,
                                                            prayerTimes.sunrise,
                                                            prayerTimes.dhuhr,
                                                            prayerTimes.asr,
                                                            prayerTimes.maghrib,
                                                            prayerTimes.isha
                                                           ])
            let entry = WidgetEntry(date: date, prayerTimes: prayerTimes)
            let timeline = Timeline(entries: [entry],
                                    policy: .after(nextRefresh))
            completion(timeline)
        }
    }
    
    private func nextRefreshTime(after currentDate: Date, prayerTimes: [Date]) -> Date {
        for prayerTime in prayerTimes.sorted() {
            if currentDate < prayerTime {
                return prayerTime
            }
        }
        // If no more prayer times today, set the next refresh to Fajr of the next day
        return prayerTimes.first!.addingTimeInterval(24 * 60 * 60)
    }

}
