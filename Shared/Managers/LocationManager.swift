//
//  LocationManager.swift
//  SalahTime
//
//  Created by Alisultan Abdullah on 13.08.2023.
//

import Foundation
import CoreLocation
import SwiftUI
import Adhan

final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate  {
    
    @Published private(set) var locationName: String = "N/A" {
        didSet {
            saveLocationName()
        }
    }
    @Published private(set) var userLocation: CLLocation? = nil {
        didSet {
            saveUserLocation()
        }
    }
    @Published private(set) var error: Error?
    @Published private(set) var isLocationActive: Bool = false
    @Published var heading: Int = 0
    private let cLLocationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    private let userDefaults = UserDefaults(suiteName: "group.com.alijaver.SalahTime")
    private let notificationManager = NotificationManager.shared
    private let prayerTimeManager = PrayerTimeManager.shared
    
    override init() {
        super.init()
        
        cLLocationManager.delegate = self
        cLLocationManager.desiredAccuracy = kCLLocationAccuracyBest
        cLLocationManager.requestWhenInUseAuthorization()
        cLLocationManager.startUpdatingLocation()
        cLLocationManager.startUpdatingHeading()
        
        getUserLocation()
        getLocationName()
    }
    
    @MainActor
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse,
                .authorizedAlways:
            isLocationActive = true
            cLLocationManager.startUpdatingLocation()
        case .denied, .notDetermined, .restricted:
            isLocationActive = false
            cLLocationManager.requestWhenInUseAuthorization()
            fetchGeocoder(tempLocation: userLocation)
            prayerTimeManager.fetchPrayerTime(tempLocation: userLocation,
                                              madhab: prayerTimeManager.madhab,
                                              method: prayerTimeManager.method) 
            
//            prayerTimeManager.fetchPrayerTimesForMonth(tempLocation: userLocation,
//                                                       madhab: prayerTimeManager.madhab,
//                                                       method: prayerTimeManager.method)
            
            notificationManager.schedulePrayerTimeNotifications()
        @unknown default:
            print("Unknown location access status.")
        }
    }
    
    @MainActor
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        self.userLocation = location
//        
        prayerTimeManager.fetchPrayerTime(tempLocation: userLocation,
                                          madhab: prayerTimeManager.madhab,
                                          method: prayerTimeManager.method)
        
//        prayerTimeManager.fetchPrayerTimesForMonth(tempLocation: userLocation, 
//                                                   madhab: prayerTimeManager.madhab,
//                                                   method:prayerTimeManager.method)
        
        notificationManager.schedulePrayerTimeNotifications()
        
        fetchGeocoder(tempLocation: location)
        
        cLLocationManager.stopUpdatingLocation()
    }
    
    @MainActor
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        self.heading = Int(newHeading.trueHeading)
    }
    
    @MainActor
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.error = error
    }
    
    @MainActor
    private func fetchGeocoder(tempLocation: CLLocation?) {
        guard let location = tempLocation else { return }
        
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                self.error = error
            } else if let placemarks = placemarks? .first {
                self.locationName = placemarks.locality ?? placemarks.administrativeArea ?? placemarks.country ?? "Unknown location"
                print(self.locationName)
            }
        }
    }
    
    func calculateQiblaDirection(from location: CLLocation) -> Int {
//        let makkah = CLLocation(latitude: 21.4225, longitude: 39.8262)  // Coordinates of Masjid Al-Haram, Makkah
//        
//        let deltaLongitude = makkah.coordinate.longitude - location.coordinate.longitude
//        let y = sin(deltaLongitude)
//        let x = cos(location.coordinate.latitude) * tan(makkah.coordinate.latitude) - sin(location.coordinate.latitude) * cos(deltaLongitude)
//        let qiblaDirection = atan2(y, x)
//        
////        return Int(qiblaDirection.radiansToDegrees)
        ///
        let qiblaDegree = Qibla(coordinates: Coordinates(latitude: location.coordinate.latitude,
                                                         longitude: location.coordinate.longitude)).direction
        return Int(qiblaDegree)
    }
    
    func requestLocation() {
        cLLocationManager.requestWhenInUseAuthorization()
    }
    
    func startUpdatingHeading() {
        cLLocationManager.startUpdatingHeading()
    }
    
    func stopUpdatingHeading() {
        cLLocationManager.stopUpdatingHeading()
    }
    
    func startUpdatingLocation() {
        cLLocationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        cLLocationManager.stopUpdatingLocation()
    }
    
    private func saveUserLocation() {
        guard let userLocation else { return }
        guard let userDefaults else { return }
        userDefaults.set(location: userLocation, forKey: "userLocation")
        print("Saved the last user's location")
    }
    
    private func getUserLocation() {
        guard let userDefaults else { return }
        userLocation = userDefaults.location(forKey: "userLocation")
        print("Gotten the last user's location")
    }
    
    private func saveLocationName() {
        guard let userDefaults else { return }
        userDefaults.setValue(locationName, forKey: "locationName")
        print("Saved the location name")
    }
    
    private func getLocationName() {
        guard let userDefaults else { return }
        if let savedString = userDefaults.string(forKey: "locationName") {
            self.locationName = savedString
        }
        print("Gotten the location name")
    }
    
}
