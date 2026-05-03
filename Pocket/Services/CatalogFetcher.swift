// CatalogFetcher.swift
// Pocket

import Foundation

struct CatalogFetcher {
    private static let catalogURL = URL(string: "https://raw.githubusercontent.com/openfpga-cores-inventory/openfpga-cores-inventory.github.io/refs/heads/main/analogue-pocket/api/v3/cores.json")!
    private let network = NetworkService()

    /// Returns both raw JSON bytes (for caching) and decoded cores.
    func fetchCatalog() async throws -> (cores: [CatalogCore], rawData: Data) {
        let data = try await network.fetchRaw(url: Self.catalogURL)
        do {
            let response = try JSONDecoder.snakeCase.decode(CatalogResponse.self, from: data)
            return (response.data, data)
        } catch {
            throw CoreManagerError.networkError(error)
        }
    }
}
