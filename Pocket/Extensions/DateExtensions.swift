//
//  DateExtensions.swift
//  Pocket
//
//  Created by JJ Hayter on 07/10/2024.
//

import Foundation

extension Date {
    func localizedFormat(dateStyle: DateFormatter.Style = .medium, timeStyle: DateFormatter.Style = .none, locale: Locale = .current) -> String {
        let formatter = DateExtensions.formatter(dateStyle: dateStyle, timeStyle: timeStyle, locale: locale)
        return formatter.string(from: self)
    }
}

private enum DateExtensions {
    private static var cache: [String: DateFormatter] = [:]

    static func formatter(dateStyle: DateFormatter.Style, timeStyle: DateFormatter.Style, locale: Locale) -> DateFormatter {
        let key = "\(dateStyle.rawValue)-\(timeStyle.rawValue)-\(locale.identifier)"
        if let cached = cache[key] { return cached }
        let f = DateFormatter()
        f.dateStyle = dateStyle
        f.timeStyle = timeStyle
        f.locale = locale
        cache[key] = f
        return f
    }
}
