//
//  CreateController.swift
//  MyCalendar
//
//  Created by Bryan Gomez on 8/31/21.
//

import Foundation
import CloudKit

class EventController {
    
    static let shared = EventController()
    let notificcationScheduler = NotificationScheduler()
    let database = CKContainer.default().privateCloudDatabase
    
    var events = [Event]()
    
    
    //MARK: - CRUD Functions
    
    func createEvent(with name: String, note: String, dueDate: Date, reminderDate: Date, location: String, completion: @escaping (Result<Event?, EventError>) -> Void) {
        
        let newEvent = Event(name: name, note: note, dueDate: dueDate, reminderDate: reminderDate, location: location)
        let record = CKRecord(event: newEvent)
        
        database.save(record) { record, error in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(.failure(.ckError(error)))
            }
            guard let record = record,
                  let savedEvent = Event(ckRecord: record) else { return completion(.failure(.couldNotUnwrap))}
            print("Saved a contact successfully with id: \(savedEvent.recordID)")
            completion(.success(savedEvent))
        }
        notificcationScheduler.scheduleNotification(for: newEvent)
    }
    
    func fetchEvent(completion: @escaping (Result<[Event], EventError>) -> Void) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: EventStrings.recordTypeKey, predicate: predicate)
        
        database.perform(query, inZoneWith: nil) { records, error in
            
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(.failure(.ckError(error)))
            }
            
            guard let records = records else { return completion(.failure(.couldNotUnwrap))}
            print("Events have been fetched successfully.")
            
            let event = records.compactMap { Event(ckRecord: $0) }
            let sortedContacts = event.sorted(by: { $0.dueDate < $1.dueDate})
            completion(.success(sortedContacts))
        }
    }
    
    func updateEvent(_ event: Event, completion: @escaping (Result<Event?, EventError>) -> Void) {
        
        let record = CKRecord(event: event)
        
        let operation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
        operation.savePolicy = .changedKeys
        operation.qualityOfService = .userInteractive
        operation.modifyRecordsCompletionBlock = { (records, _, error) in
            
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(.failure(.ckError(error)))
            }
            
            guard let record = records?.first,
                  let updateEvent = Event(ckRecord: record) else { return completion(.failure(.couldNotUnwrap))}
            print("Updated contact with a name '\(updateEvent.name)' successfully in your iCloud.")
            completion(.success(updateEvent))
        }
        
        database.add(operation)
        notificcationScheduler.scheduleNotification(for: event)
    }
    
    func delete(_ event: Event, completion: @escaping (Result<Bool, EventError>) -> Void) {
        
        let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: [event.recordID])
        operation.qualityOfService = .userInteractive
        operation.modifyRecordsCompletionBlock = { (records, _, error) in
            
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(.failure(.ckError(error)))
            }
            
            if records?.count == 0 {
                print("Record was successfully deleted from iCloud")
                completion(.success(true))
            } else {
                completion(.failure(.unexpectedRecordsFound))
            }
        }
        
        database.add(operation)
        notificcationScheduler.clearNotifications(for: event)
    }
}
