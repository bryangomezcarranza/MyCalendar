//
//  Create.swift
//  MyCalendar
//
//  Created by Bryan Gomez on 8/31/21.
//

import UIKit
import CloudKit

struct EventStrings {
    static let recordTypeKey = "Task"
    fileprivate static let nameKey = "name"
    fileprivate static let noteKey = "note"
    fileprivate static let dueDateKey = "dueDate"
    fileprivate static let isCompletedKey = "isCompleted"
    fileprivate static let reminderDateKey = "reminderDate"
    fileprivate static let locationKey = "location"
}

class Event {
    var name: String
    var note: String
    var dueDate: Date
    var isCompleted: Int64
    var reminderDate: Date
    var location: String
    var recordID: CKRecord.ID
    
    init(name: String, note: String, dueDate: Date = Date(), isCompleted: Int64 = 0, reminderDate: Date = Date(), location: String, recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)) {
        self.name = name
        self.note = note
        self.dueDate = dueDate
        self.isCompleted = isCompleted
        self.reminderDate = reminderDate
        self.location = location
        self.recordID = recordID
    }
}

//MARK: - Cloud Kit

extension Event {
    convenience init?(ckRecord: CKRecord) {
        guard let name = ckRecord[EventStrings.nameKey] as? String,
              let note = ckRecord[EventStrings.noteKey] as? String,
              let dueDate = ckRecord[EventStrings.dueDateKey] as? Date,
              let isCompleted = ckRecord[EventStrings.isCompletedKey] as? Int64,
              let reminderDate = ckRecord[EventStrings.reminderDateKey] as? Date,
              let location = ckRecord[EventStrings.locationKey] as? String else { return nil }
        
        self.init(name: name, note: note, dueDate: dueDate, isCompleted: isCompleted, reminderDate: reminderDate, location: location, recordID: ckRecord.recordID)
    }
}

extension CKRecord {
    convenience init(event: Event) {
        self.init(recordType: EventStrings.recordTypeKey, recordID: event.recordID)
        
        self.setValuesForKeys([
            EventStrings.nameKey : event.name,
            EventStrings.noteKey : event.note,
            EventStrings.dueDateKey : event.dueDate,
            EventStrings.isCompletedKey : event.isCompleted,
            EventStrings.reminderDateKey : event.reminderDate,
            EventStrings.locationKey : event.location
        ])
    }
}

//MARK: - Equadable

extension Event: Equatable {
    static func == (lhs: Event, rhs: Event) -> Bool {
        return lhs.recordID == rhs.recordID
    }
}
