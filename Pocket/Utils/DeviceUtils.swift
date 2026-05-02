//
//  DeviceUtils.swift
//  Pocket
//
//  Created by JJ Hayter on 05/07/2024.
//

import Foundation

func readDeviceInfo(from path: URL, context: DeviceContext) {
    let jsonFilePath = path.appendingPathComponent("Analogue_Pocket.json")

    DispatchQueue.global(qos: .userInitiated).async {
        guard FileManager.default.fileExists(atPath: jsonFilePath.path),
              let deviceInfo = JsonReader<DeviceInfo>.loadData(from: jsonFilePath) else { return }
        let firmwareVersion = deviceInfo.firmware.runtime.name
        DispatchQueue.main.async {
            guard context.deviceConnected else { return }
            context.firmwareVersion = firmwareVersion
        }
    }
}

func readPlatforms(from path: URL, context: DeviceContext) {
    let platformsPath = path.appendingPathComponent("Platforms")
    let fileManager = FileManager.default

    DispatchQueue.global(qos: .userInitiated).async {
        let files: [URL]
        do {
            let all = try fileManager.contentsOfDirectory(at: platformsPath, includingPropertiesForKeys: nil)
            files = all.filter { $0.pathExtension == "json" }
        } catch {
            print("[DeviceUtils.ReadPlatforms] Error eumerating platforms \(error.localizedDescription)")
            return
        }

        print("[DeviceUtils.ReadPlatforms] Loaded platforms. Reading data")

        var result: [Platform] = []
        for file in files {
            if let data = JsonReader<CodablePlatform>.loadData(from: file) {
                result.append(Platform(platform: data.platform, shortName: file.lastPathComponent.withoutFileExtension()))
                print("[DeviceUtils.ReadPlatforms] Successfully loaded platform: \(file.lastPathComponent)")
            } else {
                print("[DeviceUtils.ReadPlatforms] Error reading platform data: \(file.lastPathComponent)")
            }
        }

        DispatchQueue.main.async {
            guard context.deviceConnected else { return }
            context.platforms = result
        }
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
        let filePath = coresPath.appendingPathComponent(core).appendingPathComponent("core.json")
        
        if let data = JsonReader<CodableCoreInfo>.loadData(from: filePath) {
            result.append(CoreInfo(core: data.core.metadata))
            print("[DeviceUtils.GetCoreDataForPlatform] Successfully loaded core: \(core)")
        } else {
            print("[DeviceUtils.GetCoreDataForPlatform] Error reading core data: \(core). Reading file: \(filePath.absoluteString)")
        }
    }
    
    return result
}

func getAllInstalledCores(from path: URL) -> [InstalledCore] {
    let coresPath = path.appendingPathComponent("Cores")
    let fileManager = FileManager.default

    let folders: [URL]
    do {
        folders = try fileManager.contentsOfDirectory(
            at: coresPath, includingPropertiesForKeys: nil
        ).filter { $0.hasDirectoryPath }
    } catch {
        print("[DeviceUtils.GetAllInstalledCores] Error enumerating cores: \(error.localizedDescription)")
        return []
    }

    var result: [InstalledCore] = []
    for folder in folders {
        let identifier = folder.lastPathComponent
        let corePath = folder.appendingPathComponent("core.json")
        if let data = JsonReader<CodableCoreInfo>.loadData(from: corePath) {
            let meta = data.core.metadata
            result.append(InstalledCore(id: identifier, version: meta.version, author: meta.author))
        }
    }
    return result
}

func readGames(from path: URL) -> [Game] {
    func savePathIfExists(gamePath: URL, fileManager: FileManager) -> URL? {
        var components = gamePath.pathComponents
        
        if let index = components.lastIndex(of: "Assets") {
            components[index] = "Saves"
            var newPath = NSString.path(withComponents: components)
            newPath = (newPath as NSString).deletingPathExtension
            newPath = (newPath as NSString).appendingPathExtension("sav")!
            let newUrl = URL(fileURLWithPath: newPath, isDirectory: gamePath.hasDirectoryPath)
            
            if (fileManager.fileExists(atPath: newUrl.path)) {
                print("returning save path")
                return newUrl
            }
        }
        print("no save")
        return nil
    }
    
    let gamesPath = path.appendingPathComponent("Assets")
    let fileManager = FileManager.default
    
    var result: [Game] = []
        
    do {
        let systems = try fileManager.contentsOfDirectory(at: gamesPath, includingPropertiesForKeys: nil)
        for romPlatform in systems {
            let platformAssetsPath = romPlatform.appendingPathComponent("common")
            let games = try fileManager.contentsOfDirectory(at: platformAssetsPath, includingPropertiesForKeys: nil)
            let filteredGames = games.filter { !$0.hasDirectoryPath }
            let platformGames = filteredGames.map { Game(name: $0.lastPathComponent, platform: romPlatform.lastPathComponent, path: $0, savePath: savePathIfExists(gamePath: $0, fileManager: fileManager)) }
            result.append(contentsOf: platformGames)
        }
    } catch {
        print("[DeviceUtils.ReadGames] Error eumerating games \(error.localizedDescription)")
        return []
    }
    
    print("[DeviceUtils.GetCoreDataForPlatform] Loaded games successfully")
    return result
}
