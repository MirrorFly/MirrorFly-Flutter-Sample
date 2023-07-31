//
//  NotificationService.swift
//  NotificationService
//
//  Created by Mani Vendhan on 16/07/23.
//

import UserNotifications
//import MirrorFlySDK

class NotificationService: UNNotificationServiceExtension {
//
//    var contentHandler: ((UNNotificationContent) -> Void)?
//    var bestAttemptContent: UNMutableNotificationContent?
//
//    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
//        self.contentHandler = contentHandler
//        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
//        NSLog("#Mirrorfly Notification Received")
//        NSLog("#Mirrorfly Received data \(request)")
//        NSLog("#Mirrorfly Received data1 \(request.content)")
//        NSLog("#Mirrorfly Received data2 \(bestAttemptContent)")
//        NSLog("#Mirrorfly Received data3 \(bestAttemptContent?.userInfo)")
//        let payloadType = bestAttemptContent?.userInfo["type"] as? String
//
//
////        FlySdkMethodCalls.handleNotificationExtension(request, withContentHandler: contentHandler)
//
//        try? ChatSDK.Builder.setAppGroupContainerID(containerID: "group.com.mirrorfly.qa")
//            .isTrialLicense(isTrial: true)
//            .setLicenseKey(key: "ckIjaccWBoMNvxdbql8LJ2dmKqT5bp")
//            .setDomainBaseUrl(baseUrl: "https://api-uikit-qa.contus.us/api/v1/")
//            .buildAndInitialize()
//        print("#push-api withContentHandler received")
//        if payloadType == "media_call" {
//            NSLog("#Mirrorfly Media Call")
//            NotificationExtensionSupport.shared.didReceiveNotificationRequest(request.content.mutableCopy() as? UNMutableNotificationContent, appName: FlyDefaults.appName, onCompletion: { [self] bestAttemptContent in
//                if FlyDefaults.hideNotificationContent{
//                    bestAttemptContent?.title = FlyDefaults.appName
//                } else {
//                    if let userInfo = bestAttemptContent?.userInfo["message_id"] {
//                        bestAttemptContent?.title = encryptDecryptData(key: userInfo as? String ?? "", data: bestAttemptContent?.title ?? "", encrypt: false)
//                        print("Push Show title: \(bestAttemptContent?.title ?? "") body: \(bestAttemptContent?.body ?? ""), ID - \(userInfo)")
//                    }
//                }
//                self.bestAttemptContent = bestAttemptContent
//                contentHandler(self.bestAttemptContent!)
//            })
//        } else if payloadType == "adminblock" {
//            NSLog("#Mirrorfly Admin Block")
//            ChatSDK.Builder.initializeDelegate()
//            NotificationMessageSupport.shared.handleAdminBlockNotification(request.content.mutableCopy() as? UNMutableNotificationContent) {  bestAttemptContent in
//                contentHandler(bestAttemptContent!)
//            }
//        } else {
//            NSLog("#Mirrorfly Handle Push")
//
//            /// Handle Push messages
//            ChatSDK.Builder.initializeDelegate()
//            NotificationMessageSupport.shared.didReceiveNotificationRequest(request.content.mutableCopy() as? UNMutableNotificationContent, onCompletion: { [self] bestAttemptContents in
//                FlyLog.DLog(param1: "#notification request ID", param2: "\(request.identifier)")
//                let center = UNUserNotificationCenter.current()
//                let (messageCount, chatCount) = ChatManager.getUnreadMessageAndChatCountForUnmutedUsers()
//                if FlyDefaults.hideNotificationContent{
//                    var titleContent = emptyString()
//                    if chatCount == 1{
//                        titleContent = "\(messageCount) \(messageCount == 1 ? "message" : "messages")"
//                    } else {
//                        titleContent = "\(messageCount) messages from \(chatCount) chats"
//                    }
//                    bestAttemptContents?.title = FlyDefaults.appName + " (\(titleContent))"
//                    bestAttemptContents?.body = "New Message"
//                } else {
//                    if let userInfo = bestAttemptContents?.userInfo["message_id"] {
//                        print("Push Show title: \(bestAttemptContents?.title ?? "") body: \(bestAttemptContents?.body ?? ""), ID - \(userInfo)")
//                        FlyLog.DLog(param1: "NotificationMessageSupport id ", param2: "\(bestAttemptContents?.title ?? "") body: \(bestAttemptContents?.body ?? "")")
//                    }
//                }
//                var canVibrate = true
//                let isMuted = ContactManager.shared.getUserProfileDetails(for: bestAttemptContents?.userInfo["from_user"] as? String ?? "")?.isMuted ?? false
//                if !isMuted || !(FlyDefaults.isArchivedChatEnabled && ChatManager.getRechtChat(jid: bestAttemptContents?.userInfo["from_user"] as? String ?? "")?.isChatArchived ?? false){
//                    bestAttemptContents?.badge = messageCount as? NSNumber
//                }
//
//                let chatType = (bestAttemptContents?.userInfo["chat_type"] as? String ?? "")
//                let messageId = (self.bestAttemptContent?.userInfo["message_id"] as? String ?? "").components(separatedBy: ",").last ?? ""
//
//                self.bestAttemptContent = bestAttemptContents
//
//                if ChatManager.getMessageOfId(messageId: messageId)?.senderUserJid == FlyDefaults.myJid && (chatType == "chat" || chatType == "normal") {
//                    if !FlyUtils.isValidGroupJid(groupJid: ChatManager.getMessageOfId(messageId: messageId)?.chatUserJid) {
//                        self.bestAttemptContent?.title = "You"
//                    }
//                    canVibrate = false
//                    self.bestAttemptContent?.sound = .none
//                } else if ChatManager.getMessageOfId(messageId: messageId)?.senderUserJid != FlyDefaults.myJid {
//                    if isMuted || (FlyDefaults.isArchivedChatEnabled && ChatManager.getRechtChat(jid: bestAttemptContents?.userInfo["from_user"] as? String ?? "")?.isChatArchived ?? false) {
//                        self.bestAttemptContent?.sound = .none
//                        canVibrate = false
//                    } else if !(FlyDefaults.selectedNotificationSoundName[NotificationSoundKeys.name.rawValue]?.contains("Default") ?? false) && !(FlyDefaults.selectedNotificationSoundName[NotificationSoundKeys.name.rawValue]?.contains("None") ?? false) && FlyDefaults.notificationSoundEnable  {
//                        self.bestAttemptContent?.sound = UNNotificationSound(named: UNNotificationSoundName((FlyDefaults.selectedNotificationSoundName[NotificationSoundKeys.file.rawValue] ?? "") + "." + (FlyDefaults.selectedNotificationSoundName[NotificationSoundKeys.extensions.rawValue] ?? "")))
//                    } else if FlyDefaults.selectedNotificationSoundName[NotificationSoundKeys.name.rawValue]?.contains("Default") ?? false && FlyDefaults.notificationSoundEnable {
//                        self.bestAttemptContent?.sound = .default
//                    } else if FlyDefaults.notificationSoundEnable == false || FlyDefaults.selectedNotificationSoundName[NotificationSoundKeys.name.rawValue]?.contains("None") ?? false {
//                        self.bestAttemptContent?.sound = FlyDefaults.vibrationEnable ? UNNotificationSound(named: UNNotificationSoundName(rawValue: "1-second-of-silence.mp3"))  : nil
//                    }
//                } else if self.bestAttemptContent?.userInfo["sent_from"] as? String ?? "" == FlyDefaults.myJid && self.bestAttemptContent?.userInfo["group_id"] != nil {
//                    self.bestAttemptContent?.sound = nil
//                    canVibrate = false
//                } else if self.bestAttemptContent?.userInfo["sent_from"] as? String ?? "" != FlyDefaults.myJid && self.bestAttemptContent?.userInfo["group_id"] != nil {
//                    if !(FlyDefaults.selectedNotificationSoundName[NotificationSoundKeys.name.rawValue]?.contains("Default") ?? false) && !(FlyDefaults.selectedNotificationSoundName[NotificationSoundKeys.name.rawValue]?.contains("None") ?? false) && FlyDefaults.notificationSoundEnable  {
//                        self.bestAttemptContent?.sound = UNNotificationSound(named: UNNotificationSoundName((FlyDefaults.selectedNotificationSoundName[NotificationSoundKeys.file.rawValue] ?? "") + "." + (FlyDefaults.selectedNotificationSoundName[NotificationSoundKeys.extensions.rawValue] ?? "")))
//                    } else if FlyDefaults.selectedNotificationSoundName[NotificationSoundKeys.name.rawValue]?.contains("Default") ?? false && FlyDefaults.notificationSoundEnable {
//                        self.bestAttemptContent?.sound = .default
//                    } else if FlyDefaults.notificationSoundEnable == false || FlyDefaults.selectedNotificationSoundName[NotificationSoundKeys.name.rawValue]?.contains("None") ?? false {
//                        self.bestAttemptContent?.sound = FlyDefaults.vibrationEnable ? UNNotificationSound(named: UNNotificationSoundName(rawValue: "1-second-of-silence.mp3"))  : nil
//                    }
//                }
//                if let message = ChatManager.getMessageOfId(messageId: messageId), !message.mentionedUsersIds.isEmpty {
//                    self.bestAttemptContent?.body = convertMentionUser(message: message.messageTextContent, mentionedUsersIds: message.mentionedUsersIds)
//                }
//
//                contentHandler(self.bestAttemptContent!)
//                FlyDefaults.lastNotificationId = request.identifier
//            })
//        }
//    }
//
//    func convertMentionUser(message: String, mentionedUsersIds: [String]) -> String {
//        var replyMessage = message
//
////        for user in mentionedUsersIds {
////            let JID = user + "@" + FlyDefaults.xmppDomain
////            let myJID = try? FlyUtils.getMyJid()
////            if let profileDetail = ContactManager.shared.getUserProfileDetails(for: JID) {
////                let userName = "@\(FlyUtils.getGroupUserName(profile: profileDetail))"
////                let mentionRange = (replyMessage as NSString).range(of: "@[?]")
////                replyMessage = replyMessage.replacing(userName, range: mentionRange)
////            }
////        }
//        return replyMessage
//    }
//
//    override func serviceExtensionTimeWillExpire() {
//        // Called just before the extension will be terminated by the system.
//        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
//        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
//            contentHandler(bestAttemptContent)
//        }
//    }
//
}
extension String {
    func replacing(_ withString: String, range: NSRange) -> String {
        if let textRange = self.rangeFromNSRange(range) {
            return self.replacingCharacters(in: textRange, with: withString)
        }
        
        return self
    }
    func rangeFromNSRange(_ nsRange : NSRange) -> Range<String.Index>? {
        guard
            let from16 = utf16.index(utf16.startIndex, offsetBy: nsRange.location, limitedBy: utf16.endIndex),
            let to16 = utf16.index(utf16.startIndex, offsetBy: nsRange.location + nsRange.length, limitedBy: utf16.endIndex),
            let from = from16.samePosition(in: self),
            let to = to16.samePosition(in: self)
            else { return nil }
        return from ..< to
    }
    
    func substringFromNSRange(_ nsRange : NSRange) -> String {
        guard
            let from16 = utf16.index(utf16.startIndex, offsetBy: nsRange.location, limitedBy: utf16.endIndex),
            let to16 = utf16.index(utf16.startIndex, offsetBy: nsRange.location + nsRange.length, limitedBy: utf16.endIndex),
            let from = from16.samePosition(in: self),
            let to = to16.samePosition(in: self)
            else { return self }
        return String(self[from..<to])
    }
}
