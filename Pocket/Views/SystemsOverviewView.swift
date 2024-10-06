//
//  CoresOverviewView.swift
//  Pocket
//
//  Created by JJ Hayter on 08/07/2024.
//

import SwiftUI

struct SystemsOverviewView: View {
    // fix bugs with it effecting the top bar
    var platforms: [Platform]
    @State private var selectedPlatform: Platform.ID?
    
    var body: some View {
        HStack {
            Table(platforms, selection: $selectedPlatform) {
                TableColumn("Platform", value: \.name)
                TableColumn("Manufacturer") { platform in
                    Text(String(platform.manufacturer))
                }
            }
            Group {
                if let sp = selectedPlatform {
                    GamesListView(platform: platforms.first {
                        p in p.id == sp
                    }!)
                } else {
                    Text("Select a Platform")
                        .foregroundColor(.gray)
                        .navigationTitle("Platform")
                }
            }.frame(width: 200)
        }
    }
}

#Preview {
    SystemsOverviewView(platforms: [
        Platform(name: "Game Boy Advance", manufacturer: "Nintendo", year: "2001"),
        Platform(name: "Super Nintendo Entertainment System", manufacturer: "Nintendo", year: "1991"),
    ])
}
