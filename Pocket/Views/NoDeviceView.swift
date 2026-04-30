//
//  NoDeviceView.swift
//  Pocket
//
//  Created by JJ Hayter on 30/04/2026.
//

import SwiftUI

struct NoDeviceView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image("pocket")
                .resizable()
                .scaledToFit()
                .frame(width: 180, height: 180)

            Image(systemName: "cable.connector")
                .font(.system(size: 36, weight: .light))
                .foregroundStyle(.secondary)

            Text("Connect Your Pocket")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Plug your Analogue Pocket into this Mac via USB to get started.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 300)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    NoDeviceView()
}
