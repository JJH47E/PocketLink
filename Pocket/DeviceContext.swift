//
//  DeviceContext.swift
//  Pocket
//
//  Created by JJ Hayter on 05/07/2024.
//

import Foundation

let SIZE_UNITS = ["B", "KB", "MB", "GB", "TB"]

class DeviceContext: ObservableObject {
    @Published var deviceConnected: Bool {
        didSet {
            if !deviceConnected {
                latestFirmwareVersion = nil
            }
        }
    }
    @Published var connecting: Bool
    @Published var daSessionFailed: Bool
    @Published var volumeRoute: URL?
    @Published var storageSize: Double?
    @Published var firmwareVersion: String? {
        didSet {
            if deviceConnected {
                Task { await fetchFirmwareVersion() }
            }
        }
    }
    @Published var latestFirmwareVersion: String? = nil
    @Published var cores: [String]
    @Published var platforms: [Platform] = []

    init(firmwareVersion version: String? = nil, volumeRoute route: URL? = nil, storageSize: Double? = nil, cores: [String] = []) {
        self.deviceConnected = false
        self.connecting = false
        self.daSessionFailed = false
        self.firmwareVersion = version
        self.volumeRoute = route
        self.storageSize = storageSize
        self.cores = cores
    }

    func getPrettyStorageCapacity() -> String? {
        guard let storageSize else { return nil }

        var storageCapacity = storageSize
        var scaleCounter = 0
        let maxIndex = SIZE_UNITS.count - 1

        while storageCapacity >= 1000, scaleCounter < maxIndex {
            storageCapacity /= 1000
            scaleCounter += 1
        }

        return "\(Int(round(storageCapacity)))\(SIZE_UNITS[scaleCounter])"
    }

    func reset() {
        self.connecting = false
        self.deviceConnected = false
        self.daSessionFailed = false
        self.volumeRoute = nil
        self.cores = []
        self.storageSize = nil
    }

    private func isNewerVersion(remote: String, than installed: String) -> Bool {
        let r = remote.split(separator: ".").compactMap { Int($0) }
        let i = installed.split(separator: ".").compactMap { Int($0) }
        let len = max(r.count, i.count)
        for idx in 0..<len {
            let rv = idx < r.count ? r[idx] : 0
            let iv = idx < i.count ? i[idx] : 0
            if rv != iv { return rv > iv }
        }
        return false
    }

    @MainActor
    private func fetchFirmwareVersion() async {
        guard let installed = firmwareVersion else { return }
        do {
            let remote = try await FirmwareService().fetchLatestVersion()
            if isNewerVersion(remote: remote, than: installed) {
                latestFirmwareVersion = remote
            }
        } catch {
            // silent degradation — leave latestFirmwareVersion as nil
        }
    }
}
