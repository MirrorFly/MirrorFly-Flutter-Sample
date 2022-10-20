package com.contusdemo.mirror_fly_demo

import android.util.Log
import com.contusflysdk.activities.FlyBaseActivity
import com.contusflysdk.api.models.ChatMessage
import io.flutter.plugin.common.EventChannel

object MessageReceivedStreamHandler : EventChannel.StreamHandler {

    var onMessageReceived: EventChannel.EventSink? = null

    //Event Handler Methods
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        onMessageReceived = events
    }

    override fun onCancel(arguments: Any?) {
        onMessageReceived = null
    }
}
object MessageStatusUpdatedStreamHandler : EventChannel.StreamHandler {

    var onMessageStatusUpdated: EventChannel.EventSink? = null

    //Event Handler Methods
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        onMessageStatusUpdated = events
    }

    override fun onCancel(arguments: Any?) {
        onMessageStatusUpdated = null
    }
}
object MediaStatusUpdatedStreamHandler : EventChannel.StreamHandler {

    var onMediaStatusUpdated: EventChannel.EventSink? = null

    //Event Handler Methods
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        onMediaStatusUpdated = events
    }

    override fun onCancel(arguments: Any?) {
        onMediaStatusUpdated = null
    }
}
object UploadDownloadProgressChangedStreamHandler : EventChannel.StreamHandler {

    var onUploadDownloadProgressChanged: EventChannel.EventSink? = null

    //Event Handler Methods
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        onUploadDownloadProgressChanged = events
    }

    override fun onCancel(arguments: Any?) {
        onUploadDownloadProgressChanged = null
    }
}
object ShowOrUpdateOrCancelNotificationStreamHandler : EventChannel.StreamHandler {

    var showOrUpdateOrCancelNotification: EventChannel.EventSink? = null

    //Event Handler Methods
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        showOrUpdateOrCancelNotification = events
    }

    override fun onCancel(arguments: Any?) {
        showOrUpdateOrCancelNotification = null
    }
}