//
//  ContentView.swift
//  Sana
//
//  Created by Alina Yu on 9/29/24.
//

import SwiftUI
import CoreLocation

struct EnvironmentDashboard: View {
    @StateObject private var locationManager = LocationManager()
        
        var body: some View {
            VStack {
                if let coordinate = locationManager.lastKnownLocation {
                    Text("Latitude: \(coordinate.latitude)")
                    
                    Text("Longitude: \(coordinate.longitude)")
                } else {
                    Text("Unknown Location")
                }
                
                
                Button("Get location") {
                    locationManager.checkLocationAuthorization()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
}

#Preview {
    EnvironmentDashboard()
}
