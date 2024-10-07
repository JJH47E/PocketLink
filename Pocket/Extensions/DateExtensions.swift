//
//  DateExtensions.swift
//  Pocket
//
//  Created by JJ Hayter on 07/10/2024.
//

import Foundation

extension Date {
    func localizedFormat(style: DateFormatter.Style = .medium, locale: Locale = .current) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = style
        formatter.timeStyle = style
        formatter.locale = locale
        return formatter.string(from: self)
    }
    
    func localizedFormat(dateStyle: DateFormatter.Style = .medium, timeStyle: DateFormatter.Style = .none, locale: Locale = .current) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = dateStyle
        formatter.timeStyle = timeStyle
        formatter.locale = locale
        return formatter.string(from: self)
    }
}
