//
//  Item.swift
//  Pocket
//
//  Created by JJ Hayter on 05/07/2024.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
