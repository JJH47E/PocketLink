//
//  ContentView.swift
//  Pocket
//
//  Created by JJ Hayter on 05/07/2024.
//
import SwiftUI

struct ContentView: View {
    @StateObject private var context = DeviceContext()

    var body: some View {
        VStack {
            if context.deviceConnected {
                DeviceView(deviceContext: context)
            } else if context.connecting {
                ProgressView()
            } else {
                Text("No device detected")
            }
        }
        .padding()
        .onAppear(perform: startDiskArbitration)
    }
    
    func startDiskArbitration() {
        let contextPointer = Unmanaged.passUnretained(context).toOpaque()
        
        guard let session = DASessionCreate(kCFAllocatorDefault) else {
            fatalError("[ContentView] Unable to start disk arbitration")
        }
        
        DARegisterDiskAppearedCallback(session, nil, diskAppearedCallback, contextPointer)
        DARegisterDiskDisappearedCallback(session, nil, diskUnmountedCallback, contextPointer)
        DASessionScheduleWithRunLoop(session, CFRunLoopGetCurrent(), CFRunLoopMode.defaultMode.rawValue)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
