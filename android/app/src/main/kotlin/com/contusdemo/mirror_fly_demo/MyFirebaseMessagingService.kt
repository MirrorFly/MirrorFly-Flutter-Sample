package com.contusdemo.mirror_fly_demo

import android.annotation.SuppressLint
import android.app.*
import android.content.Intent
import android.os.Build
import androidx.annotation.RequiresApi
import androidx.core.app.NotificationCompat
import com.contus.flycommons.LogMessage
import com.contus.flycommons.PendingIntentHelper
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
//    lateinit var firebaseUtils: FirebaseUtils

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
                    notificationDialog(chatMessage)
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

    private fun notificationDialog(chatMessage: ChatMessage) {
        val notificationId = chatMessage.chatUserJid.hashCode().toLong().toInt()
        val notificationIntent = Intent(this, MainActivity::class.java).apply {
            flags = (Intent.FLAG_ACTIVITY_CLEAR_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
            putExtra("from_notification", true)
        putExtra("jid", chatMessage.senderUserJid)}
        val requestID = System.currentTimeMillis().toInt()
        val mainPendingIntent =
            PendingIntentHelper.getActivity( MirrorFlyApplication.getContext(), requestID, notificationIntent)
        val notificationManager = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
        val notificationChannelId = chatMessage.messageId
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            @SuppressLint("WrongConstant") val notificationChannel = NotificationChannel(
                notificationChannelId,
                "MirrorFly",
                NotificationManager.IMPORTANCE_MAX
            )
            // Configure the notification channel.
            notificationChannel.description = chatMessage.messageTextContent
            notificationChannel.enableLights(true)
            notificationChannel.vibrationPattern = longArrayOf(0, 1000, 500, 1000)
            notificationChannel.enableVibration(true)
            notificationManager.createNotificationChannel(notificationChannel)
        }
        val notificationBuilder = NotificationCompat.Builder(this, notificationChannelId)
        notificationBuilder.setAutoCancel(true)
            .setDefaults(Notification.DEFAULT_ALL)
            .setWhen(System.currentTimeMillis())
            .setSmallIcon(R.mipmap.ic_launcher)
            .setTicker("MirrorFly") //.setPriority(Notification.PRIORITY_MAX)
            .setContentTitle(chatMessage.senderNickName)
            .setContentText(chatMessage.messageTextContent)
        notificationBuilder.setContentIntent(mainPendingIntent)
        notificationManager.notify(notificationId, notificationBuilder.build())
    }
}