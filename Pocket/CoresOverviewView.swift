//
//  CoresOverviewView.swift
//  Pocket
//
//  Created by JJ Hayter on 08/07/2024.
//

import SwiftUI

struct CoresOverviewView: View {
    var platforms: [Platform]
    @State private var selectedPlatform: Platform.ID?
    
    var body: some View {
        NavigationSplitView {
            Table(platforms, selection: $selectedPlatform) {
                TableColumn("Platform", value: \.name)
                TableColumn("Manufacturer") { platform in
                    Text(String(platform.manufacturer))
                }
            }
            .navigationTitle("Platforms")
        } detail: {
            if let sp = selectedPlatform {
                GamesListView(platform: platforms[0])
            } else {
                Text("Select a Platform")
                    .foregroundColor(.gray)
            }
        }
    }
}

#Preview {
    CoresOverviewView(platforms: [
        Platform(id: UUID(), name: "Game Boy Advance", manufacturer: "Nintendo", releaseYear: "2001"),
        Platform(id: UUID(), name: "Super Nintendo Entertainment System", manufacturer: "Nintendo", releaseYear: "1991"),
    ])
}
