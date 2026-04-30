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
                VStack(spacing: 12) {
                    ProgressView()
                    Text("Loading — the Pocket's USB connection is slow, this may take a moment.")
                        .foregroundStyle(.secondary)
                        .font(.callout)
                        .multilineTextAlignment(.center)
                }
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
