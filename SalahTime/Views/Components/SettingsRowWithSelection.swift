//
//  SettingsRowWithSelection.swift
//  SalahTime
//
//  Created by Alisultan Abdullah on 20.09.2023.
//

import SwiftUI

struct SettingsRowWithSelection<Content : View>: View {
    let text: Text?
    let content: Content
    let systemImage: String?
    
    init(text: Text? = nil, systemImage: String? = nil, @ViewBuilder content: () -> Content) {
        self.systemImage = systemImage
        self.text = text
        self.content = content()
    }
    
    var body: some View {
        HStack {
            if let systemImage {
                Image(systemName: systemImage)
                    .foregroundStyle(.accent)
            }
            text
            Spacer()
            content
        }
    }
}

#Preview {
    SettingsRowWithSelection() {
        
    }
}
