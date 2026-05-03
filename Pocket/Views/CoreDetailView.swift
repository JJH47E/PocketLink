//
//  CoreDetailView.swift
//  Pocket
//

import SwiftUI

struct CoreDetailView: View {
    let core: CoreInfo
    @ObservedObject var viewModel: CoreDetailViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    metadataHeader
                    Divider()
                    contentSection(title: "README", state: viewModel.readmeState)
                    Divider()
                    contentSection(title: "Latest Release", state: viewModel.releaseNotesState)
                    if let url = core.url, viewModel.repoPath(from: core.url) != nil {
                        HStack {
                            Spacer()
                            Link("View on GitHub", destination: url)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle(core.description)
            .toolbar {
                ToolbarItem {
                    Button("Done") {
                        dismiss()
                    }.buttonStyle(.borderedProminent)
                }
            }
            .task {
                await viewModel.loadContent(for: core)
            }
        }
    }

    private var metadataHeader: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(core.author)
                Spacer()
                Text("v\(core.version)")
            }.font(.title)
            Text(core.description)
                .font(.title3)
            if let date = core.dateRelease {
                Text(date.localizedFormat(dateStyle: .long, timeStyle: .none))
                    .font(.title3)
            }
        }
    }

    @ViewBuilder
    private func contentSection(title: String, state: LoadState) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            switch state {
            case .idle:
                EmptyView()
            case .loading:
                ProgressView()
            case .loaded(let text):
                if let attributed = try? AttributedString(
                    markdown: text,
                    options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)
                ) {
                    Text(attributed)
                } else {
                    Text(text)
                }
            case .error(let message):
                Text(message)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    CoreDetailView(
        core: CoreInfo(
            description: "Gameboy Advance",
            author: "Spiritualized",
            url: URL(string: "https://github.com/spiritualized1997/openFPGA-GBA")!,
            version: "1.2.1",
            dateRelease: Date()
        ),
        viewModel: CoreDetailViewModel()
    )
}
