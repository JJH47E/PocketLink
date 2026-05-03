// CatalogCoreRowView.swift
// Pocket

import SwiftUI

struct CatalogCoreRowView: View {
    let core: CatalogCore
    @ObservedObject var viewModel: CoreManagerViewModel
    @State private var showRemoveAlert = false

    private var installedCore: InstalledCore? {
        viewModel.installedCores.first { $0.id.lowercased() == core.id.lowercased() }
    }
    private var isInstalled: Bool { installedCore != nil }
    private var hasUpdate: Bool { viewModel.updatableCores.contains { $0.id == core.id } }
    private var downloadProgress: Double? { viewModel.installProgress[core.id] }
    private var isDownloading: Bool { downloadProgress != nil }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(core.coreName)
                        .font(.headline)
                    Text("by \(core.author)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    if isInstalled {
                        Label("Installed", systemImage: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundStyle(.green)
                    }
                    if hasUpdate {
                        Label("Update available", systemImage: "arrow.up.circle.fill")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }
                }
            }

            HStack(spacing: 6) {
                Text(core.platform.uppercased())
                    .font(.caption2)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.secondary.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 4))

                if let installed = installedCore {
                    Text("v\(installed.version)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    if hasUpdate {
                        Image(systemName: "arrow.right")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Text("v\(core.latestVersion)")
                            .font(.caption2)
                            .foregroundStyle(.orange)
                    }
                } else {
                    Text("v\(core.latestVersion)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                actionButtons
            }

            if isDownloading, let fraction = downloadProgress {
                ProgressView(value: fraction)
                    .progressViewStyle(.linear)
                    .animation(.linear, value: fraction)
            }
        }
        .padding(.vertical, 6)
        .alert("Remove \(core.coreName)?", isPresented: $showRemoveAlert) {
            Button("Remove", role: .destructive) {
                if let installed = installedCore {
                    Task { await viewModel.remove(core: installed) }
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently delete the core from your SD card and cannot be undone.")
        }
    }

    @ViewBuilder
    private var actionButtons: some View {
        if isDownloading {
            ProgressView()
                .controlSize(.small)
        } else if hasUpdate {
            Button("Update") {
                Task { await viewModel.install(core: core) }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
            Button("Remove", role: .destructive) {
                showRemoveAlert = true
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
        } else if isInstalled {
            Button("Remove", role: .destructive) {
                showRemoveAlert = true
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
        } else {
            Button("Install") {
                Task { await viewModel.install(core: core) }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
        }
    }
}
