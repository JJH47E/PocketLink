//
//  DeviceContext.swift
//  Pocket
//
//  Created by JJ Hayter on 05/07/2024.
//

import Foundation

let SIZE_UNITS = ["B", "KB", "MB", "GB", "TB"]

class DeviceContext: ObservableObject {
    @Published var deviceConnected: Bool
    @Published var connecting: Bool
    @Published var daSessionFailed: Bool
    @Published var volumeRoute: URL?
    @Published var storageSize: Double?
    @Published var firmwareVersion: String?
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
}
