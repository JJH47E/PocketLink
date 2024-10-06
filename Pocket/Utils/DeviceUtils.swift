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

func readPlatforms(from path: URL, context: DeviceContext) -> Void {
    let platformsPath = path.appendingPathComponent("Platforms")
    let fileManager = FileManager.default
    
    var platforms: [String] = []
    
    do {
        let files = try fileManager.contentsOfDirectory(at: platformsPath, includingPropertiesForKeys: nil)
        let jsonFiles = files.filter { $0.pathExtension == "json" }
        platforms = jsonFiles.map { $0.lastPathComponent }
    } catch {
        print("[DeviceUtils.ReadPlatforms] Error eumerating platforms \(error.localizedDescription)")
        return
    }
    
    print("[DeviceUtils.ReadPlatforms] Loaded platforms. Reading data")
    
    var result: [Platform] = []
    
    for platform in platforms {
        let filePath = platformsPath.appendingPathComponent(platform)
        
        if let data = JsonReader<CodablePlatform>.loadData(from: filePath) {
            result.append(Platform(platform: data.platform))
            print("[DeviceUtils.ReadPlatforms] Successfully loaded platform: \(platform)")
        } else {
            print("[DeviceUtils.ReadPlatforms] Error reading platform data: \(platform)")
        }
    }
    
    context.platforms = result
    
    DispatchQueue.main.async {
        context.objectWillChange.send()
    }
}
