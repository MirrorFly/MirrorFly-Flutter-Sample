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
    "contus.mirrorfly/showOrUpdateOrCancelNotification"//dependency issue

let onGroupProfileFetched_channel = "contus.mirrorfly/onGroupProfileFetched"
let onNewGroupCreated_channel = "contus.mirrorfly/onNewGroupCreated"
let onGroupProfileUpdated_channel = "contus.mirrorfly/onGroupProfileUpdated"
let onNewMemberAddedToGroup_channel = "contus.mirrorfly/onNewMemberAddedToGroup"
let onMemberRemovedFromGroup_channel = "contus.mirrorfly/onMemberRemovedFromGroup"
let onFetchingGroupMembersCompleted_channel =
    "contus.mirrorfly/onFetchingGroupMembersCompleted"
let onDeleteGroup_channel = "contus.mirrorfly/onDeleteGroup"//not found
let onFetchingGroupListCompleted_channel =
    "contus.mirrorfly/onFetchingGroupListCompleted"//not found
let onMemberMadeAsAdmin_channel = "contus.mirrorfly/onMemberMadeAsAdmin"
let onMemberRemovedAsAdmin_channel = "contus.mirrorfly/onMemberRemovedAsAdmin"
let onLeftFromGroup_channel = "contus.mirrorfly/onLeftFromGroup"
let onGroupNotificationMessage_channel = "contus.mirrorfly/onGroupNotificationMessage"//not found
let onGroupDeletedLocally_channel = "contus.mirrorfly/onGroupDeletedLocally"

let blockedThisUser_channel = "contus.mirrorfly/blockedThisUser"
let myProfileUpdated_channel = "contus.mirrorfly/myProfileUpdated"
let onAdminBlockedOtherUser_channel = "contus.mirrorfly/onAdminBlockedOtherUser"
let onAdminBlockedUser_channel = "contus.mirrorfly/onAdminBlockedUser"
let onContactSyncComplete_channel = "contus.mirrorfly/onContactSyncComplete"//need to verify with ios team
let onLoggedOut_channel = "contus.mirrorfly/onLoggedOut"//not found
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
     var fetchingGroupListCompletedStreamHandler: FetchingGroupListCompletedStreamHandler?//
     var memberMadeAsAdminStreamHandler: MemberMadeAsAdminStreamHandler?
     var memberRemovedAsAdminStreamHandler: MemberRemovedAsAdminStreamHandler?
     var userWentOfflineStreamHandler: UserWentOfflineStreamHandler?
    
     var leftFromGroupStreamHandler: LeftFromGroupStreamHandler?
     var onGroupNotificationMessageStreamHandler: GroupNotificationMessageStreamHandler?
     var onGroupDeletedLocallyStreamHandler: GroupDeletedLocallyStreamHandler?
     var blockedThisUserStreamHandler: BlockedThisUserStreamHandler?
     var myProfileUpdatedStreamHandler: MyProfileUpdatedStreamHandler?
     var onAdminBlockedOtherUserStreamHandler: OnAdminBlockedOtherUserStreamHandler?
     var onAdminBlockedUserStreamHandler: OnAdminBlockedUserStreamHandler?
     var onContactSyncCompleteStreamHandler: OnContactSyncCompleteStreamHandler?
     var onLoggedOutStreamHandler: OnLoggedOutStreamHandler?
     var unblockedThisUserStreamHandler: UnblockedThisUserStreamHandler?
     var userBlockedMeStreamHandler: UserBlockedMeStreamHandler?
     var userCameOnlineStreamHandler: UserCameOnlineStreamHandler?
     var userDeletedHisProfileStreamHandler: UserDeletedHisProfileStreamHandler?
     var userProfileFetchedStreamHandler: UserProfileFetchedStreamHandler?
     var userUnBlockedMeStreamHandler: UserUnBlockedMeStreamHandler?
     var userUpdatedHisProfileStreamHandler: UserUpdatedHisProfileStreamHandler?
     var usersIBlockedListFetchedStreamHandler: UsersIBlockedListFetchedStreamHandler?
     var usersProfilesFetchedStreamHandler: UsersProfilesFetchedStreamHandler?
     var usersWhoBlockedMeListFetchedStreamHandler: UsersWhoBlockedMeListFetchedStreamHandler?
     var onConnectedStreamHandler: OnConnectedStreamHandler?
     var onDisconnectedStreamHandler: OnDisconnectedStreamHandler?
     var onConnectionNotAuthorizedStreamHandler: OnConnectionNotAuthorizedStreamHandler?
     var connectionFailedStreamHandler: ConnectionFailedStreamHandler?
     var connectionSuccessStreamHandler: ConnectionSuccessStreamHandler?
     var onWebChatPasswordChangedStreamHandler: OnWebChatPasswordChangedStreamHandler?
     var onFailureStreamHandler: OnFailureStreamHandler?
     var onProgressChangedStreamHandler: OnProgressChangedStreamHandler?
     var onSuccessStreamHandler: OnSuccessStreamHandler?
    
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
         
         ChatManager.shared.logoutDelegate = self
         FlyMessenger.shared.messageEventsDelegate = self
         ChatManager.shared.messageEventsDelegate = self
         GroupManager.shared.groupDelegate = self
         ChatManager.shared.connectionDelegate = self
         ChatManager.shared.adminBlockCurrentUserDelegate = self
         ChatManager.shared.typingStatusDelegate = self
         
         ContactManager.shared.profileDelegate = self
         ChatManager.shared.adminBlockDelegate = self
         ChatManager.shared.availableFeaturesDelegate = self
         BackupManager.shared.backupDelegate = self
         BackupManager.shared.restoreDelegate = self
//         iCloudmanager.iCloudDelegate = self
        
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
         
        if (self.onAdminBlockedOtherUserStreamHandler == nil) {
            self.onAdminBlockedOtherUserStreamHandler = OnAdminBlockedOtherUserStreamHandler()
          }
        
        FlutterEventChannel(name: onAdminBlockedOtherUser_channel, binaryMessenger: controller.binaryMessenger).setStreamHandler((self.onAdminBlockedOtherUserStreamHandler as! FlutterStreamHandler & NSObjectProtocol))
        
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
         
        if (self.leftFromGroupStreamHandler == nil) {
            self.leftFromGroupStreamHandler = LeftFromGroupStreamHandler()
          }
        
        FlutterEventChannel(name: onLeftFromGroup_channel, binaryMessenger: controller.binaryMessenger).setStreamHandler(self.leftFromGroupStreamHandler as? FlutterStreamHandler & NSObjectProtocol)
        
        if (self.userWentOfflineStreamHandler == nil) {
            self.userWentOfflineStreamHandler = UserWentOfflineStreamHandler()
          }
        
        FlutterEventChannel(name: userWentOffline_channel, binaryMessenger: controller.binaryMessenger).setStreamHandler(self.userWentOfflineStreamHandler as? FlutterStreamHandler & NSObjectProtocol)
        
         
        if (self.onGroupNotificationMessageStreamHandler == nil) {
            self.onGroupNotificationMessageStreamHandler = GroupNotificationMessageStreamHandler()
          }
        
        FlutterEventChannel(name: onGroupNotificationMessage_channel, binaryMessenger: controller.binaryMessenger).setStreamHandler(self.onGroupNotificationMessageStreamHandler as? FlutterStreamHandler & NSObjectProtocol)
         
        if (self.onGroupDeletedLocallyStreamHandler == nil) {
            self.onGroupDeletedLocallyStreamHandler = GroupDeletedLocallyStreamHandler()
          }
        
        FlutterEventChannel(name: onGroupDeletedLocally_channel, binaryMessenger: controller.binaryMessenger).setStreamHandler(self.onGroupDeletedLocallyStreamHandler as? FlutterStreamHandler & NSObjectProtocol)
         
        if (self.blockedThisUserStreamHandler == nil) {
            self.blockedThisUserStreamHandler = BlockedThisUserStreamHandler()
          }
        
        FlutterEventChannel(name: blockedThisUser_channel, binaryMessenger: controller.binaryMessenger).setStreamHandler(self.blockedThisUserStreamHandler as? FlutterStreamHandler & NSObjectProtocol)
        
         
        if (self.myProfileUpdatedStreamHandler == nil) {
            self.myProfileUpdatedStreamHandler = MyProfileUpdatedStreamHandler()
          }
        
        FlutterEventChannel(name: myProfileUpdated_channel, binaryMessenger: controller.binaryMessenger).setStreamHandler(self.myProfileUpdatedStreamHandler as? FlutterStreamHandler & NSObjectProtocol)
         
        if (self.onAdminBlockedUserStreamHandler == nil) {
            self.onAdminBlockedUserStreamHandler = OnAdminBlockedUserStreamHandler()
          }
        
        FlutterEventChannel(name: onAdminBlockedUser_channel, binaryMessenger: controller.binaryMessenger).setStreamHandler(self.onAdminBlockedUserStreamHandler as? FlutterStreamHandler & NSObjectProtocol)
         
         
        if (self.onContactSyncCompleteStreamHandler == nil) {
            self.onContactSyncCompleteStreamHandler = OnContactSyncCompleteStreamHandler()
          }
        
        FlutterEventChannel(name: onContactSyncComplete_channel, binaryMessenger: controller.binaryMessenger).setStreamHandler(self.onContactSyncCompleteStreamHandler as? FlutterStreamHandler & NSObjectProtocol)
         
        if (self.onLoggedOutStreamHandler == nil) {
            self.onLoggedOutStreamHandler = OnLoggedOutStreamHandler()
          }
        
        FlutterEventChannel(name: onLoggedOut_channel, binaryMessenger: controller.binaryMessenger).setStreamHandler(self.onLoggedOutStreamHandler as? FlutterStreamHandler & NSObjectProtocol)
         
         
        if (self.unblockedThisUserStreamHandler == nil) {
            self.unblockedThisUserStreamHandler = UnblockedThisUserStreamHandler()
          }
        
        FlutterEventChannel(name: unblockedThisUser_channel, binaryMessenger: controller.binaryMessenger).setStreamHandler(self.unblockedThisUserStreamHandler as? FlutterStreamHandler & NSObjectProtocol)
         
        if (self.userBlockedMeStreamHandler == nil) {
            self.userBlockedMeStreamHandler = UserBlockedMeStreamHandler()
          }
        
        FlutterEventChannel(name: userBlockedMe_channel, binaryMessenger: controller.binaryMessenger).setStreamHandler(self.userBlockedMeStreamHandler as? FlutterStreamHandler & NSObjectProtocol)
         
         
        if (self.userCameOnlineStreamHandler == nil) {
            self.userCameOnlineStreamHandler = UserCameOnlineStreamHandler()
          }
        
        FlutterEventChannel(name: userCameOnline_channel, binaryMessenger: controller.binaryMessenger).setStreamHandler(self.userCameOnlineStreamHandler as? FlutterStreamHandler & NSObjectProtocol)
         
         
        if (self.userDeletedHisProfileStreamHandler == nil) {
            self.userDeletedHisProfileStreamHandler = UserDeletedHisProfileStreamHandler()
          }
        
        FlutterEventChannel(name: userDeletedHisProfile_channel, binaryMessenger: controller.binaryMessenger).setStreamHandler(self.userDeletedHisProfileStreamHandler as? FlutterStreamHandler & NSObjectProtocol)
         
        if (self.userProfileFetchedStreamHandler == nil) {
            self.userProfileFetchedStreamHandler = UserProfileFetchedStreamHandler()
          }
        
        FlutterEventChannel(name: userProfileFetched_channel, binaryMessenger: controller.binaryMessenger).setStreamHandler(self.userProfileFetchedStreamHandler as? FlutterStreamHandler & NSObjectProtocol)
         
          
        if (self.userUnBlockedMeStreamHandler == nil) {
            self.userUnBlockedMeStreamHandler = UserUnBlockedMeStreamHandler()
          }
        
        FlutterEventChannel(name: userUnBlockedMe_channel, binaryMessenger: controller.binaryMessenger).setStreamHandler(self.userUnBlockedMeStreamHandler as? FlutterStreamHandler & NSObjectProtocol)
         
        if (self.userUpdatedHisProfileStreamHandler == nil) {
            self.userUpdatedHisProfileStreamHandler = UserUpdatedHisProfileStreamHandler()
          }
        
        FlutterEventChannel(name: userUpdatedHisProfile_channel, binaryMessenger: controller.binaryMessenger).setStreamHandler(self.userUpdatedHisProfileStreamHandler as? FlutterStreamHandler & NSObjectProtocol)
         
        if (self.usersIBlockedListFetchedStreamHandler == nil) {
            self.usersIBlockedListFetchedStreamHandler = UsersIBlockedListFetchedStreamHandler()
          }
        
        FlutterEventChannel(name: usersIBlockedListFetched_channel, binaryMessenger: controller.binaryMessenger).setStreamHandler(self.usersIBlockedListFetchedStreamHandler as? FlutterStreamHandler & NSObjectProtocol)
         
      
         
        if (self.usersProfilesFetchedStreamHandler == nil) {
            self.usersProfilesFetchedStreamHandler = UsersProfilesFetchedStreamHandler()
          }
        
        FlutterEventChannel(name: userProfileFetched_channel, binaryMessenger: controller.binaryMessenger).setStreamHandler(self.usersProfilesFetchedStreamHandler as? FlutterStreamHandler & NSObjectProtocol)
         
      
         
        if (self.usersWhoBlockedMeListFetchedStreamHandler == nil) {
            self.usersWhoBlockedMeListFetchedStreamHandler = UsersWhoBlockedMeListFetchedStreamHandler()
          }
        
        FlutterEventChannel(name: usersWhoBlockedMeListFetched_channel, binaryMessenger: controller.binaryMessenger).setStreamHandler(self.usersWhoBlockedMeListFetchedStreamHandler as? FlutterStreamHandler & NSObjectProtocol)
         
         
        if (self.onConnectedStreamHandler == nil) {
            self.onConnectedStreamHandler = OnConnectedStreamHandler()
          }
        
        FlutterEventChannel(name: onConnected_channel, binaryMessenger: controller.binaryMessenger).setStreamHandler(self.onConnectedStreamHandler as? FlutterStreamHandler & NSObjectProtocol)
         
        if (self.onDisconnectedStreamHandler == nil) {
            self.onDisconnectedStreamHandler = OnDisconnectedStreamHandler()
          }
        
        FlutterEventChannel(name: onDisconnected_channel, binaryMessenger: controller.binaryMessenger).setStreamHandler(self.onDisconnectedStreamHandler as? FlutterStreamHandler & NSObjectProtocol)
         
        if (self.onConnectionNotAuthorizedStreamHandler == nil) {
            self.onConnectionNotAuthorizedStreamHandler = OnConnectionNotAuthorizedStreamHandler()
          }
        
        FlutterEventChannel(name: onConnectionNotAuthorized_channel, binaryMessenger: controller.binaryMessenger).setStreamHandler(self.onConnectionNotAuthorizedStreamHandler as? FlutterStreamHandler & NSObjectProtocol)
         
         
        if (self.connectionFailedStreamHandler == nil) {
            self.connectionFailedStreamHandler = ConnectionFailedStreamHandler()
          }
        
        FlutterEventChannel(name: connectionFailed_channel, binaryMessenger: controller.binaryMessenger).setStreamHandler(self.connectionFailedStreamHandler as? FlutterStreamHandler & NSObjectProtocol)
         
         
        if (self.connectionSuccessStreamHandler == nil) {
            self.connectionSuccessStreamHandler = ConnectionSuccessStreamHandler()
          }
        
        FlutterEventChannel(name: connectionSuccess_channel, binaryMessenger: controller.binaryMessenger).setStreamHandler(self.connectionSuccessStreamHandler as? FlutterStreamHandler & NSObjectProtocol)
         
         
        if (self.onWebChatPasswordChangedStreamHandler == nil) {
            self.onWebChatPasswordChangedStreamHandler = OnWebChatPasswordChangedStreamHandler()
          }
        
        FlutterEventChannel(name: onWebChatPasswordChanged_channel, binaryMessenger: controller.binaryMessenger).setStreamHandler(self.onWebChatPasswordChangedStreamHandler as? FlutterStreamHandler & NSObjectProtocol)
         
        if (self.onFailureStreamHandler == nil) {
            self.onFailureStreamHandler = OnFailureStreamHandler()
          }
        
        FlutterEventChannel(name: onFailure_channel, binaryMessenger: controller.binaryMessenger).setStreamHandler(self.onFailureStreamHandler as? FlutterStreamHandler & NSObjectProtocol)
         
        if (self.onProgressChangedStreamHandler == nil) {
            self.onProgressChangedStreamHandler = OnProgressChangedStreamHandler()
          }
        
        FlutterEventChannel(name: onProgressChanged_channel, binaryMessenger: controller.binaryMessenger).setStreamHandler(self.onProgressChangedStreamHandler as? FlutterStreamHandler & NSObjectProtocol)
         
        if (self.onSuccessStreamHandler == nil) {
            self.onSuccessStreamHandler = OnSuccessStreamHandler()
          }
        
        FlutterEventChannel(name: onSuccess_channel, binaryMessenger: controller.binaryMessenger).setStreamHandler(self.onSuccessStreamHandler as? FlutterStreamHandler & NSObjectProtocol)
         
        
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
            case "cancelNotifications":
                FlySdkMethodCalls.cancelNotifications(call: call, result: result)
            case "insertBusyStatus":
                FlySdkMethodCalls.insertBusyStatus(call: call, result: result)
            case "getDocsMessages":
                FlySdkMethodCalls.getDocsMessages(call: call, result: result)
            case "getLinkMessages":
                FlySdkMethodCalls.getLinkMessages(call: call, result: result)
            case "isAdmin":
                FlySdkMethodCalls.isAdmin(call: call, result: result)
            case "leaveFromGroup":
                FlySdkMethodCalls.leaveFromGroup(call: call, result: result)
            case "getMediaAutoDownload":
                FlySdkMethodCalls.getMediaAutoDownload(call: call, result: result)
            case "setMediaAutoDownload":
                FlySdkMethodCalls.setMediaAutoDownload(call: call, result: result)
            case "getMediaSetting":
                FlySdkMethodCalls.getMediaSetting(call: call, result: result)
            case "saveMediaSettings":
                FlySdkMethodCalls.saveMediaSettings(call: call, result: result)
            case "downloadMedia":
                FlySdkMethodCalls.downloadMedia(call: call, result: result)
            case "updateFavouriteStatus":
                FlySdkMethodCalls.updateFavouriteStatus(call: call, result: result)
            case "iOSFileExist":
                FlySdkMethodCalls.iOSFileExist(call: call, result: result)
            case "get_favourite_messages":
                FlySdkMethodCalls.getFavouriteMessages(call: call, result: result)
            case "getUnsentMessageOfAJid":
                FlySdkMethodCalls.getUnsentMessageOfAJid(call: call, result: result)
            case "saveUnsentMessage":
                FlySdkMethodCalls.saveUnsentMessage(call: call, result: result)
            default:
                result(FlutterMethodNotImplemented)
            }
            
        })
    }
    
    func applicationDidBecomeActive(){
        if Utility.getBoolFromPreference(key: isLoggedIn) && (FlyDefaults.isLoggedIn) {
            print("connecting chat manager")
            ChatManager.connect()
            ChatManager.shared.startAutoDownload()
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


extension FlyBaseController : MessageEventsDelegate, ConnectionEventDelegate, LogoutDelegate, GroupEventsDelegate,
                              AdminBlockCurrentUserDelegate, TypingStatusDelegate, ProfileEventsDelegate,
                              AdminBlockDelegate,AvailableFeaturesDelegate, BackupEventDelegate, RestoreEventDelegate {
    
    func onMessagesCleared(toJid: String, deleteType: String?) {
        
    }
    
    func restoreProgressDidReceive(completedCount: Double, completedPercentage: String, completedSize: String) {
        
    }
    
    func restoreDidFinish() {
        
    }
    
    func restoreDidFailed(errorMessage: String) {
        
    }
    
    
    func didUpdateAvailableFeatures(features: FlyCommon.AvailableFeaturesModel) {
        
    }
    func backupProgressDidReceive(completedCount: String, completedSize: String) {
        
    }
    
    func backupDidFinish(fileUrl: String) {
        
    }
    
    func backupDidFailed(errorMessage: String) {
        
    }
    
    func userCameOnline(for jid: String) {
        
        let jsonObject: NSMutableDictionary = NSMutableDictionary()
        jsonObject.setValue(jid, forKey: "jid")
        let jsonString = Commons.json(from: jsonObject)
        if(userCameOnlineStreamHandler?.userCameOnline != nil){
            userCameOnlineStreamHandler?.userCameOnline?(jsonString)
        }else{
            print("Chat Typing Stream Handler is Nil")
        }
    
    }
    
    func userWentOffline(for jid: String) {
        let jsonObject: NSMutableDictionary = NSMutableDictionary()
        jsonObject.setValue(jid, forKey: "jid")
        let jsonString = Commons.json(from: jsonObject)
        if(userWentOfflineStreamHandler?.userWentOffline != nil){
            userWentOfflineStreamHandler?.userWentOffline?(jsonString)
        }else{
            print("userWentOffline Stream Handler is Nil")
        }
    }
    
    func userProfileFetched(for jid: String, profileDetails: FlyCommon.ProfileDetails?) {
//        var userProfileJson = JSONSerializer.toJson(profileDetails as Any)
        let jsonObject: NSMutableDictionary = NSMutableDictionary()
        jsonObject.setValue(jid, forKey: "jid")
        jsonObject.setValue(profileDetails, forKey: "profileDetails")
        let jsonString = JSONSerializer.toJson(jsonObject)
        if(userProfileFetchedStreamHandler?.userProfileFetched != nil){
            userProfileFetchedStreamHandler?.userProfileFetched?(jsonString)
        }else{
            print("userProfileFetched Stream Handler is Nil")
        }
    }
    
    func myProfileUpdated() {
        if(myProfileUpdatedStreamHandler?.myProfileUpdated != nil){
            myProfileUpdatedStreamHandler?.myProfileUpdated?(true)
        }else{
            print("myProfileUpdated Stream Handler is Nil")
        }
    }
    
    func usersProfilesFetched() {
        if(usersProfilesFetchedStreamHandler?.usersProfilesFetched != nil){
            usersProfilesFetchedStreamHandler?.usersProfilesFetched?(true)
        }else{
            print("usersProfilesFetched Stream Handler is Nil")
        }
    }
    
    func blockedThisUser(jid: String) {
        let jsonObject: NSMutableDictionary = NSMutableDictionary()
        jsonObject.setValue(jid, forKey: "jid")
        let jsonString = Commons.json(from: jsonObject)
        if(blockedThisUserStreamHandler?.blockedThisUser != nil){
            blockedThisUserStreamHandler?.blockedThisUser?(jsonString)
        }else{
            print("blockedThisUser Stream Handler is Nil")
        }
    }
    
    func unblockedThisUser(jid: String) {
        let jsonObject: NSMutableDictionary = NSMutableDictionary()
        jsonObject.setValue(jid, forKey: "jid")
        let jsonString = Commons.json(from: jsonObject)
        if(unblockedThisUserStreamHandler?.unblockedThisUser != nil){
            unblockedThisUserStreamHandler?.unblockedThisUser?(jsonString)
        }else{
            print("unblockedThisUser Stream Handler is Nil")
        }
    }
    
    func usersIBlockedListFetched(jidList: [String]) {
        let jsonObject: NSMutableDictionary = NSMutableDictionary()
        jsonObject.setValue(jidList, forKey: "jidlist")
        let jsonString = Commons.json(from: jsonObject)
        if(usersIBlockedListFetchedStreamHandler?.usersIBlockedListFetched != nil){
            usersIBlockedListFetchedStreamHandler?.usersIBlockedListFetched?(jsonString)
        }else{
            print("usersIBlockedListFetched Stream Handler is Nil")
        }
    }
    
    func usersBlockedMeListFetched(jidList: [String]) {
        let jsonObject: NSMutableDictionary = NSMutableDictionary()
        jsonObject.setValue(jidList, forKey: "jidlist")
        let jsonString = Commons.json(from: jsonObject)
        if(usersWhoBlockedMeListFetchedStreamHandler?.usersWhoBlockedMeListFetched != nil){
            usersWhoBlockedMeListFetchedStreamHandler?.usersWhoBlockedMeListFetched?(jsonString)
        }else{
            print("usersBlockedMeListFetched Stream Handler is Nil")
        }
    }
    
    func userUpdatedTheirProfile(for jid: String, profileDetails: FlyCommon.ProfileDetails) {
        let jsonObject: NSMutableDictionary = NSMutableDictionary()
        jsonObject.setValue(jid, forKey: "jid")
        let jsonString = Commons.json(from: jsonObject)
        if(userUpdatedHisProfileStreamHandler?.userUpdatedHisProfile != nil){
            userUpdatedHisProfileStreamHandler?.userUpdatedHisProfile?(jsonString)
        }else{
            print("userUpdatedTheirProfile Stream Handler is Nil")
        }
        
    }
    
    func userBlockedMe(jid: String) {
        let jsonObject: NSMutableDictionary = NSMutableDictionary()
        jsonObject.setValue(jid, forKey: "jid")
        let jsonString = Commons.json(from: jsonObject)
        if(userBlockedMeStreamHandler?.userBlockedMe != nil){
            userBlockedMeStreamHandler?.userBlockedMe?(jsonString)
        }else{
            print("userBlockedMe Stream Handler is Nil")
        }
    }
    
    func userUnBlockedMe(jid: String) {
        let jsonObject: NSMutableDictionary = NSMutableDictionary()
        jsonObject.setValue(jid, forKey: "jid")
        let jsonString = Commons.json(from: jsonObject)
        if(userUnBlockedMeStreamHandler?.userUnBlockedMe != nil){
            userUnBlockedMeStreamHandler?.userUnBlockedMe?(jsonString)
        }else{
            print("userUnBlockedMe Stream Handler is Nil")
        }
    }
    
    func hideUserLastSeen() {
        
    }
    
    func getUserLastSeen() {
        
    }
    
    func userDeletedTheirProfile(for jid: String, profileDetails: FlyCommon.ProfileDetails) {
        let jsonObject: NSMutableDictionary = NSMutableDictionary()
        jsonObject.setValue(jid, forKey: "jid")
        let jsonString = Commons.json(from: jsonObject)
        if(userDeletedHisProfileStreamHandler?.userDeletedHisProfile != nil){
            userDeletedHisProfileStreamHandler?.userDeletedHisProfile?(jsonString)
        }else{
            print("userDeletedTheirProfile Stream Handler is Nil")
        }
    }
    
    func didBlockOrUnblockSelf(userJid: String, isBlocked: Bool) {
        
    }
    
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
        
        let jsonObject: NSMutableDictionary = NSMutableDictionary()
        jsonObject.setValue(userJid, forKey: "jid")
        jsonObject.setValue(isBlocked, forKey: "status")
        let jsonString = Commons.json(from: jsonObject)
        if(onAdminBlockedUserStreamHandler?.onAdminBlockedUser != nil){
            onAdminBlockedUserStreamHandler?.onAdminBlockedUser?(jsonString)
        }else{
            print("didBlockOrUnblockContact Stream Handler is Nil")
        }
        
    }
    
    func didBlockOrUnblockGroup(groupJid: String, isBlocked: Bool) {
        
    }
    
    func didBlockOrUnblockContact(userJid: String, isBlocked: Bool) {
        
        let jsonObject: NSMutableDictionary = NSMutableDictionary()
        jsonObject.setValue(userJid, forKey: "jid")
        jsonObject.setValue("", forKey: "type")
        jsonObject.setValue(isBlocked, forKey: "status")
        let jsonString = Commons.json(from: jsonObject)
        if(onAdminBlockedOtherUserStreamHandler?.onAdminBlockedOtherUser != nil){
            onAdminBlockedOtherUserStreamHandler?.onAdminBlockedOtherUser?(jsonString)
        }else{
            print("didBlockOrUnblockContact Stream Handler is Nil")
        }
        
    }
    
    func didAddNewMemeberToGroup(groupJid: String, newMemberJid: String, addedByMemberJid: String) {
        let jsonObject: NSMutableDictionary = NSMutableDictionary()
        jsonObject.setValue(groupJid, forKey: "groupJid")
        jsonObject.setValue(newMemberJid, forKey: "newMemberJid")
        jsonObject.setValue(addedByMemberJid, forKey: "addedByMemberJid")
        let jsonString = Commons.json(from: jsonObject)
        if(newMemberAddedToGroupStreamHandler?.onNewMemberAddedToGroup != nil){
            newMemberAddedToGroupStreamHandler?.onNewMemberAddedToGroup?(jsonString)
        }else{
            print("didAddNewMemeberToGroup Stream Handler is Nil")
        }
    }
    
    func didRemoveMemberFromGroup(groupJid: String, removedMemberJid: String, removedByMemberJid: String) {
        let jsonObject: NSMutableDictionary = NSMutableDictionary()
        jsonObject.setValue(groupJid, forKey: "groupJid")
        jsonObject.setValue(removedMemberJid, forKey: "removedMemberJid")
        jsonObject.setValue(removedByMemberJid, forKey: "removedByMemberJid")
        let jsonString = Commons.json(from: jsonObject)
        if(memberRemovedFromGroupStreamHandler?.onMemberRemovedFromGroup != nil){
            memberRemovedFromGroupStreamHandler?.onMemberRemovedFromGroup?(jsonString)
        }else{
            print("didRemoveMemberFromGroup Stream Handler is Nil")
        }
        
    }
    
    func didFetchGroupProfile(groupJid: String) {
        
        if(groupProfileFetchedStreamHandler?.onGroupProfileFetched != nil){
            groupProfileFetchedStreamHandler?.onGroupProfileFetched?(groupJid)
        }else{
            print("didFetchGroupProfile Stream Handler is Nil")
        }
        
    }
    
    func didUpdateGroupProfile(groupJid: String) {
        
        if(groupProfileUpdatedStreamHandler?.onGroupProfileUpdated != nil){
            groupProfileUpdatedStreamHandler?.onGroupProfileUpdated?(groupJid)
        }else{
            print("didUpdateGroupProfile Stream Handler is Nil")
        }
        
    }
    
    func didMakeMemberAsAdmin(groupJid: String, newAdminMemberJid: String, madeByMemberJid: String) {
        let jsonObject: NSMutableDictionary = NSMutableDictionary()
        jsonObject.setValue(groupJid, forKey: "groupJid")
        jsonObject.setValue(newAdminMemberJid, forKey: "newAdminMemberJid")
        jsonObject.setValue(madeByMemberJid, forKey: "madeByMemberJid")
        let jsonString = Commons.json(from: jsonObject)
        if(memberMadeAsAdminStreamHandler?.onMemberMadeAsAdmin != nil){
            memberMadeAsAdminStreamHandler?.onMemberMadeAsAdmin?(jsonString)
        }else{
            print("didMakeMemberAsAdmin Stream Handler is Nil")
        }
        
    }
    
    func didRemoveMemberFromAdmin(groupJid: String, removedAdminMemberJid: String, removedByMemberJid: String) {
        let jsonObject: NSMutableDictionary = NSMutableDictionary()
        jsonObject.setValue(groupJid, forKey: "groupJid")
        jsonObject.setValue(removedAdminMemberJid, forKey: "removedAdminMemberJid")
        jsonObject.setValue(removedByMemberJid, forKey: "removedByMemberJid")
        let jsonString = Commons.json(from: jsonObject)
        if(memberRemovedAsAdminStreamHandler?.onMemberRemovedAsAdmin != nil){
            memberRemovedAsAdminStreamHandler?.onMemberRemovedAsAdmin?(jsonString)
        }else{
            print("didRemoveMemberFromAdmin Stream Handler is Nil")
        }
        
    }
    
    func didDeleteGroupLocally(groupJid: String) {
        if(onGroupDeletedLocallyStreamHandler?.onGroupDeletedLocally != nil){
            onGroupDeletedLocallyStreamHandler?.onGroupDeletedLocally?(groupJid)
        }else{
            print("didDeleteGroupLocally Stream Handler is Nil")
        }
        
    }
    
    func didLeftFromGroup(groupJid: String, leftUserJid: String) {
        let jsonObject: NSMutableDictionary = NSMutableDictionary()
        jsonObject.setValue(groupJid, forKey: "groupJid")
        jsonObject.setValue(leftUserJid, forKey: "leftUserJid")
        let jsonString = Commons.json(from: jsonObject)
        if(leftFromGroupStreamHandler?.onLeftFromGroup != nil){
            leftFromGroupStreamHandler?.onLeftFromGroup?(jsonString)
        }else{
            print("didRemoveMemberFromAdmin Stream Handler is Nil")
        }
    }
    
    func didCreateGroup(groupJid: String) {
        if(newGroupCreatedStreamHandler?.onNewGroupCreated != nil){
            newGroupCreatedStreamHandler?.onNewGroupCreated?(groupJid)
        }else{
            print("didCreateGroup Stream Handler is Nil")
        }
    }
    
    func didFetchGroups(groups: [FlyCommon.ProfileDetails]) {
        
    }
    
    func didFetchGroupMembers(groupJid: String) {
        if(fetchingGroupMembersCompletedStreamHandler?.onFetchingGroupMembersCompleted != nil){
            fetchingGroupMembersCompletedStreamHandler?.onFetchingGroupMembersCompleted?(groupJid)
        }else{
            print("didFetchGroupMembers Stream Handler is Nil")
        }
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
        if(onConnectedStreamHandler?.onConnected != nil){
            onConnectedStreamHandler?.onConnected?(true)
        }else{
            print("onConnected Stream Handler is Nil")
        }
    }

    func onDisconnected() {
        print("====== sdk Disconnected======")
        if(onDisconnectedStreamHandler?.onDisconnected != nil){
            onDisconnectedStreamHandler?.onDisconnected?(true)
        }else{
            print("onDisconnected Stream Handler is Nil")
        }
    }

    func onConnectionNotAuthorized() {
        print("====== sdk Not Authorized=======")
        if(onConnectionNotAuthorizedStreamHandler?.onConnectionNotAuthorized != nil){
            onConnectionNotAuthorizedStreamHandler?.onConnectionNotAuthorized?(true)
        }else{
            print("onConnectionNotAuthorized Stream Handler is Nil")
        }
    }

}
