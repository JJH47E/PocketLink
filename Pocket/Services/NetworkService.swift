// NetworkService.swift
// Pocket

import Foundation

struct NetworkService {
    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.keyDecodingStrategy = .convertFromSnakeCase
        return d
    }()

    func fetch<T: Decodable>(url: URL) async throws -> T {
        let data = try await fetchRaw(url: url)
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw CoreManagerError.networkError(error)
        }
    }

    func fetchRaw(url: URL) async throws -> Data {
        let (data, response) = try await URLSession.shared.data(from: url)
        try validateResponse(response)
        return data
    }

    private func validateResponse(_ response: URLResponse) throws {
        guard let http = response as? HTTPURLResponse else { return }
        switch http.statusCode {
        case 200...299: return
        case 403, 429: throw CoreManagerError.rateLimitExceeded
        default: throw CoreManagerError.networkError(URLError(.badServerResponse))
        }
    }
}
