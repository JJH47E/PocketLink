//
//  MemoryService.swift
//  Pocket
//
//  Created by JJ Hayter on 03/05/2026.
//

import Foundation

struct MemoryService {
    private static let saveStatesPath = "Memories/Save States"

    func readSaveStates(from deviceRoot: URL) -> [SaveState] {
        let saveStatesURL = deviceRoot.appendingPathComponent(Self.saveStatesPath)
        let fileManager = FileManager.default

        guard fileManager.fileExists(atPath: saveStatesURL.path) else { return [] }

        let coreDirs: [URL]
        do {
            coreDirs = try fileManager.contentsOfDirectory(at: saveStatesURL, includingPropertiesForKeys: [.isDirectoryKey])
                .filter { $0.hasDirectoryPath }
        } catch {
            return []
        }

        var result: [SaveState] = []
        for coreDir in coreDirs {
            let coreName = coreDir.lastPathComponent
            let files: [URL]
            do {
                files = try fileManager.contentsOfDirectory(at: coreDir, includingPropertiesForKeys: nil)
                    .filter { !$0.hasDirectoryPath }
            } catch {
                continue
            }
            for file in files {
                result.append(SaveState(core: coreName, fileName: file.lastPathComponent, path: file))
            }
        }
        return result
    }

    func backupMemories(from deviceRoot: URL, to destination: URL) throws {
        let saveStates = readSaveStates(from: deviceRoot)
        let fileManager = FileManager.default
        for state in saveStates {
            let coreDir = destination.appendingPathComponent(state.core)
            try fileManager.createDirectory(at: coreDir, withIntermediateDirectories: true)
            try fileManager.copyItem(at: state.path, to: coreDir.appendingPathComponent(state.fileName))
        }
    }

    func hasSaveStates(in folder: URL) -> Bool {
        let fileManager = FileManager.default
        guard let subdirs = try? fileManager.contentsOfDirectory(at: folder, includingPropertiesForKeys: [.isDirectoryKey])
            .filter({ $0.hasDirectoryPath }) else { return false }
        for subdir in subdirs {
            let files = (try? fileManager.contentsOfDirectory(at: subdir, includingPropertiesForKeys: nil)
                .filter { !$0.hasDirectoryPath }) ?? []
            if !files.isEmpty { return true }
        }
        return false
    }

    func restoreMemories(from backupFolder: URL, to deviceRoot: URL, overwriteExisting: Bool) throws -> Int {
        let saveStatesURL = deviceRoot.appendingPathComponent(Self.saveStatesPath)
        let fileManager = FileManager.default

        let coreDirs = (try? fileManager.contentsOfDirectory(at: backupFolder, includingPropertiesForKeys: [.isDirectoryKey])
            .filter { $0.hasDirectoryPath }) ?? []

        var count = 0
        for coreDir in coreDirs {
            let destCoreDir = saveStatesURL.appendingPathComponent(coreDir.lastPathComponent)
            try fileManager.createDirectory(at: destCoreDir, withIntermediateDirectories: true)

            let files = (try? fileManager.contentsOfDirectory(at: coreDir, includingPropertiesForKeys: nil)
                .filter { !$0.hasDirectoryPath }) ?? []

            for file in files {
                let dest = destCoreDir.appendingPathComponent(file.lastPathComponent)
                if fileManager.fileExists(atPath: dest.path) {
                    guard overwriteExisting else { continue }
                    try fileManager.removeItem(at: dest)
                }
                try fileManager.copyItem(at: file, to: dest)
                count += 1
            }
        }
        return count
    }
}
