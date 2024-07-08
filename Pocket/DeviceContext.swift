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
    @Published var volumeRoute: URL?
    @Published var storageSize: Double?
    @Published var firmwareVersion: String?
    @Published var cores: [String]

    init(firmwareVersion version: String? = nil, volumeRoute route: URL? = nil, storageSize: Double? = nil, cores: [String] = []) {
        self.deviceConnected = false
        self.firmwareVersion = version
        self.volumeRoute = route
        self.storageSize = storageSize
        self.cores = cores
    }
    
    func getPrettyStorageCapacity() -> String? {
        if (storageSize == nil) {
            return nil
        }
        
        var storageCapacity = self.storageSize!
        var scaleCounter = 0
        
        repeat {
            storageCapacity /= 1000
            scaleCounter += 1
        } while (storageCapacity > 1000)
        
        return "\(Int(round(storageCapacity)))\(SIZE_UNITS[scaleCounter])"
    }
}
