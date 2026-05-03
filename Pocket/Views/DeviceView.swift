//
//  DeviceOverviewView.swift
//  Pocket
//
//  Created by JJ Hayter on 07/07/2024.
//

import SwiftUI

struct DeviceView: View {
    @ObservedObject var deviceContext: DeviceContext
    var onEject: () -> Void = {}

    var body: some View {
        TabView {
            DeviceOverviewView(deviceContext: deviceContext, onEject: onEject)
                .tabItem {
                    Text("Info")
                }

            SystemsOverviewView(platforms: deviceContext.platforms, mountedDeviceURL: deviceContext.volumeRoute)
                .cornerRadius(5)
                .tabItem {
                    Text("Systems")
                }

            GameOverviewWrapperView(mountedVolumeUrl: deviceContext.volumeRoute, platforms: deviceContext.platforms)
                .tabItem {
                    Text("Games")
                }

            MemoriesOverviewWrapperView(mountedVolumeUrl: deviceContext.volumeRoute)
                .tabItem {
                    Text("Memories")
                }

            CoreManagerView(volumeRoute: deviceContext.volumeRoute)
                .tabItem {
                    Text("Cores")
                }
        }.padding()
    }
}

#Preview {
    DeviceView(deviceContext: DeviceContext(firmwareVersion: "1.2", volumeRoute: nil, storageSize: 128000000))
}
