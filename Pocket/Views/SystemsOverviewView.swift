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
    @State private var showSheet: Bool = false
    
    var body: some View {
        HStack {
            Table(platforms, selection: $selectedPlatform) {
                TableColumn("Platform", value: \.name)
                TableColumn("Manufacturer", value: \.manufacturer)
                TableColumn("Year", value: \.year)
            }
        }.onChange(of: selectedPlatform) { old, new in
            if new != nil {
                if (!showSheet) {
                    showSheet.toggle()
                }
            }
        }.sheet(isPresented: $showSheet) {
            print("showing sheet")
        } content: {
            SystemSelectView(platform: platforms.first {
                p in p.id == selectedPlatform
            }!, mountedDeviceUrl: mountedDeviceURL)
        }
    }
}

#Preview {
    SystemsOverviewView(platforms: [
        Platform(name: "Game Boy Advance", manufacturer: "Nintendo", year: "2001", shortName: "GBA"),
        Platform(name: "Super Nintendo Entertainment System", manufacturer: "Nintendo", year: "1991", shortName: "SNES"),
    ], mountedDeviceURL: nil)
}
