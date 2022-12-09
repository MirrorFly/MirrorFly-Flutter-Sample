package com.contusdemo.mirror_fly_demo

import io.flutter.plugin.common.EventChannel

object MessageReceivedStreamHandler : EventChannel.StreamHandler {

    var onMessageReceived: EventChannel.EventSink? = null

    
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        onMessageReceived = events
    }

    override fun onCancel(arguments: Any?) {
        onMessageReceived = null
    }
}
object MessageStatusUpdatedStreamHandler : EventChannel.StreamHandler {

    var onMessageStatusUpdated: EventChannel.EventSink? = null

    
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        onMessageStatusUpdated = events
    }

    override fun onCancel(arguments: Any?) {
        onMessageStatusUpdated = null
    }
}
object MediaStatusUpdatedStreamHandler : EventChannel.StreamHandler {

    var onMediaStatusUpdated: EventChannel.EventSink? = null

    
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        onMediaStatusUpdated = events
    }

    override fun onCancel(arguments: Any?) {
        onMediaStatusUpdated = null
    }
}
object UploadDownloadProgressChangedStreamHandler : EventChannel.StreamHandler {

    var onUploadDownloadProgressChanged: EventChannel.EventSink? = null

    
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        onUploadDownloadProgressChanged = events
    }

    override fun onCancel(arguments: Any?) {
        onUploadDownloadProgressChanged = null
    }
}
object ShowOrUpdateOrCancelNotificationStreamHandler : EventChannel.StreamHandler {

    var showOrUpdateOrCancelNotification: EventChannel.EventSink? = null

    
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        showOrUpdateOrCancelNotification = events
    }

    override fun onCancel(arguments: Any?) {
        showOrUpdateOrCancelNotification = null
    }
}
object onGroupProfileFetchedStreamHandler : EventChannel.StreamHandler {

    var onGroupProfileFetched: EventChannel.EventSink? = null

    
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        onGroupProfileFetched = events
    }

    override fun onCancel(arguments: Any?) {
        onGroupProfileFetched = null
    }
}
object onNewGroupCreatedStreamHandler : EventChannel.StreamHandler {

    var onNewGroupCreated: EventChannel.EventSink? = null

    
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        onNewGroupCreated = events
    }

    override fun onCancel(arguments: Any?) {
        onNewGroupCreated = null
    }
}
object onGroupProfileUpdatedStreamHandler : EventChannel.StreamHandler {

    var onGroupProfileUpdated: EventChannel.EventSink? = null

    
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        onGroupProfileUpdated = events
    }

    override fun onCancel(arguments: Any?) {
        onGroupProfileUpdated = null
    }
}
object onNewMemberAddedToGroupStreamHandler : EventChannel.StreamHandler {

    var onNewMemberAddedToGroup: EventChannel.EventSink? = null

    
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        onNewMemberAddedToGroup = events
    }

    override fun onCancel(arguments: Any?) {
        onNewMemberAddedToGroup = null
    }
}
object onMemberRemovedFromGroupStreamHandler : EventChannel.StreamHandler {

    var onMemberRemovedFromGroup: EventChannel.EventSink? = null

    
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        onMemberRemovedFromGroup = events
    }

    override fun onCancel(arguments: Any?) {
        onMemberRemovedFromGroup = null
    }
}
object onFetchingGroupMembersCompletedStreamHandler : EventChannel.StreamHandler {

    var onFetchingGroupMembersCompleted: EventChannel.EventSink? = null

    
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        onFetchingGroupMembersCompleted = events
    }

    override fun onCancel(arguments: Any?) {
        onFetchingGroupMembersCompleted = null
    }
}
object onDeleteGroupStreamHandler : EventChannel.StreamHandler {

    var onDeleteGroup: EventChannel.EventSink? = null

    
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        onDeleteGroup = events
    }

    override fun onCancel(arguments: Any?) {
        onDeleteGroup = null
    }
}
object onFetchingGroupListCompletedStreamHandler : EventChannel.StreamHandler {

    var onFetchingGroupListCompleted: EventChannel.EventSink? = null

    
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        onFetchingGroupListCompleted = events
    }

    override fun onCancel(arguments: Any?) {
        onFetchingGroupListCompleted = null
    }
}
object onMemberMadeAsAdminStreamHandler : EventChannel.StreamHandler {

    var onMemberMadeAsAdmin: EventChannel.EventSink? = null

    
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        onMemberMadeAsAdmin = events
    }

    override fun onCancel(arguments: Any?) {
        onMemberMadeAsAdmin = null
    }
}
object onMemberRemovedAsAdminStreamHandler : EventChannel.StreamHandler {

    var onMemberRemovedAsAdmin: EventChannel.EventSink? = null

    
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        onMemberRemovedAsAdmin = events
    }

    override fun onCancel(arguments: Any?) {
        onMemberRemovedAsAdmin = null
    }
}
object onLeftFromGroupStreamHandler : EventChannel.StreamHandler {

    var onLeftFromGroup: EventChannel.EventSink? = null

    
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        onLeftFromGroup = events
    }

    override fun onCancel(arguments: Any?) {
        onLeftFromGroup = null
    }
}
object onGroupNotificationMessageStreamHandler : EventChannel.StreamHandler {

    var onGroupNotificationMessage: EventChannel.EventSink? = null

    
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        onGroupNotificationMessage = events
    }

    override fun onCancel(arguments: Any?) {
        onGroupNotificationMessage = null
    }
}
object onGroupDeletedLocallyStreamHandler : EventChannel.StreamHandler {

    var onGroupDeletedLocally: EventChannel.EventSink? = null

    
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        onGroupDeletedLocally = events
    }

    override fun onCancel(arguments: Any?) {
        onGroupDeletedLocally = null
    }
}
object blockedThisUserStreamHandler : EventChannel.StreamHandler {

    var blockedThisUser: EventChannel.EventSink? = null


    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        blockedThisUser = events
    }

    override fun onCancel(arguments: Any?) {
        blockedThisUser = null
    }
}
object myProfileUpdatedStreamHandler : EventChannel.StreamHandler {

    var myProfileUpdated: EventChannel.EventSink? = null


    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        myProfileUpdated = events
    }

    override fun onCancel(arguments: Any?) {
        myProfileUpdated = null
    }
}
object onAdminBlockedOtherUserStreamHandler : EventChannel.StreamHandler {

    var onAdminBlockedOtherUser: EventChannel.EventSink? = null


    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        onAdminBlockedOtherUser = events
    }

    override fun onCancel(arguments: Any?) {
        onAdminBlockedOtherUser = null
    }
}
object onAdminBlockedUserStreamHandler : EventChannel.StreamHandler {

    var onAdminBlockedUser: EventChannel.EventSink? = null


    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        onAdminBlockedUser = events
    }

    override fun onCancel(arguments: Any?) {
        onAdminBlockedUser = null
    }
}
object onContactSyncCompleteStreamHandler : EventChannel.StreamHandler {

    var onContactSyncComplete: EventChannel.EventSink? = null


    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        onContactSyncComplete = events
    }

    override fun onCancel(arguments: Any?) {
        onContactSyncComplete = null
    }
}
object onLoggedOutStreamHandler : EventChannel.StreamHandler {

    var onLoggedOut: EventChannel.EventSink? = null


    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        onLoggedOut = events
    }

    override fun onCancel(arguments: Any?) {
        onLoggedOut = null
    }
}
object unblockedThisUserStreamHandler : EventChannel.StreamHandler {

    var unblockedThisUser: EventChannel.EventSink? = null


    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        unblockedThisUser = events
    }

    override fun onCancel(arguments: Any?) {
        unblockedThisUser = null
    }
}
object userBlockedMeStreamHandler : EventChannel.StreamHandler {

    var userBlockedMe: EventChannel.EventSink? = null


    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        userBlockedMe = events
    }

    override fun onCancel(arguments: Any?) {
        userBlockedMe = null
    }
}
object userCameOnlineStreamHandler : EventChannel.StreamHandler {

    var userCameOnline: EventChannel.EventSink? = null


    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        userCameOnline = events
    }

    override fun onCancel(arguments: Any?) {
        userCameOnline = null
    }
}
object userDeletedHisProfileStreamHandler : EventChannel.StreamHandler {

    var userDeletedHisProfile: EventChannel.EventSink? = null


    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        userDeletedHisProfile = events
    }

    override fun onCancel(arguments: Any?) {
        userDeletedHisProfile = null
    }
}
object userProfileFetchedStreamHandler : EventChannel.StreamHandler {

    var userProfileFetched: EventChannel.EventSink? = null


    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        userProfileFetched = events
    }

    override fun onCancel(arguments: Any?) {
        userProfileFetched = null
    }
}
object userUnBlockedMeStreamHandler : EventChannel.StreamHandler {

    var userUnBlockedMe: EventChannel.EventSink? = null


    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        userUnBlockedMe = events
    }

    override fun onCancel(arguments: Any?) {
        userUnBlockedMe = null
    }
}
object userUpdatedHisProfileStreamHandler : EventChannel.StreamHandler {

    var userUpdatedHisProfile: EventChannel.EventSink? = null


    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        userUpdatedHisProfile = events
    }

    override fun onCancel(arguments: Any?) {
        userUpdatedHisProfile = null
    }
}
object userWentOfflineStreamHandler : EventChannel.StreamHandler {

    var userWentOffline: EventChannel.EventSink? = null


    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        userWentOffline = events
    }

    override fun onCancel(arguments: Any?) {
        userWentOffline = null
    }
}
object usersIBlockedListFetchedStreamHandler : EventChannel.StreamHandler {

    var usersIBlockedListFetched: EventChannel.EventSink? = null


    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        usersIBlockedListFetched = events
    }

    override fun onCancel(arguments: Any?) {
        usersIBlockedListFetched = null
    }
}
object usersProfilesFetchedStreamHandler : EventChannel.StreamHandler {

    var usersProfilesFetched: EventChannel.EventSink? = null


    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        usersProfilesFetched = events
    }

    override fun onCancel(arguments: Any?) {
        usersProfilesFetched = null
    }
}
object usersWhoBlockedMeListFetchedStreamHandler : EventChannel.StreamHandler {

    var usersWhoBlockedMeListFetched: EventChannel.EventSink? = null


    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        usersWhoBlockedMeListFetched = events
    }

    override fun onCancel(arguments: Any?) {
        usersWhoBlockedMeListFetched = null
    }
}
object onConnectedStreamHandler : EventChannel.StreamHandler {

    var onConnected: EventChannel.EventSink? = null


    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        onConnected = events
    }

    override fun onCancel(arguments: Any?) {
        onConnected = null
    }
}
object onDisconnectedStreamHandler : EventChannel.StreamHandler {

    var onDisconnected: EventChannel.EventSink? = null


    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        onDisconnected = events
    }

    override fun onCancel(arguments: Any?) {
        onDisconnected = null
    }
}
object onConnectionNotAuthorizedStreamHandler : EventChannel.StreamHandler {

    var onConnectionNotAuthorized: EventChannel.EventSink? = null


    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        onConnectionNotAuthorized = events
    }

    override fun onCancel(arguments: Any?) {
        onConnectionNotAuthorized = null
    }
}
object connectionFailedStreamHandler : EventChannel.StreamHandler {

    var connectionFailed: EventChannel.EventSink? = null


    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        connectionFailed = events
    }

    override fun onCancel(arguments: Any?) {
        connectionFailed = null
    }
}
object connectionSuccessStreamHandler : EventChannel.StreamHandler {

    var connectionSuccess: EventChannel.EventSink? = null


    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        connectionSuccess = events
    }

    override fun onCancel(arguments: Any?) {
        connectionSuccess = null
    }
}
object onWebChatPasswordChangedStreamHandler : EventChannel.StreamHandler {

    var onWebChatPasswordChanged: EventChannel.EventSink? = null


    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        onWebChatPasswordChanged = events
    }

    override fun onCancel(arguments: Any?) {
        onWebChatPasswordChanged = null
    }
}
object setTypingStatusStreamHandler : EventChannel.StreamHandler {

    var setTypingStatus: EventChannel.EventSink? = null


    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        setTypingStatus = events
    }

    override fun onCancel(arguments: Any?) {
        setTypingStatus = null
    }
}
object onChatTypingStatusStreamHandler : EventChannel.StreamHandler {

    var onChatTypingStatus: EventChannel.EventSink? = null


    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        onChatTypingStatus = events
    }

    override fun onCancel(arguments: Any?) {
        onChatTypingStatus = null
    }
}
object onGroupTypingStatusStreamHandler : EventChannel.StreamHandler {

    var onGroupTypingStatus: EventChannel.EventSink? = null


    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        onGroupTypingStatus = events
    }

    override fun onCancel(arguments: Any?) {
        onGroupTypingStatus = null
    }
}
object onFailureStreamHandler : EventChannel.StreamHandler {

    var onFailure: EventChannel.EventSink? = null


    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        onFailure = events
    }

    override fun onCancel(arguments: Any?) {
        onFailure = null
    }
}
object onProgressChangedStreamHandler : EventChannel.StreamHandler {

    var onProgressChanged: EventChannel.EventSink? = null


    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        onProgressChanged = events
    }

    override fun onCancel(arguments: Any?) {
        onProgressChanged = null
    }
}
object onSuccessStreamHandler : EventChannel.StreamHandler {

    var onSuccess: EventChannel.EventSink? = null


    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        onSuccess = events
    }

    override fun onCancel(arguments: Any?) {
        onSuccess = null
    }
}


