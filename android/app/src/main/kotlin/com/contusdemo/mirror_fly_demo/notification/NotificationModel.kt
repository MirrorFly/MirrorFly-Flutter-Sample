package com.contusdemo.mirror_fly_demo.notification

import androidx.core.app.NotificationCompat
import com.contusflysdk.api.models.ChatMessage

data class NotificationModel(
    var messagingStyle: NotificationCompat.MessagingStyle,
    var messages: ArrayList<ChatMessage>,
    var unReadMessageCount:Int
)