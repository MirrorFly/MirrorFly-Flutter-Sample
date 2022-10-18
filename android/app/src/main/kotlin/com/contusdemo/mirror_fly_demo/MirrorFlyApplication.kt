package com.contusdemo.mirror_fly_demo

import android.app.Application
import com.contus.flycommons.LogMessage
import com.contus.flycommons.SharedPreferenceManager
import com.contus.webrtc.GroupCallDetails
import com.contus.webrtc.WebRtcCallService
import com.contus.webrtc.api.CallHelper
import com.contusflysdk.ChatSDK
import com.contusflysdk.api.ChatManager
import com.contus.webrtc.api.CallManager
import com.contus.webrtc.api.MissedCallListener
import com.contusflysdk.api.CallMessenger

class MirrorFlyApplication : Application() {


    override fun onCreate() {
        super.onCreate()

        LogMessage.enableDebugLogging(BuildConfig.DEBUG)
        ChatSDK.Builder()
            .setDomainBaseUrl(BuildConfig.SDK_BASE_URL)
            .setLicenseKey(BuildConfig.LICENSE)
            .setIsTrialLicenceKey(true)
            .build()

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
            /*override fun getDisplayName(jid: String): String {
                return ContactManager.getDisplayName(jid)
            }

            override fun isDeletedUser(jid: String): Boolean {
                return ContactManager.getProfileDetails(jid)?.contactType == ContactType.DELETED_CONTACT
            }*/

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

            /*override fun sendCallMessage(details: GroupCallDetails, users: List<String>, invitedUsers: List<String>) {
                CallMessenger.sendCallMessage(details, users, invitedUsers)
            }*/
        })

        ChatManager.callService = WebRtcCallService::class.java

    }
}