// CatalogCore.swift
// Pocket

import Foundation

// MARK: - API response wrapper

struct CatalogResponse: Decodable {
    let data: [CatalogCore]
}

// MARK: - Core entry

struct CatalogCore: Codable, Identifiable {
    let id: String                          // e.g. "AwesomeDolphin.SpaceInvaders"
    let repository: CatalogCoreRepository
    let releases: [CatalogCoreRelease]

    var author: String {
        let parts = id.split(separator: ".", maxSplits: 1)
        return parts.isEmpty ? id : String(parts[0])
    }

    var coreName: String {
        guard let dot = id.firstIndex(of: ".") else { return id }
        return String(id[id.index(after: dot)...])
    }

    var latestRelease: CatalogCoreRelease? { releases.first }

    var latestVersion: String {
        latestRelease?.core.metadata.version ?? "unknown"
    }

    var platformIds: [String] {
        latestRelease?.core.metadata.platformIds ?? []
    }

    var platform: String {
        platformIds.first ?? "unknown"
    }

    var downloadURL: URL? {
        guard let urlStr = latestRelease?.downloadUrl else { return nil }
        return URL(string: urlStr)
    }

    var requiresLicense: Bool {
        latestRelease?.requiresLicense ?? false
    }

    var githubOwner: String { repository.owner }
    var githubRepo: String { repository.name }
}

// MARK: - Repository

struct CatalogCoreRepository: Codable {
    let platform: String?
    let owner: String
    let name: String
}

// MARK: - Release

struct CatalogCoreRelease: Codable {
    let downloadUrl: String
    let requiresLicense: Bool
    let core: CatalogReleaseCore
}

struct CatalogReleaseCore: Codable {
    let metadata: CatalogReleaseMetadata
}

struct CatalogReleaseMetadata: Codable {
    let platformIds: [String]
    let version: String
    let dateRelease: String
}
