// VersionComparator.swift
// Pocket

import Foundation

enum VersionComparator {
    static func isNewer(_ candidate: String, than current: String) -> Bool {
        let lhs = parseVersion(candidate)
        let rhs = parseVersion(current)
        for i in 0..<max(lhs.count, rhs.count) {
            let l = i < lhs.count ? lhs[i] : 0
            let r = i < rhs.count ? rhs[i] : 0
            if l != r { return l > r }
        }
        return false
    }

    private static func parseVersion(_ version: String) -> [Int] {
        let stripped = version.hasPrefix("v") ? String(version.dropFirst()) : version
        return stripped.split(separator: ".").compactMap { Int($0) }
    }
}
