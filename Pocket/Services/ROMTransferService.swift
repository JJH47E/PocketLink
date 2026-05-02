//
//  ROMTransferService.swift
//  Pocket
//

import Foundation

struct ROMTransferService {
    private static let extensionHints: [String: String] = [
        "gb":   "gb",
        "gbc":  "gbc",
        "gba":  "gba",
        "nes":  "nes",
        "sms":  "sms",
        "gg":   "gg",
        "sfc":  "snes",
        "smc":  "snes",
        "md":   "genesis",
        "gen":  "genesis",
        "bin":  "genesis",
        "pce":  "pce",
        "ngp":  "ngp",
        "ngc":  "ngp",
        "ws":   "ws",
        "wsc":  "ws",
        "lynx": "lynx"
    ]

    func resolvedPlatform(for fileURL: URL, availablePlatforms: [Platform]) -> Platform? {
        let ext = fileURL.pathExtension.lowercased()
        guard let shortName = Self.extensionHints[ext] else { return nil }
        return availablePlatforms.first { $0.shortName.lowercased() == shortName }
    }

    func copyROM(source: URL, platform: Platform, volumeRoot: URL) throws {
        let destination = volumeRoot
            .appendingPathComponent("Assets")
            .appendingPathComponent(platform.shortName)
            .appendingPathComponent("common")
            .appendingPathComponent(source.lastPathComponent)
        try FileManager.default.copyItem(at: source, to: destination)
    }
}
