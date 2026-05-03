// CoreManagerError.swift
// Pocket

import Foundation

enum CoreManagerError: LocalizedError {
    case networkError(Error)
    case rateLimitExceeded
    case noZipAsset
    case extractionFailed(String)
    case sdCardWriteFailed(Error)
    case sdCardNotMounted

    var errorDescription: String? {
        switch self {
        case .networkError(let e): return "Network error: \(e.localizedDescription)"
        case .rateLimitExceeded: return "GitHub API rate limit exceeded. Please try again in one hour."
        case .noZipAsset: return "This core has no ZIP release asset and cannot be installed automatically."
        case .extractionFailed(let detail): return "Extraction failed: \(detail)"
        case .sdCardWriteFailed(let e): return "SD card write failed: \(e.localizedDescription)"
        case .sdCardNotMounted: return "No SD card is mounted. Please connect your Pocket device."
        }
    }
}
