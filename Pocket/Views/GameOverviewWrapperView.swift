//
//  GameOverviewWrapperView.swift
//  Pocket
//
//  Created by JJ Hayter on 08/10/2024.
//

import SwiftUI

struct GameOverviewWrapperView: View {
    var mountedVolumeUrl: URL?
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
                    GamesOverviewView(games: content)
                }
            }
        }.onAppear() {
            loadContentIfAble()
        }
    }
    
    func loadContentIfAble() {
        if mountedVolumeUrl != nil {
            print("[GameOverviewWrapperView] Loading game data")
            loadContent()
        } else {
            isLoading.toggle()
            content = []
        }
    }
    
    func loadContent() {
        DispatchQueue.global().async {
            let fetchedData = readGames(from: mountedVolumeUrl!)
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
