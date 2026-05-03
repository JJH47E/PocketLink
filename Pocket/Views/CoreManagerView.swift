// CoreManagerView.swift
// Pocket

import SwiftUI

struct CoreManagerView: View {
    @StateObject private var viewModel = CoreManagerViewModel()
    let volumeRoute: URL?

    @State private var selectedPlatform: String = "All"

    private var platforms: [String] {
        var seen = Set<String>()
        let all = viewModel.catalogCores.flatMap { $0.platformIds.map { $0.uppercased() } }
        return ["All"] + all.filter { seen.insert($0).inserted }.sorted()
    }

    private var filteredCores: [CatalogCore] {
        guard selectedPlatform != "All" else { return viewModel.catalogCores }
        return viewModel.catalogCores.filter {
            $0.platformIds.map { $0.uppercased() }.contains(selectedPlatform)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            if viewModel.isLoadingCatalog {
                ProgressView("Loading catalog…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                platformPicker

                ScrollView {
                    if !viewModel.updatableCores.isEmpty {
                        updatesSection
                        Divider().padding(.horizontal)
                    }

                    catalogSection
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .alert("Error", isPresented: .init(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .onAppear {
            viewModel.volumeRoute = volumeRoute
            viewModel.loadInstalledCores()
            Task { await viewModel.loadCatalog() }
        }
        .toolbar {
            ToolbarItem {
                Button {
                    Task { await viewModel.reloadCatalog() }
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .disabled(viewModel.isLoadingCatalog)
            }
        }
    }

    // MARK: - Platform Picker

    private var platformPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(platforms, id: \.self) { platform in
                    Button(platform) {
                        selectedPlatform = platform
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    .tint(selectedPlatform == platform ? .accentColor : .secondary)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }

    // MARK: - Updates Section

    private var updatesSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Updates Available")
                    .font(.headline)
                    .padding(.horizontal)
                    .padding(.top, 12)
                Spacer()
                Button("Update All") {
                    Task { await viewModel.updateAll() }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
                .padding(.horizontal)
                .padding(.top, 12)
                .disabled(viewModel.updatableCores.isEmpty)
            }
            ForEach(viewModel.updatableCores) { core in
                CatalogCoreRowView(core: core, viewModel: viewModel)
                    .padding(.horizontal)
                Divider().padding(.horizontal)
            }
        }
    }

    // MARK: - Catalog Section

    private var catalogSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("All Cores")
                .font(.headline)
                .padding(.horizontal)
                .padding(.top, 12)

            if filteredCores.isEmpty {
                Text("No cores found for the selected platform.")
                    .foregroundStyle(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity)
            } else {
                ForEach(filteredCores) { core in
                    CatalogCoreRowView(core: core, viewModel: viewModel)
                        .padding(.horizontal)
                    Divider().padding(.horizontal)
                }
            }
        }
    }
}

#Preview {
    CoreManagerView(volumeRoute: nil)
}
