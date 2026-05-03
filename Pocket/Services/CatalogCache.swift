// CatalogCache.swift
// Pocket

import Foundation

struct CatalogCache {
    private static let ttl: TimeInterval = 3600  // 1 hour
    private let cacheURL: URL

    init() {
        let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let dir = caches.appendingPathComponent("com.pocket.app")
        cacheURL = dir.appendingPathComponent("catalog.json")
    }

    init(cacheDirectory: URL) {
        cacheURL = cacheDirectory.appendingPathComponent("catalog.json")
    }

    var isFresh: Bool {
        guard let attrs = try? FileManager.default.attributesOfItem(atPath: cacheURL.path),
              let modified = attrs[.modificationDate] as? Date else { return false }
        return Date().timeIntervalSince(modified) < Self.ttl
    }

    func read() -> Data? {
        try? Data(contentsOf: cacheURL)
    }

    func write(_ data: Data) throws {
        try ensureDirectory()
        try data.write(to: cacheURL, options: .atomic)
    }

    func invalidate() {
        try? FileManager.default.removeItem(at: cacheURL)
    }

    private func ensureDirectory() throws {
        let dir = cacheURL.deletingLastPathComponent()
        if !FileManager.default.fileExists(atPath: dir.path) {
            try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }
    }
}
