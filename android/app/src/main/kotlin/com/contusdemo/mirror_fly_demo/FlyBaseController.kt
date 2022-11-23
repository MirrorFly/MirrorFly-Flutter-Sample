package com.contusdemo.mirror_fly_demo

import android.annotation.SuppressLint
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.pm.ResolveInfo
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.media.RingtoneManager
import android.media.ThumbnailUtils
import android.net.Uri
import android.os.*
import android.util.Base64
import android.webkit.MimeTypeMap
import android.widget.Toast
import androidx.core.content.FileProvider
import com.contus.flycommons.*
import com.contus.flynetwork.model.verifyfcm.VerifyFcmResponse
import com.contus.xmpp.chat.models.CreateGroupModel
import com.contus.xmpp.chat.models.Profile
import com.contusflysdk.AppUtils
import com.contusflysdk.api.*
import com.contusflysdk.api.chat.*
import com.contusflysdk.api.contacts.ContactManager
import com.contusflysdk.api.contacts.ProfileDetails
import com.contusflysdk.api.models.ChatMessage
import com.contusflysdk.api.models.ChatMessageStatusDetail
import com.contusflysdk.api.network.FlyNetwork
import com.contusflysdk.api.notification.PushNotificationManager
import com.contusflysdk.media.MediaUploadHelper
import com.contusflysdk.utils.ThumbSize
import com.contusflysdk.utils.UpDateWebPassword
import com.contusflysdk.utils.VideoRecUtils
import com.google.gson.Gson
import io.flutter.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject
import java.io.ByteArrayOutputStream
import java.io.File
import java.io.FileWriter
import java.io.IOException

class FlyBaseController(applicationContext: Context) : MethodChannel.MethodCallHandler, ChatEvents, GroupEventsListener,
    ProfileEventsListener, ChatConnectionListener, MessageEventsListener, LoginEventsListener, TypingEventListener {

    private val MIRRORFLY_METHOD_CHANNEL = "contus.mirrorfly/sdkCall"
    private val MESSAGE_ONRECEIVED_CHANNEL = "contus.mirrorfly/onMessageReceived"
    private val MESSAGE_STATUS_UPDATED_CHANNEL = "contus.mirrorfly/onMessageStatusUpdated"
    private val MEDIA_STATUS_UPDATED_CHANNEL = "contus.mirrorfly/onMediaStatusUpdated"
    private val UPLOAD_DOWNLOAD_PROGRESS_CHANGED_CHANNEL =
        "contus.mirrorfly/onUploadDownloadProgressChanged"
    private val SHOW_UPDATE_CANCEL_NOTIFICTION_CHANNEL =
        "contus.mirrorfly/showOrUpdateOrCancelNotification"

    private val onGroupProfileFetched_channel = "contus.mirrorfly/onGroupProfileFetched"
    private val onNewGroupCreated_channel = "contus.mirrorfly/onNewGroupCreated"
    private val onGroupProfileUpdated_channel = "contus.mirrorfly/onGroupProfileUpdated"
    private val onNewMemberAddedToGroup_channel = "contus.mirrorfly/onNewMemberAddedToGroup"
    private val onMemberRemovedFromGroup_channel = "contus.mirrorfly/onMemberRemovedFromGroup"
    private val onFetchingGroupMembersCompleted_channel =
        "contus.mirrorfly/onFetchingGroupMembersCompleted"
    private val onDeleteGroup_channel = "contus.mirrorfly/onDeleteGroup"
    private val onFetchingGroupListCompleted_channel =
        "contus.mirrorfly/onFetchingGroupListCompleted"
    private val onMemberMadeAsAdmin_channel = "contus.mirrorfly/onMemberMadeAsAdmin"
    private val onMemberRemovedAsAdmin_channel = "contus.mirrorfly/onMemberRemovedAsAdmin"
    private val onLeftFromGroup_channel = "contus.mirrorfly/onLeftFromGroup"
    private val onGroupNotificationMessage_channel = "contus.mirrorfly/onGroupNotificationMessage"
    private val onGroupDeletedLocally_channel = "contus.mirrorfly/onGroupDeletedLocally"

    private val TAG = "MirrorFly"

    private val mContext: Context = applicationContext


    fun configureMethodChannels (flutterEngine: FlutterEngine){
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            MIRRORFLY_METHOD_CHANNEL
        ).setMethodCallHandler(this)
        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            MESSAGE_ONRECEIVED_CHANNEL
        ).setStreamHandler(MessageReceivedStreamHandler)
        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            MESSAGE_STATUS_UPDATED_CHANNEL
        ).setStreamHandler(MessageStatusUpdatedStreamHandler)
        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            MEDIA_STATUS_UPDATED_CHANNEL
        ).setStreamHandler(MediaStatusUpdatedStreamHandler)
        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            UPLOAD_DOWNLOAD_PROGRESS_CHANGED_CHANNEL
        ).setStreamHandler(UploadDownloadProgressChangedStreamHandler)
        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            SHOW_UPDATE_CANCEL_NOTIFICTION_CHANNEL
        ).setStreamHandler(ShowOrUpdateOrCancelNotificationStreamHandler)

        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            onGroupProfileFetched_channel
        ).setStreamHandler(onGroupProfileFetchedStreamHandler)
        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            onNewGroupCreated_channel
        ).setStreamHandler(onNewGroupCreatedStreamHandler)
        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            onGroupProfileUpdated_channel
        ).setStreamHandler(onGroupProfileUpdatedStreamHandler)
        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            onNewMemberAddedToGroup_channel
        ).setStreamHandler(onNewMemberAddedToGroupStreamHandler)
        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            onMemberRemovedFromGroup_channel
        ).setStreamHandler(onMemberRemovedFromGroupStreamHandler)
        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            onFetchingGroupMembersCompleted_channel
        ).setStreamHandler(onFetchingGroupMembersCompletedStreamHandler)
        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            onDeleteGroup_channel
        ).setStreamHandler(onDeleteGroupStreamHandler)
        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            onFetchingGroupListCompleted_channel
        ).setStreamHandler(onFetchingGroupListCompletedStreamHandler)
        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            onMemberMadeAsAdmin_channel
        ).setStreamHandler(onMemberMadeAsAdminStreamHandler)
        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            onMemberRemovedAsAdmin_channel
        ).setStreamHandler(onMemberRemovedAsAdminStreamHandler)
        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            onLeftFromGroup_channel
        ).setStreamHandler(onLeftFromGroupStreamHandler)
        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            onGroupNotificationMessage_channel
        ).setStreamHandler(onGroupNotificationMessageStreamHandler)
        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            onGroupDeletedLocally_channel
        ).setStreamHandler(onGroupDeletedLocallyStreamHandler)

        listenChatMessage()
        listenGroupChatMessage()
    }

    private fun registerUser(call: MethodCall, result: MethodChannel.Result) {
        if (!call.hasArgument("userIdentifier")) {
            result.error("404", "User Mobile Number Required", null)
        } else {
            val userIdentifier: String? = call.argument("userIdentifier")
            val token: String = call.argument("token") ?: ""
            if (userIdentifier != null) {
                Log.e(TAG, userIdentifier.toString())

                try {
                    FlyCore.registerUser(
                        userIdentifier,
                        token
                    ) { isSuccess: Boolean, throwable: Throwable?, data: HashMap<String?, Any?> ->
                        if (isSuccess) {

                            val response = JSONObject(data).toString()
                            Log.e("RESPONSE_CAPTURE", "===========================")
                            DebugUtilis.v("FlyCore.registerUser", data.tojsonString())
                            if (token.isNotEmpty()) {
                                PushNotificationManager.updateFcmToken(
                                    token,
                                    object : ChatActionListener {
                                        override fun onResponse(
                                            isSuccess: Boolean,
                                            message: String
                                        ) {
                                            if (isSuccess) {
                                                Log.e("RESPONSE_CAPTURE", "===========================")
                                                DebugUtilis.v("updateFcmToken", message)
                                                LogMessage.e(TAG, "Token updated successfully")
                                            }
                                        }
                                    })
                            }
                            //ChatManager.disconnect()
                            ChatManager.connect(object : ChatConnectionListener {
                                override fun onConnected() {
                                    Handler(Looper.getMainLooper()).postDelayed({
                                        result.success(response)
                                    }, 500)

                                }

                                override fun onDisconnected() {
                                    Log.i(TAG, "Chat Manager Disconnected")
                                }

                                override fun onConnectionNotAuthorized() {
                                    result.error(
                                        "500",
                                        "Chat Manager Connection Not Authorized",
                                        null
                                    )
                                }
                            })

                        } else {
                            // Register user failed print throwable to find the exception details.
                            result.error("500", throwable?.message.toString(), null)
                        }
                    }
                } catch (e: Exception) {

                    Log.e("Exception", e.toString())

                    result.error("404", "User Name Required", null)
                }

            } else {
                Log.e("MIRROR_FLY", "user identifier is null")
                Log.e("MIRROR_FLY", call.arguments.toString())
            }
        }
    }

    private fun listenChatMessage() {
        ChatEventsManager.setupMessageEventListener(object : MessageEventsListener {
            override fun onMessageReceived(message: ChatMessage) {
                //called when the new message is received

                Log.e("MirrorFly", "message Received")
                Log.e("RESPONSE_CAPTURE", "===========================")
                DebugUtilis.v("onMessageReceived", message.tojsonString())

                MessageReceivedStreamHandler.onMessageReceived?.success(message.tojsonString())

            }

            override fun onMessageStatusUpdated(messageId: String) {
                //called when the message status is updated
                //find the index of message object in list using messageId
                //then fetch message object from db using `FlyCore.getMessageForId(messageId)` and notify the item in list
                Log.e("onMessageStatusUpdated", "Received")


                val message = FlyMessenger.getMessageOfId(messageId)
                if (message != null) {
                    Log.e("RESPONSE_CAPTURE", "===========================")
                    DebugUtilis.v("FlyMessenger.getMessageOfId", message.tojsonString())
                    MessageStatusUpdatedStreamHandler.onMessageStatusUpdated?.success(message.tojsonString())
                }
            }

            override fun onMediaStatusUpdated(message: ChatMessage) {
                Log.e(TAG, "media Status Updated ==> $message.messageId")
                Log.e("RESPONSE_CAPTURE", "===========================")
                DebugUtilis.v("onMediaStatusUpdated", message.tojsonString())
                MediaStatusUpdatedStreamHandler.onMediaStatusUpdated?.success(message.tojsonString())
            }

            override fun onUploadDownloadProgressChanged(
                messageId: String,
                progressPercentage: Int
            ) {
                //called when the media message progress is updated
                Log.e("MirrorFly", "Upload/Download Status Updated")
                val js = JSONObject()
                js.put("message_id", messageId)
                js.put("progress_percentage", progressPercentage)
                UploadDownloadProgressChangedStreamHandler.onUploadDownloadProgressChanged?.success(
                    js.toString()
                )
            }

            override fun showOrUpdateOrCancelNotification(jid: String, chatMessage: ChatMessage?) {
                Log.e("showOrUpdateOrCancelNotification", jid)
                Log.e("MirrorFly", "showOrUpdateOrCancelNotification Status Updated")

            }


            override fun onMessagesClearedOrDeleted(messageIds: ArrayList<String>, jid: String) {
                //called when the message is deleted

                Log.e("MirrorFly", "onMessagesClearedOrDeleted Status Updated")
                //onMessagesClearedOrDeleted?.success(Gson().toJson())
            }
        })
    }

    private fun listenGroupChatMessage() {
        ChatEventsManager.attachGroupEventsListener(object : GroupEventsListener {

            override fun onGroupProfileFetched(groupJid: String) {
                onGroupProfileFetchedStreamHandler.onGroupProfileFetched?.success(groupJid)
            }

            override fun onNewGroupCreated(groupJid: String) {
                onNewGroupCreatedStreamHandler.onNewGroupCreated?.success(groupJid)
            }

            override fun onGroupProfileUpdated(groupJid: String) {
                Log.e("our GroupProfileUpdated", groupJid)
                onGroupProfileUpdatedStreamHandler.onGroupProfileUpdated?.success(groupJid)
            }

            override fun onNewMemberAddedToGroup(
                groupJid: String,
                newMemberJid: String,
                addedByMemberJid: String
            ) {
                val map = JSONObject()
                map.put("groupJid", groupJid)
                map.put("newMemberJid", newMemberJid)
                map.put("addedByMemberJid", addedByMemberJid)
                onNewMemberAddedToGroupStreamHandler.onNewMemberAddedToGroup?.success(map.toString())
            }

            override fun onMemberRemovedFromGroup(
                groupJid: String,
                removedMemberJid: String,
                removedByMemberJid: String
            ) {
                val map = JSONObject()
                map.put("groupJid", groupJid)
                map.put("removedMemberJid", removedMemberJid)
                map.put("removedByMemberJid", removedByMemberJid)
                onMemberRemovedFromGroupStreamHandler.onMemberRemovedFromGroup?.success(map.toString())
            }

            override fun onFetchingGroupMembersCompleted(groupJid: String) {
                onFetchingGroupMembersCompletedStreamHandler.onFetchingGroupMembersCompleted?.success(
                    groupJid
                )
            }

            override fun onDeleteGroup(groupJid: String) {
                onDeleteGroupStreamHandler.onDeleteGroup?.success(groupJid)
            }

            override fun onFetchingGroupListCompleted(noOfGroups: Int) {
                onFetchingGroupListCompletedStreamHandler.onFetchingGroupListCompleted?.success(
                    noOfGroups
                )
            }

            override fun onMemberMadeAsAdmin(
                groupJid: String,
                newAdminMemberJid: String,
                madeByMemberJid: String
            ) {
                val map = JSONObject()
                map.put("groupJid", groupJid)
                map.put("newAdminMemberJid", newAdminMemberJid)
                map.put("madeByMemberJid", madeByMemberJid)
                onMemberMadeAsAdminStreamHandler.onMemberMadeAsAdmin?.success(map.toString())
            }

            override fun onMemberRemovedAsAdmin(
                groupJid: String,
                removedAdminMemberJid: String,
                removedByMemberJid: String
            ) {
                val map = JSONObject()
                map.put("groupJid", groupJid)
                map.put("removedAdminMemberJid", removedAdminMemberJid)
                map.put("removedByMemberJid", removedByMemberJid)
                onMemberRemovedAsAdminStreamHandler.onMemberRemovedAsAdmin?.success(map.toString())
            }

            override fun onLeftFromGroup(groupJid: String, leftUserJid: String) {
                val map = JSONObject()
                map.put("groupJid", groupJid)
                map.put("leftUserJid", leftUserJid)
                onLeftFromGroupStreamHandler.onLeftFromGroup?.success(map.toString())
            }

            override fun onGroupNotificationMessage(message: ChatMessage) {
                onGroupNotificationMessageStreamHandler.onGroupNotificationMessage?.success(message.tojsonString())
            }

            override fun onGroupDeletedLocally(groupJid: String) {
                onGroupDeletedLocallyStreamHandler.onGroupDeletedLocally?.success(groupJid)
            }

        })
    }


    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when {
            call.method.equals("media_endpoint") -> {
                result.success(MediaUploadHelper.UPLOAD_ENDPOINT)
            }
            call.method.equals("register_user") -> {
                registerUser(call, result)
            }
            call.method.equals("authtoken") -> {
                refreshAndGetAuthToken(result)
            }
            call.method.equals("get_jid") -> {
                getJid(call, result)
            }
            call.method.equals("send_text_msg") -> {
                sendTextMessage(call, result)
            }
            call.method.equals("sendLocationMessage") -> {
                sendLocationMessage(call, result)
            }
            call.method.equals("get_user_list") -> {
                getUserList(call, result)
            }
            call.method.equals("get_image_path") -> {
                getImagePath(call, result)
            }
            call.method.equals("getUserProfile") -> {
                getUserProfile(call, result)
            }
            call.method.equals("getProfileStatusList") -> {
                getProfileStatusList(result)
            }
            call.method.equals("insertDefaultStatus") -> {
                insertDefaultStatus(call, result)
            }
            call.method.equals("updateMyProfile") -> {
                updateMyProfile(call, result)
            }
            call.method.equals("updateMyProfileImage") -> {
                updateMyProfileImage(call, result)
            }
            call.method.equals("removeProfileImage") -> {
                removeProfileImage(result)
            }
            call.method.equals("setMyProfileStatus") -> {
                setMyProfileStatus(call, result)
            }
            call.method.equals("getRecentChatList") -> {
                getRecentChatList(result)
            }
            call.method.equals("getMessagesOfJid") -> {
                getMessagesOfJid(call, result)
            }
            call.method.equals("markAsReadDeleteUnreadSeparator") -> {
                markAsReadDeleteUnreadSeparator(call, result)
            }
//            call.method.equals("get_media") -> {
//                getUserMedia(call, result)
//            }
//            call.method.equals("chat_listener") -> {
//                listenChatMessage()
//            }
//            call.method.equals("groupchat_listener") -> {
//                listenGroupChatMessage()
//            }
            call.method.equals("send_image_message") -> {
                sendImageMessage(call, result)
            }
            call.method.equals("send_video_message") -> {
                sendVideoMessage(call, result)
            }
            call.method.equals("logoutOfChatSDK") -> {
                logoutOfChatSDK(result)
            }
            call.method.equals("setOnGoingChatUser") -> {
                val userJID =
                    if (call.argument<String>("jid") == null) "" else call.argument<String?>("jid")
                        .toString()
                ChatManager.setOnGoingChatUser(userJID)
            }
            call.method.equals("getUnreadMessagesCount") -> {//name changed from unread_count
//                if (call.argument<String>("jid") == null) "" else call.argument<String?>("jid")
//                    .toString()
                result.success(FlyMessenger.getUnreadMessagesCount())
            }
            call.method.equals("get_recent_chat_of") -> {
                val userJID =
                    if (call.argument<String>("jid") == null) "" else call.argument<String?>("jid")
                        .toString()
                val recent = FlyCore.getRecentChatOf(userJID)
                if (recent != null) {
                    Log.e("RESPONSE_CAPTURE", "===========================")
                    DebugUtilis.v("FlyCore.getRecentChatOf", recent.tojsonString())
                    result.success(recent.tojsonString())
                } else {
                    result.success(null)
                }
            }
            call.method.equals("download_media") -> {
                val mediaId =
                    if (call.argument<String>("media_id") == null) "" else call.argument<String?>("media_id")
                        .toString()
                val recent = FlyMessenger.downloadMedia(mediaId)
                Log.e("RESPONSE_CAPTURE", "===========================")
                DebugUtilis.v("FlyMessenger.downloadMedia", recent.tojsonString())
                result.success(recent.tojsonString())
            }
            call.method.equals("send_contact") -> {
                sendContactMessage(call, result)
            }
            call.method.equals("sendDocumentMessage") -> {
                sendDocumentMessage(call, result)
            }
            call.method.equals("open_file") -> {
                openMediaFile(call, result)
            }
            call.method.equals("sendAudioMessage") -> {
                sendAudioMessage(call, result)
            }
            call.method.equals("getRecentChatListIncludingArchived") -> {
                getRecentChatListIncludingArchived(result)
            }
            call.method.equals("searchConversation") -> {
                searchConversation(call, result)
            }
            call.method.equals("getRegisteredUsers") -> {
                getRegisteredUsers(call, result)
            }
            call.method.equals("getRecentChatOf") -> {
                val userJID = call.argument<String>("jid") ?: ""
                val recent = FlyCore.getRecentChatOf(userJID)
                if (recent != null) {
                    Log.e("RESPONSE_CAPTURE", "===========================")
                    DebugUtilis.v("FlyCore.getRecentChatOf", recent.tojsonString())
                    result.success(recent.tojsonString())
                }
            }
            call.method.equals("getMessageOfId") -> {
                val mid = call.argument<String>("mid") ?: ""
                val data = FlyMessenger.getMessageOfId(mid)
                if (data != null) {
                    Log.e("RESPONSE_CAPTURE", "===========================")
                    DebugUtilis.v("FlyMessenger.getMessageOfId", data.tojsonString())
                    result.success(data.tojsonString())
                }
            }
            call.method.equals("refreshAuthToken") -> {
                refreshAndGetAuthToken(result)
            }
            call.method.equals("clear_chat") -> {
                clearChat(call, result)
            }
            call.method.equals("reportUserOrMessages") -> {
                reportUserOrMessages(call, result)
            }
            call.method.equals("delete_messages") -> {
                deleteMessages(call, result)
            }
            call.method.equals("getMessageStatusOfASingleChatMessage") -> {
                getMessageStatusOfASingleChatMessage(call, result)
            }
            call.method.equals("updateFavouriteStatus") -> {
                updateFavouriteStatus(call, result)
            }
            call.method.equals("block_user") -> {
                blockUser(call, result)
            }
            call.method.equals("un_block_user") -> {
                unblockUser(call, result)
            }
            call.method.equals("forwardMessagesToMultipleUsers") -> {
                forwardMessagesToMultipleUsers(call, result)
            }
            call.method.equals("exportChat") -> {
                val jid = call.argument<String?>("jid") ?: ""
                FlyCore.exportChatConversationToEmail(jid, emptyList())
            }
            call.method.equals("get_message_using_ids") -> {
//                getMessageUsingIds(call, result)
            }
            call.method.equals("verifyToken") -> {
                verifyToken(call, result)
            }
            call.method.equals("createGroup") -> {
                createGroup(call, result)
            }
            call.method.equals("addUsersToGroup") -> {
                addUsersToGroup(call, result)
            }
            call.method.equals("makeAdmin") -> {
                makeAdmin(call, result)
            }
            call.method.equals("removeMemberFromGroup") -> {
                removeMemberFromGroup(call, result)
            }
            call.method.equals("getGroupMembersList") -> {
                getGroupMembersList(call, result)
            }
            call.method.equals("updateChatMuteStatus") -> {
                val jid = call.argument<String>("jid") ?: ""
                val isChecked = call.argument<Boolean>("checked") ?: false
                val groupMuteResponse = FlyCore.updateChatMuteStatus(jid, isChecked)
                DebugUtilis.v("FlyCore.updateChatMuteStatus", groupMuteResponse.toString())
            }
            call.method.equals("isAdmin") -> {
                val jid = call.argument<String>("jid") ?: ""
                val isAdmin = GroupManager.isAdmin(jid, SharedPreferenceManager.instance.currentUserJid)
                DebugUtilis.v("GroupManager.isAdmin", isAdmin.toString())
                result.success(isAdmin)
            }
            call.method.equals("isMemberOfGroup") -> {
                val jid = call.argument<String>("jid") ?: ""
                val userjid = call.argument<String>("userjid") ?: SharedPreferenceManager.instance.currentUserJid
                val isMemberGroup = GroupManager.isMemberOfGroup(jid, userjid)
                DebugUtilis.v("GroupManager.isMemberOfGroup", isMemberGroup.toString())
                result.success(isMemberGroup)
            }
//            call.method.equals("reportUserOrMessages") -> {
//                reportUserOrMessages(call, result)
//            }
            call.method.equals("leaveFromGroup") -> {
                leaveFromGroup(call, result)
            }
            call.method.equals("deleteGroup") -> {
                deleteGroup(call, result)
            }
            call.method.equals("removeGroupProfileImage") -> {
                removeGroupProfileImage(call, result)
            }
            call.method.equals("updateGroupProfileImage") -> {
                updateGroupProfileImage(call, result)
            }
            call.method.equals("updateGroupName") -> {
                updateGroupName(call, result)
            }
            call.method.equals("getMediaMessages") -> {
                val jid = call.argument<String>("jid") ?: ""
                val mediaMessage = ChatManager.getMediaMessages(jid)
                Log.e("RESPONSE_CAPTURE", "===========================")
                DebugUtilis.v("ChatManager.getMediaMessages", mediaMessage.tojsonString())
                result.success(mediaMessage.tojsonString())
            }
            call.method.equals("getDocsMessages") -> {
                val jid = call.argument<String>("jid") ?: ""
                val docMessages = ChatManager.getDocsMessages(jid)
                Log.e("RESPONSE_CAPTURE", "===========================")
                DebugUtilis.v("ChatManager.getDocsMessages", docMessages.tojsonString())
                result.success(docMessages.tojsonString())
            }
            call.method.equals("getLinkMessages") -> {
                val jid = call.argument<String>("jid") ?: ""
                val linkMessage = ChatManager.getLinkMessages(jid)
                Log.e("RESPONSE_CAPTURE", "===========================")
                DebugUtilis.v("ChatManager.getLinkMessages", linkMessage.tojsonString())
                result.success(linkMessage.tojsonString())
            }
            call.method.equals("getProfileDetails") -> {
                val jid = call.argument("jid") ?: ""
                val profileDetails = ContactManager.getProfileDetails(jid)
                if (profileDetails != null) {
                    Log.e("RESPONSE_CAPTURE", "===========================")
                    DebugUtilis.v("ContactManager.getProfileDetails", profileDetails.tojsonString())
                    result.success(profileDetails.tojsonString())
                }
            }
            call.method.equals("getUserLastSeenTime") -> {
                getUserLastSeenTime(call, result)
            }
            call.method.equals("sendContactUsInfo") -> {
                sendContactUsInfo(call, result)
            }
            call.method.equals("getUsersIBlocked") -> {
                getUsersIBlocked(call, result)
            }
            call.method.equals("loginWebChatViaQRCode") -> {
                loginWebChatViaQRCode(call, result)
            }
            call.method.equals("showCustomTones") -> {
                showCustomTones(call, result)
            }
            call.method.equals("getWebLoginDetails") -> {
                val details = WebLoginDataManager.getWebLoginDetails()
                result.success(details.tojsonString())
            }
            call.method.equals("webLoginDetailsCleared") -> {
                WebLoginDataManager.webLoginDetailsCleared()
                result.success(true)
            }
            call.method.equals("logoutWebUser") -> {
                UpDateWebPassword().upDatePassword()
                val listWebLogin = call.argument<List<String>>("listWebLogin")//qrUniqeToken list
                if(listWebLogin!=null && listWebLogin.isNotEmpty()) {
                    for (it in listWebLogin) {
                        ChatManager.logoutWebUser(it)
                    }
                }
                result.success(true)
            }
            call.method.equals("getRingtoneName") -> {
                val uri = call.argument<String>("ringtone_uri")
                result.success(getRingtoneName(uri))
            }
            call.method.equals("delete_account") -> {
                deleteAccount(call, result)
            }
            call.method.equals("get_favourite_messages") -> {
                getFavouriteMessages(result)
            }
            call.method.equals("getAllGroups") -> {
                getAllGroups(call,result)
            }
            else -> {
                result.notImplemented()
            }

        }
    }

    private fun getAllGroups(call: MethodCall,result: MethodChannel.Result){
        val server = call.argument<Boolean>("server") ?: false
        GroupManager.getAllGroups(server) { isSuccess, throwable, data ->
            if (isSuccess) {
                val profilesList = data["data"] as ArrayList<ProfileDetails>
                profilesList.let {
                    it.sortedBy { profileDetails -> profileDetails.name?.toLowerCase() }
                }
                DebugUtilis.v("GroupManager.getAllGroups", data.tojsonString())
                result.success(profilesList.tojsonString())
            } else {
                result.error("500", "Unable to get all groups", throwable)
            }
        }
    }

    private fun getFavouriteMessages(result: MethodChannel.Result) {
        val favouriteMessages : List<ChatMessage> = FlyMessenger.getFavouriteMessages()
        Log.e("RESPONSE_CAPTURE", "===========================")
        DebugUtilis.v("FlyMessenger.getFavouriteMessages", favouriteMessages.tojsonString())
        result.success(favouriteMessages.tojsonString())
    }


    private fun deleteAccount(call: MethodCall, result: MethodChannel.Result) {
        val deleteReason = call.argument("delete_reason") ?: ""
        val deleteFeedback = call.argument("delete_feedback") ?: ""
        FlyCore.deleteAccount(deleteReason, deleteFeedback) { isSuccess, throwable, data ->
            if (isSuccess) {
                Log.e("RESPONSE_CAPTURE", "===========================")
                DebugUtilis.v("FlyCore.deleteAccount", data.tojsonString())
                result.success(data.tojsonString())
            } else {
                result.error("500", "Unable to Delete the Account", throwable)
            }

        }
    }

    private fun forwardMessagesToMultipleUsers(call: MethodCall, result: MethodChannel.Result) {

        val messageIDList = call.argument<List<String>>("message_ids")
        val userList = call.argument<List<String>>("userList")

        if (messageIDList != null && userList != null) {
            ChatManager.forwardMessagesToMultipleUsers(
                messageIDList,
                userList,
                object : ChatActionListener {
                    override fun onResponse(isSuccess: Boolean, message: String) {
                        if (isSuccess) {
                            Log.e("ChatManager.forwardMessagesToMultipleUsers", message)
                            result.success(message)
                        } else {
                            result.error("500", "Unable to Favourite the Message", message)
                        }

                    }
                })
        }
    }

    private fun updateFavouriteStatus(call: MethodCall, result: MethodChannel.Result) {
        val messageID = call.argument<String>("messageID")
        val chatUserJID = call.argument<String>("chatUserJID")
        val isFavourite = call.argument<Boolean>("isFavourite")

        if (messageID != null && chatUserJID != null && isFavourite != null) {
            ChatManager.updateFavouriteStatus(
                messageID,
                chatUserJID,
                isFavourite,
                object : ChatActionListener {
                    override fun onResponse(isSuccess: Boolean, message: String) {
                        if (isSuccess) {
                            Log.e("ChatManager.updateFavouriteStatus", message)
                            result.success(message)
                        } else {
                            result.error("500", "Unable to Favourite the Message", message)
                        }
                    }
                })
        }
    }

    private fun getMessageStatusOfASingleChatMessage(call: MethodCall, result: MethodChannel.Result) {
        val messageID = call.argument<String>("messageID")
        val messageStatus: ChatMessageStatusDetail? = messageID?.let {
            FlyMessenger.getMessageStatusOfASingleChatMessage(
                it
            )
        }
        if (messageStatus != null) {
            Log.e("RESPONSE_CAPTURE", "===========================")
            DebugUtilis.v("FlyMessenger.getMessageStatusOfASingleChatMessage", messageStatus.tojsonString())
            result.success(messageStatus.tojsonString())
        } else {
            Log.e(TAG, "Message Info Error")
        }
    }

    private fun deleteMessages(call: MethodCall, result: MethodChannel.Result) {

        val isDeleteForEveryOne = call.argument<Boolean>("is_delete_for_everyone")
        val userJID = call.argument<String>("jid")
        val chatType = call.argument<String>("chat_type")
        val messageIDList = call.argument<List<String>>("message_ids")
        if (userJID != null && messageIDList != null && chatType != null) {
            if (isDeleteForEveryOne!!) {

                Log.e(TAG, "Delete For EveryOne")
                ChatManager.deleteMessagesForEveryone(
                    userJID,
                    messageIDList,
                    getDeleteChatEnum(chatType),
                    false,
                    object : ChatActionListener {
                        override fun onResponse(isSuccess: Boolean, message: String) {
                            if (isSuccess) {

                                Log.e("RESPONSE_CAPTURE", "===========================")
                                DebugUtilis.v("ChatManager.deleteMessagesForEveryone",message)
                                result.success(message)
                            } else {
                                result.error("500", "Unable to Delete the Chat", message)
                            }
                        }

                    })
            } else {

                Log.e(TAG, "Delete For Me")
                ChatManager.deleteMessagesForMe(
                    userJID,
                    messageIDList,
                    getDeleteChatEnum(chatType),
                    false,
                    object : ChatActionListener {
                        override fun onResponse(isSuccess: Boolean, message: String) {
                            if (isSuccess) {
                                Log.e("RESPONSE_CAPTURE", "===========================")
                                DebugUtilis.v("ChatManager.deleteMessagesForMe",message)
                                result.success(message)
                            } else {
                                result.error("500", "Unable to Delete the Chat", message)
                            }
                        }

                    })
            }
        }
    }

//    private fun getMessageUsingIds(call: MethodCall, result: MethodChannel.Result) {
//        val messageIDList = call.argument<List<String>>("get_message_using_ids")
//        ChatManager.getMessagesUsingIds("messageIDList")//replace flymessenger
//    }

    private fun reportUserOrMessages(call: MethodCall, result: MethodChannel.Result) {
        val userJID = call.argument<String>("jid")
        val chatType = call.argument<String>("chat_type")
        val selectedMessageID = call.argument<String>("selectedMessageID") ?: ""
        if (chatType != null && userJID != null) {
            FlyCore.reportUserOrMessages(
                userJID,
                chatType,
                selectedMessageID
            ) { isSuccess, throwable, data ->
                if (isSuccess) {
                    Log.e("RESPONSE_CAPTURE", "===========================")
                    DebugUtilis.v("FlyCore.reportUserOrMessages", data.tojsonString())
                    result.success(data)
                } else {
                    result.error("500", "Unable to report the User/Chat", throwable?.message)
                }
            }
        } else {
            result.error("500", "Parameters Missing", null)
        }
    }

    private fun clearChat(call: MethodCall, result: MethodChannel.Result) {
        val userJID = call.argument<String>("jid")
        val chatType = call.argument<String>("chat_type")
        val clearExceptStarred = call.argument<Boolean>("clear_except_starred")
        if (userJID != null && chatType != null && clearExceptStarred != null) {
            ChatManager.clearChat(
                userJID,
                getChatEnum(chatType),
                clearExceptStarred,
                object : ChatActionListener {
                    override fun onResponse(isSuccess: Boolean, message: String) {

                        result.success(isSuccess)

                    }
                })
        } else {
            result.error("500", "Parameters Missing", null)
        }
    }

    private fun getChatEnum(chatType: String): ChatTypeEnum {
        return when (chatType) {
            ChatType.TYPE_CHAT -> ChatTypeEnum.chat
            ChatType.TYPE_GROUP_CHAT -> ChatTypeEnum.groupchat
            else -> ChatTypeEnum.broadcast
        }
    }

    private fun getDeleteChatEnum(chatType: String): DeleteChatType {
        return when (chatType) {
            ChatType.TYPE_CHAT -> DeleteChatType.chat
            ChatType.TYPE_GROUP_CHAT -> DeleteChatType.groupchat
            else -> DeleteChatType.chat
        }
    }

    private fun sendAudioMessage(call: MethodCall, result: MethodChannel.Result) {
        val userJID = call.argument<String>("jid")
        val filePath = call.argument<String>("filePath") ?: ""
        val audioFile = File(filePath)
        val replyMessageID = call.argument<String>("replyMessageId") ?: ""
        val isRecorded = call.argument<Boolean>("isRecorded")
        val duration = call.argument<String>("duration")?.toLong()

        Log.i("isRecorded", isRecorded.toString())

        if (userJID != null && duration != null && isRecorded != null) {
            FlyMessenger.sendAudioMessage(
                userJID,
                audioFile,
                duration,
                isRecorded,
                replyMessageID,
                object : SendMessageListener {
                    override fun onResponse(isSuccess: Boolean, chatMessage: ChatMessage?) {
                        if (chatMessage != null) {
                            Log.e("RESPONSE_CAPTURE", "===========================")
                            DebugUtilis.v("FlyMessenger.sendAudioMessage", chatMessage.tojsonString())
                            result.success(chatMessage.tojsonString())
                        } else {
                            result.error("500", "Unable to Send Audio Message", null)
                        }
                    }
                })
        }
    }

    private fun sendContactMessage(call: MethodCall, result: MethodChannel.Result) {
        val contactList = call.argument<List<String>>("contact_list")
        val userJID = call.argument<String>("jid")
        val contactName = call.argument<String>("contact_name")
        val replyMessageID = call.argument<String>("replyMessageId") ?: ""

        if (userJID != null && contactList != null && contactName != null) {
            FlyMessenger.sendContactMessage(
                userJID,
                contactName,
                contactList,
                replyMessageID,
                object : SendMessageListener {
                    override fun onResponse(isSuccess: Boolean, chatMessage: ChatMessage?) {
                        if (chatMessage != null) {
                            Log.e("RESPONSE_CAPTURE", "===========================")
                            DebugUtilis.v("FlyMessenger.sendContactMessage", chatMessage.tojsonString())
                            result.success(chatMessage.tojsonString())
                        } else {
                            result.error("500", "Unable to Send Contact Message", null)
                        }
                    }

                })
        }
    }

    private fun sendVideoMessage(call: MethodCall, result: MethodChannel.Result) {
        val userJid = call.argument<String>("jid") ?: ""
        val filePath = call.argument<String>("filePath") ?: ""

        val videoFile = File(filePath)

        val caption = call.argument<String>("caption") ?: ""
        val replyMessageID = call.argument<String>("replyMessageId") ?: ""

        FlyMessenger.sendVideoMessage(
            userJid,
            videoFile,
            caption,
            replyMessageID,
            object : SendMessageListener {

                override fun onResponse(isSuccess: Boolean, chatMessage: ChatMessage?) {
                    if (chatMessage != null) {
                        Log.e("RESPONSE_CAPTURE", "===========================")
                        DebugUtilis.v("FlyMessenger.sendVideoMessage", chatMessage.tojsonString())
                        result.success(chatMessage.tojsonString())
                    } else {
                        result.error("500", "Unable to Send Video Message", null)
                    }
                }
            })
    }

    private fun logoutOfChatSDK(result: MethodChannel.Result) {

        try {
            FlyCore.logoutOfChatSDK { isSuccess, throwable, _ ->
                if (isSuccess) {
                    SharedPreferenceManager.instance.clearAllPreference()
                    result.success(true)
                } else {
                    result.error("400", throwable!!.message.toString(), "")
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, e.message.toString())
            result.error("400", e.message.toString(), "")
        }

    }

//    private fun getUserMedia(call: MethodCall, result: MethodChannel.Result) {
//        val messageID: String? = call.argument("message_id")
//        val message = FlyMessenger.getMessageOfId(messageID!!)
//        if (message != null) {
//            Log.e("RESPONSE_CAPTURE", "===========================")
//            DebugUtilis.v("FlyMessenger.getMessageOfId", message.tojsonString())
//            result.success(message.tojsonString())
//        } else {
//            result.error("500", "Media Details Not Found", null)
//        }
//
//    }

    private fun getMessagesOfJid(call: MethodCall, result: MethodChannel.Result) {
        if (AppUtils.isNetConnected(mContext)) {
            if (!call.hasArgument("JID")) {
                result.error("404", "User JID Required", null)
            } else {
                val userJID: String? = call.argument("JID")
                if (userJID != null) {
                    val messages: List<ChatMessage> = FlyMessenger.getMessagesOfJid(userJID)
                    Log.e("RESPONSE_CAPTURE", "===========================")
                    DebugUtilis.v("FlyMessenger.getMessagesOfJid", messages.tojsonString())

                    result.success(messages.tojsonString())
                } else {
                    result.error("500", "User JID is Empty", null)
                }
            }

        }
    }

    private fun getUserList(call: MethodCall, result: MethodChannel.Result) {
        if (AppUtils.isNetConnected(mContext)) {
            val page = call.argument("page") ?: 1
            val search = call.argument("search") ?: ""
            FlyCore.getUserList(page, 20, search) { isSuccess, throwable, data ->
                data["status"] = isSuccess
                Log.d("registered", "$isSuccess : $data : $throwable")
                if (isSuccess) {
                    Log.e("RESPONSE_CAPTURE", "===========================")
                    DebugUtilis.v("getUserList", data.tojsonString())
                    result.success(data.tojsonString())
                } else {
                    println("friends error : " + throwable.toString())
                    result.error("400", throwable!!.message.toString(), "")
                }

            }
        } else {
            Toast.makeText(mContext, "Please Check Your Internet connection", Toast.LENGTH_SHORT).show()
        }
    }

    private fun getJid(call: MethodCall, result: MethodChannel.Result) {
        if (!call.hasArgument("username")) {
            result.error("404", "User Name Required", null)
        } else {
            val userName: String? = call.argument("username")
            if (userName != null) {
                result.success(FlyUtils.getJid(userName))
            } else {
                result.error("500", "User Name is Empty", null)
            }
        }

    }

    private fun getImagePath(call: MethodCall, result: MethodChannel.Result) {
        val imageUrl = call.argument<String>("image")
        val path = Uri.parse(MediaUploadHelper.UPLOAD_ENDPOINT).buildUpon()
            .appendPath(Uri.parse(imageUrl).lastPathSegment).build().toString()
        Log.d("path : ", path)
        result.success(path)
    }

    private fun updateMyProfile(call: MethodCall, result: MethodChannel.Result) {
        val name = call.argument("name") ?: ""
        val mobile = call.argument("mobile") ?: ""
        val email = call.argument("email") ?: ""
        val status = call.argument("status") ?: "I'm Mirrorfly user"
        if (name.isNotEmpty() && mobile.isNotEmpty() && email.isNotEmpty()) {
            val profileObj = Profile()
            profileObj.name = name
            profileObj.nickName = name
            profileObj.mobileNumber = mobile
            profileObj.email = email
            profileObj.status = status
            if (call.hasArgument("image") && call.argument<String>("image") != null) {
//                if (call.argument<String>("image") != null) {
                profileObj.image = call.argument("image")
//                }
            }

            ContactManager.updateMyProfile(profileObj) { isSuccess, _, data ->
                Log.e("RESPONSE_CAPTURE", "===========================")
                DebugUtilis.v("ContactManager.updateMyProfile", data.tojsonString())
                data["status"] = isSuccess
                result.success(data.tojsonString())
            }
        } else {
            result.error(
                "400",
                "Fill All details",
                null
            )
        }
    }

    private fun updateMyProfileImage(call: MethodCall, result: MethodChannel.Result) {
        if (call.hasArgument("image")) {
            val image = call.argument<String>("image")
            if (image != null) {
                val imagefile = File(image)
                if (imagefile.exists()) {
                    ContactManager.updateMyProfileImage(imagefile) { isSuccess, _, data ->
                        Log.e("RESPONSE_CAPTURE", "===========================")
                        DebugUtilis.v("ContactManager.updateMyProfileImage", data.tojsonString())
                        data["status"] = isSuccess
                        result.success(data.tojsonString())
                    }
                } else {
                    result.error("400", "Image File Not Exist", null)
                    return
                }
            } else {
                result.error("400", "Image File Null", null)
                return
            }
        } else {
            result.error("400", "Select Image file", null)
            return
        }
    }

    private fun removeProfileImage(result: MethodChannel.Result) {
        ContactManager.removeProfileImage { isSuccess, _, data ->
            Log.e("RESPONSE_CAPTURE", "===========================")
            DebugUtilis.v("ContactManager.removeProfileImage", data.tojsonString())
            data["status"] = isSuccess
            result.success(isSuccess)
        }
    }

    private fun setMyProfileStatus(call: MethodCall, result: MethodChannel.Result) {
        if (AppUtils.isNetConnected(mContext)) {
            val status = call.argument<String>("status") ?: ""
            if (status.isNotEmpty()) {
                FlyCore.setMyProfileStatus(status) { isSuccess, _, data ->
                    data["status"] = isSuccess
                    Log.e("RESPONSE_CAPTURE", "===========================")
                    DebugUtilis.v("FlyCore.setMyProfileStatus", data.tojsonString())
                    if (isSuccess) {
                        insertDefaultStatus(call, null)
                    }
                    result.success(data.tojsonString())
                }
            }
        } else {
            result.error("500", "Please Check Your Internet connection", null)
        }
    }

    private fun getUserProfile(call: MethodCall, result: MethodChannel.Result) {
        val jid = call.argument("jid") ?: ""
        val server = call.argument<Boolean>("server") ?: false
        Log.i(TAG, "JID==> $jid")
        ContactManager.getUserProfile(jid, server, false, object : FlyCallback {
            override fun flyResponse(
                isSuccess: Boolean,
                throwable: Throwable?,
                data: HashMap<String, Any>
            ) {
                Log.e("RESPONSE_CAPTURE", "===========================")
                DebugUtilis.v("getUserProfile", data.tojsonString())
                data["status"] = isSuccess
                Log.i(TAG, "getProfile => " + data.tojsonString())
                result.success(data.tojsonString())
            }
        })
    }

    private fun sendTextMessage(call: MethodCall, result: MethodChannel.Result) {
        if (!call.hasArgument("message") && !call.hasArgument("JID")) {
            result.error("404", "Message/JID Required", null)
        } else {
            val txtMessage: String? = call.argument("message")
            val receiverJID: String? = call.argument("JID")
            val replyMessageID: String? = call.argument("replyMessageId")
            if (txtMessage != null && receiverJID != null && replyMessageID != null) {
                FlyMessenger.sendTextMessage(
                    receiverJID,
                    txtMessage,
                    replyMessageID,
                    listener = object : SendMessageListener {
                        override fun onResponse(isSuccess: Boolean, chatMessage: ChatMessage?) {
                            // you will get the message sent success response
                            if (isSuccess) {
                                Log.i(TAG, "Message Sent Successfully")
                                Log.i(TAG, "chat Message==> $chatMessage")
                                if (chatMessage != null) {
                                    Log.e("RESPONSE_CAPTURE", "===========================")
                                    DebugUtilis.v("sendTextMessage", chatMessage.tojsonString())
                                    result.success(chatMessage.tojsonString())
                                }
                            } else {
                                Log.e(TAG, "Message sent Failed")
                            }
                        }
                    })

            } else {
                result.error("500", "User Name is Empty", null)
            }
        }

    }

    private fun markAsReadDeleteUnreadSeparator(call: MethodCall, result: MethodChannel.Result) {
        if (!call.hasArgument("jid")) {
            result.error("404", "JID Required", null)
        } else {
            val receiverJID: String? = call.argument("jid")
            if (receiverJID != null) {
                Log.i(TAG, "Read Receipt of JID $receiverJID")
                //Notify the message is read by user
                ChatManager.markAsRead(receiverJID)
                //To Remove the Unread Notification Separator in Chat List
                FlyMessenger.deleteUnreadMessageSeparatorOfAConversation(receiverJID)
            } else {
                result.error("500", "JID is Empty", null)
            }
        }

    }

    private fun sendDocumentMessage(call: MethodCall, result: MethodChannel.Result) {
        if (!call.hasArgument("message") && !call.hasArgument("jid")) {
            result.error("404", "Message/JID Required", null)
        } else {
            val replyMessageId: String? = call.argument("replyMessageId")
            val receiverJID: String? = call.argument("jid")
            val file: String? = call.argument("file")
            if (replyMessageId != null && receiverJID != null) {
                FlyMessenger.sendDocumentMessage(
                    receiverJID,
                    File(file!!),
                    replyMessageId,
                    listener = object : SendMessageListener {
                        override fun onResponse(isSuccess: Boolean, chatMessage: ChatMessage?) {
                            // you will get the message sent success response
                            if (isSuccess) {
                                Log.e("RESPONSE_CAPTURE", "===========================")
                                if (chatMessage != null) {

                                    DebugUtilis.v("FlyMessenger.sendDocumentMessage", chatMessage.tojsonString())
                                    Log.i(TAG, chatMessage.tojsonString())
                                    result.success(chatMessage.tojsonString())
                                }
                            } else {
                                Log.e(TAG, "File Message sent Failed")
                                result.error("500", "File Message sent Failed", null)
                            }
                        }
                    })

            } else {
                result.error("500", "User Name is Empty", null)
            }
        }

    }

    private fun sendLocationMessage(call: MethodCall, result: MethodChannel.Result) {
        val userJid = call.argument<String>("jid") ?: ""
        val latitude = call.argument<Double>("latitude") ?: 00.0
        val longitude = call.argument<Double>("longitude") ?: 00.0
        val replyMessageId: String? = call.argument("replyMessageId")

        if (userJid.isNotEmpty() && latitude != 00.0 && longitude != 00.0 && replyMessageId != null) {
            FlyMessenger.sendLocationMessage(
                userJid,
                latitude,
                longitude,
                replyMessageId,
                object : SendMessageListener {
                    override fun onResponse(isSuccess: Boolean, chatMessage: ChatMessage?) {
                        if (chatMessage != null) {
                            Log.e("RESPONSE_CAPTURE", "===========================")
                            DebugUtilis.v("sendLocationMessage", chatMessage.tojsonString())
                            result.success(chatMessage.tojsonString())
                        } else {
                            result.error("400", "Message Not Sent", null)
                        }
                    }
                })
        } else {
            if (userJid.isEmpty())
                result.error("400", "User Jid is Empty", null)
            else if (latitude != 00.0 || longitude != 00.0)
                result.error("400", "Location is Empty", null)
        }
    }

    private fun sendImageMessage(call: MethodCall, result: MethodChannel.Result) {
        val userJid = call.argument<String>("jid") ?: ""
        val filePath = call.argument<String>("filePath") ?: ""
        createDotNoMediaFile()

        val imageFile = File(filePath)

        val caption = call.argument<String>("caption") ?: ""
        val replyMessageID = call.argument<String>("replyMessageId") ?: ""


        val thumbnailBase64 = getImageThumbImage(filePath)

        Log.e("FILEPATH", filePath)
        Log.i(TAG, filePath)
        Log.i(TAG, thumbnailBase64)

        if (userJid.isNotEmpty() && filePath.isNotEmpty()) {
            try {
                FlyMessenger.sendImageMessage(
                    userJid,
                    imageFile,
                    thumbnailBase64,
                    caption,
                    replyMessageID,
                    object : SendMessageListener {
                        override fun onResponse(isSuccess: Boolean, chatMessage: ChatMessage?) {
                            if (chatMessage != null) {
                                Log.e("RESPONSE_CAPTURE", "===========================")
                                DebugUtilis.v("FlyMessenger.sendImageMessage", chatMessage.tojsonString())
                                result.success(Gson().toJson(chatMessage))
                            }
                        }
                    })
            } catch (e: Exception) {
                Log.e("Image Send Exception", e.message.toString())
            }
        } else {
            result.error("400", "Parameters Missing", null)
        }
    }

    private fun getRecentChatList(result: MethodChannel.Result) {
        println("recent here")
        if (AppUtils.isNetConnected(mContext)) {
            //progress.show()
            FlyCore.getRecentChatList { isSuccess, throwable, data ->
                //progress.dismiss()
                if (isSuccess) {
                    Log.e("RESPONSE_CAPTURE", "===========================")
                    DebugUtilis.v("FlyCore.getRecentChatList", data.tojsonString())
                    result.success(Gson().toJson(data).toString())
                } else {
                    result.error("500", throwable!!.message, null)
                }
                Log.d("Recent ==>", data.toString())
            }
        } else {
            //Toast.makeText(this, "Please Check Your Internet connection", Toast.LENGTH_SHORT).show()
            result.error("500", "Please Check Your Internet connection", null)
        }
    }

    private fun getImageThumbImage(imagePath: String?): String {
        return if (imagePath != null) {
            val thumb = ThumbnailUtils.extractThumbnail(
                BitmapFactory.decodeFile(imagePath),
                ThumbSize.THUMB_100,
                ThumbSize.THUMB_100
            )
            if (thumb != null) {
                val byteArray = getCompressedBitmapData(thumb)
                LogMessage.v(
                    "getVideoThumbImage",
                    "final video thumbnail size: " + byteArray.size
                )
                thumb.recycle()
                Base64.encodeToString(byteArray, 0)
            } else ""
        } else ""
    }

    private fun getCompressedBitmapData(
        bitmap: Bitmap
    ): ByteArray {
        val resizedBitmap: Bitmap =
            if (bitmap.width > 48 || bitmap.height > 48) {
                getResizedBitmap(bitmap)
            } else {
                bitmap
            }
        var bitmapData = getByteArray(resizedBitmap)
        while (bitmapData.size > 2048) {
            bitmapData = getByteArray(resizedBitmap)
        }
        return bitmapData
    }

    private fun getResizedBitmap(image: Bitmap): Bitmap {
        var width = image.width
        var height = image.height
        val bitmapRatio = width.toFloat() / height.toFloat()
        if (bitmapRatio > 1) {
            width = 48
            height = (width / bitmapRatio).toInt()
        } else {
            height = 48
            width = (height * bitmapRatio).toInt()
        }
        return Bitmap.createScaledBitmap(image, width, height, true)
    }

    private fun getByteArray(bitmap: Bitmap): ByteArray {
        val bos = ByteArrayOutputStream()
        bitmap.compress(Bitmap.CompressFormat.JPEG, 50, bos)
        return bos.toByteArray()
    }

    private fun getProfileStatusList(result: MethodChannel.Result) {
        val status = FlyCore.getProfileStatusList()
        result.success(status.tojsonString())
    }

    private fun insertDefaultStatus(call: MethodCall, result: MethodChannel.Result?) {
        if (AppUtils.isNetConnected(mContext)) {
            val status = call.argument<String>("status") ?: ""
            if (status.isNotEmpty()) {
                FlyCore.insertDefaultStatus(status)
            }
            result?.success(true)
        } else {
            result?.error("500", "Please Check Your Internet connection", null)
        }
    }

    @SuppressLint("IntentReset")
    private fun openMediaFile(call: MethodCall, result: MethodChannel.Result) {

        val filePath = call.argument<String>("filePath")

        try {
            val file = filePath?.let { File(it) }
            val extension = MimeTypeMap.getFileExtensionFromUrl(filePath)
            val mimeType = MimeTypeMap.getSingleton().getMimeTypeFromExtension(extension)
            val intent = Intent(Intent.ACTION_VIEW)
            intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            val fileUri = file?.let {
                FileProvider.getUriForFile(mContext, ChatManager.fileProviderAuthority,
                    it
                )
            }
            intent.setDataAndType(fileUri, mimeType)
            val mediaListIntent = Intent(Intent.ACTION_VIEW, fileUri)
            mediaListIntent.type = mimeType
            val mediaViewerApps: List<ResolveInfo> =
                mContext.packageManager.queryIntentActivities(mediaListIntent, 0)
            try {
                when {
                    intent.resolveActivity(mContext.packageManager) != null -> mContext.startActivity(
                        intent
                    )
                    mediaViewerApps.isNotEmpty() -> mContext.startActivity(intent)
                    else -> result.error("500", "Unable to Open the File", null)
//                Toast.makeText(context, R.string.content_not_found, Toast.LENGTH_LONG).show()
                }
            } catch (e: Exception) {
                result.error("500", "Unable to Open the File", null)
            }
        } catch (e: Exception) {
            result.error("500", "File Not Found", null)
        }
    }

    private fun createDotNoMediaFile() {
//        FilePathUtils.getExternalStorage()

        val mediaPath = VideoRecUtils.getSentParentPath(Constants.MSG_TYPE_IMAGE)

        Log.e("FIle Upload root path", mediaPath)

        val sentMedia = File(mediaPath)
        if (!sentMedia.exists()) {
            Log.e(TAG, "sent Media Not exists")
            sentMedia.mkdirs()
        } else {
            Log.e(TAG, "Sent Media Already Exists")
        }
        val noMediaFile = File(sentMedia, ".nomedia")
        if (!noMediaFile.exists()) {
            Log.e(TAG, "NoMediaFile not exists")
            try {
                FileWriter(noMediaFile).use { writer ->
                    LogMessage.d(
                        TAG,
                        "createNoMedia: $writer"
                    )
                }
            } catch (e: IOException) {
                Log.e("File Upload Exception", e.message.toString())
                LogMessage.e(e)
            }
        } else {
            Log.e("File Upload", "No Media Already Exists")
        }
    }


    private fun getRecentChatListIncludingArchived(result: MethodChannel.Result) {

        val recentChatListWithArchived = FlyCore.getRecentChatListIncludingArchived()
        Log.e("RESPONSE_CAPTURE", "===========================")
        DebugUtilis.v("FlyCore.getRecentChatListIncludingArchived", recentChatListWithArchived.tojsonString())
        result.success(recentChatListWithArchived.tojsonString())

    }

    private fun searchConversation(call: MethodCall, result: MethodChannel.Result) {
        val searchKey = call.argument<String>("searchKey") ?: ""
        FlyCore.searchConversation(
            searchKey,
            Constants.EMPTY_STRING,
            true
        ) { isSuccess, _, data ->
            if (isSuccess) {
                Log.e("RESPONSE_CAPTURE", "===========================")
                DebugUtilis.v("FlyCore.searchConversation", data.tojsonString())
                val filterMessageList = data["data"] as MutableList<*>
                Log.d("searchConversation", filterMessageList.tojsonString())
                result.success(filterMessageList.tojsonString())
            }
        }
    }

    private fun getRegisteredUsers(call: MethodCall, result: MethodChannel.Result) {
        val searchKey = call.argument<String>("searchKey") ?: ""
        val jidList = call.argument<String>("jidList") ?: ""
        FlyCore.getRegisteredUsers(false) { isSuccess, _, data ->
            if (isSuccess) {
                Log.e("RESPONSE_CAPTURE", "===========================")
                DebugUtilis.v("FlyCore.getRegisteredUsers", data.tojsonString())
                result.success(data.tojsonString())
            }
        }
    }

    private fun refreshAndGetAuthToken(result: MethodChannel.Result) {
        FlyCore.refreshAndGetAuthToken { isSuccess, _, data ->
            if (isSuccess) {
                Log.e("RESPONSE_CAPTURE", "===========================")
                DebugUtilis.v("FlyCore.refreshAndGetAuthToken", data.tojsonString())
                LogMessage.d(TAG, "Token Refresh success: ${data["data"]}")
                result.success(data["data"].toString())
            } else {
                LogMessage.d(TAG, "Token Refresh failure")
                result.success(FlyUtils.decodedToken().trim())
            }
        }
    }

    private fun blockUser(call: MethodCall, result: MethodChannel.Result) {
        val userJid = call.argument<String>("userJID") ?: ""
        FlyCore.blockUser(userJid) { isSuccess, throwable, data ->
            if (isSuccess) {
                Log.e("RESPONSE_CAPTURE", "===========================")
                DebugUtilis.v("FlyCore.blockUser", data.tojsonString())
                result.success(data.tojsonString())
            } else {
                result.error("500", "Unable to Block User", throwable?.tojsonString())
            }

        }
    }

    private fun unblockUser(call: MethodCall, result: MethodChannel.Result) {
        val userJid = call.argument<String>("userJID") ?: ""

        FlyCore.unblockUser(userJid) { isSuccess, throwable, data ->
            if (isSuccess) {
                DebugUtilis.v("FlyCore.unblockUser", data.tojsonString())
                result.success(true)
            } else {
                result.error("500", "Unable to Unblock User", throwable?.tojsonString())

            }

        }
    }

    private fun createGroup(call: MethodCall, result: MethodChannel.Result) {
        val groupName = call.argument<String>("group_name") ?: ""
        val members = call.argument<List<String>>("members") ?: arrayListOf()
        val fileTemp = call.argument<String>("file") ?: ""
        val file = if (fileTemp.isNotEmpty()) File(fileTemp) else null
        GroupManager.createGroup(groupName, members,
            file, { isSuccess, throwable, hashmap ->
                if (isSuccess) {
                    Log.e("RESPONSE_CAPTURE", "===========================")
                    DebugUtilis.v("GroupManager.createGroup", hashmap.tojsonString())
                    val groupData = hashmap.getData() as CreateGroupModel
                    result.success(groupData.tojsonString())
                } else {
                    result.error("500", "Unable to Create Group", throwable.toString())
                }
            })
    }

    private fun updateGroupProfileImage(call: MethodCall, result: MethodChannel.Result) {
        val jid = call.argument<String>("jid") ?: ""
        val fileTemp = call.argument<String>("file") ?: ""
        if (fileTemp.isNotEmpty()) {
            GroupManager.updateGroupProfileImage(jid, File(fileTemp), object : ChatActionListener {
                override fun onResponse(isSuccess: Boolean, message: String) {
                    result.success(isSuccess)
                }

            })
        }

    }

    private fun addUsersToGroup(call: MethodCall, result: MethodChannel.Result) {
        val jid = call.argument<String>("jid") ?: ""
        val members = call.argument<List<String>>("members") ?: arrayListOf()
        GroupManager.addUsersToGroup(jid, members) { isSuccess, _, _ ->
            result.success(isSuccess)
        }
    }

    private fun makeAdmin(call: MethodCall, result: MethodChannel.Result) {
        val groupjid = call.argument<String>("jid") ?: ""
        val userjid = call.argument<String>("userjid") ?: ""
        GroupManager.makeAdmin(groupjid, userjid, object :
            ChatActionListener {
            override fun onResponse(isSuccess: Boolean, message: String) {
                Log.e("GroupManager.makeAdmin", message)
                result.success(isSuccess)
            }
        })
    }

    private fun removeMemberFromGroup(call: MethodCall, result: MethodChannel.Result) {
        val groupjid = call.argument<String>("jid") ?: ""
        val userjid = call.argument<String>("userjid") ?: ""
        GroupManager.removeMemberFromGroup(groupjid, userjid) { isSuccess, _, _ ->
            result.success(isSuccess)
        }
    }

    private fun verifyToken(call: MethodCall, results: MethodChannel.Result) {
        try {
            val userName = call.argument<String>("userName") ?: ""
            val googleToken = call.argument<String>("googleToken") ?: ""
            FlyNetwork.verifyToken(userName, googleToken) { isSuccess, throwable, data ->
                LogMessage.d(TAG, data["data"].toString())
                if (isSuccess) {
                    Log.e("RESPONSE_CAPTURE", "===========================")
                    DebugUtilis.v("FlyNetwork.verifyToken", data.tojsonString())
                    val fcmData = data["data"] as VerifyFcmResponse
                    results.success(fcmData.data!!.deviceToken.toString())
                } else {
                    results.error("400", throwable?.message, "")
                }
            }
        } catch (e: Exception) {
            LogMessage.d("verifyToken", e.toString())
            results.error("400", "Server Error, Please try After sometime", "")
        }
    }

    private fun getGroupMembersList(call: MethodCall, result: MethodChannel.Result) {
        val jid = call.argument<String>("jid") ?: ""
        val fromServer = call.argument<Boolean>("server")
            ?: GroupManager.doesFetchingMembersListFromServedRequired(jid)
        GroupManager.getGroupMembersList(fromServer, jid) { isSuccess, throwable, data ->
            if (isSuccess) {
                Log.e("RESPONSE_CAPTURE", "===========================")
                DebugUtilis.v("GroupManager.getGroupMembersList", data.tojsonString())
                val groupMembers: MutableList<ProfileDetails> =
                    data.getData() as ArrayList<ProfileDetails>
                val myProfileIndex =
                    groupMembers.indexOfFirst { pd -> pd.jid == SharedPreferenceManager.instance.currentUserJid }
                if (myProfileIndex >= 0) {
                    val myProfile = groupMembers[myProfileIndex]
                    groupMembers.removeAt(myProfileIndex)
                    myProfile.nickName = Constants.YOU
                    myProfile.name = Constants.YOU
                    groupMembers.add(myProfile)
                }
                result.success(groupMembers.tojsonString())
            } else {
                result.error("404", "fetching group members", throwable.toString())
            }
        }
    }

//    private fun reportUserOrMessages(call: MethodCall, result: MethodChannel.Result) {
//        val jid = call.argument<String>("jid") ?: ""
//        val type = call.argument<String>("type") ?: ChatType.TYPE_CHAT
//        FlyCore.reportUserOrMessages(jid, type) { isSuccess, _, _ ->
//            if (isSuccess) {
//                result.success(true)
//            } else {
//                result.success(false)
//            }
//        }
//    }

    private fun leaveFromGroup(call: MethodCall, result: MethodChannel.Result) {
        val jid = call.argument<String>("jid") ?: ""
        GroupManager.leaveFromGroup(jid) { isSuccess, _, _ ->
            if (isSuccess) {
                result.success(true)
            } else {
                result.success(false)
            }
        }
    }

    private fun deleteGroup(call: MethodCall, result: MethodChannel.Result) {
        val jid = call.argument<String>("jid") ?: ""
        GroupManager.deleteGroup(jid) { isSuccess, _, _ ->
            if (isSuccess) {
                result.success(true)
            } else {
                result.success(false)
            }
        }
    }

    private fun removeGroupProfileImage(call: MethodCall, result: MethodChannel.Result) {
        val jid = call.argument<String>("jid") ?: ""
        GroupManager.removeGroupProfileImage(jid, object : ChatActionListener {
            override fun onResponse(isSuccess: Boolean, message: String) {
                if (isSuccess) {
                    result.success(true)
                } else {
                    result.success(false)
                }
            }
        })
    }

    private fun updateGroupName(call: MethodCall, result: MethodChannel.Result) {
        val jid = call.argument<String>("jid") ?: ""
        val name = call.argument<String>("name") ?: ""
        GroupManager.updateGroupName(jid, name, object : ChatActionListener {
            override fun onResponse(isSuccess: Boolean, message: String) {
                if (isSuccess) {
                    result.success(true)
                } else {
                    result.success(false)
                }
            }
        })
    }

    private fun getUserLastSeenTime(call: MethodCall, result: MethodChannel.Result) {
        val jid = call.argument<String>("jid") ?: ""
        ContactManager.getUserLastSeenTime(jid, object : ContactManager.LastSeenListener {
            override fun onFailure(message: String) {
                /* No Implementation Needed */
            }

            override fun onSuccess(lastSeenTime: String) {
                Log.e("RESPONSE_CAPTURE", "===========================")
                DebugUtilis.v("ContactManager.getUserLastSeenTime", lastSeenTime)
                result.success(lastSeenTime)
            }
        })
    }

    private fun sendContactUsInfo(call: MethodCall, result: MethodChannel.Result) {
        val title = call.argument<String>("title") ?: ""
        val description = call.argument<String>("description") ?: ""
        ContactManager.sendContactUsInfo(title, description) { isSuccess, _, _ ->
            result.success(isSuccess)
        }
    }

    private fun getUsersIBlocked(call: MethodCall, result: MethodChannel.Result) {
        val serverCall = call.argument<Boolean>("serverCall") ?: false
        FlyCore.getUsersIBlocked(serverCall) { isSuccess: Boolean, _: Throwable?, data: HashMap<String, Any> ->
            if (isSuccess) {
                Log.e("RESPONSE_CAPTURE", "===========================")
                DebugUtilis.v("FlyCore.getUsersIBlocked", data.tojsonString())
                val profilesList = data.getData() as ArrayList<ProfileDetails>
                result.success(profilesList.tojsonString())
            }
        }
    }

    private fun loginWebChatViaQRCode(call: MethodCall, result: MethodChannel.Result) {
        val barcode = call.argument<String>("barcode") ?: ""
        try {
            FlyCore.loginWebChatViaQRCode(barcode) { isSuccess, _, _ ->
                result.success(isSuccess)
                if (isSuccess) {
                    val vibrator = mContext.getSystemService(FlutterActivity.VIBRATOR_SERVICE) as Vibrator
                    if (vibrator.hasVibrator()) {
                        vibrator.vibrate(50)
                    }
                }
            }
        }catch (e:java.lang.Exception){
            android.util.Log.e("qr",e.toString())
        }
    }

    private lateinit var ringToneResult: MethodChannel.Result
    private var existingCustomTone = "None"
    private fun showCustomTones(call: MethodCall, result: MethodChannel.Result) {
        ringToneResult = result
        existingCustomTone = call.argument<String>("ringtone_uri") ?: "None"
        //val existingCustomTone = Uri.parse(SharedPreferenceManager.getString(Constants.NOTIFICATION_URI))
        val customToneUri = Uri.parse(existingCustomTone).toString()
        val intent = Intent(RingtoneManager.ACTION_RINGTONE_PICKER)
        intent.putExtra(RingtoneManager.EXTRA_RINGTONE_TYPE, RingtoneManager.TYPE_NOTIFICATION)
        intent.putExtra(RingtoneManager.EXTRA_RINGTONE_TITLE, "Notification")
        if (customToneUri != "None")
            intent.putExtra(RingtoneManager.EXTRA_RINGTONE_EXISTING_URI, customToneUri)
        (mContext as Activity).startActivityForResult(intent, Constants.ACTIVITY_REQ_CODE)
        /* setting isActivityStartedForResult to true to avoid xmpp disconnection */
        ChatManager.isActivityStartedForResult = true
    }

    fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        /* setting isActivityStartedForResult to false for xmpp disconnection */
        ChatManager.isActivityStartedForResult = false
        try {
            if (resultCode == Activity.RESULT_OK && requestCode == Constants.ACTIVITY_REQ_CODE &&
                data?.parcelable<Parcelable>(RingtoneManager.EXTRA_RINGTONE_PICKED_URI) != null
            ) {
                val selectedToneUri =
                    (data.parcelable<Parcelable>(RingtoneManager.EXTRA_RINGTONE_PICKED_URI)
                        .toString())
                //SharedPreferenceManager.setString(com.contusfly.utils.Constants.NOTIFICATION_URI, data.getParcelableExtra<Parcelable>(RingtoneManager.EXTRA_RINGTONE_PICKED_URI).toString())
                //binding.notificationToneLabel.setText(getRingtoneName(SharedPreferenceManager.getString(com.contusfly.utils.Constants.NOTIFICATION_URI)))
                ringToneResult.success(selectedToneUri)
            }

            if (data == null) {
                ringToneResult.success(existingCustomTone)
                //SharedPreferenceManager.setString(com.contusfly.utils.Constants.NOTIFICATION_URI, SharedPreferenceManager.getString(com.contusfly.utils.Constants.NOTIFICATION_URI))
                //binding.notificationToneLabel.setText(getRingtoneName(SharedPreferenceManager.getString(com.contusfly.utils.Constants.NOTIFICATION_URI)))
            } else if (data.parcelable<Parcelable>(RingtoneManager.EXTRA_RINGTONE_PICKED_URI) == null) {
                ringToneResult.success("None")
                //SharedPreferenceManager.setString(com.contusfly.utils.Constants.NOTIFICATION_URI, "None")
                //binding.notificationToneLabel.setText(getRingtoneName(SharedPreferenceManager.getString(com.contusfly.utils.Constants.NOTIFICATION_URI)))
            }
        } catch (exception: Exception) {
            LogMessage.e(exception)
        }

    }

    private fun getRingtoneName(uri: String?): String? {
        val default = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION).toString()
        val ringtone = RingtoneManager.getRingtone(mContext, Uri.parse(uri ?: default))
        return ringtone.getTitle(mContext)

    }

    private inline fun <reified T : Parcelable> Intent.parcelable(key: String): T? = when {
        Build.VERSION.SDK_INT >= 33 -> getParcelableExtra(key, T::class.java)
        else -> @Suppress("DEPRECATION") getParcelableExtra(key) as? T
    }


    fun Any.tojsonString(): String {
        return Gson().toJson(this).toString()
    }

    override fun showOrUpdateOrCancelNotification(jid: String, chatMessage: ChatMessage?) {
        ShowOrUpdateOrCancelNotificationStreamHandler.showOrUpdateOrCancelNotification?.success(jid)
    }

    override fun onDeleteGroup(groupJid: String) {
        onDeleteGroupStreamHandler.onDeleteGroup?.success(groupJid)
    }

    override fun onFetchingGroupListCompleted(noOfGroups: Int) {
        onFetchingGroupListCompletedStreamHandler.onFetchingGroupListCompleted?.success(
            noOfGroups
        )
    }

    override fun onFetchingGroupMembersCompleted(groupJid: String) {
        onFetchingGroupMembersCompletedStreamHandler.onFetchingGroupMembersCompleted?.success(
            groupJid
        )
    }

    override fun onGroupDeletedLocally(groupJid: String) {
        onGroupDeletedLocallyStreamHandler.onGroupDeletedLocally?.success(groupJid)
    }


    override fun onGroupNotificationMessage(message: ChatMessage) {
        onGroupNotificationMessageStreamHandler.onGroupNotificationMessage?.success(message.tojsonString())
    }

    override fun onGroupProfileFetched(groupJid: String) {
        onGroupProfileFetchedStreamHandler.onGroupProfileFetched?.success(groupJid)
    }

    override fun onGroupProfileUpdated(groupJid: String) {
        Log.e("our GroupProfileUpdated", groupJid)
        onGroupProfileUpdatedStreamHandler.onGroupProfileUpdated?.success(groupJid)
    }

    override fun onLeftFromGroup(groupJid: String, leftUserJid: String) {
        val map = JSONObject()
        map.put("groupJid", groupJid)
        map.put("leftUserJid", leftUserJid)
        onLeftFromGroupStreamHandler.onLeftFromGroup?.success(map.toString())
    }

    override fun onMemberMadeAsAdmin(
        groupJid: String,
        newAdminMemberJid: String,
        madeByMemberJid: String
    ) {
        val map = JSONObject()
        map.put("groupJid", groupJid)
        map.put("newAdminMemberJid", newAdminMemberJid)
        map.put("madeByMemberJid", madeByMemberJid)
        onMemberMadeAsAdminStreamHandler.onMemberMadeAsAdmin?.success(map.toString())
    }

    override fun onMemberRemovedAsAdmin(
        groupJid: String,
        removedAdminMemberJid: String,
        removedByMemberJid: String
    ) {
        val map = JSONObject()
        map.put("groupJid", groupJid)
        map.put("removedAdminMemberJid", removedAdminMemberJid)
        map.put("removedByMemberJid", removedByMemberJid)
        onMemberRemovedAsAdminStreamHandler.onMemberRemovedAsAdmin?.success(map.toString())
    }

    override fun onMemberRemovedFromGroup(
        groupJid: String,
        removedMemberJid: String,
        removedByMemberJid: String
    ) {
        val map = JSONObject()
        map.put("groupJid", groupJid)
        map.put("removedMemberJid", removedMemberJid)
        map.put("removedByMemberJid", removedByMemberJid)
        onMemberRemovedFromGroupStreamHandler.onMemberRemovedFromGroup?.success(map.toString())
    }

    override fun onNewGroupCreated(groupJid: String) {
        onNewGroupCreatedStreamHandler.onNewGroupCreated?.success(groupJid)
    }

    override fun onNewMemberAddedToGroup(
        groupJid: String,
        newMemberJid: String,
        addedByMemberJid: String
    ) {
        val map = JSONObject()
        map.put("groupJid", groupJid)
        map.put("newMemberJid", newMemberJid)
        map.put("addedByMemberJid", addedByMemberJid)
        onNewMemberAddedToGroupStreamHandler.onNewMemberAddedToGroup?.success(map.toString())
    }

    override fun blockedThisUser(jid: String) {
        val map = JSONObject()
        map.put("jid", jid)
    }

    override fun myProfileUpdated(isSuccess: Boolean) {

    }

    override fun onAdminBlockedOtherUser(jid: String, type: String, status: Boolean) {
        val map = JSONObject()
        map.put("jid", jid)
        map.put("type", type)
        map.put("status", status)
    }

    override fun onAdminBlockedUser(jid: String, status: Boolean) {
        val map = JSONObject()
        map.put("jid", jid)
        map.put("status", status)
    }

    override fun onContactSyncComplete(isSuccess: Boolean) {
    }

    override fun onLoggedOut() {
        Log.d(TAG,"onLoggedOut")
    }

    override fun unblockedThisUser(jid: String) {
        val map = JSONObject()
        map.put("jid", jid)
    }

    override fun userBlockedMe(jid: String) {
        val map = JSONObject()
        map.put("jid", jid)
    }

    override fun userCameOnline(jid: String) {
        val map = JSONObject()
        map.put("jid", jid)
    }

    override fun userDeletedHisProfile(jid: String) {
        val map = JSONObject()
        map.put("jid", jid)
    }

    override fun userProfileFetched(jid: String, profileDetails: ProfileDetails) {
        val map = JSONObject()
        map.put("jid", jid)
        map.put("profileDetails", profileDetails.tojsonString())
    }

    override fun userUnBlockedMe(jid: String) {
        val map = JSONObject()
        map.put("jid", jid)
    }

    override fun userUpdatedHisProfile(jid: String) {
        val map = JSONObject()
        map.put("jid", jid)
    }

    override fun userWentOffline(jid: String) {
        val map = JSONObject()
        map.put("jid", jid)
    }

    override fun usersIBlockedListFetched(jidList: List<String>) {
        val map = JSONObject()
        map.put("jidlist", jidList)
    }

    override fun usersProfilesFetched() {}

    override fun usersWhoBlockedMeListFetched(jidList: List<String>) {
        val map = JSONObject()
        map.put("jidlist", jidList)
    }

    override fun onConnected() {
        Log.i(TAG, "Chat Manager connected")
    }

    override fun onDisconnected() {
        Log.i(TAG, "Chat Manager Disconnected")
    }

    override fun onConnectionNotAuthorized() {
        Log.i(TAG, "Chat Manager Not Authorized")
    }

    override fun connectionFailed(message: String) {
        Log.d(TAG, "connectionFailed : $message")
    }

    override fun connectionSuccess() {
        Log.d(TAG,"connection Success")
    }

    override fun onWebChatPasswordChanged(isError: Boolean) {
        Log.d(TAG,"web chat password changed error $isError")
    }

    override fun setTypingStatus(singleOrGroupJid: String, userId: String, composing: String) {
        val map = JSONObject()
        map.put("singleOrgroupJid", singleOrGroupJid)
        map.put("userId", userId)
        map.put("composing", composing)
    }


}