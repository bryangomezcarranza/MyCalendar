//
//  NotificationManger.swift
//  MyCalendar
//
//  Created by Bryan Gomez on 9/23/21.
//

import Foundation
import UserNotifications
import UIKit

class NotificationManager: NSObject {
    
    static let shared = NotificationManager()
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound ]) { authorized, error in
            if let error = error {
                print("There was an error requesting authorization to use notifications. Error \(error)")
            }
            
            if authorized {
                UNUserNotificationCenter.current().delegate = self
                self.setNotificationCategories() // costume actions.
                print("The user authorized notifications")
            } else {
               print("The user declined the use of notifiations")
                
            }
        }
    }
    
    func setNotificationCategories() {
        
        let ignoreAction = UNNotificationAction(identifier: StringConstants.ignoreNotificationActionIdentifier, title: StringConstants.ignore, options: UNNotificationActionOptions(rawValue: 0))
        
        let medicationActionsCategory = UNNotificationCategory(identifier: StringConstants.notificationCategoryIdentifier, actions: [ignoreAction], intentIdentifiers: [], hiddenPreviewsBodyPlaceholder: "", options: .customDismissAction)
        
        UNUserNotificationCenter.current().setNotificationCategories([medicationActionsCategory])
    }
}

//MARK: - Notification Delegate

extension NotificationManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        NotificationCenter.default.post(name: Notification.Name(StringConstants.reminderReceivedNotificationName), object: nil) // posting a message.
        completionHandler([.sound, .banner])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        completionHandler()
    }
}
