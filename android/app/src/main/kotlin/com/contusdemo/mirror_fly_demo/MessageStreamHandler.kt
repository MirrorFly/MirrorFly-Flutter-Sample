package com.contusdemo.mirror_fly_demo

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
object onGroupProfileFetchedStreamHandler : EventChannel.StreamHandler {

    var onGroupProfileFetched: EventChannel.EventSink? = null

    //Event Handler Methods
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        onGroupProfileFetched = events
    }

    override fun onCancel(arguments: Any?) {
        onGroupProfileFetched = null
    }
}
object onNewGroupCreatedStreamHandler : EventChannel.StreamHandler {

    var onNewGroupCreated: EventChannel.EventSink? = null

    //Event Handler Methods
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        onNewGroupCreated = events
    }

    override fun onCancel(arguments: Any?) {
        onNewGroupCreated = null
    }
}
object onGroupProfileUpdatedStreamHandler : EventChannel.StreamHandler {

    var onGroupProfileUpdated: EventChannel.EventSink? = null

    //Event Handler Methods
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        onGroupProfileUpdated = events
    }

    override fun onCancel(arguments: Any?) {
        onGroupProfileUpdated = null
    }
}
object onNewMemberAddedToGroupStreamHandler : EventChannel.StreamHandler {

    var onNewMemberAddedToGroup: EventChannel.EventSink? = null

    //Event Handler Methods
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        onNewMemberAddedToGroup = events
    }

    override fun onCancel(arguments: Any?) {
        onNewMemberAddedToGroup = null
    }
}
object onMemberRemovedFromGroupStreamHandler : EventChannel.StreamHandler {

    var onMemberRemovedFromGroup: EventChannel.EventSink? = null

    //Event Handler Methods
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        onMemberRemovedFromGroup = events
    }

    override fun onCancel(arguments: Any?) {
        onMemberRemovedFromGroup = null
    }
}
object onFetchingGroupMembersCompletedStreamHandler : EventChannel.StreamHandler {

    var onFetchingGroupMembersCompleted: EventChannel.EventSink? = null

    //Event Handler Methods
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        onFetchingGroupMembersCompleted = events
    }

    override fun onCancel(arguments: Any?) {
        onFetchingGroupMembersCompleted = null
    }
}
object onDeleteGroupStreamHandler : EventChannel.StreamHandler {

    var onDeleteGroup: EventChannel.EventSink? = null

    //Event Handler Methods
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        onDeleteGroup = events
    }

    override fun onCancel(arguments: Any?) {
        onDeleteGroup = null
    }
}
object onFetchingGroupListCompletedStreamHandler : EventChannel.StreamHandler {

    var onFetchingGroupListCompleted: EventChannel.EventSink? = null

    //Event Handler Methods
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        onFetchingGroupListCompleted = events
    }

    override fun onCancel(arguments: Any?) {
        onFetchingGroupListCompleted = null
    }
}
object onMemberMadeAsAdminStreamHandler : EventChannel.StreamHandler {

    var onMemberMadeAsAdmin: EventChannel.EventSink? = null

    //Event Handler Methods
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        onMemberMadeAsAdmin = events
    }

    override fun onCancel(arguments: Any?) {
        onMemberMadeAsAdmin = null
    }
}
object onMemberRemovedAsAdminStreamHandler : EventChannel.StreamHandler {

    var onMemberRemovedAsAdmin: EventChannel.EventSink? = null

    //Event Handler Methods
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        onMemberRemovedAsAdmin = events
    }

    override fun onCancel(arguments: Any?) {
        onMemberRemovedAsAdmin = null
    }
}
object onLeftFromGroupStreamHandler : EventChannel.StreamHandler {

    var onLeftFromGroup: EventChannel.EventSink? = null

    //Event Handler Methods
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        onLeftFromGroup = events
    }

    override fun onCancel(arguments: Any?) {
        onLeftFromGroup = null
    }
}
object onGroupNotificationMessageStreamHandler : EventChannel.StreamHandler {

    var onGroupNotificationMessage: EventChannel.EventSink? = null

    //Event Handler Methods
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        onGroupNotificationMessage = events
    }

    override fun onCancel(arguments: Any?) {
        onGroupNotificationMessage = null
    }
}
object onGroupDeletedLocallyStreamHandler : EventChannel.StreamHandler {

    var onGroupDeletedLocally: EventChannel.EventSink? = null

    //Event Handler Methods
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        onGroupDeletedLocally = events
    }

    override fun onCancel(arguments: Any?) {
        onGroupDeletedLocally = null
    }
}
