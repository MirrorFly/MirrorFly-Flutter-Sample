package com.contusdemo.mirror_fly_demo

import android.annotation.SuppressLint
import android.content.Intent
import android.content.pm.ResolveInfo
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.media.ThumbnailUtils
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.util.Base64
import android.webkit.MimeTypeMap
import android.widget.Toast
import androidx.core.content.ContextCompat
import androidx.core.content.FileProvider
import androidx.core.view.WindowCompat
import com.contus.flycommons.*
import com.contus.xmpp.chat.models.CreateGroupModel
import com.contus.flynetwork.ApiCalls
import com.contus.flynetwork.model.verifyfcm.VerifyFcmResponse
import com.contus.xmpp.chat.models.Profile
import com.contusflysdk.AppUtils
import com.contusflysdk.api.*
import com.contusflysdk.api.ChatManager.fileProviderAuthority
import com.contusflysdk.api.chat.GroupEventsListener
import com.contusflysdk.api.chat.MessageEventsListener
import com.contusflysdk.api.contacts.ContactManager
import com.contusflysdk.api.contacts.ProfileDetails
import com.contusflysdk.api.models.ChatMessage
import com.contusflysdk.api.models.ChatMessageStatusDetail
import com.contusflysdk.api.network.FlyNetwork
import com.contusflysdk.api.notification.PushNotificationManager
import com.contusflysdk.media.MediaUploadHelper
import com.contusflysdk.utils.MediaUtils
import com.contusflysdk.utils.ThumbSize
import com.contusflysdk.utils.VideoRecUtils
import com.contusflysdk.views.CustomToast
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
import java.net.URL
import java.text.DateFormatSymbols
import java.util.*
import kotlin.collections.ArrayList
import kotlin.collections.HashMap


class MainActivity : FlutterActivity(), MethodChannel.MethodCallHandler,
    EventChannel.StreamHandler {

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

    val TAG = "MirrorFly"

    private var userName = ""

    private var chatEventSink: EventChannel.EventSink? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        WindowCompat.setDecorFitsSystemWindows(window, false)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            splashScreen.setOnExitAnimationListener { splashScreenView -> splashScreenView.remove() }
        }

        super.onCreate(savedInstanceState)
    }

    @Override
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

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

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        chatEventSink = events
    }

    override fun onCancel(arguments: Any?) {
        chatEventSink = null
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
                            val responseObject = data.get("data") as JSONObject

                            userName = responseObject.get("username") as String

                            val response = JSONObject(data).toString()
                            Log.e("RESPONSE", response)
                            if (token.isNotEmpty()) {
                                PushNotificationManager.updateFcmToken(
                                    token,
                                    object : ChatActionListener {
                                        override fun onResponse(
                                            isSuccess: Boolean,
                                            message: String
                                        ) {
                                            if (isSuccess) {
                                                LogMessage.e(TAG, "Token updated successfully")
                                            }
                                        }
                                    })
                            }
                            //ChatManager.disconnect()
                            ChatManager.connect(object : ChatConnectionListener {
                                override fun onConnected() {
                                    Handler().postDelayed({
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
                Log.e("MIRROR_FLY", "useridentifier is null")
                Log.e("MIRROR_FLY", call.arguments.toString())
            }
        }
    }

    private fun listenChatMessage() {
        ChatEventsManager.setupMessageEventListener(object : MessageEventsListener {
            override fun onMessageReceived(message: ChatMessage) {
                //called when the new message is received

                Log.e("MirrorFly", "message Received")
//                DebugUtilis.v("Message Received", message.messageTextContent)
                Log.e("Message Received", message.tojsonString())

                MessageReceivedStreamHandler.onMessageReceived?.success(message.tojsonString())

            }

            override fun onMessageStatusUpdated(messageId: String) {
                //called when the message status is updated
                //find the index of message object in list using messageId
                //then fetch message object from db using `FlyCore.getMessageForId(messageId)` and notify the item in list
                Log.e("Message Ack", "Received")

                Log.e(TAG, "Message Status Updated ==> $messageId")
                val message = FlyMessenger.getMessageOfId(messageId)
                if (message != null) {
                    MessageStatusUpdatedStreamHandler.onMessageStatusUpdated?.success(message.tojsonString())
                }
            }

            override fun onMediaStatusUpdated(message: ChatMessage) {
                Log.e(TAG, "media Status Updated ==> $message.messageId")
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
                ShowOrUpdateOrCancelNotificationStreamHandler.showOrUpdateOrCancelNotification?.success(
                    jid
                )
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
                onGroupProfileFetchedStreamHandler.onGroupProfileFetched?.success(groupJid);
            }

            override fun onNewGroupCreated(groupJid: String) {
                onNewGroupCreatedStreamHandler.onNewGroupCreated?.success(groupJid);
            }

            override fun onGroupProfileUpdated(groupJid: String) {
                Log.e("our GroupProfileUpdated", groupJid);
                onGroupProfileUpdatedStreamHandler.onGroupProfileUpdated?.success(groupJid);
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
                onNewMemberAddedToGroupStreamHandler.onNewMemberAddedToGroup?.success(map.toString());
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
                onMemberRemovedFromGroupStreamHandler.onMemberRemovedFromGroup?.success(map.toString());
            }

            override fun onFetchingGroupMembersCompleted(groupJid: String) {
                onFetchingGroupMembersCompletedStreamHandler.onFetchingGroupMembersCompleted?.success(
                    groupJid
                );
            }

            override fun onDeleteGroup(groupJid: String) {
                onDeleteGroupStreamHandler.onDeleteGroup?.success(groupJid);
            }

            override fun onFetchingGroupListCompleted(noOfGroups: Int) {
                onFetchingGroupListCompletedStreamHandler.onFetchingGroupListCompleted?.success(
                    noOfGroups
                );
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
                onMemberMadeAsAdminStreamHandler.onMemberMadeAsAdmin?.success(map.toString());
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
                onMemberRemovedAsAdminStreamHandler.onMemberRemovedAsAdmin?.success(map.toString());
            }

            override fun onLeftFromGroup(groupJid: String, leftUserJid: String) {
                val map = JSONObject()
                map.put("groupJid", groupJid)
                map.put("leftUserJid", leftUserJid)
                onLeftFromGroupStreamHandler.onLeftFromGroup?.success(map.toString());
            }

            override fun onGroupNotificationMessage(message: ChatMessage) {
                onGroupNotificationMessageStreamHandler.onGroupNotificationMessage?.success(message.tojsonString());
            }

            override fun onGroupDeletedLocally(groupJid: String) {
                onGroupDeletedLocallyStreamHandler.onGroupDeletedLocally?.success(groupJid);
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
                refreshAuthToken(result)
            }
            call.method.equals("get_user_jid") -> {
                getUserJID(call, result)
            }
            call.method.equals("send_text_msg") -> {
                sendTxtMessage(call, result)
            }
            call.method.equals("sentLocationMessage") -> {
                sentLocationMessage(call, result)
            }
            call.method.equals("get_user_list") -> {
                getUsers(call, result)
            }
            call.method.equals("get_image_path") -> {
                imagepath(call, result)
            }
            call.method.equals("getProfile") -> {
                getUserProfile(call, result)
            }
            call.method.equals("getStatusList") -> {
                getStatusList(result)
            }
            call.method.equals("insertStatus") -> {
                insertStatus(call, result)
            }
            call.method.equals("updateProfile") -> {
                updateProfile(call, result)
            }
            call.method.equals("updateProfileImage") -> {
                updateProfileImage(call, result)
            }
            call.method.equals("removeProfileImage") -> {
                removeProfileImage(call, result)
            }
            call.method.equals("updateProfileStatus") -> {
                updateProfileStatus(call, result)
            }
            call.method.equals("get_recent_chats") -> {
                getRecentChat(result)
            }
            call.method.equals("get_user_chat_history") -> {
                getUserChat(call, result)
            }
            call.method.equals("send_read_receipts") -> {
                readReceipt(call, result)
            }
            call.method.equals("get_media") -> {
                getUserMedia(call, result)
            }
            call.method.equals("chat_listener") -> {
                listenChatMessage()
            }
            call.method.equals("groupchat_listener") -> {
                listenGroupChatMessage()
            }
            call.method.equals("send_image_message") -> {
                sendImageMessage(call, result)
            }
            call.method.equals("send_video_message") -> {
                sendMediaMessage(call, result)
            }
            call.method.equals("logout") -> {
                logoutChatSDK(call, result)
            }
            call.method.equals("ongoing_chat") -> {
                val userJID =
                    if (call.argument<String>("jid") == null) "" else call.argument<String?>("jid")
                        .toString()
                ChatManager.setOnGoingChatUser(userJID)
            }
            call.method.equals("unread_count") -> {
                val userJID =
                    if (call.argument<String>("jid") == null) "" else call.argument<String?>("jid")
                        .toString()
                result.success(FlyMessenger.getUnreadMessagesCount())
            }
            call.method.equals("get_recent_chat_of") -> {
                val userJID =
                    if (call.argument<String>("jid") == null) "" else call.argument<String?>("jid")
                        .toString()
                val recent = FlyCore.getRecentChatOf(userJID)
                if (recent != null) {
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
                result.success(recent.tojsonString())
            }
            call.method.equals("send_contact") -> {
                sendContact(call, result)
            }
            call.method.equals("send_document") -> {
                sendFileMessage(call, result)
            }
            call.method.equals("open_file") -> {
                openMediaFile(call, result)
            }
            call.method.equals("send_audio") -> {
                sendaudioMessage(call, result)
            }
            call.method.equals("filteredRecentChatList") -> {
                filterRecentChatList(call, result)
            }
            call.method.equals("filteredMessageList") -> {
                filterMessageList(call, result)
            }
            call.method.equals("filteredContactList") -> {
                filterContactsList(call, result)
            }
            call.method.equals("getRecentChatOf") -> {
                val userJID = call.argument<String>("jid") ?: ""
                val recent = FlyCore.getRecentChatOf(userJID)
                if (recent != null) {
                    result.success(recent.tojsonString())
                }
            }
            call.method.equals("getMessageOfId") -> {
                val mid = call.argument<String>("mid") ?: ""
                val data = FlyMessenger.getMessageOfId(mid)
                if (data != null)
                    result.success(data.tojsonString())
            }
            call.method.equals("refreshAuthToken") -> {
                refreshAuthToken(result)
            }
            call.method.equals("clear_chat") -> {
                clearChats(call, result)
            }
            call.method.equals("report_chat") -> {
                reportChat(call, result)
            }
            call.method.equals("delete_messages") -> {
                deleteMessages(call, result)
            }
            call.method.equals("get_message_info") -> {
                getMessageInfo(call, result)
            }
            call.method.equals("favourite_message") -> {
                favouriteMessage(call, result)
            }
            call.method.equals("block_user") -> {
                blockUser(call, result)
            }
            call.method.equals("un_block_user") -> {
                unBlockUser(call, result)
            }
            call.method.equals("forward_messages") -> {
                forwardMessages(call, result)
            }
            call.method.equals("exportChat") -> {
                val jid = call.argument<String?>("jid") ?: ""
                FlyCore.exportChatConversationToEmail(jid, emptyList());
            }
            call.method.equals("get_message_using_ids") -> {
                getMessageUsingIds(call, result)
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
            call.method.equals("getGroupMembers") -> {
                getGroupMembers(call, result)
            }
            call.method.equals("groupMute") -> {
                val jid = call.argument<String>("jid") ?: ""
                val isChecked = call.argument<Boolean>("checked") ?: false
                FlyCore.updateChatMuteStatus(jid, isChecked)
            }
            call.method.equals("isAdmin") -> {
                val jid = call.argument<String>("jid") ?: ""
                result.success(
                    GroupManager.isAdmin(
                        jid,
                        SharedPreferenceManager.instance.currentUserJid
                    )
                )
            }
            call.method.equals("isMemberOfGroup") -> {
                val jid = call.argument<String>("jid") ?: ""
                val userjid = call.argument<String>("userjid") ?: SharedPreferenceManager.instance.currentUserJid
                result.success(
                    GroupManager.isMemberOfGroup(
                        jid,
                        userjid
                    )
                )
            }
            call.method.equals("reportUserOrMessages") -> {
                reportUserOrMessages(call, result)
            }
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
                Log.d("getMedia",ChatManager.getMediaMessages(jid).tojsonString())
                result.success(ChatManager.getMediaMessages(jid).tojsonString())
            }
            call.method.equals("getDocsMessages") -> {
                val jid = call.argument<String>("jid") ?: ""
                Log.d("getDocs",ChatManager.getDocsMessages(jid).tojsonString())
                result.success(ChatManager.getDocsMessages(jid).tojsonString())
            }
            call.method.equals("getLinkMessages") -> {
                val jid = call.argument<String>("jid") ?: ""
                Log.d("getLinks",ChatManager.getLinkMessages(jid).tojsonString())
                result.success(ChatManager.getLinkMessages(jid).tojsonString())
            }
            call.method.equals("getProfileDetails") -> {
                val jid = call.argument("jid") ?: ""
                val profileDetails = ContactManager.getProfileDetails(jid)
                if (profileDetails != null) {
                    result.success(profileDetails.tojsonString())
                }
            }
            call.method.equals("getUserLastSeenTime") -> {
                getUserLastSeenTime(call, result)
            }
            else -> {
                result.notImplemented()
            }

        }
    }

    private fun forwardMessages(call: MethodCall, result: MethodChannel.Result) {

        val messageIDList = call.argument<List<String>>("message_ids")
        val userList = call.argument<List<String>>("userList")

        if (messageIDList != null && userList != null) {
            ChatManager.forwardMessagesToMultipleUsers(
                messageIDList,
                userList,
                object : ChatActionListener {
                    override fun onResponse(isSuccess: Boolean, message: String) {
                        if (isSuccess) {
                            result.success(message)
                        } else {
                            result.error("500", "Unable to Favourite the Message", message)
                        }

                    }
                })
        }
    }

    private fun favouriteMessage(call: MethodCall, result: MethodChannel.Result) {
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
                            result.success(message)
                        } else {
                            result.error("500", "Unable to Favourite the Message", message)
                        }
                    }
                })
        };
    }

    private fun getMessageInfo(call: MethodCall, result: MethodChannel.Result) {
        val messageID = call.argument<String>("messageID")
        val messageStatus: ChatMessageStatusDetail? = messageID?.let {
            FlyMessenger.getMessageStatusOfASingleChatMessage(
                it
            )
        }
        if (messageStatus != null) {
            DebugUtilis.v(TAG, messageStatus.tojsonString())
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
                                result.success(message)
                            } else {
                                result.error("500", "Unable to Delete the Chat", message)
                            }
                        }

                    })
            }
        }
    }

    private fun getMessageUsingIds(call: MethodCall, result: MethodChannel.Result) {
//        val messageIDList = call.argument<List<String>>("get_message_using_ids")
//        ChatManager.getMessagesUsingIds("messageIDList")//replace flymessenger
    }

    private fun reportChat(call: MethodCall, result: MethodChannel.Result) {
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
                    DebugUtilis.v(TAG, data.tojsonString())
                    result.success(data)
                } else {
                    result.error("500", "Unable to report the User/Chat", null)
                }
            }
        } else {
            result.error("500", "Parameters Missing", null)
        }
    }

    private fun clearChats(call: MethodCall, result: MethodChannel.Result) {
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

    private fun sendaudioMessage(call: MethodCall, result: MethodChannel.Result) {
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
                            Log.i(TAG, "Audio message sent")
                            result.success(chatMessage.tojsonString())
                        } else {
                            result.error("500", "Unable to Send Audio Message", null)
                        }
                    }
                })
        }
    }

    private fun sendContact(call: MethodCall, result: MethodChannel.Result) {
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
                            result.success(chatMessage.tojsonString())
                        } else {
                            result.error("500", "Unable to Send Contact Message", null)
                        }
                    }

                })
        }
    }

    private fun sendMediaMessage(call: MethodCall, result: MethodChannel.Result) {
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
                        DebugUtilis.v(TAG, chatMessage.tojsonString())
                        result.success(chatMessage.tojsonString())
                    } else {
                        result.error("500", "Unable to Send Video Message", null)
                    }
                }
            })
    }

    private fun logoutChatSDK(call: MethodCall, result: MethodChannel.Result) {

        try {
            FlyCore.logoutOfChatSDK() { isSuccess, throwable, _ ->
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

    private fun getUserMedia(call: MethodCall, result: MethodChannel.Result) {
        val messageID: String? = call.argument("message_id")
        val message = FlyMessenger.getMessageOfId(messageID!!)
        if (message != null) {
            result.success(message.tojsonString())
        } else {
            result.error("500", "Media Details Not Found", null)
        }

    }

    private fun getUserChat(call: MethodCall, result: MethodChannel.Result) {
        if (AppUtils.isNetConnected(this)) {
            if (!call.hasArgument("JID")) {
                result.error("404", "User JID Required", null)
            } else {
                val userJID: String? = call.argument("JID")
                if (userJID != null) {
                    val messages: List<ChatMessage> = FlyMessenger.getMessagesOfJid(userJID)

                    DebugUtilis.v("MESSAGE_HISTORY", messages.tojsonString())

                    result.success(messages.tojsonString())
                } else {
                    result.error("500", "User JID is Empty", null)
                }
            }

        }
    }

    private fun getUsers(call: MethodCall, result: MethodChannel.Result) {
        if (AppUtils.isNetConnected(this)) {
            val page = call.argument("page") ?: 1
            val search = call.argument("search") ?: ""
            FlyCore.getUserList(page, 20, search) { isSuccess, throwable, data ->
                data["status"] = isSuccess
                Log.d("registered", "$isSuccess : $data : $throwable")
                if (isSuccess) {
                    result.success(data.tojsonString())
                } else {
                    println("friends error : " + throwable.toString())
                    result.error("400", throwable!!.message.toString(), "")
                }

            }
        } else {
            Toast.makeText(this, "Please Check Your Internet connection", Toast.LENGTH_SHORT).show()
        }
    }

    private fun getUserJID(call: MethodCall, result: MethodChannel.Result) {
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

    private fun imagepath(call: MethodCall, result: MethodChannel.Result) {
        val imageUrl = call.argument<String>("image")
        val path = Uri.parse(MediaUploadHelper.UPLOAD_ENDPOINT).buildUpon()
            .appendPath(Uri.parse(imageUrl).lastPathSegment).build().toString()
        Log.d("path : ", path)
        result.success(path)
    }

    private fun updateProfile(call: MethodCall, result: MethodChannel.Result) {
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
            if (call.hasArgument("image")) {
                if (call.argument<String>("image") != null) {
                    profileObj.image = call.argument("image")
                }
            }

            ContactManager.updateMyProfile(profileObj) { isSuccess, _, data ->
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

    private fun updateProfileImage(call: MethodCall, result: MethodChannel.Result) {
        if (call.hasArgument("image")) {
            val image = call.argument<String>("image")
            if (image != null) {
                val imagefile = File(image)
                if (imagefile.exists()) {
                    ContactManager.updateMyProfileImage(imagefile) { isSuccess, _, data ->
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

    private fun removeProfileImage(call: MethodCall, result: MethodChannel.Result) {
        ContactManager.removeProfileImage { isSuccess, throwable, data ->
            data["status"] = isSuccess
            result.success(isSuccess)
        }
    }

    private fun updateProfileStatus(call: MethodCall, result: MethodChannel.Result) {
        if (AppUtils.isNetConnected(this)) {
            val status = call.argument<String>("status") ?: ""
            if (status.isNotEmpty()) {
                FlyCore.setMyProfileStatus(status) { isSuccess, _, data ->
                    data["status"] = isSuccess
                    if (isSuccess) {
                        insertStatus(call, null)
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

                data["status"] = isSuccess
                Log.i(TAG, "getProfile => " + data.tojsonString())
                result.success(data.tojsonString())
            }
        })
    }

    private fun sendTxtMessage(call: MethodCall, result: MethodChannel.Result) {
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
                                android.util.Log.i(TAG, "Message Sent Successfully")
                                android.util.Log.i(TAG, "chat Message==> $chatMessage")
                                if (chatMessage != null) {
                                    android.util.Log.i(TAG, chatMessage.tojsonString())
                                    result.success(chatMessage.tojsonString())
                                }
                            } else {
                                android.util.Log.e(TAG, "Message sent Failed")
                            }
                        }
                    })

            } else {
                result.error("500", "User Name is Empty", null)
            }
        }

    }

    private fun readReceipt(call: MethodCall, result: MethodChannel.Result) {
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

    private fun sendFileMessage(call: MethodCall, result: MethodChannel.Result) {
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
                                android.util.Log.i(TAG, "Message Sent Successfully")
                                android.util.Log.i(TAG, "chat Message==> $chatMessage")
                                if (chatMessage != null) {
                                    android.util.Log.i(TAG, chatMessage.tojsonString())
                                    chatEventSink?.success(chatMessage.tojsonString())
                                    result.success(chatMessage.tojsonString())
                                }
                            } else {
                                android.util.Log.e(TAG, "Message sent Failed")
                                result.error("500", "Message sent Failed", null)
                            }
                        }
                    })

            } else {
                result.error("500", "User Name is Empty", null)
            }
        }

    }

    private fun sentLocationMessage(call: MethodCall, result: MethodChannel.Result) {
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
                                DebugUtilis.v(TAG, chatMessage.mediaChatMessage.mediaThumbImage)
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

    private fun getRecentChat(result: MethodChannel.Result) {
        println("recent here")
        if (AppUtils.isNetConnected(this)) {
            //progress.show()
            FlyCore.getRecentChatList { isSuccess, throwable, data ->
                //progress.dismiss()
                if (isSuccess) {
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
                val byteArray = getCompressedBitmapData(thumb, 2048, 48)
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
        bitmap: Bitmap,
        maxFileSize: Int,
        maxDimensions: Int
    ): ByteArray {
        val resizedBitmap: Bitmap =
            if (bitmap.width > maxDimensions || bitmap.height > maxDimensions) {
                getResizedBitmap(bitmap, maxDimensions)
            } else {
                bitmap
            }
        var bitmapData = getByteArray(resizedBitmap)
        while (bitmapData.size > maxFileSize) {
            bitmapData = getByteArray(resizedBitmap)
        }
        return bitmapData
    }

    private fun getResizedBitmap(image: Bitmap, maxSize: Int): Bitmap {
        var width = image.width
        var height = image.height
        val bitmapRatio = width.toFloat() / height.toFloat()
        if (bitmapRatio > 1) {
            width = maxSize
            height = (width / bitmapRatio).toInt()
        } else {
            height = maxSize
            width = (height * bitmapRatio).toInt()
        }
        return Bitmap.createScaledBitmap(image, width, height, true)
    }

    private fun getByteArray(bitmap: Bitmap): ByteArray {
        val bos = ByteArrayOutputStream()
        bitmap.compress(Bitmap.CompressFormat.JPEG, 50, bos)
        return bos.toByteArray()
    }

    private fun getStatusList(result: MethodChannel.Result) {
        val status = FlyCore.getProfileStatusList()
        result.success(status.tojsonString())
    }

    private fun insertStatus(call: MethodCall, result: MethodChannel.Result?) {
        if (AppUtils.isNetConnected(this)) {
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
                FileProvider.getUriForFile(context, fileProviderAuthority,
                    it
                )
            }
            intent.setDataAndType(fileUri, mimeType)
            val mediaListIntent = Intent(Intent.ACTION_VIEW, fileUri)
            mediaListIntent.type = mimeType
            val mediaViewerApps: List<ResolveInfo> =
                context.packageManager.queryIntentActivities(mediaListIntent, 0)
            try {
                when {
                    intent.resolveActivity(context.packageManager) != null -> context.startActivity(
                        intent
                    )
                    mediaViewerApps.isNotEmpty() -> context.startActivity(intent)
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
            Log.e("File Upload", "sent Media Not exists")
            sentMedia.mkdirs()
        } else {
            Log.e("File Upload", "Sent Media Already Exists")
        }
        val noMediaFile = File(sentMedia, ".nomedia")
        if (!noMediaFile.exists()) {
            Log.e("File Upload", "NoMediaFile not exists")
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


    private fun filterRecentChatList(call: MethodCall, result: MethodChannel.Result) {

        val recentChatListWithArchived = FlyCore.getRecentChatListIncludingArchived()
        Log.d("getRecentChatListIncludingArchived", recentChatListWithArchived.toString())
        result.success(recentChatListWithArchived.tojsonString())

    }

    private fun filterMessageList(call: MethodCall, result: MethodChannel.Result) {
        val searchKey = call.argument<String>("searchKey") ?: ""
        FlyCore.searchConversation(
            searchKey,
            Constants.EMPTY_STRING,
            true
        ) { isSuccess, _, data ->
            if (isSuccess) {
                val filterMessageList = data["data"] as MutableList<*>
                Log.d("searchConversation", filterMessageList.tojsonString())
                result.success(filterMessageList.tojsonString())
            }
        }
    }

    private fun filterContactsList(call: MethodCall, result: MethodChannel.Result) {
        val searchKey = call.argument<String>("searchKey") ?: ""
        val jidList = call.argument<String>("jidList") ?: ""
        FlyCore.getRegisteredUsers(false) { isSuccess, _, data ->
            if (isSuccess) {
                Log.d("getRegisteredUsers", data.toString())

                result.success(data.tojsonString())
            }
        }
    }

    private fun refreshAuthToken(result: MethodChannel.Result) {
        FlyCore.refreshAndGetAuthToken { isSuccess, _, data ->
            if (isSuccess) {
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
                //User is blocked update the UI
                result.success(data.tojsonString())
            } else {
                result.error("500", "Unable to Block User", throwable?.tojsonString())
                //User blocking failed print throwable to find the exception details
            }

        }
    }

    private fun unBlockUser(call: MethodCall, result: MethodChannel.Result) {
        val userJid = call.argument<String>("userJID") ?: ""

        FlyCore.unblockUser(userJid) { isSuccess, throwable, data ->
            if (isSuccess) {
                //User is blocked update the UI
                result.success(data.tojsonString())
            } else {
                result.error("500", "Unable to Unblock User", throwable?.tojsonString())
                //User blocking failed print throwable to find the exception details
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
                    val groupData = hashmap.getData() as CreateGroupModel
                    result.success(groupData.tojsonString())
                    //showToast(hashmap.getMessage())
                } else {
                    //showToast(throwable.toString() + "***")
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
        GroupManager.addUsersToGroup(jid, members) { isSuccess, _, data ->
            result.success(isSuccess)
        }
    }

    private fun makeAdmin(call: MethodCall, result: MethodChannel.Result) {
        val groupjid = call.argument<String>("jid") ?: ""
        val userjid = call.argument<String>("userjid") ?: ""
        GroupManager.makeAdmin(groupjid, userjid, object :
            ChatActionListener {
            override fun onResponse(isSuccess: Boolean, message: String) {
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
                LogMessage.d(TAG, data["data"].toString());
                if (isSuccess) {
                    val datas = data["data"] as VerifyFcmResponse
                    results.success(datas.data!!.deviceToken.toString())
                } else {
                    results.error("400", "${throwable}", "")
                }
            }
            /*{data=VerifyFcmResponse(data=Data(message=null, deviceToken=cA4S-VM3S5mvgA7xGjh0TD:APA91bFazQ91xEnLI9fa_3gZnZFPJ-ZzrSNIljDhS1J9mq47fH7MWb6cz2Gauc35B6EDCY4hnARJxNNXTKiOcy6rodTmdROze9qnIzCX6_UY6mUgKooLU6GcYhoFaFU_eWOCdZOWo9e0, status=null, username=null), error=null, message=Data Retrieved Successfully, status=200), http_status_code=200, message=Data Retrieved Successfully, params={mobileNumber=919894940560, googleToken=eyJhbGciOiJSUzI1NiIsImtpZCI6ImRjMzdkNTkzNjVjNjIyOGI4Y2NkYWNhNTM2MGFjMjRkMDQxNWMxZWEiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL3NlY3VyZXRva2VuLmdvb2dsZS5jb20vbWlycm9yZmx5LXVpa2l0LWRldiIsImF1ZCI6Im1pcnJvcmZseS11aWtpdC1kZXYiLCJhdXRoX3RpbWUiOjE2Njc1ODAyOTMsInVzZXJfaWQiOiIyMlQwNjhubVozWDVOakczc1p2c1JLam1abWsxIiwic3ViIjoiMjJUMDY4bm1aM1g1TmpHM3NadnNSS2ptWm1rMSIsImlhdCI6MTY2NzU4MDI5NSwiZXhwIjoxNjY3NTgzODk1LCJwaG9uZV9udW1iZXIiOiIrOTE5ODk0OTQwNTYwIiwiZmlyZWJhc2UiOnsiaWRlbnRpdGllcyI6eyJwaG9uZSI6WyIrOTE5ODk0OTQwNTYwIl19LCJzaWduX2luX3Byb3ZpZGVyIjoicGhvbmUifX0.LU3My7usVoHRlxkYpdYcMaRz_4J-g33-aEsui0Agv3BpUgQLypamovwrIr_Noik6olijonh57Z7Fy400JstzDT-ATv4dUT-pU0hVgsgobRVbsDYCv7ehI6IAuM4z7Y4eKXLSibx3x_pHgflPSnXrp20nMH3gK0Ud1olE5NV6FXQtq7aInYsi7qo10XDXyQ8n9jeG12rnB-JYmvMxQL03Wz7N0bv0wcnFpXKotQfO_xiAHztds7w-zDICiHqT6i6WnN8OQ3o3xSssKGUkqsr0FRNhRhzQFqZ-af8o3scmV8kH4CyJf5ITlYC0D8wcmA8-oXgMk8EGg3Ju6RFQC5bIjQ}}*/
        } catch (e: Exception) {
            LogMessage.d("verifyToken", e.toString())
            results.error("400", "Server Error, Please try After sometime", "")
        }
    }

    private fun getGroupMembers(call: MethodCall, result: MethodChannel.Result) {
        val jid = call.argument<String>("jid") ?: ""
        val fromServer = call.argument<Boolean>("server")
            ?: GroupManager.doesFetchingMembersListFromServedRequired(jid)
        GroupManager.getGroupMembersList(fromServer, jid) { isSuccess, throwable, data ->
            if (isSuccess) {
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
                //groupMembers = ProfileDetailsUtils.sortGroupProfileList(groupMembers)
                result.success(groupMembers.tojsonString())
            } else {
                //showToast(com.contus.flycommons.getString(R.string.error_fetching_group_members))
                result.error("404", "fetching group members", throwable.toString())
            }
        }
    }

    private fun reportUserOrMessages(call: MethodCall, result: MethodChannel.Result) {
        val jid = call.argument<String>("jid") ?: ""
        val type = call.argument<String>("type") ?: ChatType.TYPE_CHAT
        FlyCore.reportUserOrMessages(jid, type) { isSuccess, _, data ->
            if (isSuccess) {
                result.success(true)
            } else {
                result.success(false)
            }
        }
    }

    private fun leaveFromGroup(call: MethodCall, result: MethodChannel.Result) {
        val jid = call.argument<String>("jid") ?: ""
        GroupManager.leaveFromGroup(jid) { isSuccess, _, data ->
            if (isSuccess) {
                result.success(true)
            } else {
                result.success(false)
            }
        }
    }

    private fun deleteGroup(call: MethodCall, result: MethodChannel.Result) {
        val jid = call.argument<String>("jid") ?: ""
        GroupManager.deleteGroup(jid) { isSuccess, _, data ->
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

    fun updateGroupName(call: MethodCall, result: MethodChannel.Result) {
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

    fun getUserLastSeenTime(call: MethodCall, result: MethodChannel.Result) {
        val jid = call.argument<String>("jid") ?: ""
        ContactManager.getUserLastSeenTime(jid, object : ContactManager.LastSeenListener {
                override fun onFailure(message: String) {
                    /* No Implementation Needed */
                }

                override fun onSuccess(lastSeenTime: String) {
                    result.success(lastSeenTime)
                }
            })
    }

    /*private fun getGroupedMediaList(mediaMessages: List<ChatMessage>, isMedia:Boolean, isLinkMedia:Boolean = false) : List<GroupedMedia> {
        val calendarInstance = Calendar.getInstance()
        val currentYear = calendarInstance[Calendar.YEAR]
        val currentMonth = calendarInstance[Calendar.MONTH]
        val currentDay = calendarInstance[Calendar.DAY_OF_MONTH]
        val calendar: Calendar = GregorianCalendar()
        val dateSymbols = DateFormatSymbols().months
        var year: Int
        var month: Int
        var day: Int
        val viewAllMediaList = mutableListOf<GroupedMedia>()
        var previousCategoryType = 10
        mediaMessages.forEach { chatMessage ->
            val date = Date(chatMessage.getMessageSentTime()/1000)
            calendar.time = date
            year = calendar[Calendar.YEAR]
            month = calendar[Calendar.MONTH]
            day = calendar[Calendar.DAY_OF_MONTH]

            val category = getCategoryName(dateSymbols, currentDay, currentMonth, currentYear, day, month, year)

            if (isLinkMedia) {
                if (previousCategoryType != category.first)
                    viewAllMediaList.add(GroupedMedia.Header(category.second))
                previousCategoryType = category.first
                getMessageWithURLList(chatMessage).forEach { viewAllMediaList.add(it) }
            } else {
                if (!chatMessage.isMessageRecalled() && (chatMessage.isMediaDownloaded() || chatMessage.isMediaUploaded())
                    && isMediaAvailable(chatMessage, isMedia)) {
                    if (previousCategoryType != category.first)
                        viewAllMediaList.add(GroupedMedia.Header(category.second))
                    previousCategoryType = category.first
                    viewAllMediaList.add(GroupedMedia.MessageItem(chatMessage))
                }
            }
        }
        return viewAllMediaList
    }
    fun ChatMessage.isMediaDownloaded(): Boolean {
        return isMediaMessage() && (mediaChatMessage.mediaDownloadStatus == MediaDownloadStatus.MEDIA_DOWNLOADED)
    }
    fun ChatMessage.isMediaUploaded(): Boolean {
        return isMediaMessage() && (mediaChatMessage.mediaUploadStatus == MediaUploadStatus.MEDIA_UPLOADED)
    }
    fun ChatMessage.isMediaMessage() = (isAudioMessage() || isVideoMessage() || isImageMessage() || isFileMessage())
    fun ChatMessage.isTextMessage() = messageType == com.contus.flycommons.models.MessageType.TEXT
    fun ChatMessage.isAudioMessage() = messageType == com.contus.flycommons.models.MessageType.AUDIO
    fun ChatMessage.isImageMessage() = messageType == com.contus.flycommons.models.MessageType.IMAGE
    fun ChatMessage.isVideoMessage() = messageType == com.contus.flycommons.models.MessageType.VIDEO
    fun ChatMessage.isFileMessage() = messageType == com.contus.flycommons.models.MessageType.DOCUMENT
    fun ChatMessage.isNotificationMessage() = messageType == com.contus.flycommons.models.MessageType.NOTIFICATION

    private fun getMessageWithURLList(message: ChatMessage): MutableList<GroupedMedia> {
        val messageList = mutableListOf<GroupedMedia>()
        val textContent = when {
            message.isTextMessage() -> {
                message.getMessageTextContent()
            }
            message.isImageMessage() || message.isVideoMessage() -> {
                message.getMediaChatMessage().getMediaCaptionText()
            }
            else -> Constants.EMPTY_STRING
        }
        if (textContent.isNotBlank()) {
            getUrlAndHostList(textContent).forEach {
                val map = hashMapOf<String, String>()
                map["host"] = it.first
                map["url"] = it.second
                messageList.add(GroupedMedia.MessageItem(message, map))
            }
        }
        return messageList
    }
    private fun getUrlAndHostList(text: String): java.util.ArrayList<Pair<String, String>> {
        val urls = java.util.ArrayList<Pair<String, String>>()
        val splitString = text.split("\\s+".toRegex())
        for (string in splitString) {
            try {
                val item = URL(string)
                urls.add(Pair(item.host, item.toString()))
            } catch (ignored: Exception) {
                //No Implementation needed
            }
        }
        return urls
    }
    private fun isMediaAvailable(chatMessage: ChatMessage, isMedia: Boolean): Boolean {
        return (!isMedia || isMediaExists(chatMessage.getMediaChatMessage().getMediaLocalStoragePath()))
    }
    fun isMediaExists(filePath: String?): Boolean {
        return if (filePath != null) {
            val file = File(filePath)
            file.exists()
        } else false
    }

    private fun getCategoryName(dateSymbols: Array<String>, currentDay: Int, currentMonth: Int, currentYear: Int,
                                day: Int, month: Int, year: Int): Pair<Int, String> {
        return when {
            (currentYear - year) == 1 -> {
                if (currentMonth < month) {
                    Pair(4, dateSymbols[month])
                } else {
                    Pair(5, year.toString())
                }
            }
            currentYear > year -> {
                Pair(5, year.toString())
            }
            (currentMonth - month) == 1 -> {
                if (day > currentDay)
                    Pair(3, "Last Month")
                else
                    Pair(4, dateSymbols[month])
            }
            currentMonth > month -> Pair(4, dateSymbols[month])
            (currentDay - day) > 7 -> {
                Pair(2, "Last Month")
            }
            (currentDay - day) > 2 -> {
                Pair(1, "Last Week")
            }
            else -> Pair(0, "Recent")
        }
    }*/

    fun Any.tojsonString(): String {
        return Gson().toJson(this).toString()
    }
}
