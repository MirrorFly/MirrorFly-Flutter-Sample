//
//  FlyBaseController.swift
//  Runner
//
//  Created by ManiVendhan on 10/11/22.
//

import Foundation
import Flutter
import FlyCore
import FlyCommon


let MIRRORFLY_METHOD_CHANNEL = "contus.mirrorfly/sdkCall"

let MESSAGE_ONRECEIVED_CHANNEL = "contus.mirrorfly/onMessageReceived"
let MESSAGE_STATUS_UPDATED_CHANNEL = "contus.mirrorfly/onMessageStatusUpdated"
let MEDIA_STATUS_UPDATED_CHANNEL = "contus.mirrorfly/onMediaStatusUpdated"
let UPLOAD_DOWNLOAD_PROGRESS_CHANGED_CHANNEL =
    "contus.mirrorfly/onUploadDownloadProgressChanged"
let SHOW_UPDATE_CANCEL_NOTIFICTION_CHANNEL =
    "contus.mirrorfly/showOrUpdateOrCancelNotification"

let onGroupProfileFetched_channel = "contus.mirrorfly/onGroupProfileFetched"
let onNewGroupCreated_channel = "contus.mirrorfly/onNewGroupCreated"
let onGroupProfileUpdated_channel = "contus.mirrorfly/onGroupProfileUpdated"
let onNewMemberAddedToGroup_channel = "contus.mirrorfly/onNewMemberAddedToGroup"
let onMemberRemovedFromGroup_channel = "contus.mirrorfly/onMemberRemovedFromGroup"
let onFetchingGroupMembersCompleted_channel =
    "contus.mirrorfly/onFetchingGroupMembersCompleted"
let onDeleteGroup_channel = "contus.mirrorfly/onDeleteGroup"
let onFetchingGroupListCompleted_channel =
    "contus.mirrorfly/onFetchingGroupListCompleted"
let onMemberMadeAsAdmin_channel = "contus.mirrorfly/onMemberMadeAsAdmin"
let onMemberRemovedAsAdmin_channel = "contus.mirrorfly/onMemberRemovedAsAdmin"
let onLeftFromGroup_channel = "contus.mirrorfly/onLeftFromGroup"
let onGroupNotificationMessage_channel = "contus.mirrorfly/onGroupNotificationMessage"
let onGroupDeletedLocally_channel = "contus.mirrorfly/onGroupDeletedLocally"

let blockedThisUser_channel = "contus.mirrorfly/blockedThisUser"
let myProfileUpdated_channel = "contus.mirrorfly/myProfileUpdated"
let onAdminBlockedOtherUser_channel = "contus.mirrorfly/onAdminBlockedOtherUser"
let onAdminBlockedUser_channel = "contus.mirrorfly/onAdminBlockedUser"
let onContactSyncComplete_channel = "contus.mirrorfly/onContactSyncComplete"
let onLoggedOut_channel = "contus.mirrorfly/onLoggedOut"
let unblockedThisUser_channel = "contus.mirrorfly/unblockedThisUser"
let userBlockedMe_channel = "contus.mirrorfly/userBlockedMe"
let userCameOnline_channel = "contus.mirrorfly/userCameOnline"
let userDeletedHisProfile_channel = "contus.mirrorfly/userDeletedHisProfile"
let userProfileFetched_channel = "contus.mirrorfly/userProfileFetched"
let userUnBlockedMe_channel = "contus.mirrorfly/userUnBlockedMe"
let userUpdatedHisProfile_channel = "contus.mirrorfly/userUpdatedHisProfile"
let userWentOffline_channel = "contus.mirrorfly/userWentOffline"
let usersIBlockedListFetched_channel = "contus.mirrorfly/usersIBlockedListFetched"
let usersProfilesFetched_channel = "contus.mirrorfly/usersProfilesFetched"
let usersWhoBlockedMeListFetched_channel = "contus.mirrorfly/usersWhoBlockedMeListFetched"
let onConnected_channel = "contus.mirrorfly/onConnected"
let onDisconnected_channel = "contus.mirrorfly/onDisconnected"
let onConnectionNotAuthorized_channel = "contus.mirrorfly/onConnectionNotAuthorized"
let connectionFailed_channel = "contus.mirrorfly/connectionFailed"
let connectionSuccess_channel = "contus.mirrorfly/connectionSuccess"
let onWebChatPasswordChanged_channel = "contus.mirrorfly/onWebChatPasswordChanged"
let setTypingStatus_channel = "contus.mirrorfly/setTypingStatus"
let onChatTypingStatus_channel = "contus.mirrorfly/onChatTypingStatus"
let onGroupTypingStatus_channel = "contus.mirrorfly/onGroupTypingStatus"
let onFailure_channel = "contus.mirrorfly/onFailure"
let onProgressChanged_channel = "contus.mirrorfly/onProgressChanged"
let onSuccess_channel = "contus.mirrorfly/onSuccess"

class FlyBaseController: NSObject{
    
     var messageReceivedStreamHandler: MessageReceivedStreamHandler?
     var messageStatusUpdatedStreamHandler: MessageStatusUpdatedStreamHandler?
     var mediaStatusUpdatedStreamHandler: MediaStatusUpdatedStreamHandler?
     var uploadDownloadProgressChangedStreamHandler: UploadDownloadProgressChangedStreamHandler?
     var showOrUpdateOrCancelNotificationStreamHandler: ShowOrUpdateOrCancelNotificationStreamHandler?
     var groupProfileFetchedStreamHandler: GroupProfileFetchedStreamHandler?
     var newGroupCreatedStreamHandler: NewGroupCreatedStreamHandler?
     var groupProfileUpdatedStreamHandler: GroupProfileUpdatedStreamHandler?
     var newMemberAddedToGroupStreamHandler: NewMemberAddedToGroupStreamHandler?
     var memberRemovedFromGroupStreamHandler: MemberRemovedFromGroupStreamHandler?
     var fetchingGroupMembersCompletedStreamHandler: FetchingGroupMembersCompletedStreamHandler?
     var deleteGroupStreamHandler: DeleteGroupStreamHandler?
     var fetchingGroupListCompletedStreamHandler: FetchingGroupListCompletedStreamHandler?
     var memberMadeAsAdminStreamHandler: MemberMadeAsAdminStreamHandler?
     var memberRemovedAsAdminStreamHandler: MemberRemovedAsAdminStreamHandler?
    
     var onChatTypingStatusStreamHandler: OnChatTypingStatusStreamHandler?
     var onsetTypingStatusStreamHandler: OnsetTypingStatusStreamHandler?
     var onGroupTypingStatusStreamHandler: OnGroupTypingStatusStreamHandler?

    
     func initSDK(controller: FlutterViewController, licenseKey: String, isTrial: Bool, baseUrl: String, containerID: String){
         
         print("Initializing SDK")
        
        let groupConfig = try? GroupConfig.Builder.enableGroupCreation(groupCreation: true)
            .onlyAdminCanAddOrRemoveMembers(adminOnly: true)
            .setMaximumMembersInAGroup(membersCount: 200)
            .build()
        assert(groupConfig != nil)

        try? ChatSDK.Builder.setAppGroupContainerID(containerID: containerID)
            .setLicenseKey(key: licenseKey)
            .isTrialLicense(isTrial: isTrial)
            .setDomainBaseUrl(baseUrl: baseUrl)
            .setGroupConfiguration(groupConfig: groupConfig!)
            .buildAndInitialize()
        
    
        
        let methodChannel = FlutterMethodChannel(name: MIRRORFLY_METHOD_CHANNEL, binaryMessenger: controller.binaryMessenger)
        
        prepareMethodHandler(methodChannel: methodChannel)
        
        registerEventChannels(controller: controller)
         
         FlyMessenger.shared.messageEventsDelegate = self
         ChatManager.shared.messageEventsDelegate = self
         
         ChatManager.shared.logoutDelegate = self
         FlyMessenger.shared.messageEventsDelegate = self
         ChatManager.shared.messageEventsDelegate = self
         GroupManager.shared.groupDelegate = self
         ChatManager.shared.connectionDelegate = self
         ChatManager.shared.adminBlockCurrentUserDelegate = self
         ChatManager.shared.typingStatusDelegate = self
        
    }

     func registerEventChannels(controller: FlutterViewController){
        if (self.messageReceivedStreamHandler == nil) {
            self.messageReceivedStreamHandler = MessageReceivedStreamHandler()
          }
                
        FlutterEventChannel(name: MESSAGE_ONRECEIVED_CHANNEL, binaryMessenger: controller.binaryMessenger).setStreamHandler((self.messageReceivedStreamHandler as! FlutterStreamHandler & NSObjectProtocol))

        if (self.messageStatusUpdatedStreamHandler == nil) {
            self.messageStatusUpdatedStreamHandler = MessageStatusUpdatedStreamHandler()
          }
        FlutterEventChannel(name: MESSAGE_STATUS_UPDATED_CHANNEL, binaryMessenger: controller.binaryMessenger).setStreamHandler((self.messageStatusUpdatedStreamHandler as! FlutterStreamHandler & NSObjectProtocol))
        
        if (self.mediaStatusUpdatedStreamHandler == nil) {
            self.mediaStatusUpdatedStreamHandler = MediaStatusUpdatedStreamHandler()
          }
        
        FlutterEventChannel(name: MEDIA_STATUS_UPDATED_CHANNEL, binaryMessenger: controller.binaryMessenger).setStreamHandler((self.mediaStatusUpdatedStreamHandler as! FlutterStreamHandler & NSObjectProtocol))
        
        if (self.uploadDownloadProgressChangedStreamHandler == nil) {
            self.uploadDownloadProgressChangedStreamHandler = UploadDownloadProgressChangedStreamHandler()
          }
        FlutterEventChannel(name: UPLOAD_DOWNLOAD_PROGRESS_CHANGED_CHANNEL, binaryMessenger: controller.binaryMessenger).setStreamHandler(self.uploadDownloadProgressChangedStreamHandler as? FlutterStreamHandler & NSObjectProtocol)
        
        if (self.showOrUpdateOrCancelNotificationStreamHandler == nil) {
            self.showOrUpdateOrCancelNotificationStreamHandler = ShowOrUpdateOrCancelNotificationStreamHandler()
          }
        
        FlutterEventChannel(name: SHOW_UPDATE_CANCEL_NOTIFICTION_CHANNEL, binaryMessenger: controller.binaryMessenger).setStreamHandler(self.showOrUpdateOrCancelNotificationStreamHandler as? FlutterStreamHandler & NSObjectProtocol)
        
        if (self.groupProfileFetchedStreamHandler == nil) {
            self.groupProfileFetchedStreamHandler = GroupProfileFetchedStreamHandler()
          }
        
        FlutterEventChannel(name: onGroupProfileFetched_channel, binaryMessenger: controller.binaryMessenger).setStreamHandler(self.groupProfileFetchedStreamHandler as? FlutterStreamHandler & NSObjectProtocol)
        
        if (self.newGroupCreatedStreamHandler == nil) {
            self.newGroupCreatedStreamHandler = NewGroupCreatedStreamHandler()
          }
        
        FlutterEventChannel(name: onNewGroupCreated_channel, binaryMessenger: controller.binaryMessenger).setStreamHandler(self.newGroupCreatedStreamHandler as? FlutterStreamHandler & NSObjectProtocol)
        
        if (self.groupProfileUpdatedStreamHandler == nil) {
            self.groupProfileUpdatedStreamHandler = GroupProfileUpdatedStreamHandler()
          }
        
        FlutterEventChannel(name: onGroupProfileUpdated_channel, binaryMessenger: controller.binaryMessenger).setStreamHandler(self.groupProfileUpdatedStreamHandler as? FlutterStreamHandler & NSObjectProtocol)
        
        if (self.newMemberAddedToGroupStreamHandler == nil) {
            self.newMemberAddedToGroupStreamHandler = NewMemberAddedToGroupStreamHandler()
          }
        
        FlutterEventChannel(name: onNewMemberAddedToGroup_channel, binaryMessenger: controller.binaryMessenger).setStreamHandler(self.newMemberAddedToGroupStreamHandler as? FlutterStreamHandler & NSObjectProtocol)
        
        
        if (self.memberRemovedFromGroupStreamHandler == nil) {
            self.memberRemovedFromGroupStreamHandler = MemberRemovedFromGroupStreamHandler()
          }
        
        FlutterEventChannel(name: onMemberRemovedFromGroup_channel, binaryMessenger: controller.binaryMessenger).setStreamHandler(self.memberRemovedFromGroupStreamHandler as? FlutterStreamHandler & NSObjectProtocol)
        
        if (self.fetchingGroupMembersCompletedStreamHandler == nil) {
            self.fetchingGroupMembersCompletedStreamHandler = FetchingGroupMembersCompletedStreamHandler()
          }
        
        FlutterEventChannel(name: onFetchingGroupMembersCompleted_channel, binaryMessenger: controller.binaryMessenger).setStreamHandler(self.fetchingGroupMembersCompletedStreamHandler as? FlutterStreamHandler & NSObjectProtocol)
        
        if (self.deleteGroupStreamHandler == nil) {
            self.deleteGroupStreamHandler = DeleteGroupStreamHandler()
          }
        
        FlutterEventChannel(name: onDeleteGroup_channel, binaryMessenger: controller.binaryMessenger).setStreamHandler(self.deleteGroupStreamHandler as? FlutterStreamHandler & NSObjectProtocol)
        
        if (self.fetchingGroupListCompletedStreamHandler == nil) {
            self.fetchingGroupListCompletedStreamHandler = FetchingGroupListCompletedStreamHandler()
          }
        
        
        FlutterEventChannel(name: onFetchingGroupListCompleted_channel, binaryMessenger: controller.binaryMessenger).setStreamHandler(self.fetchingGroupListCompletedStreamHandler as? FlutterStreamHandler & NSObjectProtocol)
        
        if (self.memberMadeAsAdminStreamHandler == nil) {
            self.memberMadeAsAdminStreamHandler = MemberMadeAsAdminStreamHandler()
          }
        
        FlutterEventChannel(name: onMemberMadeAsAdmin_channel, binaryMessenger: controller.binaryMessenger).setStreamHandler(self.memberMadeAsAdminStreamHandler as? FlutterStreamHandler & NSObjectProtocol)
        
        if (self.memberRemovedAsAdminStreamHandler == nil) {
            self.memberRemovedAsAdminStreamHandler = MemberRemovedAsAdminStreamHandler()
          }
        
        FlutterEventChannel(name: onMemberRemovedAsAdmin_channel, binaryMessenger: controller.binaryMessenger).setStreamHandler(self.memberRemovedAsAdminStreamHandler as? FlutterStreamHandler & NSObjectProtocol)
        
        if (self.onChatTypingStatusStreamHandler == nil) {
            self.onChatTypingStatusStreamHandler = OnChatTypingStatusStreamHandler()
          }
                
        FlutterEventChannel(name: onChatTypingStatus_channel, binaryMessenger: controller.binaryMessenger).setStreamHandler((self.onChatTypingStatusStreamHandler!))
        
         if (self.onsetTypingStatusStreamHandler == nil) {
            self.onsetTypingStatusStreamHandler = OnsetTypingStatusStreamHandler()
          }
                
        FlutterEventChannel(name: setTypingStatus_channel, binaryMessenger: controller.binaryMessenger).setStreamHandler((self.onsetTypingStatusStreamHandler!))
        
        if (self.onGroupTypingStatusStreamHandler == nil) {
            self.onGroupTypingStatusStreamHandler = OnGroupTypingStatusStreamHandler()
          }
                
        FlutterEventChannel(name: onGroupTypingStatus_channel, binaryMessenger: controller.binaryMessenger).setStreamHandler((self.onGroupTypingStatusStreamHandler!))
        

    }
     func prepareMethodHandler(methodChannel: FlutterMethodChannel){
        methodChannel.setMethodCallHandler({
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            switch call.method {
            case "syncContacts":
                FlySdkMethodCalls.syncContacts(call: call, result: result)
            case "contactSyncStateValue":
                FlySdkMethodCalls.contactSyncStateValue(call: call, result: result)
            case "contactSyncState":
                FlySdkMethodCalls.contactSyncState(call: call, result: result)
            case "revokeContactSync":
                FlySdkMethodCalls.revokeContactSync(call: call, result: result)
            case "getUsersWhoBlockedMe":
                FlySdkMethodCalls.getUsersWhoBlockedMe(call: call, result: result)
            case "getUnKnownUserProfiles":
                FlySdkMethodCalls.getUnKnownUserProfiles(call: call, result: result)
            case "getMyProfileStatus":
                FlySdkMethodCalls.getMyProfileStatus(call: call, result: result)
            case "getMyBusyStatus":
                FlySdkMethodCalls.getMyBusyStatus(call: call, result: result)
            case "setMyBusyStatus":
                FlySdkMethodCalls.setMyBusyStatus(call: call, result: result)
            case "enableDisableBusyStatus":
                FlySdkMethodCalls.enableDisableBusyStatus(call: call, result: result)
            case "getBusyStatusList":
                FlySdkMethodCalls.getBusyStatusList(call: call, result: result)
            case "deleteProfileStatus":
                FlySdkMethodCalls.deleteProfileStatus(call: call, result: result)
            case "deleteBusyStatus":
                FlySdkMethodCalls.deleteBusyStatus(call: call, result: result)
            case "enableDisableHideLastSeen":
                FlySdkMethodCalls.enableDisableHideLastSeen(call: call, result: result)
            case "isHideLastSeenEnabled":
                FlySdkMethodCalls.isHideLastSeenEnabled(call: call, result: result)
            case "deleteMessagesForMe":
                FlySdkMethodCalls.deleteMessagesForMe(call: call, result: result)
            case "deleteMessagesForEveryone":
                FlySdkMethodCalls.deleteMessagesForEveryone(call: call, result: result)
            case "markAsRead":
                FlySdkMethodCalls.markAsRead(call: call, result: result)
            case "deleteUnreadMessageSeparatorOfAConversation":
                FlySdkMethodCalls.deleteUnreadMessageSeparatorOfAConversation(call: call, result: result)
            case "getRecalledMessagesOfAConversation":
                FlySdkMethodCalls.getRecalledMessagesOfAConversation(call: call, result: result)
            case "uploadMedia":
                FlySdkMethodCalls.uploadMedia(call: call, result: result)
            case "getMessagesUsingIds":
                FlySdkMethodCalls.getMessagesUsingIds(call: call, result: result)
            case "updateMediaDownloadStatus":
                FlySdkMethodCalls.updateMediaDownloadStatus(call: call, result: result)
            case "updateMediaUploadStatus":
                FlySdkMethodCalls.updateMediaUploadStatus(call: call, result: result)
            case "cancelMediaUploadOrDownload":
                FlySdkMethodCalls.cancelMediaUploadOrDownload(call: call, result: result)
            case "setMediaEncryption":
                FlySdkMethodCalls.setMediaEncryption(call: call, result: result)
            case "deleteAllMessages":
                FlySdkMethodCalls.deleteAllMessages(call: call, result: result)
            case "getGroupJid":
                FlySdkMethodCalls.getGroupJid(call: call, result: result)
            case "getProfileDetails":
                FlySdkMethodCalls.getProfileDetails(call: call, result: result)
            case "getProfileStatusList":
                FlySdkMethodCalls.getProfileStatusList(call: call, result: result)
            case "insertDefaultStatus":
                FlySdkMethodCalls.insertDefaultStatus(call: call, result: result)
            case "getRingtoneName":
                FlySdkMethodCalls.getRingtoneName(call: call, result: result)
                
            case "setOnGoingChatUser":
                FlySdkMethodCalls.setOnGoingChatUser(call: call, result: result)
                
            case "markAsReadDeleteUnreadSeparator":
                FlySdkMethodCalls.markAsReadDeleteUnreadSeparator(call: call, result: result)
            case "getMessagesOfJid":
                FlySdkMethodCalls.getMessagesOfJid(call: call, result: result)
                
                
            case "updateRecentChatPinStatus":
                FlySdkMethodCalls.updateRecentChatPinStatus(call: call, result: result)
                
            case "deleteRecentChat"://need to discuss there is 2 delete recent chat functions
                FlySdkMethodCalls.deleteRecentChat(call: call, result: result)
            case "recentChatPinnedCount":
                FlySdkMethodCalls.recentChatPinnedCount(call: call, result: result)
            case "getRecentChatList":
                FlySdkMethodCalls.getRecentChatList(call: call, result: result)
//            case "get_recent_chat_of":
//                FlySdkMethodCalls.getRecentChatOf(call: call, result: result)
            case "getRecentChatListIncludingArchived":
                FlySdkMethodCalls.getRecentChatListIncludingArchived(call: call, result: result)
            case "getRecentChatOf":
                FlySdkMethodCalls.getRecentChatOf(call: call, result: result)
                
            case "register_user":
                FlySdkMethodCalls.registerUser(call: call, result: result)
            case "authtoken":
                FlySdkMethodCalls.refreshAndGetAuthToken(call: call, result: result)
            case "refreshAuthToken":
                FlySdkMethodCalls.refreshAndGetAuthToken(call: call, result: result)
            case "verifyToken":
                FlySdkMethodCalls.verifyToken(call: call, result: result)
            case "get_jid":
                FlySdkMethodCalls.getJid(call: call, result: result)
            case "send_text_msg":
                FlySdkMethodCalls.sendTextMessage(call: call, result: result)
            case "sendLocationMessage":
                FlySdkMethodCalls.sendLocationMessage(call: call, result: result)
            case "send_image_message":
                FlySdkMethodCalls.sendImageMessage(call: call, result: result)
            case "send_video_message":
                FlySdkMethodCalls.sendVideoMessage(call: call, result: result)
            case "sendContactMessage":
                FlySdkMethodCalls.sendContactMessage(call: call, result: result)
            case "sendDocumentMessage":
                FlySdkMethodCalls.sendDocumentMessage(call: call, result: result)
            case "sendAudioMessage":
                FlySdkMethodCalls.sendAudioMessage(call: call, result: result)
            case "get_user_list":
                FlySdkMethodCalls.getUserList(call: call, result: result)
            case "getRegisteredUsers"://In Android we call getRegisteredUsers
//                FlySdkMethodCalls.getUserList(call: call, result: result)
                FlySdkMethodCalls.getRegisteredUsers(call: call, result: result)
                
            case "getUserProfile":
                FlySdkMethodCalls.getUserProfile(call: call, result: result)
            case "clear_chat":
                FlySdkMethodCalls.clearChat(call: call, result: result)
                
            case "updateMyProfile":
                FlySdkMethodCalls.updateMyProfile(call: call, result: result)
                
            case "media_endpoint":
                FlySdkMethodCalls.getMediaEndPoint(call: call, result: result)
                
            case "reportUserOrMessages":
                FlySdkMethodCalls.reportUserOrMessages(call: call, result: result)
            case "block_user":
                FlySdkMethodCalls.blockUser(call: call, result: result)
            case "un_block_user":
                FlySdkMethodCalls.unblockUser(call: call, result: result)
            case "createGroup":
                FlySdkMethodCalls.createGroup(call: call, result: result)
            case "getUserLastSeenTime":
                FlySdkMethodCalls.getUserLastSeenTime(call: call, result: result)
            case "getUsersIBlocked":
                FlySdkMethodCalls.getUsersIBlocked(call: call, result: result)
            case "setMyProfileStatus":
                FlySdkMethodCalls.setMyProfileStatus(call: call, result: result)
            case "sendData":
                let UserJid = Utility.getStringFromPreference(key: notificationUserJid)
                Utility.saveInPreference(key: notificationUserJid, value: "")
                result(UserJid)
            case "getMediaMessages":
                FlySdkMethodCalls.getMediaMessages(call: call, result: result)
            case "isMemberOfGroup":
                FlySdkMethodCalls.isMemberOfGroup(call: call, result: result)
            case "updateArchiveUnArchiveChat":
                FlySdkMethodCalls.updateArchiveUnArchiveChat(call: call, result: result)
            case "getArchivedChatList":
                FlySdkMethodCalls.getArchivedChatList(call: call, result: result)
            case "updateChatMuteStatus":
                FlySdkMethodCalls.updateChatMuteStatus(call: call, result: result)
            case "sendTypingStatus":
                FlySdkMethodCalls.sendTypingStatus(call: call, result: result)
            case "sendTypingGoneStatus":
                FlySdkMethodCalls.sendTypingGoneStatus(call: call, result: result)
            case "setNotificationSound":
                FlySdkMethodCalls.setNotificationSound(call: call, result: result)
            case "isBusyStatusEnabled":
                FlySdkMethodCalls.isBusyStatusEnabled(call: call, result: result)
            case "updateMyProfileImage":
                FlySdkMethodCalls.updateMyProfileImage(call: call, result: result)
            case "isUserUnArchived":
                FlySdkMethodCalls.isUserUnArchived(call: call, result: result)
            case "forwardMessagesToMultipleUsers":
                FlySdkMethodCalls.forwardMessagesToMultipleUsers(call: call, result: result)
            case "removeProfileImage":
                FlySdkMethodCalls.removeProfileImage(call: call, result: result)
            case "isArchivedSettingsEnabled":
                FlySdkMethodCalls.isArchivedSettingsEnabled(call: call, result: result)
            case "getGroupMembersList":
                FlySdkMethodCalls.getGroupMembersList(call: call, result: result)
            case "enableDisableArchivedSettings":
                FlySdkMethodCalls.enableDisableArchivedSettings(call: call, result: result)
            case "clearAllConversation":
                FlySdkMethodCalls.clearAllConversation(call: call, result: result)
            default:
                result(FlutterMethodNotImplemented)
            }
            
        })
    }
    
    func applicationDidBecomeActive(){
        if Utility.getBoolFromPreference(key: isLoggedIn) && (FlyDefaults.isLoggedIn) {
            print("connecting chat manager")
            ChatManager.connect()
        }else{
            print(Utility.getBoolFromPreference(key: isLoggedIn))
            print(FlyDefaults.isLoggedIn)
            print("Unable to connect chat manager")
        }
    }
    
    func applicationDidEnterBackground(){
        if (FlyDefaults.isLoggedIn) {
            print("Disconnecting Chat Manager")
            ChatManager.disconnect()
        }
    }
    
}


extension FlyBaseController : MessageEventsDelegate, ConnectionEventDelegate, LogoutDelegate, GroupEventsDelegate, AdminBlockCurrentUserDelegate, TypingStatusDelegate {
    func onChatTypingStatus(userJid: String, status: FlyCommon.TypingStatus) {
        
        print("onChatTypingStatus")
        let jsonObject: NSMutableDictionary = NSMutableDictionary()
        
        
        jsonObject.setValue(userJid, forKey: "singleOrgroupJid")
        jsonObject.setValue(userJid, forKey: "userId")
        jsonObject.setValue(status == TypingStatus.composing ? "composing" : "Gone", forKey: "composing")
        
        print("json data-->\(jsonObject)")
        

        let jsonString = Commons.json(from: jsonObject)
        print("json-->\(String(describing: jsonString))")
        
        if(onsetTypingStatusStreamHandler?.onSetTyping != nil){
            onsetTypingStatusStreamHandler?.onSetTyping?(jsonString)

        }else{
            print("Chat Typing Stream Handler is Nil")
        }
        
    }
    
    func onGroupTypingStatus(groupJid: String, groupUserJid: String, status: FlyCommon.TypingStatus) {
        
        print("onGroupTypingStatus")
        
        let jsonObject: NSMutableDictionary = NSMutableDictionary()
//        jsonObject.setValue(groupJid, forKey: "groupJid")
//        jsonObject.setValue(groupUserJid, forKey: "groupUserJid")
//        jsonObject.setValue(status.rawValue, forKey: "status")
        jsonObject.setValue(groupJid, forKey: "singleOrgroupJid")
        jsonObject.setValue(groupUserJid, forKey: "userId")
        jsonObject.setValue(status == TypingStatus.composing ? "composing" : "Gone", forKey: "composing")
        let jsonString = Commons.json(from: jsonObject)
        
        if(onsetTypingStatusStreamHandler?.onSetTyping != nil){
            onsetTypingStatusStreamHandler?.onSetTyping?(jsonString)
        }else{
            print("Group Chat Typing Stream Handler is Nil")
        }
    }
    
    func onMessageReceived(message: FlyCommon.ChatMessage, chatJid: String) {

        print("Message Received Update--->")
        print(JSONSerializer.toJson(message))

        var messageReceivedJson = JSONSerializer.toJson(message)
        messageReceivedJson = messageReceivedJson.replacingOccurrences(of: "{\"some\":", with: "")
        messageReceivedJson = messageReceivedJson.replacingOccurrences(of: "}}", with: "}")

        if(messageReceivedStreamHandler?.onMessageReceived != nil){
            messageReceivedStreamHandler?.onMessageReceived?(messageReceivedJson)

        }else{
            print("Message Stream Handler is Nil")
        }

    }

    func onMessageStatusUpdated(messageId: String, chatJid: String, status: FlyCommon.MessageStatus) {

        print("====Message status update====")
        print("messageID-->\(messageId)")
        
//        var tempSaveContact = ContactManager.shared.saveTempContact(userId: chatJid)
//        print(tempSaveContact as Any)
        
//        FlyMessenger.database.messageManager.getMessageDetailFor(id: messageId)!)
        
        let chatMessage = ChatManager.getMessageOfId(messageId: messageId)
        print("Message Status Update--->\(String(describing: chatMessage))")
        print("getMessageOfId==>", ChatManager.getMessageOfId(messageId: messageId)?.messageTextContent as Any)
        var chatMessageJson = JSONSerializer.toJson(chatMessage as Any)

        chatMessageJson = chatMessageJson.replacingOccurrences(of: "{\"some\":", with: "")
        chatMessageJson = chatMessageJson.replacingOccurrences(of: "}}", with: "}")
        print(chatMessageJson)

        if(messageStatusUpdatedStreamHandler?.onMessageStatusUpdated != nil){
            messageStatusUpdatedStreamHandler?.onMessageStatusUpdated?(chatMessageJson)

        }else{
            print("Message status Stream Handler is Nil")
        }

    }

    func onMediaStatusUpdated(message: FlyCommon.ChatMessage) {
        print("Media Status Update--->")
        var chatMediaJson = JSONSerializer.toJson(message as Any)
        chatMediaJson = chatMediaJson.replacingOccurrences(of: "{\"some\":", with: "")
        chatMediaJson = chatMediaJson.replacingOccurrences(of: "}}", with: "}")
        print(chatMediaJson)

        if(mediaStatusUpdatedStreamHandler?.onMediaStatusUpdated != nil){
            mediaStatusUpdatedStreamHandler?.onMediaStatusUpdated?(chatMediaJson)
        }else{
            print("chatMediaJson Stream Handler is Nil")
        }
    }

    func onMediaStatusFailed(error: String, messageId: String) {
        print("Media Status Failed--->\(error)")
    }

    func onMediaProgressChanged(message: FlyCommon.ChatMessage, progressPercentage: Float) {
        print("Media Status Onprogress changed---> \(progressPercentage)")
    }

    func onMessagesClearedOrDeleted(messageIds: Array<String>) {
        print("Message Cleared--->")
    }

    func onMessagesDeletedforEveryone(messageIds: Array<String>) {
        print("Message Deleted For Everyone--->")
    }

    func showOrUpdateOrCancelNotification() {
        print("Message showOrUpdateOrCancelNotification--->")
    }

    func onMessagesCleared(toJid: String) {
        print("Message onMessagesCleared--->")
    }

    func setOrUpdateFavourite(messageId: String, favourite: Bool, removeAllFavourite: Bool) {
        print("Message setOrUpdateFavourite--->")
    }

    func onMessageTranslated(message: FlyCommon.ChatMessage, jid: String) {
        print("Message onMessageTranslated--->")
    }
    
    func didBlockOrUnblockCurrentUser(userJid: String, isBlocked: Bool) {
        
    }
    
    func didBlockOrUnblockGroup(groupJid: String, isBlocked: Bool) {
        
    }
    
    func didBlockOrUnblockContact(userJid: String, isBlocked: Bool) {
        
    }
    
    func didAddNewMemeberToGroup(groupJid: String, newMemberJid: String, addedByMemberJid: String) {
        
    }
    
    func didRemoveMemberFromGroup(groupJid: String, removedMemberJid: String, removedByMemberJid: String) {
        
    }
    
    func didFetchGroupProfile(groupJid: String) {
        
    }
    
    func didUpdateGroupProfile(groupJid: String) {
        
    }
    
    func didMakeMemberAsAdmin(groupJid: String, newAdminMemberJid: String, madeByMemberJid: String) {
        
    }
    
    func didRemoveMemberFromAdmin(groupJid: String, removedAdminMemberJid: String, removedByMemberJid: String) {
        
    }
    
    func didDeleteGroupLocally(groupJid: String) {
        
    }
    
    func didLeftFromGroup(groupJid: String, leftUserJid: String) {
        
    }
    
    func didCreateGroup(groupJid: String) {
        
    }
    
    func didFetchGroups(groups: [FlyCommon.ProfileDetails]) {
        
    }
    
    func didFetchGroupMembers(groupJid: String) {
        
    }
    
    func didReceiveGroupNotificationMessage(message: FlyCommon.ChatMessage) {
        
    }
    
    func didReceiveLogout() {
        print("logout delegate received")
        print("AppDelegate LogoutDelegate ===> LogoutDelegate")
        Utility.saveInPreference(key: isProfileSaved, value: false)
        Utility.saveInPreference(key: isLoggedIn, value: false)

        ChatManager.logoutApi { isSuccess, flyError, flyData in
           if isSuccess {
               print("requestLogout Logout api isSuccess")

           }else{
               print("Logout api error : \(String(describing: flyError))")

           }
       }
        ChatManager.enableContactSync(isEnable: ENABLE_CONTACT_SYNC)
        ChatManager.disconnect()
        ChatManager.shared.resetFlyDefaults()
    }
    
    func onConnected() {
        print("====== sdk connected=======")
    }

    func onDisconnected() {
        print("====== sdk Disconnected======")
    }

    func onConnectionNotAuthorized() {
        print("====== sdk Not Authorized=======")
    }

}
