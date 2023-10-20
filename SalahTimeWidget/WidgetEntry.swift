//
//  WidgetEntry.swift
//  SalahTime
//
//  Created by Alisultan Abdullah on 20.10.2023.
//

import WidgetKit
import Adhan

struct WidgetEntry: TimelineEntry {
    let date: Date
    let prayerTimes: PrayerTimes?
}
