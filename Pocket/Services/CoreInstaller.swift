// CoreInstaller.swift
// Pocket

import Foundation

struct CoreInstaller {

    // MARK: Download

    func downloadZip(from url: URL, progress: @escaping (Double) -> Void) async throws -> URL {
        let (asyncBytes, response) = try await URLSession.shared.bytes(from: url)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw CoreManagerError.networkError(URLError(.badServerResponse))
        }

        let expected = response.expectedContentLength
        let destURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("zip")

        FileManager.default.createFile(atPath: destURL.path, contents: nil)
        let handle = try FileHandle(forWritingTo: destURL)

        var buffer = Data(capacity: 65_536)
        var received: Int64 = 0

        do {
            for try await byte in asyncBytes {
                buffer.append(byte)
                received += 1
                if buffer.count >= 65_536 {
                    try handle.write(contentsOf: buffer)
                    buffer.removeAll(keepingCapacity: true)
                    if expected > 0 {
                        progress(Double(received) / Double(expected))
                    }
                }
            }
            if !buffer.isEmpty {
                try handle.write(contentsOf: buffer)
            }
            try handle.close()
        } catch {
            try? handle.close()
            try? FileManager.default.removeItem(at: destURL)
            throw CoreManagerError.networkError(error)
        }

        progress(1.0)
        return destURL
    }

    // MARK: Extract

    func extractZip(at zipURL: URL, to destination: URL) throws {
        try FileManager.default.createDirectory(at: destination, withIntermediateDirectories: true)

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/unzip")
        process.arguments = ["-o", zipURL.path, "-d", destination.path]

        let pipe = Pipe()
        process.standardError = pipe
        process.standardOutput = pipe

        try process.run()
        process.waitUntilExit()

        guard process.terminationStatus == 0 else {
            let output = String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
            throw CoreManagerError.extractionFailed(output)
        }
    }

    // MARK: Copy to SD card

    func copyToSDCard(extractedFolder: URL, coreIdentifier: String, volumeRoute: URL) throws {
        let coresDir = volumeRoute.appendingPathComponent("Cores")
        let destination = coresDir.appendingPathComponent(coreIdentifier)

        // Remove existing installation if present
        if FileManager.default.fileExists(atPath: destination.path) {
            try FileManager.default.removeItem(at: destination)
        }

        // Look for the core folder inside the extraction result
        let sourceFolder = resolveSourceFolder(in: extractedFolder, coreIdentifier: coreIdentifier)

        do {
            try FileManager.default.moveItem(at: sourceFolder, to: destination)
        } catch {
            // Cross-volume move fails; fall back to copy + delete
            do {
                try FileManager.default.copyItem(at: sourceFolder, to: destination)
                try? FileManager.default.removeItem(at: sourceFolder)
            } catch let copyError {
                throw CoreManagerError.sdCardWriteFailed(copyError)
            }
        }
    }

    private func resolveSourceFolder(in extractedFolder: URL, coreIdentifier: String) -> URL {
        // Try <extractedFolder>/Cores/<coreIdentifier>
        let withCoresPrefix = extractedFolder
            .appendingPathComponent("Cores")
            .appendingPathComponent(coreIdentifier)
        if FileManager.default.fileExists(atPath: withCoresPrefix.path) {
            return withCoresPrefix
        }
        // Try <extractedFolder>/<coreIdentifier>
        let direct = extractedFolder.appendingPathComponent(coreIdentifier)
        if FileManager.default.fileExists(atPath: direct.path) {
            return direct
        }
        // Fall back to the extracted folder itself
        return extractedFolder
    }

    // MARK: Cleanup

    func cleanup(zipURL: URL?, extractionDir: URL?) {
        if let zip = zipURL { try? FileManager.default.removeItem(at: zip) }
        if let dir = extractionDir { try? FileManager.default.removeItem(at: dir) }
    }

    // MARK: Remove

    func removeCoreFolder(coreIdentifier: String, volumeRoute: URL) throws {
        let target = volumeRoute
            .appendingPathComponent("Cores")
            .appendingPathComponent(coreIdentifier)
        guard FileManager.default.fileExists(atPath: target.path) else { return }
        do {
            try FileManager.default.removeItem(at: target)
        } catch {
            throw CoreManagerError.sdCardWriteFailed(error)
        }
    }
}
