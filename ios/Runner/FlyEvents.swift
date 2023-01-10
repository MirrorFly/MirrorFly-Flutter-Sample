//
//  FlyEvents.swift
//  Runner
//
//  Created by User on 01/12/22.
//

import Foundation
import Flutter



public class MessageReceivedStreamHandler: FlutterStreamHandler {
    public var onMessageReceived: FlutterEventSink?
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.onMessageReceived = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.onMessageReceived = nil
        return nil
    }
    
}
class MessageStatusUpdatedStreamHandler: NSObject, FlutterStreamHandler {
    public var onMessageStatusUpdated: FlutterEventSink?
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.onMessageStatusUpdated = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.onMessageStatusUpdated = nil
        return nil
    }
}
class MediaStatusUpdatedStreamHandler: NSObject, FlutterStreamHandler {
    public var onMediaStatusUpdated: FlutterEventSink?
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.onMediaStatusUpdated = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.onMediaStatusUpdated = nil
        return nil
    }
}
class UploadDownloadProgressChangedStreamHandler: NSObject, FlutterStreamHandler {
    public var onUploadDownloadProgressChanged: FlutterEventSink?
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        onUploadDownloadProgressChanged = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        onUploadDownloadProgressChanged = nil
        return nil
    }
}
class ShowOrUpdateOrCancelNotificationStreamHandler: NSObject, FlutterStreamHandler {
    public var showOrUpdateOrCancelNotification: FlutterEventSink?
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        showOrUpdateOrCancelNotification = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        showOrUpdateOrCancelNotification = nil
        return nil
    }
}
class GroupProfileFetchedStreamHandler: NSObject, FlutterStreamHandler {
    public var onGroupProfileFetched: FlutterEventSink?
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        onGroupProfileFetched = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        onGroupProfileFetched = nil
        return nil
    }
}

class NewGroupCreatedStreamHandler: NSObject, FlutterStreamHandler {
    public var onNewGroupCreated: FlutterEventSink?
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        onNewGroupCreated = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        onNewGroupCreated = nil
        return nil
    }
}
class GroupProfileUpdatedStreamHandler: NSObject, FlutterStreamHandler {
    public var onGroupProfileUpdated: FlutterEventSink?
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        onGroupProfileUpdated = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        onGroupProfileUpdated = nil
        return nil
    }
}
class NewMemberAddedToGroupStreamHandler: NSObject, FlutterStreamHandler {
    public var onNewMemberAddedToGroup: FlutterEventSink?
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        onNewMemberAddedToGroup = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        onNewMemberAddedToGroup = nil
        return nil
    }
}
class MemberRemovedFromGroupStreamHandler: NSObject, FlutterStreamHandler {
    public var onMemberRemovedFromGroup: FlutterEventSink?
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        onMemberRemovedFromGroup = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        onMemberRemovedFromGroup = nil
        return nil
    }
}
class FetchingGroupMembersCompletedStreamHandler: NSObject, FlutterStreamHandler {
    public var onFetchingGroupMembersCompleted: FlutterEventSink?
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        onFetchingGroupMembersCompleted = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        onFetchingGroupMembersCompleted = nil
        return nil
    }
}
class DeleteGroupStreamHandler: NSObject, FlutterStreamHandler {
    public var onDeleteGroup: FlutterEventSink?
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        onDeleteGroup = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        onDeleteGroup = nil
        return nil
    }
}
class FetchingGroupListCompletedStreamHandler: NSObject, FlutterStreamHandler {
    public var onFetchingGroupListCompleted: FlutterEventSink?
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        onFetchingGroupListCompleted = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        onFetchingGroupListCompleted = nil
        return nil
    }
}
class MemberMadeAsAdminStreamHandler: NSObject, FlutterStreamHandler {
    public var onMemberMadeAsAdmin: FlutterEventSink?
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        onMemberMadeAsAdmin = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        onMemberMadeAsAdmin = nil
        return nil
    }
}
class MemberRemovedAsAdminStreamHandler: NSObject, FlutterStreamHandler {
    public var onMemberRemovedAsAdmin: FlutterEventSink?
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        onMemberRemovedAsAdmin = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        onMemberRemovedAsAdmin = nil
        return nil
    }
}
class LeftFromGroupStreamHandler: NSObject, FlutterStreamHandler {
    public var onLeftFromGroup: FlutterEventSink?
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        onLeftFromGroup = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        onLeftFromGroup = nil
        return nil
    }
}

class GroupNotificationMessageStreamHandler: NSObject, FlutterStreamHandler {
    public var onGroupNotificationMessage: FlutterEventSink?
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        onGroupNotificationMessage = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        onGroupNotificationMessage = nil
        return nil
    }
}
class GroupDeletedLocallyStreamHandler: NSObject, FlutterStreamHandler {
    public var onGroupDeletedLocally: FlutterEventSink?
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        onGroupDeletedLocally = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        onGroupDeletedLocally = nil
        return nil
    }
}
class blockedThisUserStreamHandler: NSObject, FlutterStreamHandler {
    public var blockedThisUser: FlutterEventSink?
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        blockedThisUser = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        blockedThisUser = nil
        return nil
    }
}
class myProfileUpdatedStreamHandler: NSObject, FlutterStreamHandler {
    public var myProfileUpdated: FlutterEventSink?
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        myProfileUpdated = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        myProfileUpdated = nil
        return nil
    }
}
class onAdminBlockedOtherUserStreamHandler: NSObject, FlutterStreamHandler {
    public var onAdminBlockedOtherUser: FlutterEventSink?
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        onAdminBlockedOtherUser = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        onAdminBlockedOtherUser = nil
        return nil
    }
}
class onAdminBlockedUserStreamHandler: NSObject, FlutterStreamHandler {
    public var onAdminBlockedUser: FlutterEventSink?
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        onAdminBlockedUser = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        onAdminBlockedUser = nil
        return nil
    }
}
class onContactSyncCompleteStreamHandler: NSObject, FlutterStreamHandler {
    public var onContactSyncComplete: FlutterEventSink?
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        onContactSyncComplete = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        onContactSyncComplete = nil
        return nil
    }
}
class onLoggedOutStreamHandler: NSObject, FlutterStreamHandler {
    public var onLoggedOut: FlutterEventSink?
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        onLoggedOut = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        onLoggedOut = nil
        return nil
    }
}
class unblockedThisUserStreamHandler: NSObject, FlutterStreamHandler {
    public var unblockedThisUser: FlutterEventSink?
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        unblockedThisUser = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        unblockedThisUser = nil
        return nil
    }
}
class userBlockedMeStreamHandler: NSObject, FlutterStreamHandler {
    public var userBlockedMe: FlutterEventSink?
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        userBlockedMe = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        userBlockedMe = nil
        return nil
    }
}
class userCameOnlineStreamHandler: NSObject, FlutterStreamHandler {
    public var userCameOnline: FlutterEventSink?
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        userCameOnline = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        userCameOnline = nil
        return nil
    }
}
class userDeletedHisProfileStreamHandler: NSObject, FlutterStreamHandler {
    public var userDeletedHisProfile: FlutterEventSink?
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        userDeletedHisProfile = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        userDeletedHisProfile = nil
        return nil
    }
}
class userProfileFetchedStreamHandler: NSObject, FlutterStreamHandler {
    public var userProfileFetched: FlutterEventSink?
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        userProfileFetched = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        userProfileFetched = nil
        return nil
    }
}
class userUnBlockedMeStreamHandler: NSObject, FlutterStreamHandler {
    public var userUnBlockedMe: FlutterEventSink?
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        userUnBlockedMe = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        userUnBlockedMe = nil
        return nil
    }
}
class userUpdatedHisProfileStreamHandler: NSObject, FlutterStreamHandler {
    public var userUpdatedHisProfile: FlutterEventSink?
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        userUpdatedHisProfile = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        userUpdatedHisProfile = nil
        return nil
    }
}
class userWentOfflineStreamHandler: NSObject, FlutterStreamHandler {
    public var userWentOffline: FlutterEventSink?
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        userWentOffline = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        userWentOffline = nil
        return nil
    }
}
class usersIBlockedListFetchedStreamHandler: NSObject, FlutterStreamHandler {
    public var usersIBlockedListFetched: FlutterEventSink?
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        usersIBlockedListFetched = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        usersIBlockedListFetched = nil
        return nil
    }
}
class usersProfilesFetchedStreamHandler: NSObject, FlutterStreamHandler {
    public var usersProfilesFetched: FlutterEventSink?
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        usersProfilesFetched = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        usersProfilesFetched = nil
        return nil
    }
}
class usersWhoBlockedMeListFetchedStreamHandler: NSObject, FlutterStreamHandler {
    public var usersWhoBlockedMeListFetched: FlutterEventSink?
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        usersWhoBlockedMeListFetched = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        usersWhoBlockedMeListFetched = nil
        return nil
    }
}
class onConnectedStreamHandler: NSObject, FlutterStreamHandler {
    public var onConnected: FlutterEventSink?
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        onConnected = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        onConnected = nil
        return nil
    }
}
class onDisconnectedStreamHandler: NSObject, FlutterStreamHandler {
    public var onDisconnected: FlutterEventSink?
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        onDisconnected = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        onDisconnected = nil
        return nil
    }
}
class onConnectionNotAuthorizedStreamHandler: NSObject, FlutterStreamHandler {
    public var onConnectionNotAuthorized: FlutterEventSink?
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        onConnectionNotAuthorized = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        onConnectionNotAuthorized = nil
        return nil
    }
}
class connectionFailedStreamHandler: NSObject, FlutterStreamHandler {
    public var connectionFailed: FlutterEventSink?
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        connectionFailed = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        connectionFailed = nil
        return nil
    }
}
class connectionSuccessStreamHandler: NSObject, FlutterStreamHandler {
    public var connectionSuccess: FlutterEventSink?
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        connectionSuccess = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        connectionSuccess = nil
        return nil
    }
}
class onWebChatPasswordChangedStreamHandler: NSObject, FlutterStreamHandler {
    public var onWebChatPasswordChanged: FlutterEventSink?
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        onWebChatPasswordChanged = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        onWebChatPasswordChanged = nil
        return nil
    }
}
class setTypingStatusStreamHandler: NSObject, FlutterStreamHandler {
    public var setTypingStatus: FlutterEventSink?
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        setTypingStatus = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        setTypingStatus = nil
        return nil
    }
}
class onChatTypingStatusStreamHandler: NSObject, FlutterStreamHandler {
    public var onChatTypingStatus: FlutterEventSink?
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        onChatTypingStatus = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        onChatTypingStatus = nil
        return nil
    }
}
class onGroupTypingStatusStreamHandler: NSObject, FlutterStreamHandler {
    public var onGroupTypingStatus: FlutterEventSink?
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        onGroupTypingStatus = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        onGroupTypingStatus = nil
        return nil
    }
}
class onFailureStreamHandler: NSObject, FlutterStreamHandler {
    public var onFailure: FlutterEventSink?
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        onFailure = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        onFailure = nil
        return nil
    }
}
class onProgressChangedStreamHandler: NSObject, FlutterStreamHandler {
    public var onProgressChanged: FlutterEventSink?
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        onProgressChanged = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        onProgressChanged = nil
        return nil
    }
}
class onSuccessStreamHandler: NSObject, FlutterStreamHandler {
    public var onSuccess: FlutterEventSink?
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        onSuccess = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        onSuccess = nil
        return nil
    }
}
class OnChatTypingStatusStreamHandler: NSObject, FlutterStreamHandler {
    public var onChatTyping: FlutterEventSink?
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.onChatTyping = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.onChatTyping = nil
        return nil
    }
}
class OnGroupTypingStatusStreamHandler: NSObject, FlutterStreamHandler {
    public var onGroupTyping: FlutterEventSink?
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.onGroupTyping = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.onGroupTyping = nil
        return nil
    }
}
