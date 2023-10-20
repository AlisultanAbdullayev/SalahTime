//
//  SalahTimeApp.swift
//  SalahTime
//
//  Created by Alisultan Abdullah on 13.08.2023.
//

import SwiftUI

@main
struct SalahTimeApp: App {
    
    @StateObject private var locationManager = LocationManager()
    @StateObject private var notificationManager = NotificationManager.shared
    
    var body: some Scene {
        WindowGroup {
            TabPageView()
                .environmentObject(locationManager)
        }
    }
    
 }
