//
//  Platform.swift
//  Pocket
//
//  Created by JJ Hayter on 08/07/2024.
//

import Foundation

struct Platform: Identifiable, Hashable {
    let id: UUID
    let name: String
    let manufacturer: String
    let releaseYear: String
    let games = ["Test", "Test2"]
    
    init(id: UUID, name: String, manufacturer: String, releaseYear: String) {
        self.id = id
        self.name = name
        self.manufacturer = manufacturer
        self.releaseYear = releaseYear
    }
}
