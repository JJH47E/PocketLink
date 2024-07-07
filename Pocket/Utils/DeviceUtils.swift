//
//  DeviceUtils.swift
//  Pocket
//
//  Created by JJ Hayter on 05/07/2024.
//

import Foundation

func readDeviceInfo(from path: URL, context: DeviceContext) {
    let jsonFilePath = path.appendingPathComponent("Analogue_Pocket.json")
    
    guard FileManager.default.fileExists(atPath: jsonFilePath.path) else {
        DispatchQueue.main.async {
            context.deviceConnected = false
        }
        return
    }

    if let deviceInfo = JsonReader<DeviceInfo>.loadData(from: jsonFilePath) {
        context.firmwareVersion = deviceInfo.firmware.runtime.name
    }
    
    DispatchQueue.main.async {
        context.objectWillChange.send()
    }
}
