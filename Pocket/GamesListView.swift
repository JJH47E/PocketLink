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
        List(platform.games, id: \.self) { game in
            Text(game)
        }
        .navigationTitle(platform.name)
    }
}

#Preview {
    GamesListView(platform: Platform(id: UUID(), name: "Game Boy Advance", manufacturer: "Nintendo", releaseYear: "2001"))
}
