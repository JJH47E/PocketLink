//
//  GitHubService.swift
//  Pocket
//

import Foundation

struct GitHubReadmeResponse: Codable {
    let content: String
}

struct GitHubReleaseResponse: Codable {
    let body: String?
}

enum GitHubServiceError: LocalizedError {
    case rateLimitExceeded
    case notFound
    case httpError(Int)
    case decodingFailure

    var errorDescription: String? {
        switch self {
        case .rateLimitExceeded:
            return "GitHub API rate limit exceeded. Please try again later."
        case .notFound:
            return "Not found on GitHub."
        case .httpError(let code):
            return "GitHub API error (HTTP \(code))."
        case .decodingFailure:
            return "Unexpected response from GitHub."
        }
    }
}

struct GitHubService {
    private static let baseURL = "https://api.github.com"

    func fetchREADME(owner: String, repo: String) async throws -> String {
        let url = URL(string: "\(Self.baseURL)/repos/\(owner)/\(repo)/readme")!
        let (data, response) = try await URLSession.shared.data(from: url)
        try validate(response: response)
        guard let decoded = try? JSONDecoder().decode(GitHubReadmeResponse.self, from: data) else {
            throw GitHubServiceError.decodingFailure
        }
        let stripped = decoded.content.components(separatedBy: .newlines).joined()
        guard let bytes = Data(base64Encoded: stripped),
              let text = String(data: bytes, encoding: .utf8) else {
            throw GitHubServiceError.decodingFailure
        }
        return text
    }

    func fetchLatestRelease(owner: String, repo: String) async throws -> String {
        let url = URL(string: "\(Self.baseURL)/repos/\(owner)/\(repo)/releases/latest")!
        let (data, response) = try await URLSession.shared.data(from: url)
        try validate(response: response)
        guard let decoded = try? JSONDecoder().decode(GitHubReleaseResponse.self, from: data) else {
            throw GitHubServiceError.decodingFailure
        }
        return decoded.body ?? ""
    }

    private func validate(response: URLResponse) throws {
        guard let http = response as? HTTPURLResponse else { return }
        switch http.statusCode {
        case 200...299: return
        case 403, 429: throw GitHubServiceError.rateLimitExceeded
        case 404: throw GitHubServiceError.notFound
        default: throw GitHubServiceError.httpError(http.statusCode)
        }
    }
}
