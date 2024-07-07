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
