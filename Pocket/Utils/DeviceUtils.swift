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
            return
        }

        var result: [Platform] = []
        for file in files {
            if let data = JsonReader<CodablePlatform>.loadData(from: file) {
                result.append(Platform(platform: data.platform, shortName: file.lastPathComponent.withoutFileExtension()))
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

    let cores: [String]
    do {
        let files = try fileManager.contentsOfDirectory(at: coresPath, includingPropertiesForKeys: nil)
        cores = files.filter { $0.pathExtension.lowercased() == systemName.lowercased() }.map { $0.lastPathComponent }
    } catch {
        return []
    }

    return cores.compactMap { core in
        let filePath = coresPath.appendingPathComponent(core).appendingPathComponent("core.json")
        return JsonReader<CodableCoreInfo>.loadData(from: filePath).map { CoreInfo(core: $0.core.metadata) }
    }
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
        return []
    }

    return folders.compactMap { folder in
        let corePath = folder.appendingPathComponent("core.json")
        guard let data = JsonReader<CodableCoreInfo>.loadData(from: corePath) else { return nil }
        let meta = data.core.metadata
        return InstalledCore(id: folder.lastPathComponent, version: meta.version, author: meta.author)
    }
}

func readGames(from path: URL) -> [Game] {
    func savePathIfExists(gamePath: URL, fileManager: FileManager) -> URL? {
        var components = gamePath.pathComponents
        guard let index = components.lastIndex(of: "Assets") else { return nil }
        components[index] = "Saves"
        var newPath = NSString.path(withComponents: components)
        newPath = (newPath as NSString).deletingPathExtension
        newPath = (newPath as NSString).appendingPathExtension("sav")!
        let newUrl = URL(fileURLWithPath: newPath, isDirectory: gamePath.hasDirectoryPath)
        return fileManager.fileExists(atPath: newUrl.path) ? newUrl : nil
    }

    let gamesPath = path.appendingPathComponent("Assets")
    let fileManager = FileManager.default

    var result: [Game] = []

    do {
        let systems = try fileManager.contentsOfDirectory(at: gamesPath, includingPropertiesForKeys: nil)
        for romPlatform in systems {
            let platformAssetsPath = romPlatform.appendingPathComponent("common")
            let games = try fileManager.contentsOfDirectory(at: platformAssetsPath, includingPropertiesForKeys: nil)
            let platformGames = games
                .filter { !$0.hasDirectoryPath }
                .map { Game(name: $0.lastPathComponent, platform: romPlatform.lastPathComponent, path: $0, savePath: savePathIfExists(gamePath: $0, fileManager: fileManager)) }
            result.append(contentsOf: platformGames)
        }
    } catch {
        return []
    }

    return result
}
