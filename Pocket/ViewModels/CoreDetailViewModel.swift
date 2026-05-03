//
//  CoreDetailViewModel.swift
//  Pocket
//

import Foundation

enum LoadState {
    case idle
    case loading
    case loaded(String)
    case error(String)
}

@MainActor
class CoreDetailViewModel: ObservableObject {
    @Published var readmeState: LoadState = .idle
    @Published var releaseNotesState: LoadState = .idle

    private let service = GitHubService()
    private var readmeCache: [String: String] = [:]
    private var releaseNotesCache: [String: String] = [:]

    func loadContent(for core: CoreInfo) async {
        guard let (owner, repo) = repoPath(from: core.url) else {
            readmeState = .error("No GitHub repository linked.")
            releaseNotesState = .error("Release notes unavailable — no GitHub repository linked.")
            return
        }
        let key = "\(owner)/\(repo)"

        if let cached = readmeCache[key] {
            readmeState = .loaded(cached)
        } else {
            readmeState = .loading
        }

        if let cached = releaseNotesCache[key] {
            releaseNotesState = .loaded(cached)
        } else {
            releaseNotesState = .loading
        }

        let needsReadme = readmeCache[key] == nil
        let needsRelease = releaseNotesCache[key] == nil
        guard needsReadme || needsRelease else { return }

        let svc = service
        async let readmeFetch = fetchOptional(needsReadme) { try await svc.fetchREADME(owner: owner, repo: repo) }
        async let releaseFetch = fetchOptional(needsRelease) { try await svc.fetchLatestRelease(owner: owner, repo: repo) }
        let (readmeResult, releaseResult) = await (readmeFetch, releaseFetch)

        if let result = readmeResult {
            switch result {
            case .success(let text):
                readmeCache[key] = text
                readmeState = .loaded(text)
            case .failure(let error):
                readmeState = .error(error.localizedDescription)
            }
        }

        if let result = releaseResult {
            switch result {
            case .success(let text):
                releaseNotesCache[key] = text
                releaseNotesState = text.isEmpty ? .loaded("No release notes available.") : .loaded(text)
            case .failure(let error):
                releaseNotesState = .error(error.localizedDescription)
            }
        }
    }

    func repoPath(from url: URL?) -> (owner: String, repo: String)? {
        guard let url, url.host == "github.com" else { return nil }
        let components = url.pathComponents.filter { $0 != "/" }
        guard components.count >= 2 else { return nil }
        return (components[0], components[1])
    }

    private nonisolated func fetchOptional(
        _ needed: Bool,
        _ fetch: () async throws -> String
    ) async -> Result<String, Error>? {
        guard needed else { return nil }
        do { return .success(try await fetch()) }
        catch { return .failure(error) }
    }
}
