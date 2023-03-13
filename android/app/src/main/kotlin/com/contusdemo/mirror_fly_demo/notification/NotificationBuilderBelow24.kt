package com.contusdemo.mirror_fly_demo.notification

import android.app.Notification
import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.graphics.BitmapFactory
import android.text.TextUtils
import androidx.core.app.NotificationCompat
import androidx.core.content.ContextCompat
import com.contus.flycommons.ChatTypeEnum
import com.contus.flycommons.Constants
import com.contus.flycommons.LogMessage
import com.contus.flycommons.PendingIntentHelper
import com.contus.flycommons.models.MessageType
import com.contusdemo.mirror_fly_demo.BuildConfig
import com.contusdemo.mirror_fly_demo.R
import com.contusflysdk.api.ChatManager
import com.contusflysdk.api.FlyMessenger
import com.contusflysdk.api.contacts.ContactManager
import com.contusflysdk.api.models.ChatMessage

object NotificationBuilderBelow24 {

    private val chatNotifications = hashMapOf<Int, ArrayList<ChatMessage>>()

    fun createNotification(context: Context, message: ChatMessage) {
        val chatJid = message.getChatUserJid()
        val notificationId = chatJid.hashCode().toLong().toInt()
        val profileDetails = ContactManager.getProfileDetails(chatJid)

        if (profileDetails?.isMuted == true)
            return

        try {
            val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            val notificationCompatBuilder = NotificationCompat.Builder(context,  (BuildConfig.APPLICATION_ID + ".notification")).apply {
                setSmallIcon(R.drawable.ic_notification_blue)
                setLargeIcon(BitmapFactory.decodeResource(context.resources, R.drawable.ic_notification_blue))
                color = ContextCompat.getColor(context, R.color.colorAccent)
                setOnlyAlertOnce(true)
                setAutoCancel(true)
                setDefaults(Notification.DEFAULT_SOUND)
                setContentTitle(profileDetails?.name)
            }

            if (!chatNotifications.containsKey(notificationId))
                chatNotifications[notificationId] = arrayListOf()

            /*if (BuildConfig.HIPAA_COMPLIANCE_ENABLED)
                hippaComplianceNotificationBuilder(context, notificationCompatBuilder)
            else*/
                appendChatMessageInNotificationBuilder(context, notificationCompatBuilder, notificationId, message)

            val notificationIntent = Intent(context, ChatManager.startActivity).apply {
                flags = (Intent.FLAG_ACTIVITY_CLEAR_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
                putExtra(Constants.IS_FROM_NOTIFICATION, true)
                if (!TextUtils.isEmpty(chatJid)) putExtra("jid", chatJid)
            }
            val pendingIntent = PendingIntentHelper.getActivity(context, Constants.NOTIFICATION_ID, notificationIntent)
            notificationCompatBuilder.setContentIntent(pendingIntent)
            NotifyRefererUtils.setNotificationSound(notificationCompatBuilder)
            notificationManager.notify(Constants.NOTIFICATION_ID, notificationCompatBuilder.build())
        } catch (e: Exception) {
            LogMessage.e(e)
        }
    }

    private fun appendChatMessageInNotificationBuilder(
        context: Context,
        notificationCompatBuilder: NotificationCompat.Builder,
        notificationId: Int,
        message: ChatMessage
    ) {
        val messageList = chatNotifications[notificationId]!!
        messageList.add(message)

        if (messageList.size > 1) {
            GetMsgNotificationUtils.getMessagesInboxNotification(context, notificationCompatBuilder, messageList)
        } else {
            var messageContent = getMessageContent(message)
            messageContent = getGroupUserAppendedText(message, messageContent)
            notificationCompatBuilder.setContentText(messageContent)
        }
    }

    /**
     * Returns the message summary
     *
     * @param message Instance of message
     * @return String Summary of the message
     */
    private fun getMessageContent(message: ChatMessage): String {
        return if (MessageType.TEXT == message.getMessageType()) message.getMessageTextContent() else message.getMessageType().name.toUpperCase()
    }

    /**
     * Returns group user appended text if the chat type is group.
     *
     * @param message        Unseen message
     * @param messageContent Notification line message content
     * @return String Appended with group user
     */
    private fun getGroupUserAppendedText(message: ChatMessage, messageContent: String): String {
        var appendedContent = messageContent
        if (ChatTypeEnum.groupchat == message.getMessageChatType()) {
            val groupUser = ContactManager.getProfileDetails(message.getChatUserJid())
            appendedContent = groupUser?.name + ":" + messageContent
        }
        return appendedContent
    }

    private fun hippaComplianceNotificationBuilder(context: Context,
                                                   notBuilder: NotificationCompat.Builder) {
        val name = "Mirrorfly"//context.getAppName()
        notBuilder.setContentText("New Message")
        notBuilder.setDefaults(Notification.DEFAULT_SOUND)
        notBuilder.setContentTitle(GetMsgNotificationUtils.getSummaryTitle(name, FlyMessenger.getUnreadMessageCountExceptMutedChat(), FlyMessenger.getUnreadMessagesCount()))
    }

    fun cancelNotifications() {
        chatNotifications.clear()
    }
}