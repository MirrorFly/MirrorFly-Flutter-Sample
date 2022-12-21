import UIKit
import Flutter
import FlyCore
import FlyCommon
import GoogleMaps
import UserNotifications
import FirebaseAuth
import Firebase


var BASE_URL = "https://api-uikit-qa.contus.us/api/v1/"
var LICENSE_KEY = "ckIjaccWBoMNvxdbql8LJ2dmKqT5bp"
let XMPP_DOMAIN = "xmpp-preprod-sandbox.mirrorfly.com"
let XMPP_PORT = 5222
let SOCKETIO_SERVER_HOST = "https://signal-preprod-sandbox.mirrorfly.com/"
let JANUS_URL = "wss://janus.mirrorfly.com"
//let CONTAINER_ID = "group.com.mirror.flyflutter"
let CONTAINER_ID = "group.com.mirrorfly.qa"
let ENABLE_CONTACT_SYNC = false
let IS_LIVE = false
let WEB_LOGIN_URL = "https://webchat-preprod-sandbox.mirrorfly.com/"
let IS_MOBILE_NUMBER_LOGIN = true
let MIRRORFLY_METHOD_CHANNEL = "contus.mirrorfly/sdkCall"

let MESSAGE_STATUS_UPDATED_CHANNEL = "contus.mirrorfly/onMessageStatusUpdated"
let MEDIA_STATUS_UPDATED_CHANNEL = "contus.mirrorfly/onMediaStatusUpdated"
let UPLOAD_DOWNLOAD_PROGRESS_CHANGED_CHANNEL =
    "contus.mirrorfly/onUploadDownloadProgressChanged"
let SHOW_UPDATE_CANCEL_NOTIFICTION_CHANNEL =
    "contus.mirrorfly/showOrUpdateOrCancelNotification"

let onGroupProfileFetched_channel = "contus.mirrorfly/onGroupProfileFetched"
let onNewGroupCreated_channel = "contus.mirrorfly/onNewGroupCreated"
let onGroupProfileUpdated_channel = "contus.mirrorfly/onGroupProfileUpdated"
let onNewMemberAddedToGroup_channel = "contus.mirrorfly/onNewMemberAddedToGroup"
let onMemberRemovedFromGroup_channel = "contus.mirrorfly/onMemberRemovedFromGroup"
let onFetchingGroupMembersCompleted_channel =
    "contus.mirrorfly/onFetchingGroupMembersCompleted"
let onDeleteGroup_channel = "contus.mirrorfly/onDeleteGroup"
let onFetchingGroupListCompleted_channel =
    "contus.mirrorfly/onFetchingGroupListCompleted"
let onMemberMadeAsAdmin_channel = "contus.mirrorfly/onMemberMadeAsAdmin"
let onMemberRemovedAsAdmin_channel = "contus.mirrorfly/onMemberRemovedAsAdmin"
let onLeftFromGroup_channel = "contus.mirrorfly/onLeftFromGroup"
let onGroupNotificationMessage_channel = "contus.mirrorfly/onGroupNotificationMessage"
let onGroupDeletedLocally_channel = "contus.mirrorfly/onGroupDeletedLocally"

let blockedThisUser_channel = "contus.mirrorfly/blockedThisUser"
let myProfileUpdated_channel = "contus.mirrorfly/myProfileUpdated"
let onAdminBlockedOtherUser_channel = "contus.mirrorfly/onAdminBlockedOtherUser"
let onAdminBlockedUser_channel = "contus.mirrorfly/onAdminBlockedUser"
let onContactSyncComplete_channel = "contus.mirrorfly/onContactSyncComplete"
let onLoggedOut_channel = "contus.mirrorfly/onLoggedOut"
let unblockedThisUser_channel = "contus.mirrorfly/unblockedThisUser"
let userBlockedMe_channel = "contus.mirrorfly/userBlockedMe"
let userCameOnline_channel = "contus.mirrorfly/userCameOnline"
let userDeletedHisProfile_channel = "contus.mirrorfly/userDeletedHisProfile"
let userProfileFetched_channel = "contus.mirrorfly/userProfileFetched"
let userUnBlockedMe_channel = "contus.mirrorfly/userUnBlockedMe"
let userUpdatedHisProfile_channel = "contus.mirrorfly/userUpdatedHisProfile"
let userWentOffline_channel = "contus.mirrorfly/userWentOffline"
let usersIBlockedListFetched_channel = "contus.mirrorfly/usersIBlockedListFetched"
let usersProfilesFetched_channel = "contus.mirrorfly/usersProfilesFetched"
let usersWhoBlockedMeListFetched_channel = "contus.mirrorfly/usersWhoBlockedMeListFetched"
let onConnected_channel = "contus.mirrorfly/onConnected"
let onDisconnected_channel = "contus.mirrorfly/onDisconnected"
let onConnectionNotAuthorized_channel = "contus.mirrorfly/onConnectionNotAuthorized"
let connectionFailed_channel = "contus.mirrorfly/connectionFailed"
let connectionSuccess_channel = "contus.mirrorfly/connectionSuccess"
let onWebChatPasswordChanged_channel = "contus.mirrorfly/onWebChatPasswordChanged"
let setTypingStatus_channel = "contus.mirrorfly/setTypingStatus"
let onChatTypingStatus_channel = "contus.mirrorfly/onChatTypingStatus"
let onGroupTypingStatus_channel = "contus.mirrorfly/onGroupTypingStatus"
let onFailure_channel = "contus.mirrorfly/onFailure"
let onProgressChanged_channel = "contus.mirrorfly/onProgressChanged"
let onSuccess_channel = "contus.mirrorfly/onSuccess"



let googleApiKey = "AIzaSyDnjPEs86MRsnFfW1sVPKvMWjqQRnSa7Ts"

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, LogoutDelegate, GroupEventsDelegate, ConnectionEventDelegate{
    
    
    var postNotificationdidEnterBackground : NotificationCenter? = nil
    
    let MESSAGE_ONRECEIVED_CHANNEL = "contus.mirrorfly/onMessageReceived"
    var messageReceivedStreamHandler: MessageReceivedStreamHandler?
    var messageStatusUpdatedStreamHandler: MessageStatusUpdatedStreamHandler?
    var mediaStatusUpdatedStreamHandler: MediaStatusUpdatedStreamHandler?
    var uploadDownloadProgressChangedStreamHandler: UploadDownloadProgressChangedStreamHandler?
    var showOrUpdateOrCancelNotificationStreamHandler: ShowOrUpdateOrCancelNotificationStreamHandler?
    
    
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      
//      #if LOCAL || DEBUG || DEV
//      BASE_URL = "https://api-uikit-qa.contus.us/api/v1/"
//      LICENSE_KEY = "ckIjaccWBoMNvxdbql8LJ2dmKqT5bp"
//
//      #elseif QA
//      BASE_URL = "https://api-uikit-dev.contus.us/api/v1/"
//      LICENSE_KEY = "ckIjaccWBoMNvxdbql8LJ2dmKqT5bp"
//
//      #endif
      
      let groupConfig = try? GroupConfig.Builder.enableGroupCreation(groupCreation: true)
          .onlyAdminCanAddOrRemoveMembers(adminOnly: true)
          .setMaximumMembersInAGroup(membersCount: 200)
          .build()
      assert(groupConfig != nil)
      
      print("============================")
      print(BASE_URL)
      print("============================")
      

      try? ChatSDK.Builder.setAppGroupContainerID(containerID: CONTAINER_ID)
          .setLicenseKey(key: LICENSE_KEY)
          .isTrialLicense(isTrial: !IS_LIVE)
          .setDomainBaseUrl(baseUrl: BASE_URL)
          .setGroupConfiguration(groupConfig: groupConfig!)
          .buildAndInitialize()
//      GMSServices.provideAPIKey("AIzaSyBy7JDQj6Ar03dMXFCQ-SHgBdBPnKAteG4")
      
      let controller : FlutterViewController = window?.rootViewController as! FlutterViewController

      let methodChannel = FlutterMethodChannel(name: MIRRORFLY_METHOD_CHANNEL, binaryMessenger: controller.binaryMessenger)
      
      FlyMethodChannel.prepareMethodHandler(methodChannel: methodChannel)
      
      
      if (self.messageReceivedStreamHandler == nil) {
          self.messageReceivedStreamHandler = MessageReceivedStreamHandler()
        }
              
      FlutterEventChannel(name: MESSAGE_ONRECEIVED_CHANNEL, binaryMessenger: controller.binaryMessenger).setStreamHandler((self.messageReceivedStreamHandler as! FlutterStreamHandler & NSObjectProtocol))

      if (self.messageStatusUpdatedStreamHandler == nil) {
          self.messageStatusUpdatedStreamHandler = MessageStatusUpdatedStreamHandler()
        }
      FlutterEventChannel(name: MESSAGE_STATUS_UPDATED_CHANNEL, binaryMessenger: controller.binaryMessenger).setStreamHandler((self.messageStatusUpdatedStreamHandler as! FlutterStreamHandler & NSObjectProtocol))
      
      if (self.mediaStatusUpdatedStreamHandler == nil) {
          self.mediaStatusUpdatedStreamHandler = MediaStatusUpdatedStreamHandler()
        }
      
      FlutterEventChannel(name: MEDIA_STATUS_UPDATED_CHANNEL, binaryMessenger: controller.binaryMessenger).setStreamHandler((self.mediaStatusUpdatedStreamHandler as! FlutterStreamHandler & NSObjectProtocol))
      
      FlutterEventChannel(name: UPLOAD_DOWNLOAD_PROGRESS_CHANGED_CHANNEL, binaryMessenger: controller.binaryMessenger).setStreamHandler(UploadDownloadProgressChangedStreamHandler())
      
      FlutterEventChannel(name: SHOW_UPDATE_CANCEL_NOTIFICTION_CHANNEL, binaryMessenger: controller.binaryMessenger).setStreamHandler(ShowOrUpdateOrCancelNotificationStreamHandler())
      
      FlutterEventChannel(name: onGroupProfileFetched_channel, binaryMessenger: controller.binaryMessenger).setStreamHandler(GroupProfileFetchedStreamHandler())
      
      FlutterEventChannel(name: onNewGroupCreated_channel, binaryMessenger: controller.binaryMessenger).setStreamHandler(NewGroupCreatedStreamHandler())
      
      FlutterEventChannel(name: onGroupProfileUpdated_channel, binaryMessenger: controller.binaryMessenger).setStreamHandler(GroupProfileUpdatedStreamHandler())
      
      FlutterEventChannel(name: onNewMemberAddedToGroup_channel, binaryMessenger: controller.binaryMessenger).setStreamHandler(NewMemberAddedToGroupStreamHandler())
      
      FlutterEventChannel(name: onMemberRemovedFromGroup_channel, binaryMessenger: controller.binaryMessenger).setStreamHandler(MemberRemovedFromGroupStreamHandler())
      
      FlutterEventChannel(name: onFetchingGroupMembersCompleted_channel, binaryMessenger: controller.binaryMessenger).setStreamHandler(FetchingGroupMembersCompletedStreamHandler())
      
      FlutterEventChannel(name: onDeleteGroup_channel, binaryMessenger: controller.binaryMessenger).setStreamHandler(DeleteGroupStreamHandler())
      
      FlutterEventChannel(name: onFetchingGroupListCompleted_channel, binaryMessenger: controller.binaryMessenger).setStreamHandler(FetchingGroupListCompletedStreamHandler())
      
      FlutterEventChannel(name: onMemberMadeAsAdmin_channel, binaryMessenger: controller.binaryMessenger).setStreamHandler(MemberMadeAsAdminStreamHandler())
      
      FlutterEventChannel(name: onMemberRemovedAsAdmin_channel, binaryMessenger: controller.binaryMessenger).setStreamHandler(MemberRemovedAsAdminStreamHandler())
      
      FlutterEventChannel(name: onLeftFromGroup_channel, binaryMessenger: controller.binaryMessenger).setStreamHandler(LeftFromGroupStreamHandler())
      
      FlutterEventChannel(name: onGroupNotificationMessage_channel, binaryMessenger: controller.binaryMessenger).setStreamHandler(GroupNotificationMessageStreamHandler())
      
      FlutterEventChannel(name: onGroupDeletedLocally_channel, binaryMessenger: controller.binaryMessenger).setStreamHandler(GroupDeletedLocallyStreamHandler())
      
      FlutterEventChannel(name: blockedThisUser_channel, binaryMessenger: controller.binaryMessenger).setStreamHandler(blockedThisUserStreamHandler())
      
      FlutterEventChannel(name: myProfileUpdated_channel, binaryMessenger: controller.binaryMessenger).setStreamHandler(myProfileUpdatedStreamHandler())
      
      FlutterEventChannel(name: onAdminBlockedOtherUser_channel, binaryMessenger: controller.binaryMessenger).setStreamHandler(onAdminBlockedOtherUserStreamHandler())
      
      FlutterEventChannel(name: onAdminBlockedUser_channel, binaryMessenger: controller.binaryMessenger).setStreamHandler(onAdminBlockedUserStreamHandler())
      
      FlutterEventChannel(name: onContactSyncComplete_channel, binaryMessenger: controller.binaryMessenger).setStreamHandler(onContactSyncCompleteStreamHandler())
      
      FlutterEventChannel(name: onLoggedOut_channel, binaryMessenger: controller.binaryMessenger).setStreamHandler(onLoggedOutStreamHandler())
      
      FlutterEventChannel(name: unblockedThisUser_channel, binaryMessenger: controller.binaryMessenger).setStreamHandler(unblockedThisUserStreamHandler())
      
      FlutterEventChannel(name: userBlockedMe_channel, binaryMessenger: controller.binaryMessenger).setStreamHandler(userBlockedMeStreamHandler())
      
      FlutterEventChannel(name: userCameOnline_channel, binaryMessenger: controller.binaryMessenger).setStreamHandler(userCameOnlineStreamHandler())
      
      FlutterEventChannel(name: userDeletedHisProfile_channel, binaryMessenger: controller.binaryMessenger).setStreamHandler(userDeletedHisProfileStreamHandler())
      
      FlutterEventChannel(name: userProfileFetched_channel, binaryMessenger: controller.binaryMessenger).setStreamHandler(userProfileFetchedStreamHandler())
      
      FlutterEventChannel(name: userUnBlockedMe_channel, binaryMessenger: controller.binaryMessenger).setStreamHandler(userUnBlockedMeStreamHandler())
      
      FlutterEventChannel(name: userUpdatedHisProfile_channel, binaryMessenger: controller.binaryMessenger).setStreamHandler(userUpdatedHisProfileStreamHandler())
      
      FlutterEventChannel(name: userWentOffline_channel, binaryMessenger: controller.binaryMessenger).setStreamHandler(userWentOfflineStreamHandler())
      
      FlutterEventChannel(name: usersIBlockedListFetched_channel, binaryMessenger: controller.binaryMessenger).setStreamHandler(usersIBlockedListFetchedStreamHandler())
      
      FlutterEventChannel(name: usersProfilesFetched_channel, binaryMessenger: controller.binaryMessenger).setStreamHandler(usersProfilesFetchedStreamHandler())
      
      FlutterEventChannel(name: usersWhoBlockedMeListFetched_channel, binaryMessenger: controller.binaryMessenger).setStreamHandler(usersWhoBlockedMeListFetchedStreamHandler())
      
      FlutterEventChannel(name: onConnected_channel, binaryMessenger: controller.binaryMessenger).setStreamHandler(onConnectedStreamHandler())
      
      FlutterEventChannel(name: onDisconnected_channel, binaryMessenger: controller.binaryMessenger).setStreamHandler(onDisconnectedStreamHandler())
      
      FlutterEventChannel(name: onConnectionNotAuthorized_channel, binaryMessenger: controller.binaryMessenger).setStreamHandler(onConnectionNotAuthorizedStreamHandler())
      
      FlutterEventChannel(name: connectionFailed_channel, binaryMessenger: controller.binaryMessenger).setStreamHandler(connectionFailedStreamHandler())
      
      FlutterEventChannel(name: connectionSuccess_channel, binaryMessenger: controller.binaryMessenger).setStreamHandler(connectionSuccessStreamHandler())
      
      FlutterEventChannel(name: onWebChatPasswordChanged_channel, binaryMessenger: controller.binaryMessenger).setStreamHandler(onWebChatPasswordChangedStreamHandler())
      
      FlutterEventChannel(name: setTypingStatus_channel, binaryMessenger: controller.binaryMessenger).setStreamHandler(setTypingStatusStreamHandler())
      
      FlutterEventChannel(name: onChatTypingStatus_channel, binaryMessenger: controller.binaryMessenger).setStreamHandler(onChatTypingStatusStreamHandler())
      
      FlutterEventChannel(name: onGroupTypingStatus_channel, binaryMessenger: controller.binaryMessenger).setStreamHandler(onGroupTypingStatusStreamHandler())
      
      FlutterEventChannel(name: onFailure_channel, binaryMessenger: controller.binaryMessenger).setStreamHandler(onFailureStreamHandler())
      
      FlutterEventChannel(name: onProgressChanged_channel, binaryMessenger: controller.binaryMessenger).setStreamHandler(onProgressChangedStreamHandler())
      
      FlutterEventChannel(name: onSuccess_channel, binaryMessenger: controller.binaryMessenger).setStreamHandler(onSuccessStreamHandler())

      
      GMSServices.provideAPIKey(googleApiKey)
      
      // MARK:- Push Notification
      clearPushNotifications()
      registerForPushNotifications()
      
      ChatManager.shared.logoutDelegate = self
      FlyMessenger.shared.messageEventsDelegate = self
      ChatManager.shared.messageEventsDelegate = self
      GroupManager.shared.groupDelegate = self
      ChatManager.shared.logoutDelegate = self
      ChatManager.shared.connectionDelegate = self
//      ChatManager.shared.adminBlockCurrentUserDelegate = self
      
      
      FirebaseApp.configure()
//      Messaging.messaging().delegate = self
      if #available(iOS 10.0, *) {
          // For iOS 10 display notification (sent via APNS)
          UNUserNotificationCenter.current().delegate = self
          
          let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
          UNUserNotificationCenter.current().requestAuthorization(
              options: authOptions,
              completionHandler: { val, error in
              }
          )
      } else {
          let settings: UIUserNotificationSettings =
          UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
          application.registerUserNotificationSettings(settings)
      }
      
      application.registerForRemoteNotifications()
      
    
      GeneratedPluginRegistrant.register(with: self)
      
      return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

//    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
//        if let deviceToken = fcmToken {
//            print("DeviceToken ==> " + deviceToken)
//            Utility.saveInPreference(key: googleToken, value: deviceToken)
//        }
//    }
    
    override func applicationDidBecomeActive(_ application: UIApplication) {
        print("#appDelegate applicationDidBecomeActive")
        if Utility.getBoolFromPreference(key: isLoggedIn) && (FlyDefaults.isLoggedIn) {
            print("connecting chat manager")
            ChatManager.connect()
            
        }else{
            print(Utility.getBoolFromPreference(key: isLoggedIn))
            print(FlyDefaults.isLoggedIn)
            print("Unable to connect chat manager")
        }
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(didEnterBackground), object: nil)
    }
    
    override func applicationDidEnterBackground(_ application: UIApplication) {
        print("#appDelegate applicationDidEnterBackground")
        postNotificationdidEnterBackground = NotificationCenter.default
        postNotificationdidEnterBackground?.post(name: Notification.Name(didEnterBackground), object: nil)

        if (FlyDefaults.isLoggedIn) {
            print("Disconnecting Chat Manager")
            ChatManager.disconnect()
        }
    }
    
    func onConnected() {
        print("======sdk connected=======")
    }
    
    func onDisconnected() {
        print("======sdk Disconnected======")
    }
    
    func onConnectionNotAuthorized() {
        print("======sdk Not Authorized=======")
    }
    
    
    func didAddNewMemeberToGroup(groupJid: String, newMemberJid: String, addedByMemberJid: String) {
        
    }
    
    func didRemoveMemberFromGroup(groupJid: String, removedMemberJid: String, removedByMemberJid: String) {
        
    }
    
    func didFetchGroupProfile(groupJid: String) {
        
    }
    
    func didUpdateGroupProfile(groupJid: String) {
        
    }
    
    func didMakeMemberAsAdmin(groupJid: String, newAdminMemberJid: String, madeByMemberJid: String) {
        
    }
    
    func didRemoveMemberFromAdmin(groupJid: String, removedAdminMemberJid: String, removedByMemberJid: String) {
        
    }
    
    func didDeleteGroupLocally(groupJid: String) {
        
    }
    
    func didLeftFromGroup(groupJid: String, leftUserJid: String) {
        
    }
    
    func didCreateGroup(groupJid: String) {
        
    }
    
    func didFetchGroups(groups: [FlyCommon.ProfileDetails]) {
        
    }
    
    func didFetchGroupMembers(groupJid: String) {
        
    }
    
    func didReceiveGroupNotificationMessage(message: FlyCommon.ChatMessage) {
        
    }
    
    
    
    
    func didReceiveLogout() {
        print("logout delegate received")
        print("AppDelegate LogoutDelegate ===> LogoutDelegate")
        Utility.saveInPreference(key: isProfileSaved, value: false)
        Utility.saveInPreference(key: isLoggedIn, value: false)
        
        ChatManager.logoutApi { isSuccess, flyError, flyData in
           if isSuccess {
               print("requestLogout Logout api isSuccess")
               
           }else{
               print("Logout api error : \(String(describing: flyError))")
              
           }
       }
        ChatManager.enableContactSync(isEnable: ENABLE_CONTACT_SYNC)
        ChatManager.disconnect()
        ChatManager.shared.resetFlyDefaults()
    }
    
    
}

extension AppDelegate : UNUserNotificationCenterDelegate{
    /// Register for APNS Notifications
    func registerForPushNotifications() {
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { granted, error in
            if granted {
                self.getNotificationSettings()
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                    FlyUtils.setBaseUrl(BASE_URL)
                }
            }
        }
//        registerForVOIPNotifications()
    }
    /// This method is used to clear notifications and badge count
    func clearPushNotifications() {
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        //Mark:- Added for swizzling
//        Auth.auth().setAPNSToken(deviceToken, type: .unknown)
        // Pass device token to messaging
//        Messaging.messaging().apnsToken = deviceToken
//        Messaging.messaging().setAPNSToken(deviceToken, type: .unknown)
        
        let token = deviceToken.map { String(format: "%.2hhx", $0) }.joined()
        if token.count == 0 {
            print("Push Status Credentials APNS:")
            return;
        }
        print("#token appDelegate \(token)")
        print("#token application DT => \(token)")
//        VOIPManager.sharedInstance.saveAPNSToken(token: token)
        Utility.saveInPreference(key: googleToken, value: token)
//        VOIPManager.sharedInstance.updateDeviceToken()
//        return super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }
    
    override func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Push didFailToRegisterForRemoteNotificationsWithError)")
    }
    override func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
    override func application(_ application: UIApplication, didReceiveRemoteNotification notification: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("Push userInfo \(notification)")
        completionHandler(.noData)
        // Handle the message for firebase auth phone verification
//            if Auth.auth().canHandleNotification(notification) {
//                completionHandler(.noData)
//                return
//            }
//
//            // Handle it for firebase messaging analytics
//            if ((notification["gcm.message_id"]) != nil) {
//                Messaging.messaging().appDidReceiveMessage(notification)
//            }
//
//            return super.application(application, didReceiveRemoteNotification: notification, fetchCompletionHandler: completionHandler)

    }
    override func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.notification.request.content.threadIdentifier.contains(XMPP_DOMAIN){
//            if FlyDefaults.isBlockedByAdmin {
//                navigateToBlockedScreen()
//            } else {
//                navigateToChatScreen(chatId: response.notification.request.content.threadIdentifier, completionHandler: completionHandler)
//            }
        }
    }
    
}


extension AppDelegate : MessageEventsDelegate {
    func onMessageReceived(message: FlyCommon.ChatMessage, chatJid: String) {
        
        print("Message Received Update--->")
        print(JSONSerializer.toJson(message))
        
        if(self.messageReceivedStreamHandler?.onMessageReceived != nil){
            self.messageReceivedStreamHandler?.onMessageReceived?(JSONSerializer.toJson(message))

        }else{
            print("Message Stream Handler is Nil")
        }
        
    }
    
    func onMessageStatusUpdated(messageId: String, chatJid: String, status: FlyCommon.MessageStatus) {
        
        let chatMessage = FlyMessenger.getMessageOfId(messageId: messageId)
        print("Message Status Update--->")
        var chatMessageJson = JSONSerializer.toJson(chatMessage as Any)
        
        chatMessageJson = chatMessageJson.replacingOccurrences(of: "{\"some\":", with: "")
        chatMessageJson = chatMessageJson.replacingOccurrences(of: "}}", with: "}")
        print(chatMessageJson)
        
        if(self.messageStatusUpdatedStreamHandler?.onMessageStatusUpdated != nil){
            self.messageStatusUpdatedStreamHandler?.onMessageStatusUpdated?(chatMessageJson)

        }else{
            print("Message Stream Handler is Nil")
        }
//        var chatMessage = FlyMessenger.getMessageOfId(messageId: messageId)
//        print("Message Status Update--->")
//        print(JSONSerializer.toJson(chatMessage as Any))
//        messageStatusEventSink(JSONSerializer.toJson(chatMessage as Any))
    }
    
    func onMediaStatusUpdated(message: FlyCommon.ChatMessage) {
        print("Media Status Update--->")
        var chatMediaJson = JSONSerializer.toJson(message as Any)
        chatMediaJson = chatMediaJson.replacingOccurrences(of: "{\"some\":", with: "")
        chatMediaJson = chatMediaJson.replacingOccurrences(of: "}}", with: "}")
        print(chatMediaJson)
        
        if(self.mediaStatusUpdatedStreamHandler?.onMediaStatusUpdated != nil){
            self.mediaStatusUpdatedStreamHandler?.onMediaStatusUpdated?(chatMediaJson)
        }else{
            print("chatMediaJson Stream Handler is Nil")
        }
    }
    
    func onMediaStatusFailed(error: String, messageId: String) {
        print("Media Status Failed--->\(error)")
    }
    
    func onMediaProgressChanged(message: FlyCommon.ChatMessage, progressPercentage: Float) {
        print("Media Status Onprogress changed---> \(progressPercentage)")
    }
    
    func onMessagesClearedOrDeleted(messageIds: Array<String>) {
        print("Message Cleared--->")
    }
    
    func onMessagesDeletedforEveryone(messageIds: Array<String>) {
        print("Message Deleted For Everyone--->")
    }
    
    func showOrUpdateOrCancelNotification() {
        print("Message showOrUpdateOrCancelNotification--->")
    }
    
    func onMessagesCleared(toJid: String) {
        print("Message onMessagesCleared--->")
    }
    
    func setOrUpdateFavourite(messageId: String, favourite: Bool, removeAllFavourite: Bool) {
        print("Message setOrUpdateFavourite--->")
    }
    
    func onMessageTranslated(message: FlyCommon.ChatMessage, jid: String) {
        print("Message onMessageTranslated--->")
    }
    func getNotificationSettings() {
      UNUserNotificationCenter.current().getNotificationSettings { settings in
        print("Notification settings: \(settings)")
      }
    }
    
}

