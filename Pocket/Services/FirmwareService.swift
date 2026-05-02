//
//  FirmwareService.swift
//  Pocket
//

import Foundation

struct FirmwareService {
    private static let endpoint = URL(string: "https://www.analogue.co/support/pocket/firmware/latest")!

    func fetchLatestVersion() async throws -> String {
        let (data, response) = try await URLSession.shared.data(from: Self.endpoint)
        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            throw URLError(.badServerResponse)
        }
        guard let version = String(data: data, encoding: .utf8).map({ $0.trimmingCharacters(in: .whitespacesAndNewlines) }), !version.isEmpty else {
            throw URLError(.cannotParseResponse)
        }
        return version
    }
}
