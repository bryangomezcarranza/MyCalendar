//
//  StringDateFormatter.swift
//  MyCalendar
//
//  Created by Bryan Gomez on 9/5/21.
//

import Foundation

extension String {
    func toDate(withFormat format: String = "MMM d, yyyy  h:mm a" ) -> Date {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = format
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .short
    guard let date = dateFormatter.date(from: self) else {
      preconditionFailure("Take a look to your format")
    }
    return date
  }
}
