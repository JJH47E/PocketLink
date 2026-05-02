//
//  FilesystemUtils.swift
//  Pocket
//
//  Created by JJ Hayter on 05/07/2024.
//

import Foundation
import AppKit

func getVolumePath(for volumeName: String) -> URL? {
    let path = "/Volumes/\(volumeName)"
    return URL(string: path)
}

func copyFile(source: URL, destination: URL) throws {
    try FileManager.default.copyItem(at: source, to: destination)
}

func fileURL(from path: String) -> URL {
    return URL(fileURLWithPath: path)
}

func openFinder(at url: URL) {
    NSWorkspace.shared.activateFileViewerSelecting([url])
}
