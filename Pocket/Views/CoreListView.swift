//
//  CoreListView.swift
//  Pocket
//
//  Created by JJ Hayter on 06/10/2024.
//

import SwiftUI

struct CoreListView: View {
    var mountedVolumeUrl: URL?
    var platform: String
    @State private var isLoading: Bool = true
    @State private var content: [CoreInfo] = []
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
            } else {
                if content.isEmpty {
                    Text("No cores found. It is likely an error occurred.")
                        .padding()
                } else {
                    ScrollView {
                        ForEach(content) { core in
                            CoreListItemView(core: core)
                        }
                    }.frame(minHeight: 150)
                }
            }
        }.onChange(of: platform, initial: true) { _, __ in
            loadContentIfAble()
        }
    }
    
    func loadContentIfAble() {
        if mountedVolumeUrl != nil {
            print("[CoreListView] Loading Core data for platform: \(platform)")
            loadContent()
        } else {
            isLoading.toggle()
            content = []
        }
    }
    
    func loadContent() {
        DispatchQueue.global().async {
            let fetchedData = getCoreDataForPlatform(from: mountedVolumeUrl!, systemName: platform)
            DispatchQueue.main.async {
                content = fetchedData
                isLoading = false
            }
        }
    }
}

#Preview {
    CoreListView(mountedVolumeUrl: nil, platform: "GBA")
}
