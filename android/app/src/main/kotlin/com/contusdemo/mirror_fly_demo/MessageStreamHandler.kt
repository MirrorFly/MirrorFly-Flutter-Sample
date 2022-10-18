package com.contusdemo.mirror_fly_demo

import android.util.Log
import com.contusflysdk.activities.FlyBaseActivity
import com.contusflysdk.api.models.ChatMessage
import io.flutter.plugin.common.EventChannel

class MessageStreamHandler : FlyBaseActivity(), EventChannel.StreamHandler {

    private var chatEventSink: EventChannel.EventSink? = null

    //Event Handler Methods
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        chatEventSink = events
    }

    override fun onCancel(arguments: Any?) {
        chatEventSink = null
    }

    override fun onMessageReceived(message: ChatMessage) {
        super.onMessageReceived(message)
        // received message object
        Log.e("Message Received", message.messageTextContent)
        chatEventSink?.success(message)
    }

}