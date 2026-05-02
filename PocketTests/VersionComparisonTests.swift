// VersionComparisonTests.swift
// PocketTests

import XCTest
@testable import Pocket

final class VersionComparisonTests: XCTestCase {

    private let vm = CoreManagerViewModel()

    func testParseSimpleVersion() {
        XCTAssertEqual(vm.parseVersion("1.2.3"), [1, 2, 3])
    }

    func testParseVersionWithVPrefix() {
        XCTAssertEqual(vm.parseVersion("v1.2.3"), [1, 2, 3])
    }

    func testParsePartialVersion() {
        XCTAssertEqual(vm.parseVersion("2.0"), [2, 0])
    }

    func testCatalogVersionIsNewer() {
        let catalog = makeCatalogCore(id: "author.Core", version: "1.1.0")
        let installed = InstalledCore(id: "author.Core", version: "1.0.0", author: "author")
        let vm = CoreManagerViewModel()
        vm.catalogCores = [catalog]
        vm.installedCores = [installed]
        vm.computeUpdates()
        XCTAssertFalse(vm.updatableCores.isEmpty)
    }

    func testNoUpdateWhenVersionsMatch() {
        let catalog = makeCatalogCore(id: "author.Core", version: "1.0.0")
        let installed = InstalledCore(id: "author.Core", version: "1.0.0", author: "author")
        let vm = CoreManagerViewModel()
        vm.catalogCores = [catalog]
        vm.installedCores = [installed]
        vm.computeUpdates()
        XCTAssertTrue(vm.updatableCores.isEmpty)
    }

    func testCatalogVersionIsOlderThanInstalled() {
        let catalog = makeCatalogCore(id: "author.Core", version: "0.9.0")
        let installed = InstalledCore(id: "author.Core", version: "1.0.0", author: "author")
        let vm = CoreManagerViewModel()
        vm.catalogCores = [catalog]
        vm.installedCores = [installed]
        vm.computeUpdates()
        XCTAssertTrue(vm.updatableCores.isEmpty)
    }

    // MARK: - Helper

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
            repository: CatalogCoreRepository(platform: "github", owner: "author", name: "repo"),
            releases: [release]
        )
    }
}
