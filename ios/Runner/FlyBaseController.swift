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
    
    static let MESSAGE_ONRECEIVED_CHANNEL = "contus.mirrorfly/onMessageReceived"
    static var messageReceivedStreamHandler: MessageReceivedStreamHandler?
    static var messageStatusUpdatedStreamHandler: MessageStatusUpdatedStreamHandler?
    static var mediaStatusUpdatedStreamHandler: MediaStatusUpdatedStreamHandler?
    static var uploadDownloadProgressChangedStreamHandler: UploadDownloadProgressChangedStreamHandler?
    static var showOrUpdateOrCancelNotificationStreamHandler: ShowOrUpdateOrCancelNotificationStreamHandler?
    static var groupProfileFetchedStreamHandler: GroupProfileFetchedStreamHandler?
    static var newGroupCreatedStreamHandler: NewGroupCreatedStreamHandler?
    static var groupProfileUpdatedStreamHandler: GroupProfileUpdatedStreamHandler?
    static var newMemberAddedToGroupStreamHandler: NewMemberAddedToGroupStreamHandler?
    static var memberRemovedFromGroupStreamHandler: MemberRemovedFromGroupStreamHandler?
    static var fetchingGroupMembersCompletedStreamHandler: FetchingGroupMembersCompletedStreamHandler?
    static var deleteGroupStreamHandler: DeleteGroupStreamHandler?
    static var fetchingGroupListCompletedStreamHandler: FetchingGroupListCompletedStreamHandler?
    static var memberMadeAsAdminStreamHandler: MemberMadeAsAdminStreamHandler?
    static var memberRemovedAsAdminStreamHandler: MemberRemovedAsAdminStreamHandler?
    
    static var onChatTypingStatusStreamHandler: OnChatTypingStatusStreamHandler?
    static var onGroupTypingStatusStreamHandler: OnGroupTypingStatusStreamHandler?
    
    
//    override init() {
//        super.init()
//        ChatManager.shared.connectionDelegate = self
//    }

    
    static func initSDK(controller: FlutterViewController, licenseKey: String, isTrial: Bool, baseUrl: String, containerID: String){
        
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
        
//        ChatManager.shared.connectionDelegate = self
    
        
        let methodChannel = FlutterMethodChannel(name: MIRRORFLY_METHOD_CHANNEL, binaryMessenger: controller.binaryMessenger)
        
        prepareMethodHandler(methodChannel: methodChannel)
        
        registerEventChannels(controller: controller)
        
//        ChatManager.shared.logoutDelegate = self
//        FlyMessenger.shared.messageEventsDelegate = self
//        ChatManager.shared.messageEventsDelegate = self
//        GroupManager.shared.groupDelegate = self
//        ChatManager.shared.logoutDelegate = self
//        ChatManager.shared.connectionDelegate = self
    }

    static func registerEventChannels(controller: FlutterViewController){
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
        
        if (self.onGroupTypingStatusStreamHandler == nil) {
            self.onGroupTypingStatusStreamHandler = OnGroupTypingStatusStreamHandler()
          }
                
        FlutterEventChannel(name: onGroupTypingStatus_channel, binaryMessenger: controller.binaryMessenger).setStreamHandler((self.onGroupTypingStatusStreamHandler!))
        

    }
    static func prepareMethodHandler(methodChannel: FlutterMethodChannel){
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
            default:
                result(FlutterMethodNotImplemented)
            }
            
        })
    }
    
    
    
}

extension FlyBaseController: ConnectionEventDelegate{
    
    func onConnected() {
        print("======sdk connected=======")
    }
    
    func onDisconnected() {
        print("======sdk Disconnected======")
    }
    
    func onConnectionNotAuthorized() {
        print("======sdk Not Authorized=======")
    }
}
