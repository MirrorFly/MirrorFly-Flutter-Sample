package com.contusdemo.mirror_fly_demo

import android.app.Application
import android.content.Context
import com.contus.flycommons.Constants
import com.contus.flycommons.LogMessage
import com.contus.webrtc.GroupCallDetails
import com.contus.webrtc.WebRtcCallService
import com.contus.webrtc.api.CallHelper
import com.contus.webrtc.api.CallManager
import com.contus.webrtc.api.MissedCallListener
import com.contusflysdk.ChatSDK
import com.contusflysdk.GroupConfig
import com.contusflysdk.api.CallMessenger
import com.contusflysdk.api.ChatManager
import com.contusflysdk.api.GroupManager
import com.contusflysdk.api.contacts.ContactManager
import com.contusflysdk.api.utils.NameHelper
import io.flutter.app.FlutterApplication


class MirrorFlyApplication : FlutterApplication() {

    init {
        instance = this
    }

    companion object {
        private var instance: MirrorFlyApplication? = null

        fun getContext(): Context {
            return instance!!.applicationContext
        }
    }
    override fun onCreate() {
        super.onCreate()

        LogMessage.enableDebugLogging(BuildConfig.DEBUG)

        GroupManager.setNameHelper(object  : NameHelper {
            override fun getDisplayName(jid: String): String {
                return if (ContactManager.getProfileDetails(jid) != null) ContactManager.getProfileDetails(jid)!!.name else Constants.EMPTY_STRING
            }
        })

        val groupConfiguration = GroupConfig.Builder()
            .enableGroupCreation(true)
            .setMaximumMembersInAGroup(250)
            .onlyAdminCanAddOrRemoveMembers(true)
            .build()

        ChatSDK.Builder()
            .setDomainBaseUrl(BuildConfig.SDK_BASE_URL)
            .setLicenseKey(BuildConfig.LICENSE)
            .setIsTrialLicenceKey(BuildConfig.IS_TRIAL_LICENSE)
            .setMediaFolderName("MFlutter")
            .setGroupConfiguration(groupConfiguration)
            .build()

        //activity to open when use clicked from notification
        //activity to open when a user logout from the app.
        ChatManager.enableMobileNumberLogin(true) //for syncContact
//        ChatManager.startActivity = MainActivity::class.java

        //initialize call sdk
        CallManager.init(this)
//        CallManager.setCurrentUserId(SharedPreferenceManager.instance.currentUserJid)
//        CallManager.setSignalServerUrl(BuildConfig.SIGNAL_SERVER)
//        CallManager.setJanusWebSocketServerUrl(BuildConfig.JANUS_WEB_SOCKET_SERVER)
        CallManager.setCallActivityClass(MainActivity::class.java)
//CallManager.setIceServers(ICE_SERVERS_LIST)
        CallManager.setMissedCallListener(object : MissedCallListener {
            override fun onMissedCall(
                isOneToOneCall: Boolean,
                userJid: String,
                groupId: String?,
                callType: String,
                userList: ArrayList<String>
            ) {
                //show missed call notification
            }
        })

        CallManager.setCallHelper(object : CallHelper {
//            override fun getDisplayName(jid: String): String {
//                return ContactManager.getDisplayName(jid)
//            }
//
//            override fun isDeletedUser(jid: String): Boolean {
//                return ContactManager.getProfileDetails(jid)?.contactType == ContactType.DELETED_CONTACT
//            }

            override fun getNotificationContent(callDirection: String): String {
                return callDirection
            }

            override fun sendCallMessage(
                details: GroupCallDetails,
                users: List<String>,
                invitedUsers: List<String>
            ) {
                CallMessenger.sendCallMessage(details, users, invitedUsers)
            }
//
//            override fun sendCallMessage(details: GroupCallDetails, users: List<String>, invitedUsers: List<String>) {
//                CallMessenger.sendCallMessage(details, users, invitedUsers)
//            }
        })

        ChatManager.callService = WebRtcCallService::class.java

    }
}