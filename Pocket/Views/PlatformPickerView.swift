//
//  PlatformPickerView.swift
//  Pocket
//

import SwiftUI

struct PlatformPickerView: View {
    let platforms: [Platform]
    let onSelect: (Platform?) -> Void

    @State private var selectedPlatform: Platform?

    var body: some View {
        VStack(spacing: 0) {
            List(platforms, selection: $selectedPlatform) { platform in
                Text(platform.name).tag(platform)
            }
            .frame(minWidth: 280, minHeight: 200)
            HStack {
                Button("Cancel") { onSelect(nil) }
                Spacer()
                Button("Add") { onSelect(selectedPlatform) }
                    .disabled(selectedPlatform == nil)
                    .keyboardShortcut(.defaultAction)
            }
            .padding()
        }
        .frame(minWidth: 300, minHeight: 260)
    }
}
