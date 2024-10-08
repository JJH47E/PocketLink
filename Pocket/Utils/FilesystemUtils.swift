//
//  FilesystemUtils.swift
//  Pocket
//
//  Created by JJ Hayter on 05/07/2024.
//

import Foundation

func getVolumePath(for volumeName: String) -> URL? {
    let path = "/Volumes/\(volumeName)"
    return URL(string: path)
}

func copyFile(source: URL, destination: URL) {
    do {
        try FileManager.default.copyItem(at: source, to: destination)
        print("[CopyFile] File copied successfuly")
    } catch {
        print("[CopyFile] Error copying file from \(source.absoluteString) to \(destination.absoluteString): \(error)")
    }
}
