import UIKit
import Flutter
//import FlyCore
//import FlyCommon
import GoogleMaps
import UserNotifications
import FirebaseAuth
import Firebase



@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate{
    
    let googleApiKey = "AIzaSyDnjPEs86MRsnFfW1sVPKvMWjqQRnSa7Ts"
   
    var postNotificationdidEnterBackground : NotificationCenter? = nil
    
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      
      let _ : FlutterViewController = window?.rootViewController as! FlutterViewController
           
      GMSServices.provideAPIKey(googleApiKey)
      
      // MARK:- Push Notification
//      clearPushNotifications()
//      registerForPushNotifications()
      
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
//                    FlyUtils.setBaseUrl(BASE_URL)
                }
            }
        }
//        registerForVOIPNotifications()
    }
    /// This method is used to clear notifications and badge count
    func clearPushNotifications() {
        
//        print("###Clearing push notification")
//        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
//        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
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
//        Utility.saveInPreference(key: googleToken, value: token)
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
//        if let profileDetails = ContactManager.shared.getUserProfileDetails(for: chatId) , chatId != FlyDefaults.myJid{
//            Utility.saveInPreference(key: notificationUserJid, value: profileDetails.jid ?? "")
            
//        }
       
//        if response.notification.request.content.threadIdentifier.contains(XMPP_DOMAIN){
//            if FlyDefaults.isBlockedByAdmin {
//                navigateToBlockedScreen()
//            } else {
//                navigateToChatScreen(chatId: response.notification.request.content.threadIdentifier, completionHandler: completionHandler)
//            }
//        }
    }
    
}


