//
//  DeviceOverviewView.swift
//  Pocket
//
//  Created by JJ Hayter on 07/07/2024.
//

import SwiftUI

struct DeviceView: View {
    var deviceContext: DeviceContext
    
    var body: some View {
        TabView {
            DeviceOverviewView(deviceContext: deviceContext)
                .tabItem {
                    Text("Info")
                }
            
            SystemsOverviewView(platforms: deviceContext.platforms)
                .cornerRadius(5)
                .tabItem {
                    Text("Systems")
                }
            
            Text("Games List View")
                .tabItem {
                    Text("Games")
                }
        }.padding()
    }
}

#Preview {
    DeviceView(deviceContext: DeviceContext(firmwareVersion: "1.2", volumeRoute: nil, storageSize: 128000000))
}
