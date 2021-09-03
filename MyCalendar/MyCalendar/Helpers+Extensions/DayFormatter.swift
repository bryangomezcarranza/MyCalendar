//
//  DayFormatter.swift
//  MyCalendar
//
//  Created by Bryan Gomez on 9/2/21.
//

import Foundation

extension Date {
    func formatDay() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: self)
    }
}
