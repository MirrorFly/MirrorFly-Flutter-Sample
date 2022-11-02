package com.contusdemo.mirror_fly_demo

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
import androidx.annotation.NonNull
import androidx.core.content.FileProvider
import androidx.core.view.WindowCompat
import com.contus.flycommons.*
import com.contus.xmpp.chat.models.Profile
import com.contusflysdk.AppUtils
import com.contusflysdk.api.*
import com.contusflysdk.api.ChatManager.fileProviderAuthority
import com.contusflysdk.api.chat.MessageEventsListener
import com.contusflysdk.api.contacts.ContactManager
import com.contusflysdk.api.contacts.ProfileDetails
import com.contusflysdk.api.models.ChatMessage
import com.contusflysdk.api.models.ChatMessageStatusDetail
import com.contusflysdk.media.MediaUploadHelper
import com.contusflysdk.utils.ThumbSize
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

    companion object {
        const val GROUP_EVENT = "group_events"
        const val ARCHIVE_EVENT = "archive_events"
        const val MESSAGE_RECEIVED = "message_received"
        const val MESSAGE_UPDATED = "message_updated"
        const val MEDIA_STATUS_UPDATED = "media_status_updated"
        const val MEDIA_UPLOAD_DOWNLOAD_PROGRESS = "media_upload_download_progress"
        const val MUTE_EVENT = "mute_event"
        const val PIN_EVENT = "pin_event"
    }
    val TAG = "MirrorFly"

    private var userName = ""

    private val ENGINE_ID = "1"

    private var chatEventSink: EventChannel.EventSink? = null

    //    private var onMessageReceived: EventChannel.EventSink? = null
//    private var onMessageStatusUpdated: EventChannel.EventSink? = null
//    private var onMediaStatusUpdated: EventChannel.EventSink? = null
//    private var onUploadDownloadProgressChanged: EventChannel.EventSink? = null
//    private var showOrUpdateOrCancelNotification: EventChannel.EventSink? = null
//    private var onMessagesClearedOrDeleted: EventChannel.EventSink? = null
//    private var chatStatusEventSink: EventChannel.EventSink? = null
    override fun onCreate(savedInstanceState: Bundle?) {
        // Aligns the Flutter view vertically with the window.
        WindowCompat.setDecorFitsSystemWindows(window, false)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            // Disable the Android splash screen fade out animation to avoid
            // a flicker before the similar frame is drawn in Flutter.
            splashScreen.setOnExitAnimationListener { splashScreenView -> splashScreenView.remove() }
        }

        super.onCreate(savedInstanceState)
    }

    @Override
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, MIRRORFLY_METHOD_CHANNEL).setMethodCallHandler(this)
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, MESSAGE_ONRECEIVED_CHANNEL).setStreamHandler(MessageReceivedStreamHandler)
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, MESSAGE_STATUS_UPDATED_CHANNEL).setStreamHandler(MessageStatusUpdatedStreamHandler)
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, MEDIA_STATUS_UPDATED_CHANNEL).setStreamHandler(MediaStatusUpdatedStreamHandler)
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, UPLOAD_DOWNLOAD_PROGRESS_CHANGED_CHANNEL).setStreamHandler(UploadDownloadProgressChangedStreamHandler)
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, SHOW_UPDATE_CANCEL_NOTIFICTION_CHANNEL).setStreamHandler(ShowOrUpdateOrCancelNotificationStreamHandler)
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        arguments as? String
        Log.d("unique", arguments.toString())
//        if (arguments.toString()== MESSAGE_RECEIVED){
//            Log.d("unique2",arguments.toString())
//            onMessageReceived=events
//        }
        chatEventSink = events

//        if (arguments!=null) {
//            when {
//                arguments.toString().equals(MESSAGE_RECEIVED)->onMessageReceived=events
//                arguments.toString().equals(MESSAGE_UPDATED)->onMessageStatusUpdated=events
////                arguments.equals(MEDIA_STATUS_UPDATED)->onMediaStatusUpdated=events
////                arguments.equals(MEDIA_UPLOAD_DOWNLOAD_PROGRESS)->onUploadDownloadProgressChanged=events
//
////                arguments.equals(MESSAGE_RECEIVED)->showOrUpdateOrCancelNotification=events
////                arguments.equals(MESSAGE_RECEIVED)->onMessagesClearedOrDeleted=events
//            }
//        }
    }

    override fun onCancel(arguments: Any?) {
        chatEventSink = null
//        if (arguments!=null) {
//            when {
//                arguments.equals(MESSAGE_RECEIVED)->onMessageReceived=null
//                arguments.equals(MESSAGE_UPDATED)->onMessageStatusUpdated=null
//                /*arguments.equals(MESSAGE_RECEIVED)->onMediaStatusUpdated=null
//                arguments.equals(MESSAGE_RECEIVED)->onUploadDownloadProgressChanged=null
//                arguments.equals(MESSAGE_RECEIVED)->showOrUpdateOrCancelNotification=null
//                arguments.equals(MESSAGE_RECEIVED)->onMessagesClearedOrDeleted=null*/
//            }
//        }
    }

//    override fun onMessageReceived(message: ChatMessage) {
//        super.onMessageReceived(message)
//        // received message object
//        android.util.Log.e("Message Received", message.messageTextContent)
//        chatEventSink?.success(message)
//    }

    private fun registerUser(call: MethodCall, result: MethodChannel.Result) {
        if (!call.hasArgument("userIdentifier")) {
            result.error("404", "User Mobile Number Required", null)
        } else {
            val userIdentifier: String? = call.argument("userIdentifier")
            if (userIdentifier != null) {
                Log.e(TAG, userIdentifier.toString())

                try {
                    FlyCore.registerUser(userIdentifier) { isSuccess: Boolean, throwable: Throwable?, data: HashMap<String?, Any?> ->
                        if (isSuccess) {
                            val responseObject = data.get("data") as JSONObject

                            userName = responseObject.get("username") as String

                            val response = JSONObject(data).toString()
                            Log.e("RESPONSE", response)
                            //ChatManager.disconnect()
                            ChatManager.connect(object : ChatConnectionListener {
                                override fun onConnected() {
                                    Handler().postDelayed({
                                        result.success(response)
                                    },500)
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
//                if (message != null && message.messageType == MessageType.IMAGE) {
//                    DebugUtilis.v("STAT", message.mediaChatMessage.mediaThumbImage)
//                }
                if (message != null) {
                    MessageStatusUpdatedStreamHandler.onMessageStatusUpdated?.success(message.tojsonString())
                }
//                chatEventSink?.success(Gson().toJson(message).toString())
                MessageStatusUpdatedStreamHandler.onMessageStatusUpdated?.success(
                    Gson().toJson(
                        message
                    ).toString()
                )
            }

            override fun onMediaStatusUpdated(message: ChatMessage) {
                Log.e(TAG, "media Status Updated ==> $message.messageId")
                MediaStatusUpdatedStreamHandler.onMediaStatusUpdated?.success(message.tojsonString())

//                Handler().postDelayed({
//                    chatEventSink?.success(Gson().toJson(message).toString())
//                }, 1000)
                //called when the media message status is updated like downloaded,uploaded,failed
                //find the index of message object in list using messageId
                //then fetch message object from db using `FlyCore.getMessageForId(messageId)` and notify the item in list
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

            override fun showOrUpdateOrCancelNotification(jid: String,chatMessage: ChatMessage?) {
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


    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when {
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
                val userJID = if(call.argument<String>("jid")==null) "" else call.argument<String?>("jid").toString()
                val recent  = FlyCore.getRecentChatOf(userJID)
                if (recent!=null){
                    result.success(recent.tojsonString())
                }
            }
            call.method.equals("download_media") -> {
                val media_id =
                    if (call.argument<String>("media_id") == null) "" else call.argument<String?>("media_id")
                        .toString()
                val recent = FlyMessenger.downloadMedia(media_id)
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


            //not implemneted
            call.method.equals("get_message_using_ids") -> {
                getMessageUsingIds(call, result)
            }

            else -> {
                result.notImplemented()
            }

        }
    }

    private fun favouriteMessage(call: MethodCall, result: MethodChannel.Result) {
        val messageID = call.argument<String>("messageID")
        val chatUserJID = call.argument<String>("chatUserJID")
        val isFavourite = call.argument<Boolean>("isFavourite")

        if (messageID != null && chatUserJID != null && isFavourite != null) {
            ChatManager.updateFavouriteStatus(messageID, chatUserJID, isFavourite,  object : ChatActionListener {
                override fun onResponse(isSuccess: Boolean, message: String) {
                    if (isSuccess){
                        result.success(message)
                    }else{
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
        }else{
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
                            if (isSuccess){
                                result.success(message)
                            }else{
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
                            if (isSuccess){
                                result.success(message)
                            }else{
                                result.error("500", "Unable to Delete the Chat", message)
                            }
                        }

                    })
            }
        }
    }

    private fun getMessageUsingIds(call: MethodCall, result: MethodChannel.Result) {
//        val messageIDList = call.argument<List<String>>("get_message_using_ids")
//        ChatManager.getMessagesUsingIds(messageIDList)
    }

    private fun reportChat(call: MethodCall, result: MethodChannel.Result) {
        val userJID = call.argument<String>("jid")
        val chatType = call.argument<String>("chat_type")
        val selectedMessageID = call.argument<String>("selectedMessageID") ?: ""
        if (chatType != null && userJID != null) {
            FlyCore.reportUserOrMessages(userJID, chatType, selectedMessageID) {isSuccess, throwable, data ->
                if (isSuccess) {
                    DebugUtilis.v(TAG, data.tojsonString())
                    result.success(data)
                } else {
                    result.error("500", "Unable to report the User/Chat", null)
                }
            }
        }else{
            result.error("500", "Parameters Missing", null)
        }
    }

    private fun clearChats(call: MethodCall, result: MethodChannel.Result) {
        val userJID = call.argument<String>("jid")
        val chatType = call.argument<String>("chat_type")
        val clearExceptStarred = call.argument<Boolean>("clear_except_starred")
        if (userJID != null && chatType != null && clearExceptStarred != null) {
            ChatManager.clearChat(userJID, getChatEnum(chatType), clearExceptStarred, object : ChatActionListener {
                override fun onResponse(isSuccess: Boolean, message: String) {

                    result.success(isSuccess)

                }
            })
        }else{
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
            FlyMessenger.sendAudioMessage(userJID, audioFile, duration, isRecorded, replyMessageID, object : SendMessageListener {
                override fun onResponse(isSuccess: Boolean, chatMessage: ChatMessage?) {
                    if (chatMessage != null) {
                        Log.i(TAG, "Audio message sent")
                        result.success(chatMessage.tojsonString())
                    }else{
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
            FlyMessenger.sendContactMessage(userJID, contactName, contactList, replyMessageID, object : SendMessageListener {
                override fun onResponse(isSuccess: Boolean, chatMessage: ChatMessage?) {
                    if (chatMessage != null) {
                        result.success(chatMessage.tojsonString())
                    }else{
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
            val messageTime = message.getMessageSentTime()
            val base64Img = message.getMediaChatMessage()?.getMediaThumbImage()
            val filePath = message.getMediaChatMessage()?.getMediaLocalStoragePath()
            val mediaCaptionText = message.getMediaChatMessage()?.getMediaCaptionText()

            val array = Base64.decode(base64Img, Base64.DEFAULT)

            DebugUtilis.v("MEDIA_DETAIL1", array.toString())
            DebugUtilis.v("MEDIA_DETAIL", message.tojsonString())

//            Log.i(TAG, (message).toString())
            result.success(message.tojsonString())
        } else {
            result.error("500", "Media Details Not Found", null)
        }

//        val messageDetail = message.msgBody
//        val mediaDetail = messageDetail.media
//        val mediaStatus = mediaDetail.mediaDownloadStatus
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
            //progress.show()
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
            /*if (call.hasArgument("image")) {
                val image = call.argument<String>("image")
                if (image != null) {
                    val imagefile = File(image)
                    if (imagefile.exists()) {
                        profileObj.image = imagefile.absolutePath
                    } else {
                        result.error("400", "Image File Not Exist", null)
                        return
                    }
                } else {
                    result.error("400", "Image File Null", null)
                    return
                }
            }*/
            ContactManager.updateMyProfile(profileObj) { isSuccess, throwable, data ->
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
                    ContactManager.updateMyProfileImage(imagefile) { isSuccess, throwable, data ->
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
//            result.success(data.tojsonString())
            result.success(isSuccess)
        }
    }

    private fun updateProfileStatus(call: MethodCall, result: MethodChannel.Result) {
        if (AppUtils.isNetConnected(this)) {
            val status = call.argument<String>("status") ?: ""
            if (status.isNotEmpty()) {
                FlyCore.setMyProfileStatus(status) { isSuccess, throwable, data ->
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
                Log.i(TAG,"getProfile => "+data.tojsonString())
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

        if (userJid.isNotEmpty()&&latitude!=00.0&&longitude!=00.0 && replyMessageId != null) {
            FlyMessenger.sendLocationMessage(userJid, latitude, longitude, replyMessageId, object : SendMessageListener {
                override fun onResponse(isSuccess: Boolean, chatMessage: ChatMessage?) {
                    if (chatMessage != null) {
                        result.success(chatMessage.tojsonString())
                    }else{
                        result.error("400", "Message Not Sent", null)
                    }
                }
            })
        } else {
            if (userJid.isEmpty())
                result.error("400", "User Jid is Empty", null)
            else if (latitude!=00.0||longitude!=00.0)
                result.error("400", "Location is Empty", null)
        }
    }

    private fun sendImageMessage(call: MethodCall, result: MethodChannel.Result) {
        val userJid = call.argument<String>("jid") ?: ""
//        val filename = call.argument<String>("fileName") ?: "image"
//        val fileSize = call.argument<String>("fileSize") ?: "0"
        val filePath = call.argument<String>("filePath") ?: ""
        createDotNoMediaFile()

        val imageFile = File(filePath)

//        val fileLocalPath = call.argument<String>("localPath") ?: ""
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
                    "final video thumbnail size: " + byteArray!!.size
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
    ): ByteArray? {
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

    private fun openMediaFile(call: MethodCall, result: MethodChannel.Result) {

        val filePath = call.argument<String>("filePath")
//        try{
//            MediaUtils.openMediaFile(this, filePath)
//            result.success(true)
//        } catch (e: Exception){
//            result.error("500", "File Not Found", null)
////                Toast.makeText(context, R.string.content_not_found, Toast.LENGTH_LONG).show()
//        }

        try {
            val file = File(filePath)
            val extension = MimeTypeMap.getFileExtensionFromUrl(filePath)
            val mimeType = MimeTypeMap.getSingleton().getMimeTypeFromExtension(extension)
            val intent = Intent(Intent.ACTION_VIEW)
            intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            val fileUri = FileProvider.getUriForFile(context, fileProviderAuthority, file)
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
        }else{
            Log.e("File Upload", "Sent Media Already Exists")
        }
        val noMediaFile = File(sentMedia, ".nomedia")
        if (!noMediaFile.exists()) {
            Log.e("File Upload", "NoMediaFile not exists")
            try {
                FileWriter(noMediaFile).use { writer -> LogMessage.d(TAG, "createNoMedia: $writer") }
            } catch (e: IOException) {
                Log.e("File Upload Exception", e.message.toString())
                LogMessage.e(e)
            }
        }else{
            Log.e("File Upload", "No Media Already Exists")
        }
    }




    private fun filterRecentChatList(call: MethodCall, result: MethodChannel.Result) {
        val searchKey = call.argument<String>("searchKey") ?: ""
        //val recentChatList = mutableListOf<RecentChat>()
        val recentChatListWithArchived = FlyCore.getRecentChatListIncludingArchived()
        Log.d("getRecentChatListIncludingArchived", recentChatListWithArchived.toString())
        result.success(recentChatListWithArchived.tojsonString())
        /*for (recentChat in recentChatListWithArchived)
            if (recentChat.profileName != null && recentChat.profileName.contains(searchKey, true))
                recentChatList.add(recentChat)
        filterRecentChatList.value = recentChatList*/
    }

    private fun filterMessageList(call: MethodCall, result: MethodChannel.Result) {
        val searchKey = call.argument<String>("searchKey") ?: ""
        FlyCore.searchConversation(
            searchKey,
            Constants.EMPTY_STRING,
            true
        ) { isSuccess, _, data ->
            if (isSuccess) {
                val datas = data["data"] as MutableList<ChatMessage>
                Log.d("searchConversation", datas.tojsonString())
                result.success(datas.tojsonString())
            }
        }
    }

    fun filterContactsList(call: MethodCall, result: MethodChannel.Result) {
        val searchKey = call.argument<String>("searchKey") ?: ""
        val jidList = call.argument<String>("jidList") ?: ""
        FlyCore.getRegisteredUsers(false) { isSuccess, _, data ->
            if (isSuccess) {
                Log.d("getRegisteredUsers", data.toString())
                val profileDetails = data["data"] as MutableList<ProfileDetails>
                /*filterProfileList.value = profileDetails.filter {
                    !jidList.contains(it.jid) && it.name.contains(
                        searchKey,
                        true
                    )
                }.sortedBy { it.name }*/
                result.success(data.tojsonString())
            }
        }
    }

    private fun refreshAuthToken(result: MethodChannel.Result){
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
    private fun blockUser(call: MethodCall, result: MethodChannel.Result){
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
    private fun unBlockUser(call: MethodCall, result: MethodChannel.Result){
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

    fun Any.tojsonString(): String {
        return Gson().toJson(this).toString()
    }

}