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
    
    func fetchPrayerTimeData(date: Date,
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
    
    
    func createPrayerTimeLine(date: Date,
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
            let prayerTimes = prayerManager.prayerTimes
            let entry = WidgetEntry(date: date, prayerTimes: prayerTimes)
            let timeline = Timeline(entries: [entry],
                                    policy: .atEnd)
            completion(timeline)
        }
    }

}
