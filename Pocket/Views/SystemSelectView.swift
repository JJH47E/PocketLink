//
//  GamesListView.swift
//  Pocket
//
//  Created by JJ Hayter on 08/07/2024.
//

import SwiftUI

struct SystemSelectView: View {
    let platform: Platform
    let mountedDeviceUrl: URL?

    var body: some View {
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
                // need a way to convert long name to short name!
                CoreListView(mountedVolumeUrl: mountedDeviceUrl, platform: "GBC")
            }.frame(maxWidth: .infinity, alignment: .leading).padding(.leading)
        }
    }
}

#Preview {
    SystemSelectView(platform: Platform(name: "Game Boy Advance", manufacturer: "Nintendo", year: "2001"), mountedDeviceUrl: nil)
}
