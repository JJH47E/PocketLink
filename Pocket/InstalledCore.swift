// InstalledCore.swift
// Pocket

import Foundation

struct InstalledCore: Identifiable, Hashable {
    let id: String         // e.g. "spiritualized.GBA"
    let version: String
    let author: String

    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: InstalledCore, rhs: InstalledCore) -> Bool { lhs.id == rhs.id }
}
