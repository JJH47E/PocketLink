// CoreManagerViewModelTests.swift
// PocketTests

import XCTest
@testable import Pocket

final class CoreManagerViewModelTests: XCTestCase {

    @MainActor
    func testLoadCatalogUsesCache() async throws {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: dir) }

        let cores = [makeCatalogCore(id: "agg23.NES", version: "0.9.3")]
        let response = CatalogResponseEncodableTest(data: cores)
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let data = try encoder.encode(response)

        let cache = CatalogCache(cacheDirectory: dir)
        try cache.write(data)

        let vm = CoreManagerViewModelTestable(cache: cache)
        await vm.loadCatalogFromCache()
        XCTAssertEqual(vm.catalogCores.count, 1)
        XCTAssertEqual(vm.catalogCores.first?.id, "agg23.NES")
    }

    @MainActor
    func testComputeUpdatesFindsStaleCore() {
        let vm = CoreManagerViewModel()
        vm.catalogCores = [makeCatalogCore(id: "author.NES", version: "2.0.0")]
        vm.installedCores = [InstalledCore(id: "author.NES", version: "1.0.0", author: "author")]
        vm.computeUpdates()
        XCTAssertEqual(vm.updatableCores.count, 1)
    }

    @MainActor
    func testComputeUpdatesSkipsUninstalledCores() {
        let vm = CoreManagerViewModel()
        vm.catalogCores = [makeCatalogCore(id: "author.GBA", version: "1.0.0")]
        vm.installedCores = []
        vm.computeUpdates()
        XCTAssertTrue(vm.updatableCores.isEmpty)
    }

    // MARK: - Helpers

    private func makeCatalogCore(id: String, version: String) -> CatalogCore {
        let release = CatalogCoreRelease(
            downloadUrl: "https://example.com/core.zip",
            requiresLicense: false,
            core: CatalogReleaseCore(
                metadata: CatalogReleaseMetadata(
                    platformIds: ["nes"],
                    version: version,
                    dateRelease: "2024-01-01"
                )
            )
        )
        return CatalogCore(
            id: id,
            repository: CatalogCoreRepository(platform: "github", owner: "owner", name: "repo"),
            releases: [release]
        )
    }
}

// Encodable wrapper matching the cache format
struct CatalogResponseEncodableTest: Encodable {
    let data: [CatalogCore]
}

// Subclass for injecting a pre-populated cache
@MainActor
final class CoreManagerViewModelTestable: CoreManagerViewModel {
    private let injectedCache: CatalogCache

    init(cache: CatalogCache) {
        self.injectedCache = cache
        super.init()
    }

    func loadCatalogFromCache() async {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        guard let data = injectedCache.read(),
              let response = try? decoder.decode(CatalogResponse.self, from: data) else { return }
        catalogCores = response.data
    }
}
