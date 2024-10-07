//
//  CoreListItemView.swift
//  Pocket
//
//  Created by JJ Hayter on 07/10/2024.
//

import SwiftUI

struct CoreListItemView: View {
    var core: CoreInfo
    
    var body: some View {
        VStack {
            HStack {
                Text(core.author)
                Spacer()
                Text("v\(core.version)")
            }.font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
            Group {
                Text(core.description)
                if (core.dateRelease != nil) {
                    Text(core.dateRelease!.localizedFormat(dateStyle: .long, timeStyle: .none))
                }
            }.font(.title3).frame(maxWidth: .infinity, alignment: .leading)
            if (core.url != nil) {
                HStack {
                    Spacer()
                    Link(destination: core.url!) {
                        Text(core.url!.absoluteString)
                    }
                }
            }
        }.padding()
    }
}

#Preview {
    CoreListItemView(core: CoreInfo(description: "Gameboy Advance", author: "Dummy1", url: URL(string: "https://github.com")!, version: "1.2.1", dateRelease: Date()))
}
