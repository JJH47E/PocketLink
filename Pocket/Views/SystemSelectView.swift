//
//  GamesListView.swift
//  Pocket
//
//  Created by JJ Hayter on 08/07/2024.
//

import SwiftUI

struct SystemSelectView: View {
    @Environment(\.dismiss) private var dismiss
    
    let platform: Platform
    let mountedDeviceUrl: URL?

    var body: some View {
        NavigationStack {
            VStack {
                Group {
                    Text(platform.name)
                        .font(.title)
                        .padding(EdgeInsets(top: 20, leading: 0, bottom: 0, trailing: 0))
                    Text(platform.manufacturer)
                        .font(.subheadline)
                    Text(platform.year)
                        .font(.subheadline)
                    Divider()
                        .padding(EdgeInsets(top: 20, leading: 0, bottom: 0, trailing: 0))
                    Text("Installed Cores")
                        .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                        .padding(EdgeInsets(top: 20, leading: 0, bottom: 0, trailing: 0))
                    CoreListView(mountedVolumeUrl: mountedDeviceUrl, platform: platform.shortName)
                }.frame(minWidth: 600, maxWidth: .infinity, alignment: .leading).padding(.leading)
            }
            .navigationTitle("System")
                .toolbar {
                    ToolbarItem() {
                        Button("Done") {
                            dismiss()
                        }.buttonStyle(.borderedProminent)
                    }
            }
        }
    }
}

#Preview {
    SystemSelectView(platform: Platform(name: "Game Boy Advance", manufacturer: "Nintendo", year: "2001", shortName: "GBA"), mountedDeviceUrl: nil)
}
