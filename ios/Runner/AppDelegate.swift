import UIKit
import PushKit
import Flutter
import GoogleMaps
import UserNotifications
import FirebaseAuth
import Firebase
import MirrorFlySDK
import mirrorfly_plugin

import CallKit


#if DEBUG
    let ISEXPORT = false
#else
    let ISEXPORT = true
#endif

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
    let googleApiKey = "AIzaSyDnjPEs86MRsnFfW1sVPKvMWjqQRnSa7Ts"
   
    var postNotificationdidEnterBackground : NotificationCenter? = nil
    
    let XMPP_DOMAIN = "xmpp-uikit-qa.contus.us"
    
    let tag = "#Mirrorfly call"
    var voipRegistry:PKPushRegistry?
//    var voipRegister = PKPushRegistry.init(queue: .main)
    
    
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      
      let _ : FlutterViewController = window?.rootViewController as! FlutterViewController
           
      GMSServices.provideAPIKey(googleApiKey)
    
//      FirebaseApp.configure()
      
      UNUserNotificationCenter.current().delegate = self
      if #available(iOS 10, *) {
         UNUserNotificationCenter.current().requestAuthorization(options:[.badge, .alert, .sound]){ granted, error in }
      } else {
         application.registerUserNotificationSettings(UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil))
      }
      application.registerForRemoteNotifications()
      
      
      let licenseKey = Utility.getStringFromPreference(key: "licenseKey")
      let containerID = Utility.getStringFromPreference(key: "containerID")

      NSLog("#Mirrorfly licenseKey \(licenseKey)")
      NSLog("#Mirrorfly containerID \(containerID)")

//      if #available(iOS 10.0, *) {
//        UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
//      }
      
//      if #available(iOS 10.0, *) {
//             // For iOS 10 display notification (sent via APNS)
//             UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
//
//
//         }
      
      
      GeneratedPluginRegistrant.register(with: self)
      
      return true
  }
//    override func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
//        if response.notification.request.content.threadIdentifier.contains(XMPP_DOMAIN){
//            NSLog("#MirrorFlyCall AppDelegate XMPP Push received")
//        }else if response.notification.request.content.threadIdentifier == "media-call" {
////            pushChatId = "media-call"
//            NSLog("#MirrorFlyCall AppDelegate Push received")
//            if FlyDefaults.isBlockedByAdmin {
////                navigateToBlockedScreen()
//                NSLog("#MirrorFlyCall AppDelegate Blocked received")
//            } else {
//                NSLog("#MirrorFlyCall AppDelegate Push received 2")
//            }
//
//        }
//    }
//9788933954
    //8526697581
//
    override func application(_ application: UIApplication, didReceiveRemoteNotification notification: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
            // Handle the silent push notification and perform necessary tasks in the background
            NSLog("#Mirrorfly Appdelegate didReceiveRemoteNotification \(notification)")
            // Call the completion handler when finished processing the notification
            completionHandler(.newData)
        }

    
    override func applicationWillTerminate(_ application: UIApplication) {
        NSLog("#Voip Fly Defaults \(FlyDefaults.myJid)")
    }

   
    
}

extension AppDelegate {
//    override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
//            //Mark:- Added for swizzling
//    //        Auth.auth().setAPNSToken(deviceToken, type: .unknown)
//
//        NSLog("\(tag) ###didRegisterForRemoteNotificationsWithDeviceToken")
//
//            let token = deviceToken.map { String(format: "%.2hhx", $0) }.joined()
//            if token.count == 0 {
//                NSLog("Push Status Credentials APNS:")
//                return;
//            }
//        NSLog("\(tag) #token appDelegate \(token)")
//        NSLog("\(tag) #token application DT => \(token)")
//            NSLog("\(tag) Push token --> \(token)")
//
//        VOIPManager.sharedInstance.savePushToken(token: token)
//            Utility.saveInPreference(key: "googleToken", value: token)
//            VOIPManager.sharedInstance.updateDeviceToken()
//        }

//    override func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//            completionHandler([.alert, .sound])
//        }
//    override func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
//            print("###userNotificationCenter withCompletionHandler")
//            let chatId = response.notification.request.content.threadIdentifier
//            print("chat ID ---> \(chatId)")
//
//        }
}


