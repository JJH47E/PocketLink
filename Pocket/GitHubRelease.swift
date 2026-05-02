// GitHubRelease.swift
// Pocket

import Foundation

struct GitHubAsset: Codable {
    let name: String
    let browserDownloadUrl: String
}

struct GitHubRelease: Codable {
    let tagName: String
    let assets: [GitHubAsset]

    var zipAsset: GitHubAsset? {
        assets.first { $0.name.hasSuffix(".zip") }
    }
}
