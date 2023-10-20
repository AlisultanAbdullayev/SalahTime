//
//  PrayerTimeManager.swift
//  SalahTime
//
//  Created by Alisultan Abdullah on 19.09.2023.
//

import SwiftUI
import Adhan
import CoreLocation

final class PrayerTimeManager: ObservableObject {
    
    static let shared = PrayerTimeManager()
    @Published var prayerTimes: PrayerTimes?
    @Published var madhab: Madhab = .shafi {
        didSet {
            saveMadhabToUD()
        }
    }
    @Published var method: CalculationMethod = .turkey {
        didSet {
            saveMethodToUD()
        }
    }
    @Published var prayerTimesArr = [PrayerTimes]()
    @Published var prayerTimeIndex: Int?
//    @Published var prayerTime: PrayerTimes?
    private let userDefaults = UserDefaults.standard
    let madhabs: [Madhab] = [.hanafi, .shafi]
    let methods: [CalculationMethod] = CalculationMethod.allCases
    
    private init() {
        getMadhabFromUD()
        getMethodFromUD()
    }
    
    @MainActor
    func fetchPrayerTimesForMonth(tempLocation: CLLocation?, madhab: Madhab,  method: CalculationMethod) {
        guard let location = tempLocation else { return }
        
        let coordinates = Coordinates(latitude: location.coordinate.latitude,
                                      longitude: location.coordinate.longitude)
        
        var params = method.params
        params.madhab = madhab
        
        let calendar = Calendar(identifier: .gregorian)
        let currentDate = Date()
        let range = calendar.range(of: .day, in: .month, for: currentDate)
        
        guard let range else { return }
        
        prayerTimesArr = []
        
        for day in range.lowerBound...range.upperBound {
            let dateComponents = DateComponents(year: calendar.component(.year, from: currentDate),
                                                month: calendar.component(.month, from: currentDate),
                                                day: day)
            if let date = calendar.date(from: dateComponents),
               let prayers = PrayerTimes(coordinates: coordinates, date: dateComponents, calculationParameters: params) {
                print("Date: \(date)")
                print("fajr \(formattedPrayerTime(prayers.fajr))")
                print("sunrise \(formattedPrayerTime(prayers.sunrise))")
                print("dhuhr \(formattedPrayerTime(prayers.dhuhr))")
                print("asr \(formattedPrayerTime(prayers.asr))")
                print("maghrib \(formattedPrayerTime(prayers.maghrib))")
                print("isha \(formattedPrayerTime(prayers.isha))")
                print("------------- \(prayerTimesArr.count) -------------")
                
            prayerTimesArr.append(prayers)
            }
        }
        
        getPrayerTimeWithDate(date: currentDate)
    }
    
    @MainActor
    func loadNextMonthPrayerTimes() {
        guard let location = LocationManager().userLocation else { return }
                 let coordinates = Coordinates(latitude: location.coordinate.latitude,
                                      longitude: location.coordinate.longitude)
        
        var params = method.params
        params.madhab = madhab

        let calendar = Calendar(identifier: .gregorian)
        
        // Get the first day of the next month
        guard let firstDayOfNextMonth = calendar.date(byAdding: .month, value: 1, to: Date()) else {
            print("Failed to calculate the first day of the next month.")
            return
        }
        
        let range = calendar.range(of: .day, in: .month, for: firstDayOfNextMonth)
        
        guard let range = range else { return }
        
        prayerTimesArr = [] // Clear the array or consider appending if you want to keep current month's data
        
        for day in range.lowerBound...range.upperBound {
            let dateComponents = DateComponents(year: calendar.component(.year, from: firstDayOfNextMonth),
                                                month: calendar.component(.month, from: firstDayOfNextMonth),
                                                day: day)
            if let date = calendar.date(from: dateComponents),
               let prayers = PrayerTimes(coordinates: coordinates, date: dateComponents, calculationParameters: params) {
                print("Date: \(date)")
                print("fajr \(formattedPrayerTime(prayers.fajr))")
                print("sunrise \(formattedPrayerTime(prayers.sunrise))")
                print("dhuhr \(formattedPrayerTime(prayers.dhuhr))")
                print("asr \(formattedPrayerTime(prayers.asr))")
                print("maghrib \(formattedPrayerTime(prayers.maghrib))")
                print("isha \(formattedPrayerTime(prayers.isha))")
                print("------------- \(prayerTimesArr.count) -------------")
                
                prayerTimesArr.append(prayers)
            }
        }
        
        // Assuming you want to update the index to the first day of the next month as well
        getPrayerTimeWithDate(date: firstDayOfNextMonth)
    }
    
    @discardableResult
    @MainActor
    func getPrayerTimeWithDate(date: Date) -> Int {
        let calendar = Calendar(identifier: .gregorian)
        
//        let prayerTime = prayerTimesArr.first { prayerTime in
//            prayerTime.date == DateComponents(year: calendar.component(.year, from: date),
//                                              month: calendar.component(.month, from: date),
//                                              day: calendar.component(.day, from: date))
//        }
//        
//        self.prayerTime = prayerTime
        
        let prayerTimeIndex = prayerTimesArr.firstIndex { prayerTime in
            prayerTime.date == DateComponents(year: calendar.component(.year, from: date),
                                              month: calendar.component(.month, from: date),
                                              day: calendar.component(.day, from: date))
        }
        
        guard let prayerTimeIndex else { fatalError("PrayerTimeIndex is nil") }
        self.prayerTimeIndex = prayerTimeIndex
        
        self.prayerTimes = prayerTimesArr[prayerTimeIndex]
        
        return prayerTimeIndex
    }
    
    @MainActor
    func getPrayerTimeWithDateComponents(dateComponents: DateComponents) -> Int {
        let prayerTimeIndex = prayerTimesArr.firstIndex { prayerTime in
            prayerTime.date == dateComponents
        }
        
        guard let prayerTimeIndex else { fatalError("PrayerTimeIndex is nil") }
        
        return prayerTimeIndex
    }
    
    @MainActor
    func fetchPrayerTime(tempLocation: CLLocation?, madhab: Madhab, method: CalculationMethod) {
        guard let location = tempLocation else { return }
        
        let coordinates = Coordinates(latitude: location.coordinate.latitude,
                                      longitude: location.coordinate.longitude)
        
        var params = method.params
        params.madhab = madhab
        
        let components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        let prayerTimes = PrayerTimes(coordinates: coordinates, date: components, calculationParameters: params)
        
        self.prayerTimes = prayerTimes
        
        NotificationManager.shared.schedulePrayerTimeNotifications()
    }
    
    func formattedPrayerTime(_ prayerTime: Date?) -> String {
        guard let prayerTime = prayerTime else { return "N/A" }
        
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.timeStyle = .short
        
        return formatter.string(from: prayerTime)
    }
    
    func getFormattedDate(date: Date, calendar: Calendar) -> String {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = calendar
        dateFormatter.dateFormat = "yyyy MMMM dd"
        let formattedDate = dateFormatter.string(from: calendar.date(from: components) ?? date)
        return formattedDate
    }
    
    private func saveMadhabToUD() {
        userDefaults.setValue(madhab.rawValue, forKey: "madhab")
        print("Madhab saved!")
    }
    
    private func getMadhabFromUD() {
        let savedMadhab = userDefaults.integer(forKey: "madhab")
        guard let madhab = Madhab(rawValue: savedMadhab) else {
            print("Error while fetching madhab from UD!")
            return
        }
        self.madhab = madhab
        print("Gotten madhab from UD!")
    }
    
    private func saveMethodToUD() {
        userDefaults.setValue(method.rawValue, forKey: "method")
        print("Method saved!")
    }
    
    private func getMethodFromUD() {
        guard let savedMethod = userDefaults.string(forKey: "method") else {
            print("Error while fetching method from UD!")
            return
        }
        guard let methodRawValue = CalculationMethod(rawValue: savedMethod) else {
            print("Calculation method from raw value!")
            return
        }
        
        self.method = methodRawValue
        print("Gotten method from UD!")
    }
    
}
