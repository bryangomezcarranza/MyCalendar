//
//  Create.swift
//  MyCalendar
//
//  Created by Bryan Gomez on 8/31/21.
//

import UIKit
import CloudKit

struct EventStrings {
    static let recordTypeKey = "Create"
    fileprivate static let nameKey = "name"
    fileprivate static let noteKey = "note"
    fileprivate static let dueDateKey = "dueDate"
    fileprivate static let reminderDateKey = "reminderKey"
}

class Event {
    var name: String
    var note: String
    var dueDate: Date
    var isCompleted: Bool
    var reminderDate: Date
    var recordID: CKRecord.ID
    
    init(name: String, note: String, dueDate: Date = Date(), isCompleted: Bool = false, reminderDate: Date = Date(), recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString) ) {
        self.name = name
        self.note = note
        self.dueDate = dueDate
        self.isCompleted = isCompleted
        self.reminderDate = reminderDate
        self.recordID = recordID
    }
}

extension Event {
    convenience init?(ckRecord: CKRecord) {
        guard let name = ckRecord[EventStrings.nameKey] as? String,
              let note = ckRecord[EventStrings.noteKey] as? String,
              let dueDate = ckRecord[EventStrings.dueDateKey] as? Date else { return nil }
        
        self.init(name: name, note: note, dueDate: dueDate, recordID: ckRecord.recordID)
    }
}

extension CKRecord {
    convenience init(event: Event) {
        self.init(recordType: EventStrings.recordTypeKey, recordID: event.recordID)
        
        self.setValuesForKeys([
            EventStrings.nameKey : event.name,
            EventStrings.noteKey : event.note,
            EventStrings.dueDateKey : event.dueDate
        ])
    }
}

//MARK: - Equadable
extension Event: Equatable {
    static func == (lhs: Event, rhs: Event) -> Bool {
        return lhs.recordID == rhs.recordID
    }
}
