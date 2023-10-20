//
//  LocationNotFoundView.swift
//  SalahTime
//
//  Created by Alisultan Abdullah on 9.09.2023.
//

import SwiftUI

struct LocationNotFoundView: View {
    var body: some View {
        VStack(spacing: 30){
            Image(systemName: "location.fill")
                .font(.system(size: 90))
                .foregroundColor(.green)
            
            HStack{
                Text("Correct")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Location")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
            }
            Text("To access the most accurate prayer times instantly through the Salah app, you need to allow location access.")
                .font(.callout)
                .fontWeight(.light)
                .multilineTextAlignment(.center)
                .padding()
            
            Text("We only need your location information while you are using the app. This enables us to provide prayer times specific to your location and is not shared with any other parties.")
                .font(.callout)
                .fontWeight(.light)
                .multilineTextAlignment(.center)
                .padding()
            
            Spacer()
            
            Button {
                if let url = URL(string: UIApplication.openSettingsURLString){
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
                
            } label: {
                Label("Allow location access", systemImage: "location.fill")
                    .frame(maxWidth: .infinity)
            }
            .foregroundStyle(.white)
            .padding()
            .background(.green)
            .cornerRadius(15)
            
            Text("Enable Location Access from Settings")
                .font(.callout)
                .foregroundColor(.secondary)
        }
        .padding(30)
    }
}

#Preview {
    LocationNotFoundView()
}
