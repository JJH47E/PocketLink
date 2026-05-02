//
//  GameOverviewWrapperView.swift
//  Pocket
//
//  Created by JJ Hayter on 08/10/2024.
//

import SwiftUI

struct GameOverviewWrapperView: View {
    var mountedVolumeUrl: URL?
    var platforms: [Platform] = []
    @State private var isLoading: Bool = true
    @State private var content: [Game] = []

    var body: some View {
        VStack {
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
            } else {
                if content.isEmpty {
                    Text("No games found.")
                        .padding()
                } else {
                    GamesOverviewView(
                        games: content,
                        platforms: platforms,
                        volumeRoot: mountedVolumeUrl,
                        onTransferComplete: loadContent
                    )
                }
            }
        }.onAppear() {
            loadContentIfAble()
        }
    }

    func loadContentIfAble() {
        if mountedVolumeUrl != nil {
            loadContent()
        } else {
            isLoading = false
            content = []
        }
    }

    func loadContent() {
        guard let url = mountedVolumeUrl else { return }
        DispatchQueue.global().async {
            let fetchedData = readGames(from: url)
            DispatchQueue.main.async {
                content = fetchedData
                isLoading = false
            }
        }
    }
}

#Preview {
    GameOverviewWrapperView()
}
