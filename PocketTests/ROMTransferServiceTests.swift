// ROMTransferServiceTests.swift
// PocketTests

import XCTest
@testable import Pocket

final class ROMTransferServiceTests: XCTestCase {
    private let service = ROMTransferService()

    private func platform(shortName: String) -> Platform {
        Platform(name: "Test", manufacturer: "Test", year: "2000", shortName: shortName)
    }

    func testKnownExtensionResolvesToInstalledPlatform() {
        let url = URL(fileURLWithPath: "/tmp/game.gb")
        let platforms = [platform(shortName: "gb")]
        let result = service.resolvedPlatform(for: url, availablePlatforms: platforms)
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.shortName, "gb")
    }

    func testKnownExtensionWithMissingPlatformReturnsNil() {
        let url = URL(fileURLWithPath: "/tmp/game.gb")
        let platforms = [platform(shortName: "gba")]
        XCTAssertNil(service.resolvedPlatform(for: url, availablePlatforms: platforms))
    }

    func testUnknownExtensionReturnsNil() {
        let url = URL(fileURLWithPath: "/tmp/game.xyz")
        let platforms = [platform(shortName: "gb"), platform(shortName: "gba")]
        XCTAssertNil(service.resolvedPlatform(for: url, availablePlatforms: platforms))
    }

    func testExtensionMatchIsCaseInsensitive() {
        let url = URL(fileURLWithPath: "/tmp/game.GBA")
        let platforms = [platform(shortName: "gba")]
        XCTAssertNotNil(service.resolvedPlatform(for: url, availablePlatforms: platforms))
    }

    func testAlternateExtensionMapsSameShortName() {
        let sfc = URL(fileURLWithPath: "/tmp/game.sfc")
        let smc = URL(fileURLWithPath: "/tmp/game.smc")
        let platforms = [platform(shortName: "snes")]
        XCTAssertEqual(service.resolvedPlatform(for: sfc, availablePlatforms: platforms)?.shortName, "snes")
        XCTAssertEqual(service.resolvedPlatform(for: smc, availablePlatforms: platforms)?.shortName, "snes")
    }
}
