//
//  DeviceOverviewView.swift
//  Pocket
//
//  Created by JJ Hayter on 07/07/2024.
//

import SwiftUI

struct DeviceOverviewView: View {
    // may need to make this state object?
    var deviceContext: DeviceContext
    
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
                        Text("Firmware Version: \(version)")
                    }
                    if let storageSize = deviceContext.getPrettyStorageCapacity() {
                        Text("Storage: \(storageSize)")
                    }
                }.frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
                HStack {
                    Spacer()
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
