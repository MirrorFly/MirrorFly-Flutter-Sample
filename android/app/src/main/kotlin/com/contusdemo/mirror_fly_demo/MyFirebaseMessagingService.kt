package com.contusdemo.mirror_fly_demo

import android.app.Application
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.annotation.RequiresApi
import androidx.core.app.NotificationCompat
import com.contus.flycommons.LogMessage
import com.contusflysdk.api.contacts.ContactManager
import com.contusflysdk.api.models.ChatMessage
import com.contusflysdk.api.notification.NotificationEventListener
import com.contusflysdk.api.notification.PushNotificationManager
import com.contusflysdk.utils.Utils
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage

class MyFirebaseMessagingService : FirebaseMessagingService() {

    /**
     * Instance of the chat utils class that contains the common firebase methods
     */
    lateinit var firebaseUtils: FirebaseUtils

    /**
     * Called when message is received.
     *
     * @param remoteMessage Object representing the message received from Firebase Cloud Messaging.
     */
    override fun onMessageReceived(remoteMessage: RemoteMessage) {
        super.onMessageReceived(remoteMessage)
        // Data messages are handled here in onMessageReceived whether the app is in the foreground
        // or background. Data messages are the type traditionally used with GCM.
        val notificationData: Map<String, String> = remoteMessage.data
        LogMessage.d(TAG, "RemoteMessage:$notificationData")
        if (notificationData.isNotEmpty()) {
            //firebaseUtils.handleReceivedMessage(this, notificationData)
            PushNotificationManager.handleReceivedMessage(notificationData, object : NotificationEventListener {
                override fun onMessageReceived(chatMessage : ChatMessage) {
                    val messageType = Utils.returnEmptyStringIfNull(notificationData[com.contus.flycommons.Constants.TYPE])
                    LogMessage.d(TAG,chatMessage.messageTextContent)
                    val builder: NotificationCompat.Builder = NotificationCompat.Builder(MirrorFlyApplication.getContext())
                        .setSmallIcon(R.mipmap.ic_launcher)
                        .setContentTitle(chatMessage.senderNickName)
                        .setContentText(chatMessage.messageTextContent)

                    val notificationIntent = Intent(MirrorFlyApplication.getContext(), MainActivity::class.java)
                    val contentIntent: PendingIntent = PendingIntent.getActivity(
                        MirrorFlyApplication.getContext(), 0, notificationIntent,
                        PendingIntent.FLAG_UPDATE_CURRENT
                    )
                    builder.setContentIntent(contentIntent)

                    // Add as notification

                    // Add as notification
                    val manager: NotificationManager =
                        getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                    manager.notify(chatMessage.messageSentTime.toInt(), builder.build())
                }

                override fun onGroupNotification(groupJid: String, titleContent: String, chatMessage : ChatMessage) {
                    /* Create the notification for group creation with parameter values */
                    //AppNotificationManager.createNotification(MobileApplication.getContext(), chatMessage)
                }

                @RequiresApi(Build.VERSION_CODES.M)
                override fun onCancelNotification() {
                    //AppNotificationManager.cancelNotifications(context)
                }
            })
        }
    }

    override fun onDeletedMessages() {
        // When the app instance receives this callback, perform a full sync with the app server.
        // This occurs when there are too many messages (>100) pending for your app on a particular
        // device at the time it connects or if the device hasn't connected to FCM
        // in more than one month.
    }

    override fun onNewToken(s: String) {
        LogMessage.e(TAG, "FirebaseToken:$s")
        //firebaseUtils.postRefreshedToken(s)
    }

    companion object {
        private val TAG = MyFirebaseMessagingService::class.java.simpleName
    }

    override fun onDestroy() {
        super.onDestroy()
        //firebaseUtils.onDestroy()
    }

    override fun onCreate() {
        super.onCreate()
    }
}