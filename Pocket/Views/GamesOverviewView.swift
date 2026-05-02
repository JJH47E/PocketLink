//
//  GamesOverviewView.swift
//  Pocket
//
//  Created by JJ Hayter on 08/10/2024.
//

import SwiftUI
import UniformTypeIdentifiers

struct GamesOverviewView: View {
    var games: [Game]
    var platforms: [Platform] = []
    var volumeRoot: URL? = nil
    var onTransferComplete: () -> Void = {}

    @State private var selectedGame: Game.ID?
    @State private var searchText = ""
    @State private var isDropTargeted = false
    @State private var pickerQueue: [URL] = []
    @State private var showPlatformPicker = false
    @State private var currentPickerURL: URL? = nil

    private var filteredGames: [Game] {
        guard !searchText.isEmpty else { return games }
        let query = searchText.lowercased()
        return games.filter {
            $0.displayName.lowercased().contains(query) || $0.platform.lowercased().contains(query)
        }
    }

    var body: some View {
        VStack {
            Table(of: Game.self, selection: $selectedGame) {
                TableColumn("Platform", value: \.displayName)
                TableColumn("Platform", value: \.platform)
            } rows: {
                ForEach(filteredGames) { game in
                    TableRow(game)
                        .contextMenu {
                            if (game.savePath != nil) {
                                Button("Backup Save") {
                                    openSaveDialog(filePath: game.savePath!)
                                }
                            }
                            Button("Backup ROM") {
                                openSaveDialog(filePath: game.path)
                            }
                        }
                }
            }
            .onDrop(of: [UTType.fileURL], isTargeted: $isDropTargeted) { providers in
                for provider in providers {
                    provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, _ in
                        guard let data = item as? Data,
                              let url = URL(dataRepresentation: data, relativeTo: nil) else { return }
                        DispatchQueue.main.async { processFiles([url]) }
                    }
                }
                return true
            }
            .overlay {
                if isDropTargeted {
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.accentColor, lineWidth: 2)
                        .allowsHitTesting(false)
                }
            }
            HStack {
                Spacer()
                Button() {
                    openBackupAllDialog()
                } label: {
                    Text("Backup All Saves")
                }.disabled(backupAllButtonDisabled()).padding()
            }
        }
        .toolbar {
            ToolbarItem {
                Button("Add Games") { openAddGamesPanel() }
                    .disabled(volumeRoot == nil)
            }
        }
        .searchable(text: $searchText)
        .sheet(isPresented: $showPlatformPicker, onDismiss: showNextPicker) {
            if let url = currentPickerURL {
                PlatformPickerView(platforms: platforms) { selectedPlatform in
                    showPlatformPicker = false
                    if let platform = selectedPlatform {
                        transferFile(url, to: platform)
                    }
                }
            }
        }
    }

    // MARK: - Add Games

    func openAddGamesPanel() {
        let panel = NSOpenPanel()
        panel.title = "Select ROMs to add"
        panel.allowsMultipleSelection = true
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        if panel.runModal() == .OK {
            processFiles(panel.urls)
        }
    }

    func processFiles(_ urls: [URL]) {
        let service = ROMTransferService()
        for url in urls {
            if let platform = service.resolvedPlatform(for: url, availablePlatforms: platforms) {
                transferFile(url, to: platform)
            } else {
                enqueueForPicker(url)
            }
        }
    }

    func transferFile(_ url: URL, to platform: Platform) {
        guard let root = volumeRoot else { return }
        do {
            try ROMTransferService().copyROM(source: url, platform: platform, volumeRoot: root)
            onTransferComplete()
        } catch {
            showTransferError(error.localizedDescription)
        }
    }

    func enqueueForPicker(_ url: URL) {
        pickerQueue.append(url)
        showNextPicker()
    }

    func showNextPicker() {
        guard !showPlatformPicker, let next = pickerQueue.first else { return }
        currentPickerURL = next
        pickerQueue.removeFirst()
        showPlatformPicker = true
    }

    func showTransferError(_ message: String) {
        let alert = NSAlert()
        alert.messageText = "Transfer Failed"
        alert.informativeText = message
        alert.alertStyle = .warning
        alert.runModal()
    }

    // MARK: - Backup (existing)

    func backupAllButtonDisabled() -> Bool {
        for game in games {
            if (game.savePath != nil) {
                return false
            }
        }
        return true
    }

    func openBackupAllDialog() {
        let panel = NSOpenPanel()
        panel.title = "Select destination to copy saves"
        panel.canCreateDirectories = true
        panel.showsTagField = false
        panel.canChooseFiles = false
        panel.canChooseDirectories = true

        if panel.runModal() == .OK, let selectedURL = panel.url {
            for game in games {
                if (game.savePath == nil) {
                    continue
                }
                copyFile(source: game.savePath!, destination: selectedURL.appendingPathComponent(game.savePath!.lastPathComponent))
            }
        }
    }

    func openSaveDialog(filePath: URL) {
        let panel = NSSavePanel()
        panel.title = "Select destination to copy file"
        panel.canCreateDirectories = true
        panel.showsTagField = false
        panel.nameFieldStringValue = filePath.lastPathComponent

        if panel.runModal() == .OK, let selectedURL = panel.url {
            copyFile(source: filePath, destination: selectedURL)
        }
    }
}

#Preview {
    GamesOverviewView(games: [
        Game(name: "Pocket Red", platform: "GBA", path: URL(string: "~/Documents/test.jpg")!, savePath: URL(string: "~/Documents/testSave.jpg")),
        Game(name: "Tecmo Bowl", platform: "NES", path: URL(string: "~/Documents/test.jpg")!, savePath: nil),
        Game(name: "Polyopoly", platform: "BOARD", path: URL(string: "~/Documents/test.jpg")!, savePath: nil)
    ])
}
