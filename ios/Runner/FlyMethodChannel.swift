//
//  FlyMethodChannel.swift
//  Runner
//
//  Created by ManiVendhan on 10/11/22.
//

import Foundation
import Flutter

class FlyMethodChannel{
    
    static func prepareMethodHandler(methodChannel: FlutterMethodChannel){
        methodChannel.setMethodCallHandler({
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            switch call.method {
            case "syncContacts":
                FlySdkMethodCalls.syncContacts(call: call, result: result)
            case "contactSyncStateValue"://need to cross check with saravanan
                FlySdkMethodCalls.contactSyncStateValue(call: call, result: result)
            case "contactSyncState":
                FlySdkMethodCalls.contactSyncState(call: call, result: result)
            case "revokeContactSync":
                FlySdkMethodCalls.revokeContactSync(call: call, result: result)
            case "getUsersWhoBlockedMe":
                FlySdkMethodCalls.getUsersWhoBlockedMe(call: call, result: result)
            case "getUnKnownUserProfiles":
                FlySdkMethodCalls.getUnKnownUserProfiles(call: call, result: result)
            case "getMyProfileStatus"://need to cross check with saravanan. bcz profile status is received in profile, why need seperate function
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
            case "deleteAllMessages"://need to discuss with saravanan bcz there is clear chat as a seperate function
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
                FlySdkMethodCalls.getUserList(call: call, result: result)
                
            case "getUserProfile":
                FlySdkMethodCalls.getUserProfile(call: call, result: result)
            case "clear_chat":
                FlySdkMethodCalls.clearChat(call: call, result: result)
                
            case "updateMyProfile":
                FlySdkMethodCalls.updateMyProfile(call: call, result: result)
                
            case "media_endpoint":
                FlySdkMethodCalls.getMediaEndPoint(call: call, result: result)
            default:
                result(FlutterMethodNotImplemented)
            }
            
        })
    }
    
    //get_image_path
    
}

