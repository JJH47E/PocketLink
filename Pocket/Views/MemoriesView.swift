//
//  MemoriesView.swift
//  Pocket
//
//  Created by JJ Hayter on 03/05/2026.
//

import SwiftUI
import AppKit

struct MemoriesView: View {
    var saveStates: [SaveState]
    var volumeRoot: URL? = nil

    private let memoryService = MemoryService()

    private var groupedByCore: [(String, [SaveState])] {
        let grouped = Dictionary(grouping: saveStates, by: \.core)
        return grouped.keys.sorted().map { ($0, grouped[$0]!) }
    }

    var body: some View {
        List {
            if groupedByCore.isEmpty {
                Text("No memories found.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(groupedByCore, id: \.0) { core, states in
                    Section(header: Text(core)) {
                        ForEach(states) { state in
                            Text(state.fileName)
                        }
                    }
                }
            }
        }
        .toolbar {
            ToolbarItemGroup {
                Button("Backup Memories") {
                    openBackupDialog()
                }
                .disabled(volumeRoot == nil || saveStates.isEmpty)

                Button("Restore Memories") {
                    openRestoreDialog()
                }
                .disabled(volumeRoot == nil)
            }
        }
    }

    // MARK: - Backup

    private func openBackupDialog() {
        guard let root = volumeRoot else { return }
        let panel = NSOpenPanel()
        panel.title = "Select destination for memories backup"
        panel.canCreateDirectories = true
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        guard panel.runModal() == .OK, let dest = panel.url else { return }

        do {
            try memoryService.backupMemories(from: root, to: dest)
        } catch {
            showAlert(title: "Backup Failed", message: error.localizedDescription, style: .warning)
        }
    }

    // MARK: - Restore

    private func openRestoreDialog() {
        guard let root = volumeRoot else { return }
        let panel = NSOpenPanel()
        panel.title = "Select memories backup folder"
        panel.canCreateDirectories = false
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        guard panel.runModal() == .OK, let backupFolder = panel.url else { return }

        guard memoryService.hasSaveStates(in: backupFolder) else {
            showAlert(title: "No Memories Found", message: "No memories found in the selected folder.", style: .warning)
            return
        }

        let overwrite = shouldOverwrite(backupFolder: backupFolder, deviceRoot: root)

        do {
            let count = try memoryService.restoreMemories(from: backupFolder, to: root, overwriteExisting: overwrite)
            showAlert(title: "Restore Complete", message: "\(count) \(count == 1 ? "memory" : "memories") restored.", style: .informational)
        } catch {
            showAlert(title: "Restore Failed", message: error.localizedDescription, style: .warning)
        }
    }

    private func shouldOverwrite(backupFolder: URL, deviceRoot: URL) -> Bool {
        let fileManager = FileManager.default
        let saveStatesURL = deviceRoot.appendingPathComponent("Memories/Save States")
        let coreDirs = (try? fileManager.contentsOfDirectory(at: backupFolder, includingPropertiesForKeys: [.isDirectoryKey])
            .filter { $0.hasDirectoryPath }) ?? []

        for coreDir in coreDirs {
            let destCoreDir = saveStatesURL.appendingPathComponent(coreDir.lastPathComponent)
            let files = (try? fileManager.contentsOfDirectory(at: coreDir, includingPropertiesForKeys: nil)
                .filter { !$0.hasDirectoryPath }) ?? []
            for file in files {
                if fileManager.fileExists(atPath: destCoreDir.appendingPathComponent(file.lastPathComponent).path) {
                    let alert = NSAlert()
                    alert.messageText = "Overwrite existing memories?"
                    alert.informativeText = "Some memories already exist on the device. Do you want to overwrite them?"
                    alert.addButton(withTitle: "Overwrite")
                    alert.addButton(withTitle: "Skip")
                    alert.alertStyle = .warning
                    return alert.runModal() == .alertFirstButtonReturn
                }
            }
        }
        return false
    }

    private func showAlert(title: String, message: String, style: NSAlert.Style) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.alertStyle = style
        alert.runModal()
    }
}

#Preview {
    MemoriesView(saveStates: [
        SaveState(core: "Spiritualized.GBC", fileName: "Pokemon Red.ss0", path: URL(fileURLWithPath: "/tmp/a")),
        SaveState(core: "Spiritualized.GBC", fileName: "Pokemon Blue.ss0", path: URL(fileURLWithPath: "/tmp/b")),
        SaveState(core: "Analogue.Pocket.GB", fileName: "Tetris.ss0", path: URL(fileURLWithPath: "/tmp/c")),
    ])
}
