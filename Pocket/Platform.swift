//
//  Platform.swift
//  Pocket
//
//  Created by JJ Hayter on 08/07/2024.
//

import Foundation

struct CodablePlatform: Decodable {
    let platform: CodablePlatformInfo
    
    init(platform: CodablePlatformInfo) {
        self.platform = platform
    }
}

struct CodablePlatformInfo: Decodable {
    let name: String
    let manufacturer: String
    let year: Int
    
    init(name: String, manufacturer: String, year: Int) {
        self.name = name
        self.manufacturer = manufacturer
        self.year = year
    }
}

struct Platform: Identifiable, Hashable {
    let id: UUID
    let name: String
    let manufacturer: String
    let year: String
    let shortName: String
    
    init(platform: CodablePlatformInfo, shortName: String) {
        self.id = UUID()
        self.name = platform.name
        self.manufacturer = platform.manufacturer
        self.year = String(platform.year)
        self.shortName = shortName
    }
    
    init(name: String, manufacturer: String, year: String, shortName: String) {
        self.id = UUID()
        self.name = name
        self.manufacturer = manufacturer
        self.year = year
        self.shortName = shortName
    }
}
