//
//  NotificationManager.swift
//  SalahTime
//
//  Created by Alisultan Abdullah on 19.09.2023.
//

import Foundation
import UserNotifications
import Adhan

final class NotificationManager: ObservableObject {
    
    static let shared = NotificationManager()
    private let prayerTimeManager = PrayerTimeManager.shared
    private let notificationCenter = UNUserNotificationCenter.current()
    private let userDefaults = UserDefaults.standard
    let minuteOptions: [Int] = [10, 15, 20, 25, 30, 45, 60]
    @Published var isTriggered: Bool = false
    @Published var notificationSettings: [String : Bool] = [
        "Fajr": true,
        "Sunrise": false,
        "Dhuhr": true,
        "Asr": true,
        "Maghrib": true,
        "Isha": true
    ] {
        didSet {
            saveNotificationSettings()
        }
    }
    @Published var notificationSettingsBefore: [String : Bool] = [
        "Fajr": false,
        "Sunrise": false,
        "Dhuhr": false,
        "Asr": false,
        "Maghrib": false,
        "Isha": false
    ] {
        didSet {
            saveNotificationSettingsBefore()
        }
    }
    @Published var notifyBefore: Bool = false
    @Published var beforeMinutes: Int = 20 {
        didSet {
            saveNotifyBeforeMinutes()
        }
    }
    
    private init() {
        getNotificationSettings()
        getNotificationSettingsBefore()
        getNotifyBeforeMinutes()
        
        notificationCenter.requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Error requesting authorization for notifications: \(error.localizedDescription)")
            } else if granted {
                print("User granted permission for notifications.")
            } else {
                print("User denied permission for notifications.")
            }
        }
    }
    
    @MainActor
    func scheduleNotification(for prayerTime: Date, with prayerName: String) {
        let content = UNMutableNotificationContent()
        content.title = "Salah time"
        content.subtitle = prayerName
        content.body = "Kindly remind you about \(prayerName) time!"
        content.sound = UNNotificationSound.default
        
        let prayerComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute],
                                                               from: prayerTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: prayerComponents, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        notificationCenter.add(request) { error in
            guard let error else { return }
            print(error.localizedDescription)
        }
    }
    
    @MainActor
    func scheduleNotificationBefore(for prayerTime: Date, with prayerName: String, before minutes: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Salah time"
        //        content.subtitle = prayerName
        content.body = "Kindly remind you that \(minutes) minutes left until \(prayerName)!"
        content.sound = UNNotificationSound.default
        
        var prayerComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: prayerTime)
        
        if prayerComponents.minute != nil {
            prayerComponents.minute! -= minutes
            beforeMinutes = minutes
        }
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: prayerComponents, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        notificationCenter.add(request) { error in
            guard let error else { return }
            print(error.localizedDescription)
        }
    }
    
    @MainActor
    func schedulePrayerTimeNotifications() {
        
        notificationCenter.removeAllPendingNotificationRequests()
        
//        guard let prayerTimeIndex = prayerTimeManager.prayerTimeIndex else {
//            print("Can not get prayerTimeIndex")
//            return
//        }
        
//        let prayerTimes = prayerTimeManager.prayerTimesArr[prayerTimeIndex]
        guard let prayerTimes = prayerTimeManager.prayerTimes else { print("No prayerTimes available!"); return }
//
//        let range = prayerTimeIndex..<min(prayerTimeIndex + 6, prayerTimeManager.prayerTimesArr.count - 1)
//        
//        let subset = prayerTimeManager.prayerTimesArr[range]
//        
//        for prayerTime in subset {
//            scheduleNotificationsPerEachDay(prayerTime: prayerTime)
//        }
//        
//        if range.upperBound >= prayerTimeManager.prayerTimesArr.count - 1 {
//            isTriggered = true
//        }
        
                let prayerTimesToNotify = [
                    ("Fajr", prayerTimes.fajr),
                    ("Sunrise", prayerTimes.sunrise),
                    ("Dhuhr", prayerTimes.dhuhr),
                    ("Asr", prayerTimes.asr),
                    ("Maghrib", prayerTimes.maghrib),
                    ("Isha", prayerTimes.isha)
                ]
        
                for (prayerName, prayerTime) in prayerTimesToNotify {
                    if notificationSettings[prayerName] == true {
                        scheduleNotification(for: prayerTime, with: prayerName)
                    }
                }
        
                for (prayerName, prayerTime) in prayerTimesToNotify {
                    if notificationSettingsBefore[prayerName] == true {
                        scheduleNotificationBefore(for: prayerTime, with: prayerName, before: beforeMinutes)
                    }
                }
        
        print("Notifications generated!")
//        notificationCenter.getPendingNotificationRequests(completionHandler: { [weak self] requests in
//            while requests.count == 0 {
//                self?.schedulePrayerTimeNotifications()
//                for request in requests {
//                    print(request)
//                }
//            }
//        })
    }
//    
//    @MainActor
//    private func scheduleNotificationsPerEachDay(prayerTime: PrayerTimes) {
//        let prayerNames = ["Fajr", "Sunrise", "Dhuhr", "Asr", "Maghrib", "Isha"]
//        let prayerDates = [prayerTime.fajr,
//                           prayerTime.sunrise,
//                           prayerTime.dhuhr,
//                           prayerTime.asr,
//                           prayerTime.maghrib,
//                           prayerTime.isha]
//        
//        for (index, prayerDate) in prayerDates.enumerated() {
//            let prayerName = prayerNames[index]
//
//            if notificationSettingsBefore[prayerName] == true {
//                scheduleNotificationBefore(for: prayerDate, with: prayerName, before: beforeMinutes)
//            }
//
//            if notificationSettings[prayerName] == true {
//                scheduleNotification(for: prayerDate, with: prayerName)
//            }
//        }
//    }
    
    @MainActor
    func updateNotificationSettings(for prayerName: String, sendNotification: Bool, isBefore: Bool = false) {
        if isBefore {
            notificationSettingsBefore[prayerName] = sendNotification
        } else {
            notificationSettings[prayerName] = sendNotification
        }
        schedulePrayerTimeNotifications()
    }
    
    private func saveNotificationSettings() {
        userDefaults.setValue(notificationSettings, forKey: "notifications")
        print("Saved the notification settings")
    }
    
    private func getNotificationSettings() {
        if let savedDictionary = userDefaults.dictionary(forKey: "notifications") as? [String : Bool] {
            notificationSettings = savedDictionary
        } else {
            print("Can not get notification settings data from User Defaults!")
        }
    }
    
    private func saveNotifyBeforeMinutes() {
        userDefaults.setValue(beforeMinutes, forKey: "beforeMinutes")
    }
    
    private func getNotifyBeforeMinutes() {
        if userDefaults.integer(forKey: "beforeMinutes") != 0 {
            beforeMinutes = userDefaults.integer(forKey: "beforeMinutes")
        }
    }
    
    private func saveNotificationSettingsBefore() {
        userDefaults.setValue(notificationSettingsBefore, forKey: "notificationsBefore")
        print("Saved the before-notification settings")
    }
    
    private func getNotificationSettingsBefore() {
        if let savedDictionary = userDefaults.dictionary(forKey: "notificationsBefore") as? [String : Bool] {
            notificationSettingsBefore = savedDictionary
        } else {
            print("Can not get before-notification settings data from User Defaults!")
        }
    }
    
}
