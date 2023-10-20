//
//  SettingsView.swift
//  SalahTime
//
//  Created by Alisultan Abdullah on 13.08.2023.
//

import SwiftUI
import Adhan

struct SettingsView: View {
    
    @StateObject private var prayerTimeManager = PrayerTimeManager.shared
    @StateObject private var notificationManager = NotificationManager.shared
    @State private var isOpened = false
    
    var body: some View {
        Form {
            Section {
                SettingsRowWithSelection(text: Text("Minutes before"), systemImage: "hourglass") {
                    Picker("", selection: $notificationManager.beforeMinutes) {
                        ForEach(notificationManager.minuteOptions, id: \.self) { minute in
                            if minute != 60 {
                                Text("\(minute) minutes")
                            } else {
                                Text("1 hour")
                            }
                        }
                        
                    }
                }
                DisclosureGroup(isExpanded: $isOpened) {
                    ForEach(notificationManager.notificationSettingsBefore.keys.sorted(), id: \.self) { key in
                        Toggle(isOn: Binding(
                            get: { self.notificationManager.notificationSettingsBefore[key] ?? false },
                            set: { newValue in
                                self.notificationManager.updateNotificationSettings(for: key,
                                                                                    sendNotification: newValue,
                                                                                    isBefore: true)
                                UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                            }
                        )) {
                            Text(key)
                        }
                    }
                } label: {
                    Label("Prayer times before", systemImage: "clock")
                        .labelStyle(.titleOnly)
                }
            } header: {
                Text("Notifications:")
            }
            Section {
                SettingsRowWithSelection(text: Text("Madhab"), systemImage: "doc.plaintext") {
                    Picker("", selection: $prayerTimeManager.madhab) {
                        ForEach(prayerTimeManager.madhabs, id: \.self) { madhab in
                            Text("\(madhab == .hanafi ? "Hanafi" : "Shafi")")
                        }
                    }
                }
                SettingsRowWithSelection(text: Text("Institution"), systemImage: "book") {
                    Picker("", selection: $prayerTimeManager.method) {
                        ForEach(prayerTimeManager.methods, id: \.self) { method in
                            switch method {
                            case .dubai:
                                Text("Dubai")
                            case .muslimWorldLeague:
                                Text("Muslim World League")
                            case .egyptian:
                                Text("Egyptian General Authority of Survey")
                            case .karachi:
                                Text("University of Islamic Sciences, Karachi")
                            case .ummAlQura:
                                Text("Umm Al-Qura University, Makkah")
                            case .moonsightingCommittee:
                                Text("Moonsighting Committee Worldwide")
                            case .northAmerica:
                                Text("Islamic Society of North America")
                            case .kuwait:
                                Text("Kuwait")
                            case .qatar:
                                Text("Qatar")
                            case .singapore:
                                Text("Majlis Ugama Islam Singapura, Singapore")
                            case .tehran:
                                Text("Institute of Geophysics, University of Tehran")
                            case .turkey:
                                Text("Diyanet İşleri Başkanlığı, Turkey")
                            case .other:
                                Text("Other")
                            }
//                            Text("\(method.rawValue)")
                        }
                    }
                    .pickerStyle(NavigationLinkPickerStyle())
                }
            } header: {
                Text("Calculations:")
            }
            VStack {
                Text("Make 🤲 for us")
                Text("Made with ❤️")
                Text("by Alisultan Abdullah")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .onChange(of: notificationManager.beforeMinutes, {
            self.notificationManager.schedulePrayerTimeNotifications()
        })
        .onDisappear {
            self.isOpened = false
        }
        .navigationTitle("Settings")
    }
}

#Preview {
    SettingsView()
}

