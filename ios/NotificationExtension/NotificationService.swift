//
//  NotificationService.swift
//  NotificationService
//
//  Created by Mani Vendhan on 16/07/23.
//

//import UserNotifications
import mirrorfly_plugin

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        MirrorFlyNotification().handleNotification(notificationRequest: request, contentHandler: contentHandler, containerID: "group.com.mirrorfly.flutter", licenseKey: "xxx")
        
    }

    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

}
