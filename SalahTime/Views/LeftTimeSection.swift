//
//  LeftTimeSection.swift
//  SalahTime
//
//  Created by Alisultan Abdullah on 23.10.2023.
//

import SwiftUI
import Adhan

struct LeftTimeSection: View {
    
    let prayers: PrayerTimes
    
    var body: some View {
        Section {
            if let nextPrayer = prayers.nextPrayer() {
                Text(prayers.time(for: nextPrayer), style: .timer)
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                Text(prayers.fajr.addingTimeInterval(86400), style: .timer)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        } header: {
            Text("Left time")
                .foregroundColor(.accentColor)
                .font(.body)
                .fontWeight(.regular)
        }
        .font(.largeTitle)
        .fontWeight(.bold)
        .fontDesign(.rounded)
    }
}

//#Preview {
//    LeftTimeSection()
//}
