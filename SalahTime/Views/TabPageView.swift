//
//  TabPageView.swift
//  SalahTime
//
//  Created by Alisultan Abdullah on 13.08.2023.
//

import SwiftUI

struct TabPageView: View {
    var body: some View {
        TabView {
            NavigationStack {
                ContentView()
            }
            .tabItem {
                Label("Time", systemImage: "clock")
            }
            NavigationStack {
                QiblaView()
            }
            .tabItem {
                Label("Qibla", systemImage: "safari.fill")
            }
            NavigationStack {
                EventsView()
            }
            .tabItem {
                Label("Calendar", systemImage: "calendar")
            }
            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gear")
            }
        }
    }
}

#Preview {
    TabPageView()
}
