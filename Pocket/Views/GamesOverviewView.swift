//
//  GamesOverviewView.swift
//  Pocket
//
//  Created by JJ Hayter on 08/10/2024.
//

import SwiftUI

struct GamesOverviewView: View {
    var games: [Game]
    @State private var selectedGame: Game.ID?
    
    var body: some View {
        Table(of: Game.self, selection: $selectedGame) {
            TableColumn("Platform", value: \.displayName)
            TableColumn("Platform", value: \.platform)
        } rows: {
            ForEach(games) { game in
                TableRow(game)
                    .contextMenu {
                        if (game.savePath != nil) {
                            Button("Backup Save") {
                                openSaveDialog(filePath: game.savePath!)
                            }
                        }
                        Button("Backup ROM") {
                            openSaveDialog(filePath: game.path)
                        }
                    }
            }
        }
    }
    
    func openSaveDialog(filePath: URL) {
        let panel = NSSavePanel()
        panel.title = "Select destination to copy file"
        panel.canCreateDirectories = true
        panel.showsTagField = false
        panel.nameFieldStringValue = filePath.lastPathComponent

        if panel.runModal() == .OK, let selectedURL = panel.url {
            copyFile(source: filePath, destination: selectedURL)
        }
    }
}

#Preview {
    GamesOverviewView(games: [
        Game(name: "Pocket Red", platform: "GBA", path: URL(string: "~/Documents/test.jpg")!, savePath: URL(string: "~/Documents/testSave.jpg")),
        Game(name: "Tecmo Bowl", platform: "NES", path: URL(string: "~/Documents/test.jpg")!, savePath: nil),
        Game(name: "Polyopoly", platform: "BOARD", path: URL(string: "~/Documents/test.jpg")!, savePath: nil)
    ])
}
