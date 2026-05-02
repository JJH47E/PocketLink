//
//  DeviceOverviewView.swift
//  Pocket
//
//  Created by JJ Hayter on 07/07/2024.
//

import SwiftUI

struct DeviceOverviewView: View {
    @ObservedObject var deviceContext: DeviceContext
    var onEject: () -> Void = {}

    var body: some View {
        HStack {
            VStack {
                Image("pocket")
                    .resizable()
                    .scaledToFit()
                    .clipped()
            }.padding()
            VStack {
                Group {
                    Text("Analogue Pocket")
                        .font(.title)
                        .padding(EdgeInsets(top: 20, leading: 0, bottom: 0, trailing: 0))
                    if let version = deviceContext.firmwareVersion {
                        HStack(spacing: 6) {
                            Text("Firmware Version: \(version)")
                            if deviceContext.latestFirmwareVersion != nil {
                                Text("Update available")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                            }
                        }
                    }
                    if let storageSize = deviceContext.getPrettyStorageCapacity() {
                        Text("Storage: \(storageSize)")
                    }
                }.frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        onEject()
                    } label: {
                        Label("Eject", systemImage: "eject")
                    }
                    .disabled(deviceContext.volumeRoute == nil || deviceContext.isEjecting)
                    Button {
                        openFinder(at: deviceContext.volumeRoute!)
                    } label: {
                        Text("Show in Finder")
                    }.disabled(deviceContext.volumeRoute == nil)
                }
            }.padding()
        }
    }
}

#Preview {
    DeviceOverviewView(deviceContext: DeviceContext(firmwareVersion: "1.2", volumeRoute: nil, storageSize: 128000000))
}
