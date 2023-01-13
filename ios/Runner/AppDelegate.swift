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



let googleApiKey = "AIzaSyDnjPEs86MRsnFfW1sVPKvMWjqQRnSa7Ts"


@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate{
    
    
   
    var postNotificationdidEnterBackground : NotificationCenter? = nil
    
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      
      let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
      
      FlyBaseController.initSDK(controller: controller, licenseKey: LICENSE_KEY, isTrial: !IS_LIVE, baseUrl: BASE_URL, containerID: CONTAINER_ID)
      
      ChatManager.shared.logoutDelegate = self
      FlyMessenger.shared.messageEventsDelegate = self
      ChatManager.shared.messageEventsDelegate = self
      GroupManager.shared.groupDelegate = self
      ChatManager.shared.connectionDelegate = self
      ChatManager.shared.adminBlockCurrentUserDelegate = self
      ChatManager.shared.typingStatusDelegate = self
//      ChatManager.shared.adminBlockDelegate = self
//      ContactManager.shared.profileDelegate = self
      
      GMSServices.provideAPIKey(googleApiKey)
      
      // MARK:- Push Notification
      clearPushNotifications()
      registerForPushNotifications()
      
      
      FirebaseApp.configure()
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
    
}

extension AppDelegate {
    /// Register for APNS Notifications
    func registerForPushNotifications() {
        print("###Registering push notification")
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
        
            print("###Clearing push notification")
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        //Mark:- Added for swizzling
        Auth.auth().setAPNSToken(deviceToken, type: .unknown)
        
        print("###didRegisterForRemoteNotificationsWithDeviceToken")
        
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
        print("###didFailToRegisterForRemoteNotificationsWithError")
        print("Push didFailToRegisterForRemoteNotificationsWithError)")
    }
    override func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
    override func application(_ application: UIApplication, didReceiveRemoteNotification notification: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("Push userInfo \(notification)")
            if Auth.auth().canHandleNotification(notification) {
                completionHandler(.noData)
                return
            }else{
                print("###canHandleNotification issue")
            }

    }
    func getNotificationSettings() {
          UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("Notification settings: \(settings)")
          }
        }
    override func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("###userNotificationCenter withCompletionHandler")
        let chatId = response.notification.request.content.threadIdentifier
        print("chat ID ---> \(chatId)")
        if let profileDetails = ContactManager.shared.getUserProfileDetails(for: chatId) , chatId != FlyDefaults.myJid{
            Utility.saveInPreference(key: notificationUserJid, value: profileDetails.jid ?? "")
            
        }
        
       
//        if response.notification.request.content.threadIdentifier.contains(XMPP_DOMAIN){
//            if FlyDefaults.isBlockedByAdmin {
//                navigateToBlockedScreen()
//            } else {
//                navigateToChatScreen(chatId: response.notification.request.content.threadIdentifier, completionHandler: completionHandler)
//            }
//        }
    }
    
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


extension AppDelegate : MessageEventsDelegate, ConnectionEventDelegate, LogoutDelegate, GroupEventsDelegate, AdminBlockCurrentUserDelegate, TypingStatusDelegate {
    func onChatTypingStatus(userJid: String, status: FlyCommon.TypingStatus) {
        
        print("onChatTypingStatus")
        let jsonObject: NSMutableDictionary = NSMutableDictionary()
        jsonObject.setValue(userJid, forKey: "fromUserJid")
        jsonObject.setValue(status.rawValue, forKey: "status")
        
        print("json data-->\(jsonObject)")
        

        let jsonString = Commons.json(from: jsonObject)
        print("json-->\(jsonString)")
        
        if(FlyBaseController.onChatTypingStatusStreamHandler?.onChatTyping != nil){
            FlyBaseController.onChatTypingStatusStreamHandler?.onChatTyping?(jsonString)

        }else{
            print("Chat Typing Stream Handler is Nil")
        }
        
    }
    
    func onGroupTypingStatus(groupJid: String, groupUserJid: String, status: FlyCommon.TypingStatus) {
        
        print("onGroupTypingStatus")
        
        let jsonObject: NSMutableDictionary = NSMutableDictionary()
        jsonObject.setValue(groupJid, forKey: "groupJid")
        jsonObject.setValue(groupUserJid, forKey: "groupUserJid")
        jsonObject.setValue(status.rawValue, forKey: "status")
        
        let jsonString = Commons.json(from: jsonObject)
        
        if(FlyBaseController.onGroupTypingStatusStreamHandler?.onGroupTyping != nil){
            FlyBaseController.onGroupTypingStatusStreamHandler?.onGroupTyping?(jsonString)

        }else{
            print("Group Chat Typing Stream Handler is Nil")
        }
    }
    
    func onMessageReceived(message: FlyCommon.ChatMessage, chatJid: String) {

        print("Message Received Update--->")
        print(JSONSerializer.toJson(message))

        var messageReceivedJson = JSONSerializer.toJson(message)
        messageReceivedJson = messageReceivedJson.replacingOccurrences(of: "{\"some\":", with: "")
        messageReceivedJson = messageReceivedJson.replacingOccurrences(of: "}}", with: "}")

        if(FlyBaseController.messageReceivedStreamHandler?.onMessageReceived != nil){
            FlyBaseController.messageReceivedStreamHandler?.onMessageReceived?(messageReceivedJson)

        }else{
            print("Message Stream Handler is Nil")
        }

    }

    func onMessageStatusUpdated(messageId: String, chatJid: String, status: FlyCommon.MessageStatus) {

        let chatMessage = FlyMessenger.getMessageOfId(messageId: messageId)
        print("Message Status Update--->\(chatMessage)")
        var chatMessageJson = JSONSerializer.toJson(chatMessage as Any)

        chatMessageJson = chatMessageJson.replacingOccurrences(of: "{\"some\":", with: "")
        chatMessageJson = chatMessageJson.replacingOccurrences(of: "}}", with: "}")
        print(chatMessageJson)

        if(FlyBaseController.messageStatusUpdatedStreamHandler?.onMessageStatusUpdated != nil){
            FlyBaseController.messageStatusUpdatedStreamHandler?.onMessageStatusUpdated?(chatMessageJson)

        }else{
            print("Message Stream Handler is Nil")
        }

    }

    func onMediaStatusUpdated(message: FlyCommon.ChatMessage) {
        print("Media Status Update--->")
        var chatMediaJson = JSONSerializer.toJson(message as Any)
        chatMediaJson = chatMediaJson.replacingOccurrences(of: "{\"some\":", with: "")
        chatMediaJson = chatMediaJson.replacingOccurrences(of: "}}", with: "}")
        print(chatMediaJson)

        if(FlyBaseController.mediaStatusUpdatedStreamHandler?.onMediaStatusUpdated != nil){
            FlyBaseController.mediaStatusUpdatedStreamHandler?.onMediaStatusUpdated?(chatMediaJson)
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
    
    func didBlockOrUnblockCurrentUser(userJid: String, isBlocked: Bool) {
        
    }
    
    func didBlockOrUnblockGroup(groupJid: String, isBlocked: Bool) {
        
    }
    
    func didBlockOrUnblockContact(userJid: String, isBlocked: Bool) {
        
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
        
    }
    
    func onConnected() {
        print("======Appdelegate sdk connected=======")
    }

    func onDisconnected() {
        print("======Appdelegate sdk Disconnected======")
    }

    func onConnectionNotAuthorized() {
        print("======Appdelegate sdk Not Authorized=======")
    }

}

