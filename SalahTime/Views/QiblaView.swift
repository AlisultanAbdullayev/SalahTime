//
//  QiblaView.swift
//  SalahTime
//
//  Created by Alisultan Abdullah on 13.08.2023.
//

import SwiftUI
import CoreLocation
import Adhan

struct QiblaView: View {
    
    @EnvironmentObject var locationManager: LocationManager
    var qiblaDirection: Int {
        locationManager.calculateQiblaDirection(from: locationManager.userLocation ?? CLLocation(latitude: 0, longitude: 0))
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                if locationManager.isLocationActive {
                    VStack {
                        VStack(alignment: .leading) {
                            Text("Device Heading: \(locationManager.heading)")
                            Text("Qibla Direction: \(qiblaDirection)")
                        }
                        .foregroundColor(.secondary)
                        .padding()
                        Spacer()
                        VStack {
                            Image(systemName: "arrow.up")
                                .resizable()
                                .foregroundStyle(
                                    (locationManager.heading >= qiblaDirection - 1 &&
                                     locationManager.heading <= qiblaDirection + 1) ? .green : .secondary
                                )
                                .rotationEffect(Angle(degrees: Double(-locationManager.heading + (locationManager.calculateQiblaDirection(from: locationManager.userLocation ?? CLLocation(latitude: 0, longitude: 0))))))
                        }
                        .frame(width: 150, height: 200)
                        Spacer()
                    }
                    .onChange(of: locationManager.heading) { _, newValue in
                        if (newValue >= qiblaDirection - 1 &&
                            newValue <= qiblaDirection + 1) {
                            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                        }
                    }
                    .onAppear {
                        locationManager.startUpdatingLocation()
                        locationManager.startUpdatingHeading()
                    }
                    .onDisappear {
                        locationManager.stopUpdatingLocation()
                        locationManager.stopUpdatingHeading()
                    }
                } else {
                    Text("Enable location services for exact data!")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding()
                }
            }
            
        }
        .navigationTitle("Qibla view")
    }
}

#Preview {
    QiblaView()
        .environmentObject(LocationManager())
}
