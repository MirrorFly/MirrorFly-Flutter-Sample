package com.contusdemo.mirror_fly_demo.notification

import android.content.Context
import androidx.core.app.NotificationCompat
import com.contus.flycommons.models.MessageType
import com.contusdemo.mirror_fly_demo.R
import com.contusdemo.mirror_fly_demo.notification.NotifyRefererUtils.getGroupUserAppendedText
import com.contusdemo.mirror_fly_demo.notification.NotifyRefererUtils.hasMultipleSenders
import com.contusflysdk.api.contacts.ContactManager
import com.contusflysdk.api.models.ChatMessage
import com.contusflysdk.utils.ChatUtils
import java.util.*

/**
 * This Class contains all the common operations for creating and showing notification
 *
 * @author ContusTeam <developers></developers>@contus.in>
 * @version 2.0
 */
object GetMsgNotificationUtils {
    private const val deleted_message = "This message was deleted"

    /**
     * Returns the message summary
     *
     * @param message Instance of message
     * @return String Summary of the message
     */
    private fun getMessageSummary(message: ChatMessage): String {
        return if (MessageType.TEXT == message.getMessageType() || MessageType.NOTIFICATION == message.getMessageType()) if (message.isMessageRecalled()) deleted_message else message.getMessageTextContent() else if (MessageType.IMAGE == message.getMessageType() || MessageType.VIDEO == message.getMessageType()) {
            message.getMediaChatMessage().getMediaCaptionText().ifEmpty { message.getMessageType().name.toUpperCase(Locale.getDefault()) }
        } else message.getMessageType().name.toUpperCase(Locale.getDefault())
    }

    /**
     * Returns the message summary
     *
     * @param message Instance of message
     * @return String Summary of the message
     */
    internal fun getMessageSummary(context: Context, message: ChatMessage): String {

        return if (MessageType.TEXT == message.getMessageType() || MessageType.NOTIFICATION == message.getMessageType()) if (message.isMessageRecalled()) deleted_message else ChatUtils.getSpannedText(message.getMessageTextContent()) else if (message.isMessageRecalled()) deleted_message else getMediaMessageContent(context, message)
    }

    private fun getMediaMessageContent(context: Context, message: ChatMessage): String {
        val contentBuilder = StringBuilder()
        when (message.getMessageType()) {
            MessageType.AUDIO -> contentBuilder.append(context.resources
                    .getString(R.string.audio_emoji)).append(" ").append("Audio")
            MessageType.CONTACT ->
                contentBuilder.append(context.resources
                        .getString(R.string.contact_emoji)).append(" ").append("Contact")
            MessageType.DOCUMENT ->
                contentBuilder.append(context.resources
                        .getString(R.string.file_emoji)).append(" ").append("File")
            MessageType.IMAGE -> contentBuilder.append(context.resources.getString(R.string.image_emoji)).append(" ")
                    .append(if (message.getMediaChatMessage() != null && message.getMediaChatMessage().getMediaCaptionText() != null && message.getMediaChatMessage().getMediaCaptionText().isNotEmpty()) message.getMediaChatMessage().getMediaCaptionText() else "Image")
            MessageType.LOCATION ->
                contentBuilder.append(context.resources
                        .getString(R.string.location_emoji)).append(" ").append("Location")
            MessageType.VIDEO -> contentBuilder.append(context.resources.getString(R.string.video_emoji)).append(" ")
                    .append(if (message.getMediaChatMessage() != null && message.getMediaChatMessage().getMediaCaptionText() != null && message.getMediaChatMessage().getMediaCaptionText().isNotEmpty()) message.getMediaChatMessage().getMediaCaptionText() else "Video")
            else -> {
                // No Implementation Needed
            }
        }
        return contentBuilder.toString()
    }

    /**
     * Loads messages in inbox style
     *
     * @param context        Instance of Context
     * @param notificationCompatBuilder     Instance of NotificationCompat.Builder
     * @param unseenMessages List of unread messages
     */
    internal fun getMessagesInboxNotification(context: Context,
                                              notificationCompatBuilder: NotificationCompat.Builder,
                                              unseenMessages: List<ChatMessage>) {
        val senderDisplayNames: MutableMap<String, String?> = HashMap()
        val hasMultipleSenders = hasMultipleSenders(unseenMessages)
        val inboxStyle = NotificationCompat.InboxStyle()
        val size = unseenMessages.size
        for (i in 0 until size) {
            val message = unseenMessages[i]
            val messageFrom = message.getChatUserJid()
            if (hasMultipleSenders) {
                var sender: String?
                if (senderDisplayNames.containsKey(messageFrom)) {
                    sender = senderDisplayNames[messageFrom]
                } else {
                    val profileDetails = ContactManager.getProfileDetails(messageFrom)
                    sender = profileDetails!!.name
                    senderDisplayNames[messageFrom] = sender
                }
                val messageContent = sender + " : " + getMessageSummary(message)
                inboxStyle.addLine(getGroupUserAppendedText(message, messageContent, "@"))
            } else {
                val messageContent = getMessageSummary(context, message)
                inboxStyle.addLine(getGroupUserAppendedText(message, messageContent, ":"))
            }
        }
        val summaryText = String.format(context.getString(R.string.unseen_message), unseenMessages.size)
        inboxStyle.setSummaryText(summaryText)
        notificationCompatBuilder.setContentText(summaryText)
        if (hasMultipleSenders) {
            val title = context.getString(R.string.title_app_name)
            inboxStyle.setBigContentTitle(title)
            notificationCompatBuilder.setContentTitle(title)
        } else {
            val profileDetails = ContactManager.getProfileDetails(unseenMessages[0].getChatUserJid())
            val title = profileDetails!!.name
            inboxStyle.setBigContentTitle(title)
            notificationCompatBuilder.setContentTitle(title)
        }
        notificationCompatBuilder.setStyle(inboxStyle)
    }


    fun getSummaryTitle(name : String, unreadMessageCount: Int, unreadChatCount: Int): String {
        var summary = name
        summary = if (unreadMessageCount == 1)
            "$summary ($unreadMessageCount message"
        else
            "$summary ($unreadMessageCount messages"
        summary = if (unreadChatCount == 1)
            "$summary)"
        else
            "$summary from $unreadChatCount chats)"
        return summary
    }
}