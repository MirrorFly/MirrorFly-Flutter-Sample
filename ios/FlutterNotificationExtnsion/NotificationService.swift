//
//  NotificationService.swift
//  FlutterNotificationExtnsion
//
//  Created by User on 20/12/22.
//

import UserNotifications

import FlyXmpp
import FlyCore
import FlyCommon

//let BASE_URL = "https://api-preprod-sandbox.mirrorfly.com/api/v1/"
let BASE_URL = "https://api-uikit-qa.contus.us/api/v1/"
//let LICENSE_KEY = "lu3Om85JYSghcsB6vgVoSgTlSQArL5"
let LICENSE_KEY = "ckIjaccWBoMNvxdbql8LJ2dmKqT5bp"

let CONTAINER_ID = "group.com.mirrorfly.qa"

let IS_LIVE = false

let APP_NAME = "UiKit"

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    
    var notificationIDs = [String]()

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        let payloadType = bestAttemptContent?.userInfo["type"] as? String
        try? ChatSDK.Builder.setAppGroupContainerID(containerID: CONTAINER_ID)
            .isTrialLicense(isTrial: !IS_LIVE)
            .setLicenseKey(key: LICENSE_KEY)
            .setDomainBaseUrl(baseUrl: BASE_URL)
            .buildAndInitialize()
        print("#push-api withContentHandler received")
        if payloadType == "media_call" {
//            NotificationExtensionSupport.shared.didReceiveNotificationRequest(request.content.mutableCopy() as? UNMutableNotificationContent, appName: FlyDefaults.appName, onCompletion: { [self] bestAttemptContent in
//                if FlyDefaults.hideNotificationContent{
//                    bestAttemptContent?.title = FlyDefaults.appName
//                }else{
//                    if let userInfo = bestAttemptContent?.userInfo["message_id"] {
//                        bestAttemptContent?.title = encryptDecryptData(key: userInfo as? String ?? "", data: bestAttemptContent?.title ?? "", encrypt: false)
//                        print("Push Show title: \(bestAttemptContent?.title ?? "") body: \(bestAttemptContent?.body ?? ""), ID - \(userInfo)")
//                    }
//                }
//                self.bestAttemptContent = bestAttemptContent
//                contentHandler(self.bestAttemptContent!)
//            })
        }
        else {
            ChatSDK.Builder.initializeDelegate()
            // Handle Message Push messages
            NotificationMessageSupport.shared.didReceiveNotificationRequest(request.content.mutableCopy() as? UNMutableNotificationContent, onCompletion: { [self] bestAttemptContent in
                FlyLog.DLog(param1: "#notification request ID", param2: "\(request.identifier)")
                let center = UNUserNotificationCenter.current()
                let (messageCount, chatCount) = ChatManager.getUNreadMessageAndChatCount()
                if FlyDefaults.hideNotificationContent{
                    var titleContent = emptyString()
                    if chatCount == 1{
                        titleContent = "\(messageCount) \(messageCount == 1 ? "message" : "messages")"
                    }else{
                        titleContent = "\(messageCount) messages from \(chatCount) chats"
                    }
                    bestAttemptContent?.title = FlyDefaults.appName + " (\(titleContent))"
                    bestAttemptContent?.body = "New Message"
                }else{
                    if let userInfo = bestAttemptContent?.userInfo["message_id"] {
                        print("Push Show title: \(bestAttemptContent?.title ?? "") body: \(bestAttemptContent?.body ?? ""), ID - \(userInfo)")
                        FlyLog.DLog(param1: "NotificationMessageSupport id ", param2: "\(bestAttemptContent?.title ?? "") body: \(bestAttemptContent?.body ?? "")")
                    }
                }
                bestAttemptContent?.badge = messageCount as? NSNumber
                self.bestAttemptContent = bestAttemptContent
                contentHandler(self.bestAttemptContent!)
                FlyDefaults.lastNotificationId = request.identifier
            })
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
    

}
