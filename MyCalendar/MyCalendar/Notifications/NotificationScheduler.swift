//
//  NotificationScheduler.swift
//  MyCalendar
//
//  Created by Bryan Gomez on 9/21/21.
//

import Foundation
import UserNotifications
import CloudKit

class NotificationScheduler {
    
    func scheduleNotification(for event: Event) {
        
        clearNotifications(for: event)
        
        let timeOfDay = event.reminderDate
        let identifier = event.recordID.recordName
        
        let content = UNMutableNotificationContent()
        content.title = "\(event.name)"
        content.body = "Starts on \(event.dueDate.formatDueDate())"
        content.sound = .default
        content.userInfo = [StringConstants.eventID : identifier]
        content.categoryIdentifier = StringConstants.eventReminderCategoryIdentifier
        
        let fireDateComponent = Calendar.current.dateComponents([.hour, .minute, .day], from: timeOfDay)
        let trigger = UNCalendarNotificationTrigger(dateMatching: fireDateComponent, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Unable to add notification request. Error \(error.localizedDescription)")
            }
        }
    }
    
    func clearNotifications(for event: Event) {
        let identifier = event.recordID.recordName
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
}
