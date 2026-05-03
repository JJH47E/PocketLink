// CatalogCacheTests.swift
// PocketTests

import XCTest
@testable import Pocket

final class CatalogCacheTests: XCTestCase {

    private var cache: CatalogCache!
    private var tempDir: URL!

    override func setUpWithError() throws {
        tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        cache = CatalogCache(cacheDirectory: tempDir)
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: tempDir)
    }

    func testWriteAndReadRoundTrip() throws {
        let data = Data("hello cache".utf8)
        try cache.write(data)
        let read = cache.read()
        XCTAssertEqual(read, data)
    }

    func testCreatesDirectoryIfMissing() throws {
        XCTAssertFalse(FileManager.default.fileExists(atPath: tempDir.path))
        try cache.write(Data("x".utf8))
        XCTAssertTrue(FileManager.default.fileExists(atPath: tempDir.path))
    }

    func testFreshCacheIsDetected() throws {
        try cache.write(Data("x".utf8))
        XCTAssertTrue(cache.isFresh)
    }

    func testStaleCacheIsDetected() throws {
        try cache.write(Data("x".utf8))

        let cacheURL = tempDir.appendingPathComponent("catalog.json")
        let pastDate = Date(timeIntervalSinceNow: -7200)  // 2 hours ago
        try FileManager.default.setAttributes(
            [.modificationDate: pastDate], ofItemAtPath: cacheURL.path
        )
        XCTAssertFalse(cache.isFresh)
    }

    func testInvalidateRemovesFile() throws {
        try cache.write(Data("x".utf8))
        cache.invalidate()
        XCTAssertNil(cache.read())
    }

    func testEmptyCacheIsNotFresh() {
        XCTAssertFalse(cache.isFresh)
    }
}
