package com.contusdemo.mirror_fly_demo.notification

import android.app.NotificationManager
import android.content.Context
import android.os.Build
import android.service.notification.StatusBarNotification
import androidx.core.app.NotificationManagerCompat
import com.contus.flycommons.Constants
import com.contus.flycommons.SharedPreferenceManager
import com.contusflysdk.api.models.ChatMessage

object AppNotificationManager {

    /**
     * Creates local notification when the app is in foreground for the incoming messages.
     *
     * @param context Instance of Context
     * @param chatMessage Received Message
     */
    fun createNotification(context: Context, chatMessage: ChatMessage) {
        /**
         * if the user enables mute notification in settings, we should not show any notification
         */
        if (SharedPreferenceManager.instance.getBoolean("mute_notification"))
            return

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
           /* if (BuildConfig.HIPAA_COMPLIANCE_ENABLED)
                NotificationBuilder.createSecuredNotification(context, chatMessage)
            else*/
                NotificationBuilder.createNotification(context, chatMessage)
        } else {
            NotificationBuilderBelow24.createNotification(context, chatMessage)
        }
    }

    fun cancelNotifications(context: Context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            val barNotifications: Array<StatusBarNotification> = notificationManager.activeNotifications
            for (notification in barNotifications) {
                NotificationManagerCompat.from(context).cancel(notification.id)
            }
            NotificationBuilder.cancelNotifications()
        } else {
            NotificationManagerCompat.from(context).cancel(Constants.NOTIFICATION_ID)
            NotificationBuilderBelow24.cancelNotifications()
        }
        //CallNotificationUtils.cancelNotifications()
    }

    fun clearConversationOnNotification(context: Context, jId:String) {
        val id = jId.hashCode().toLong().toInt()
        if (NotificationBuilder.chatNotifications.size > 0) {
            val notification = NotificationBuilder.chatNotifications[id]
            notification?.messagingStyle?.messages?.clear()
            notification?.messages?.clear()
            notification?.messagingStyle?.historicMessages?.clear()
            notification?.messagingStyle?.conversationTitle = Constants.EMPTY_STRING
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                val barNotifications: Array<StatusBarNotification> = notificationManager.activeNotifications
                for (notification in barNotifications) {
                    if (notification.id == id) NotificationManagerCompat.from(context).cancel(notification.id)
                }
                NotificationBuilder.chatNotifications.remove(id)
            } else {
                NotificationManagerCompat.from(context).cancel(Constants.NOTIFICATION_ID)
                NotificationBuilderBelow24.cancelNotifications()
            }
        }
    }
}