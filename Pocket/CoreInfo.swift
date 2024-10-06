//
//  CoreInfo.swift
//  Pocket
//
//  Created by JJ Hayter on 06/10/2024.
//

import Foundation

struct CodableCoreInfo: Decodable {
    let core: CodableCore
    
    init(core: CodableCore) {
        self.core = core
    }
}

struct CodableCore: Decodable {
    let metadata: CodableCoreMetadata
    
    init(metadata: CodableCoreMetadata) {
        self.metadata = metadata
    }
}

struct CodableCoreMetadata: Decodable {
    let description: String
    let author: String
    // maybe try URL?
    let url: String
    let version: String
    let dateRelease: Date
}

struct CoreInfo: Identifiable, Hashable {
    let id: UUID
    let description: String
    let author: String
    let url: String
    let version: String
    let dateRelease: Date
    
    init(core: CodableCoreMetadata) {
        self.id = UUID()
        self.description = core.description
        self.author = core.author
        self.url = core.url
        self.version = core.version
        self.dateRelease = core.dateRelease
    }
    
    init(description: String, author: String, url: String, version: String, dateRelease: Date) {
        self.id = UUID()
        self.description = description
        self.author = author
        self.url = url
        self.version = version
        self.dateRelease = dateRelease
    }
}
