//
//  DayFormatter.swift
//  MyCalendar
//
//  Created by Bryan Gomez on 9/2/21.
//

import Foundation

extension Date {
    
    func formatDay() -> String {
        return formatted(.dateTime.month(.abbreviated).day().year())
    }
}

extension Date {
    func formatDueDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
}

extension Date {
    func formatDate() -> String {
        return formatted(.dateTime.hour().minute())
    }
}
