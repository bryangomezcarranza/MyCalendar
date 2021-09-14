//
//  DateFormatter.swift
//  MyCalendar
//
//  Created by Bryan Gomez on 8/31/21.
//

import Foundation

extension Date {
    func formatDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
}
