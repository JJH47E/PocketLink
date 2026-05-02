// CoreRemovalTests.swift
// PocketTests

import XCTest
@testable import Pocket

final class CoreRemovalTests: XCTestCase {

    private var tempDir: URL!
    private var coresDir: URL!
    private let installer = CoreInstaller()

    override func setUpWithError() throws {
        tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        coresDir = tempDir.appendingPathComponent("Cores")
        try FileManager.default.createDirectory(at: coresDir, withIntermediateDirectories: true)
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: tempDir)
    }

    func testRemoveExistingCoreSucceeds() throws {
        let coreFolder = coresDir.appendingPathComponent("author.NES")
        try FileManager.default.createDirectory(at: coreFolder, withIntermediateDirectories: true)
        XCTAssertTrue(FileManager.default.fileExists(atPath: coreFolder.path))

        try installer.removeCoreFolder(coreIdentifier: "author.NES", volumeRoute: tempDir)
        XCTAssertFalse(FileManager.default.fileExists(atPath: coreFolder.path))
    }

    func testRemoveMissingCoreTreatedAsSuccess() throws {
        // Should not throw when folder does not exist
        XCTAssertNoThrow(
            try installer.removeCoreFolder(coreIdentifier: "author.Missing", volumeRoute: tempDir)
        )
    }
}
