//
//  MemoriesOverviewWrapperView.swift
//  Pocket
//
//  Created by JJ Hayter on 03/05/2026.
//

import SwiftUI

struct MemoriesOverviewWrapperView: View {
    var mountedVolumeUrl: URL?
    @State private var isLoading: Bool = true
    @State private var content: [SaveState] = []

    private let memoryService = MemoryService()

    var body: some View {
        VStack {
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
            } else {
                MemoriesView(saveStates: content, volumeRoot: mountedVolumeUrl)
            }
        }
        .onAppear {
            loadContentIfAble()
        }
    }

    private func loadContentIfAble() {
        if mountedVolumeUrl != nil {
            loadContent()
        } else {
            isLoading = false
            content = []
        }
    }

    private func loadContent() {
        guard let url = mountedVolumeUrl else { return }
        DispatchQueue.global().async {
            let fetched = memoryService.readSaveStates(from: url)
            DispatchQueue.main.async {
                content = fetched
                isLoading = false
            }
        }
    }
}

#Preview {
    MemoriesOverviewWrapperView()
}
