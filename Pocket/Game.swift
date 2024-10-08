//
//  Game.swift
//  Pocket
//
//  Created by JJ Hayter on 08/10/2024.
//

import Foundation

struct Game: Identifiable, Hashable {
    let id: UUID
    let name: String
    let displayName: String
    let platform: String
    let path: URL
    let savePath: URL?
    
    init(name: String, platform: String, path: URL, savePath: URL?) {
        self.id = UUID()
        self.name = name
        self.displayName = name.withoutFileExtension()
        self.platform = platform
        self.path = path
        self.savePath = savePath
    }
}
