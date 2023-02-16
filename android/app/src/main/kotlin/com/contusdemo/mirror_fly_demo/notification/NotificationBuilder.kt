package com.contusdemo.mirror_fly_demo.notification

import android.Manifest
import android.annotation.SuppressLint
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.*
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.net.Uri
import android.os.Build
import android.text.TextUtils
import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.core.app.Person
import androidx.core.content.ContextCompat
import androidx.core.graphics.drawable.IconCompat
import com.bumptech.glide.Glide
import com.bumptech.glide.load.engine.DiskCacheStrategy
import com.contus.flycommons.Constants
import com.contus.flycommons.LogMessage
import com.contus.flycommons.PendingIntentHelper
import com.contus.flycommons.SharedPreferenceManager
import com.contus.flycommons.SharedPreferenceManager.Companion.VIBRATION
import com.contus.webrtc.api.CallLogManager
import com.contusdemo.mirror_fly_demo.BuildConfig
import com.contusdemo.mirror_fly_demo.R
import com.contusflysdk.api.ChatManager
import com.contusflysdk.api.FlyMessenger
import com.contusflysdk.api.contacts.ContactManager
import com.contusflysdk.api.contacts.ProfileDetails
import com.contusflysdk.api.models.ChatMessage
import com.contusflysdk.media.MediaUploadHelper

object NotificationBuilder {

    val TAG = this.javaClass.name
    val chatNotifications = hashMapOf<Int, NotificationModel>()
    private var securedNotificationChannelId = 0

    /**
     * Create notification when new chat message received
     * @param context Context of the application
     * @param message Instance of the ChatMessage
     */
    fun createNotification(context: Context, message: ChatMessage) {
        var lastMessageTime: Long = 0
        val chatJid = message.getChatUserJid()
        val lastMessageContent = StringBuilder()
        val notificationId = chatJid.hashCode().toLong().toInt()
        val profileDetails = ContactManager.getProfileDetails(chatJid)

        if (profileDetails?.isMuted == true)
            return

        var messagingStyle =
            NotificationCompat.MessagingStyle(Person.Builder().setName("Me").build())

        if (!chatNotifications.containsKey(notificationId))
            chatNotifications[notificationId] = NotificationModel(messagingStyle, arrayListOf(),0)

        val notificationModel = chatNotifications[notificationId]

        val isMessageRecalled = message.isMessageRecalled()

        notificationModel?.let {
            if (isMessageRecalled) { //if message was recalled then rebuild the message style
                val oldMessages = notificationModel.messages.toMutableList()
                notificationModel.messages.clear()
                oldMessages.forEach { chatMessage ->
                    notificationModel.messages.add(if (chatMessage.messageId == message.messageId) message else chatMessage)
                    appendChatMessageInMessageStyle(context, lastMessageContent, messagingStyle, if (chatMessage.messageId == message.messageId) message else chatMessage)
                }
                notificationModel.messagingStyle = messagingStyle
            } else {
                messagingStyle = notificationModel.messagingStyle
                notificationModel.messages.add(message)
                appendChatMessageInMessageStyle(context, lastMessageContent, messagingStyle, message)
            }
            setConversationTitleMessagingStyle(
                context,
                profileDetails,
                notificationModel.messages.size,
                messagingStyle
            )
            lastMessageTime = if (message.getMessageSentTime()
                    .toString().length > 13
            ) message.getMessageSentTime() / 1000 else message.getMessageSentTime()
        }

        displayMessageNotification(
            context,
            notificationId,
            profileDetails,
            messagingStyle,
            lastMessageContent.toString(),
            lastMessageTime
        )
        displaySummaryNotification(context, lastMessageContent)
    }

    /**
     * Append [ChatMessage] content to the provided [NotificationCompat.MessagingStyle]
     * @param context Context of the application
     * @param messageContent Last message content to be updated
     * @param messagingStyle Unique messaging style of the conversation
     * @param message Instance of the ChatMessage
     */
    private fun appendChatMessageInMessageStyle(
        context: Context,
        messageContent: StringBuilder,
        messagingStyle: NotificationCompat.MessagingStyle,
        message: ChatMessage
    ) {
        val userProfile: ProfileDetails? =
            ContactManager.getProfileDetails(message.getSenderUserJid())
        val name = userProfile?.name ?: Constants.EMPTY_STRING
        val contentBuilder = StringBuilder()
        contentBuilder.append(GetMsgNotificationUtils.getMessageSummary(context, message))
        messageContent.append(contentBuilder)

        val userProfileImage = getUserProfileImage(context, userProfile)
        if (userProfile != null && userProfileImage != null) {
            messagingStyle.addMessage(
                contentBuilder, message.getMessageSentTime(),
                Person.Builder().setName(name)
                    .setIcon(IconCompat.createWithBitmap(userProfileImage)).build()
            )
        } else {
            messagingStyle.addMessage(
                contentBuilder, message.getMessageSentTime(),
                Person.Builder().setName(name)
                    .setIcon(IconCompat.createWithResource(context, R.drawable.ic_notification_blue)).build()
            )
        }
    }

    /**
     * Set the title of the conversation to the provided [NotificationCompat.MessagingStyle]
     * @param context Context of the application
     * @param profileDetails ProfileDetails of the conversation
     * @param messagingStyle Unique messaging style of the conversation
     * @param messagesCount total unread messages count of the conversation
     */
    private fun setConversationTitleMessagingStyle(
        context: Context,
        profileDetails: ProfileDetails?,
        messagesCount: Int,
        messagingStyle: NotificationCompat.MessagingStyle
    ) {
        val title = profileDetails?.name
        if (messagesCount > 1) {
            val appendMessagesLabel = " messages)"
            val modifiedTitle: String
            if (profileDetails!!.isGroupProfile) {
                modifiedTitle = "$title ($messagesCount$appendMessagesLabel"
                messagingStyle.setGroupConversation(true).conversationTitle = modifiedTitle
            } else if (chatNotifications.size <= 1) {
                modifiedTitle = " ($messagesCount$appendMessagesLabel"
                messagingStyle.conversationTitle = modifiedTitle
            }
        } else if (profileDetails!!.isGroupProfile) messagingStyle.setGroupConversation(true).conversationTitle =
            title
    }

    /**
     * Create [NotificationCompat.Builder] and display chat message notification
     * @param context Context of the application
     * @param notificationId Unique notification id of the conversation
     * @param profileDetails ProfileDetails of the conversation
     * @param messagingStyle Unique MessagingStyle of the conversation
     * @param lastMessageContent Last message of the conversation
     * @param lastMessageTime Time of the last message
     */
    private fun displayMessageNotification(
        context: Context,
        notificationId: Int,
        profileDetails: ProfileDetails?,
        messagingStyle: NotificationCompat.MessagingStyle,
        lastMessageContent: String,
        lastMessageTime: Long
    ) {
        val title = profileDetails?.name
        val chatJid = profileDetails?.jid

        val notificationIntent = Intent(context, ChatManager.startActivity).apply {
            flags = (Intent.FLAG_ACTIVITY_CLEAR_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
            putExtra(Constants.IS_FROM_NOTIFICATION, true)
            if (!TextUtils.isEmpty(chatJid)) putExtra("jid", chatJid)
        }

        val requestID = System.currentTimeMillis().toInt()
        val mainPendingIntent =
            PendingIntentHelper.getActivity(context, requestID, notificationIntent)
        val notificationCompatBuilder = NotificationCompat.Builder(
            context,
            buildNotificationChannelAndGetChannelId(context, notificationId.toString())
        )

        chatNotifications[notificationId]!!.unReadMessageCount++
        val unReadMessageCount  = if (chatNotifications.size == 1) getTotalUnReadMessageCount(notificationId) else chatNotifications[notificationId]?.unReadMessageCount ?:1
        LogMessage.i(TAG,"unReadMessageCount $unReadMessageCount")
        val storedNotification = SharedPreferenceManager.instance.getString("notification_uri")

        Log.e("Notification play sound", storedNotification)
        chatNotifications[notificationId]!!.unReadMessageCount = unReadMessageCount
        notificationCompatBuilder.apply {
            setStyle(messagingStyle)
            setContentTitle(title)
            setContentText(lastMessageContent)
            setAutoCancel(true)
            setSmallIcon(R.drawable.ic_notification_blue)
            color = ContextCompat.getColor(context, R.color.colorAccent)
            setContentIntent(mainPendingIntent)
            setGroup(GROUP_KEY_MESSAGE)  // Adds the notification to the group sharing the specified key.
            setNumber(unReadMessageCount)
            setSound(Uri.parse(storedNotification))
            setGroupAlertBehavior(NotificationCompat.GROUP_ALERT_SUMMARY)
            setCategory(NotificationCompat.CATEGORY_MESSAGE)
            priority = NotificationCompat.PRIORITY_HIGH
            setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            setLargeIcon(getUserProfileImage(context, profileDetails))

            if (lastMessageTime > 0)
                setWhen(lastMessageTime)

            if (SharedPreferenceManager.instance.getBoolean("vibration")) {
                setVibrate(NotifyRefererUtils.defaultVibrationPattern)
            } else {
                setVibrate(null)
            }
        }

        LogMessage.d("sdk","${Build.VERSION.SDK_INT} < ${Build.VERSION_CODES.O}")
        //if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O)
            NotifyRefererUtils.setNotificationSound(notificationCompatBuilder)

        val mNotificationManagerCompat: NotificationManagerCompat =
            NotificationManagerCompat.from(context)
        if (ActivityCompat.checkSelfPermission(context, Manifest.permission.POST_NOTIFICATIONS) != PackageManager.PERMISSION_GRANTED) {
            LogMessage.d("Firebase Message","Permission Issue")
            return
        }
        mNotificationManagerCompat.notify(notificationId, notificationCompatBuilder.build())
    }

    /**
     * Create [NotificationCompat.Builder] and display summary of the multiple chat conversations
     * @param context Context of the application
     * @param lastMessageContent Last message of the conversation
     */
    private fun displaySummaryNotification(context: Context, lastMessageContent: StringBuilder) {
        val summaryText = StringBuilder()
        val appTitle = context.resources.getString(R.string.title_app_name)
        summaryText.append(getMessagesCount()).append(" messages from ")
            .append(chatNotifications.size).append(" chats")

        val inboxStyle = NotificationCompat.InboxStyle().setBigContentTitle(appTitle)
        inboxStyle.setSummaryText(summaryText)
        for (notificationInlineMessage in 0 until chatNotifications.size) inboxStyle.addLine("notificationInlineMessage")

        val summaryBuilder =
            NotificationCompat.Builder(context, buildNotificationChannelAndGetChannelId(context, null)).apply {
                setContentTitle(appTitle)
                setContentText(lastMessageContent)
                setSmallIcon(R.drawable.ic_notification_blue)
                color = ContextCompat.getColor(context, R.color.colorAccent)
                setContentIntent(getSummaryPendingIntent(context))
                setLargeIcon(BitmapFactory.decodeResource(context.resources, R.drawable.ic_notification_blue))
                setAutoCancel(true)
                setNumber(chatNotifications.size)
                setStyle(inboxStyle)
                setGroup(GROUP_KEY_MESSAGE)
                setGroupSummary(true)
                build()
            }

        if (chatNotifications.size > 0) {
            val mNotificationManagerCompat: NotificationManagerCompat =
                NotificationManagerCompat.from(context)
            if (ActivityCompat.checkSelfPermission(context, Manifest.permission.POST_NOTIFICATIONS) != PackageManager.PERMISSION_GRANTED) {
                
                return
            }
            mNotificationManagerCompat.notify(SUMMARY_ID, summaryBuilder.build())
        }
    }

    /**
     * Build notification channel with given notification ID.
     * @param context Context of the application
     * @param notificationId Unique notification id of the conversation
     * @return String notificationId
     */
    private fun buildNotificationChannelAndGetChannelId(context: Context, notificationId: String?): String {
        val notificationManager =
            context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotifyRefererUtils.buildNotificationChannel(context, notificationManager)
        } else
            notificationId ?: NotifyRefererUtils.getNotificationId()
    }

    /**
     * Create Pending Intent to open application when tap on summary notification
     * @param context Context of the application
     * @return PendingIntent
     */
    private fun getSummaryPendingIntent(context: Context): PendingIntent {
        val notificationIntent = Intent(context, ChatManager.startActivity)
        notificationIntent.flags = (Intent.FLAG_ACTIVITY_CLEAR_TASK
                or Intent.FLAG_ACTIVITY_CLEAR_TOP)
        notificationIntent.putExtra(Constants.IS_FROM_NOTIFICATION, true)
        notificationIntent.putExtra("jid", "")
        val requestID = System.currentTimeMillis().toInt()
        return PendingIntentHelper.getActivity(context, requestID, notificationIntent)
    }

    /**
     * Get total unread messages count showing in the Push
     * @return total unread messages count
     */
    private fun getMessagesCount(): Long {
        var totalMessagesCount = 0L
        chatNotifications.values.forEach { notificationModel ->
            totalMessagesCount += notificationModel.messages.size
        }
        return totalMessagesCount
    }

    @SuppressLint("UseCompatLoadingForDrawables")
    private fun getUserProfileImage(context: Context, profileDetails: ProfileDetails?): Bitmap? {
        var bitmapUserProfile: Bitmap? = null
        var imgUrl = profileDetails?.image ?: ""
        try {
            if (imgUrl.isNotEmpty()) {
                imgUrl = Uri.parse(MediaUploadHelper.UPLOAD_ENDPOINT).buildUpon()
                    .appendPath(Uri.parse(imgUrl).lastPathSegment).build().toString()
                val file = Glide.with(context).asFile().load(imgUrl).diskCacheStrategy(
                    DiskCacheStrategy.ALL).submit().get()
                bitmapUserProfile = getCircularBitmap(BitmapFactory.decodeFile(file.absolutePath))
            } else {
                // Load Default icon based on name
                bitmapUserProfile = if (profileDetails != null && profileDetails.isGroupProfile) {
                    drawableToBitmap(context.getDrawable(R.drawable.ic_group_avatar))
                } else {
                    getCircularBitmap(drawableToBitmap(setDrawable(context, profileDetails)))
                }
            }
        } catch (e: Exception) {
            Log.d("qwerty", "Inside getProfileImage Exception ===> $e")
        }
        return bitmapUserProfile
    }

    private fun getCircularBitmap(bitmap: Bitmap?): Bitmap {
        val output: Bitmap = if (bitmap!!.width > bitmap.height) {
            Bitmap.createBitmap(bitmap.height, bitmap.height, Bitmap.Config.ARGB_8888)
        } else {
            Bitmap.createBitmap(bitmap.width, bitmap.width, Bitmap.Config.ARGB_8888)
        }
        val canvas = Canvas(output)
        val color = -0xbdbdbe
        val paint = Paint()
        val rect = Rect(0, 0, bitmap.width, bitmap.height)
        val r: Int = if (bitmap.width > bitmap.height) {
            bitmap.height / 2
        } else {
            bitmap.width / 2
        }
        paint.isAntiAlias = true
        canvas.drawARGB(0, 0, 0, 0)
        paint.color = color
        canvas.drawCircle(r.toFloat(), r.toFloat(), r.toFloat(), paint)
        paint.xfermode = PorterDuffXfermode(PorterDuff.Mode.SRC_IN)
        canvas.drawBitmap(bitmap, rect, rect, paint)
        return output
    }

    @Synchronized
    fun setDrawable(context: Context, profileDetails: ProfileDetails?): Drawable? {
        if (profileDetails != null && !profileDetails.isGroupProfile) {
            return SetDrawable(context, profileDetails).setDrawable(profileDetails.name)!!
        }
        return ContextCompat.getDrawable(context, R.drawable.ic_profile)
    }

    private fun drawableToBitmap(drawable: Drawable?): Bitmap? {
        if (drawable is BitmapDrawable && drawable.bitmap != null) {
            return drawable.bitmap
        }
        val bitmap: Bitmap = if (drawable!!.intrinsicWidth <= 0 || drawable.intrinsicHeight <= 0) {
            Bitmap.createBitmap(
                1,
                1,
                Bitmap.Config.ARGB_8888
            ) // Single color bitmap will be created of 1x1 pixel
        } else {
            Bitmap.createBitmap(
                drawable.intrinsicWidth,
                drawable.intrinsicHeight,
                Bitmap.Config.ARGB_8888
            )
        }
        val canvas = Canvas(bitmap)
        drawable.setBounds(0, 0, canvas.width, canvas.height)
        drawable.draw(canvas)
        return bitmap
    }

    /**
     * Creates a MESSAGING_STYLE Notification for the devices starting on API level 24, otherwise, displays a basic BIG_TEXT_STYLE notification.
     *
     * @param message The most recent received message
     */
    fun createSecuredNotification(context: Context, message: ChatMessage) {
        val name = "Mirrorfly Flutter"//context.getAppName()
        val chatJid = message.getChatUserJid()
        val lastMessageContent = StringBuilder()
        val notificationId = chatJid.hashCode().toLong().toInt()
        val profileDetails = ContactManager.getProfileDetails(chatJid)

        if (profileDetails?.isMuted == true)
            return

        val messagingStyle = NotificationCompat.MessagingStyle(Person.Builder().setName("Me").build())

        if (!chatNotifications.containsKey(notificationId))
            chatNotifications[notificationId] = NotificationModel(messagingStyle, arrayListOf(),0)

        val notificationModel = chatNotifications[notificationId]

        notificationModel!!.messages.add(message)

        if (securedNotificationChannelId == 0)
            securedNotificationChannelId = notificationId

        lastMessageContent.append("New Message")

        messagingStyle.addMessage(lastMessageContent, message.getMessageSentTime(),
            Person.Builder()
                .setName(GetMsgNotificationUtils.getSummaryTitle(name, FlyMessenger.getUnreadMessageCountExceptMutedChat(), FlyMessenger.getUnreadMessagesCount()))
                .setIcon(IconCompat.createWithResource(context, R.drawable.ic_notification_blue))
                .build())

        val lastMessageTime: Long = if (message.getMessageSentTime().toString().length > 13) message.getMessageSentTime() / 1000 else message.getMessageSentTime()

        val notificationIntent = Intent(context, ChatManager.startActivity).apply {
            flags = (Intent.FLAG_ACTIVITY_CLEAR_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
            putExtra(Constants.IS_FROM_NOTIFICATION, true)
            if (!TextUtils.isEmpty(chatJid)) putExtra("jid", "")
        }
        val requestID = System.currentTimeMillis().toInt()
        val mainPendingIntent = PendingIntentHelper.getActivity(context, requestID, notificationIntent)
        val notificationCompatBuilder = NotificationCompat.Builder(
            context,
            buildNotificationChannelAndGetChannelId(context, securedNotificationChannelId.toString())
        )

        notificationCompatBuilder.apply {
            setStyle(messagingStyle)
            setContentTitle(name)
            setContentText(lastMessageContent)
            setAutoCancel(true)
            setSmallIcon(R.drawable.ic_notification_blue)
            color = ContextCompat.getColor(context, R.color.colorAccent)
            setContentIntent(mainPendingIntent)
            setGroup(GROUP_KEY_MESSAGE)  // Adds the notification to the group sharing the specified key.
            setNumber(FlyMessenger.getUnreadMessageCountExceptMutedChat())
            setGroupAlertBehavior(NotificationCompat.GROUP_ALERT_SUMMARY)
            setCategory(NotificationCompat.CATEGORY_MESSAGE)
            priority = NotificationCompat.PRIORITY_HIGH
            setVisibility(NotificationCompat.VISIBILITY_PUBLIC)

            if (lastMessageTime > 0)
                setWhen(lastMessageTime)

            if (SharedPreferenceManager.instance.getBoolean("vibration")) {
                setVibrate(NotifyRefererUtils.defaultVibrationPattern)
            } else {
                setVibrate(null)
            }
        }

        //if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O)
            NotifyRefererUtils.setNotificationSound(notificationCompatBuilder)

        val mNotificationManagerCompat: NotificationManagerCompat =
            NotificationManagerCompat.from(context)
        mNotificationManagerCompat.notify(securedNotificationChannelId, notificationCompatBuilder.build())

        displaySummaryNotification(context, lastMessageContent)
    }

    fun cancelNotifications() {
        chatNotifications.clear()
        securedNotificationChannelId = 0
    }

    private fun getTotalUnReadMessageCount(notificationId: Int): Int {
        val unReadCallCount =0;
        return if (unReadCallCount == 0) FlyMessenger.getUnreadMessageCountExceptMutedChat() + CallLogManager.getUnreadMissedCallCount() else chatNotifications[notificationId]?.unReadMessageCount ?: 1
    }

    // A unique identifier string for creating the group notification.
    private const val GROUP_KEY_MESSAGE: String = BuildConfig.APPLICATION_ID + ".MESSAGE"
    private const val SUMMARY_ID = 0
}