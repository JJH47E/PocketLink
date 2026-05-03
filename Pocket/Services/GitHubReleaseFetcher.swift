// GitHubReleaseFetcher.swift
// Pocket

import Foundation

struct GitHubReleaseFetcher {
    private static let baseURL = "https://api.github.com/repos"
    private let network = NetworkService()

    func fetchZipDownloadURL(owner: String, repo: String) async throws -> URL {
        guard let url = URL(string: "\(Self.baseURL)/\(owner)/\(repo)/releases/latest") else {
            throw CoreManagerError.networkError(URLError(.badURL))
        }
        let release: GitHubRelease = try await network.fetch(url: url)
        guard let asset = release.zipAsset,
              let downloadURL = URL(string: asset.browserDownloadUrl) else {
            throw CoreManagerError.noZipAsset
        }
        return downloadURL
    }
}
