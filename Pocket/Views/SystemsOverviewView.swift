//
//  CoresOverviewView.swift
//  Pocket
//
//  Created by JJ Hayter on 08/07/2024.
//

import SwiftUI

struct SystemsOverviewView: View {
    var platforms: [Platform]
    var mountedDeviceURL: URL?
    @State private var selectedPlatform: Platform.ID?
    
    var body: some View {
        HStack {
            Table(platforms, selection: $selectedPlatform) {
                TableColumn("Platform", value: \.name)
                TableColumn("Manufacturer", value: \.manufacturer)
                TableColumn("Year", value: \.year)
            }
            Group {
                if let sp = selectedPlatform {
                    SystemSelectView(platform: platforms.first {
                        p in p.id == sp
                    }!, mountedDeviceUrl: mountedDeviceURL!)
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
    ], mountedDeviceURL: nil)
}
