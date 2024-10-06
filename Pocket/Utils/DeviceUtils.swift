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

func getCoreDataForPlatform(from path: URL, systemName: String) -> [CoreInfo] {
    let coresPath = path.appendingPathComponent("Cores")
    let fileManager = FileManager.default
    
    var cores: [String] = []
    
    do {
        let files = try fileManager.contentsOfDirectory(at: coresPath, includingPropertiesForKeys: nil)
        let filteredCores = files.filter { $0.pathExtension.lowercased() == systemName.lowercased() }
        cores = filteredCores.map { $0.lastPathComponent }
    } catch {
        print("[DeviceUtils.GetCoreDataForPlatform] Error eumerating cores \(error.localizedDescription)")
        return []
    }
    
    print("[DeviceUtils.GetCoreDataForPlatform] Loaded Cores. Reading data")
    
    var result: [CoreInfo] = []
    
    for core in cores {
        let filePath = coresPath.appendingPathComponent(core).appendingPathExtension("core.json")
        
        if let data = JsonReader<CodableCoreInfo>.loadData(from: filePath) {
            result.append(CoreInfo(core: data.core.metadata))
            print("[DeviceUtils.GetCoreDataForPlatform] Successfully loaded core: \(core)")
        } else {
            print("[DeviceUtils.GetCoreDataForPlatform] Error reading core data: \(core)")
        }
    }
    
    return result
}
