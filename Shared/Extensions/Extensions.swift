//
//  Extensions.swift
//  SalahTime
//
//  Created by Alisultan Abdullah on 19.09.2023.
//

import Foundation
import CoreLocation

extension Double {
    var radiansToDegrees: Double { return self * 180.0 / .pi }
}

extension UserDefaults {
    func set(location:CLLocation, forKey key: String) {
        let locationLat = NSNumber(value:location.coordinate.latitude)
        let locationLon = NSNumber(value:location.coordinate.longitude)
        self.set(["lat": locationLat, "long": locationLon], forKey:key)
    }
    
    func location(forKey key: String) -> CLLocation? {
        if let locationDictionary = self.object(forKey: key) as? Dictionary<String,NSNumber> {
            let locationLat = locationDictionary["lat"]!.doubleValue
            let locationLon = locationDictionary["long"]!.doubleValue
            return CLLocation(latitude: locationLat, longitude: locationLon)
        }
        return nil
    }
}
