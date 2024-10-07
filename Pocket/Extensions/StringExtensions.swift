//
//  StringExtensions.swift
//  Pocket
//
//  Created by JJ Hayter on 07/10/2024.
//

import Foundation

extension String {
    func withoutFileExtension() -> String {
        return (self as NSString).deletingPathExtension
    }
}
