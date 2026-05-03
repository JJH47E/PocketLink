//
//  SaveState.swift
//  Pocket
//
//  Created by JJ Hayter on 03/05/2026.
//

import Foundation

struct SaveState: Identifiable {
    let id: UUID
    let core: String
    let fileName: String
    let path: URL

    init(core: String, fileName: String, path: URL) {
        self.id = UUID()
        self.core = core
        self.fileName = fileName
        self.path = path
    }
}
