//
//  SalahTimeRowView.swift
//  SalahTime
//
//  Created by Alisultan Abdullah on 13.08.2023.
//

import SwiftUI

struct SalahTimeRowView: View {
    
    @StateObject private var notificationManager = NotificationManager.shared
    let imageName: String
    let salahTime: String
    let salahName: String
    
    var body: some View {
        HStack {
            HStack {
                Image(systemName: imageName)
                    .frame(width: 30, alignment: .leading)
                Text(salahName)
            }
            .frame(width: 110, alignment: .leading)
            Spacer(minLength: 80)
            Button {
                if notificationManager.notificationSettings[salahName] == true {
                    notificationManager.updateNotificationSettings(for: salahName, sendNotification: false)
                } else {
                    notificationManager.updateNotificationSettings(for: salahName, sendNotification: true)
                }
                UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
            } label: {
                Image(systemName: notificationManager.notificationSettings[salahName] ?? true ? "bell.fill" : "bell.slash")
                    .tint(Color(.label))
            }
            Spacer()
            Text("\(salahTime)")
        }
        .padding(.vertical, 5)
    }
}

#Preview {
    SalahTimeRowView(imageName: "sun", salahTime: "12:30", salahName: "Fajr")
}
