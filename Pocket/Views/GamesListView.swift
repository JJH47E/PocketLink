//
//  GamesListView.swift
//  Pocket
//
//  Created by JJ Hayter on 08/07/2024.
//

import SwiftUI

struct GamesListView: View {
    let platform: Platform

    var body: some View {
        Text(platform.name)
    }
}

#Preview {
    GamesListView(platform: Platform(name: "Game Boy Advance", manufacturer: "Nintendo", year: "2001"))
}
