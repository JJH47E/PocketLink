//
//  ContentView.swift
//  Pocket
//
//  Created by JJ Hayter on 05/07/2024.
//
import SwiftUI

struct ContentView: View {
    @StateObject private var monitor = DeviceMonitor()

    var body: some View {
        VStack {
            if monitor.context.daSessionFailed {
                Text("Unable to start device monitoring")
            } else if monitor.context.deviceConnected {
                DeviceView(deviceContext: monitor.context)
            } else if monitor.context.connecting {
                ProgressView()
            } else {
                Text("No device detected")
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
