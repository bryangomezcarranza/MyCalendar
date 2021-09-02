//
//  EventTaskError.swift
//  MyCalendar
//
//  Created by Bryan Gomez on 8/31/21.
//

import Foundation

enum EventError: LocalizedError {
    
    case ckError(Error)
    case couldNotUnwrap
    case unexpectedRecordsFound
    
    var errorDescription: String? {
        switch self {
        case .ckError(let error):
            return error.localizedDescription
        case .couldNotUnwrap:
            return "Unable to get this Event/Task"
        case .unexpectedRecordsFound:
            return "Looks like we tried to delete records but had an issue."
        }
    }
}
