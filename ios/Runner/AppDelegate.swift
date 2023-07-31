import UIKit
import PushKit
import Flutter
//import FlyCore
//import FlyCommon
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
    

//      registerForVOIPNotifications()
      
//      UNUserNotificationCenter.current().delegate = self
//      if #available(iOS 10, *) {
//         UNUserNotificationCenter.current().requestAuthorization(options:[.badge, .alert, .sound]){ granted, error in }
//      } else {
//         application.registerUserNotificationSettings(UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil))
//      }
      
      if #available(iOS 10.0, *) {
             // For iOS 10 display notification (sent via APNS)
             UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate


         }
//      application.registerForRemoteNotifications()
      
      VOIPManager.sharedInstance.updateDeviceToken()
      
      GeneratedPluginRegistrant.register(with: self)
      
      return super.application(application, didFinishLaunchingWithOptions: launchOptions)
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
//    override func application(_ application: UIApplication, didReceiveRemoteNotification notification: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
//            // Handle the silent push notification and perform necessary tasks in the background
//            NSLog("#Mirrorfly Appdelegate didReceiveRemoteNotification \(notification)")
//            // Call the completion handler when finished processing the notification
//            completionHandler(.noData)
//        }

    
    override func applicationWillTerminate(_ application: UIApplication) {
        NSLog("#Voip Fly Defaults \(FlyDefaults.myJid)")
    }

   
    
}

//extension AppDelegate {
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
//
//    override func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//            completionHandler([.alert, .sound])
//        }
////    override func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
////            print("###userNotificationCenter withCompletionHandler")
////            let chatId = response.notification.request.content.threadIdentifier
////            print("chat ID ---> \(chatId)")
////
////        }
//}

//extension AppDelegate : PKPushRegistryDelegate{
//    func registerForVOIPNotifications() {
//        NSLog("\(tag) Registering Voip Notification")
//
//        voipRegistry = PKPushRegistry(queue: .main)
//        DispatchQueue.main.async {
//            self.voipRegistry?.delegate = self
//        }
//
//        voipRegistry?.desiredPushTypes = [.voIP]
//    }
//
//    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
//
//        NSLog("\(tag) VoIP Token: \(pushCredentials)")
//        let deviceTokenString = pushCredentials.token.reduce("") { $0 + String(format: "%02X", $1) }
//        NSLog("\(tag) #token pushRegistry VT => \(deviceTokenString)")
//        VOIPManager.sharedInstance.saveVOIPToken(token: deviceTokenString)
//        FlyCallUtils.sharedInstance.setConfigUserDefaults(deviceTokenString, withKey: "updatedTokenVOIP")
//        Utility.saveInPreference(key: "voipToken", value: deviceTokenString)
//        VOIPManager.sharedInstance.updateDeviceToken()
//    }
//
//    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
////        try? ChatSDK.Builder.setAppGroupContainerID(containerID: "group.com.mirrorfly.qa")
////                    .isTrialLicense(isTrial: true)
////                    .setLicenseKey(key: "ckIjaccWBoMNvxdbql8LJ2dmKqT5bp")
////                    .setDomainBaseUrl(baseUrl: "https://api-uikit-qa.contus.us/api/v1/")
////                    .buildAndInitialize()
//
//        NSLog("\(tag) Push VOIP Received with Payload - %@",payload.dictionaryPayload)
//        NSLog("\(tag) #callopt \(FlyUtils.printTime()) pushRegistry voip received")
//
//        NSLog("#VOIP myjid ***\(FlyDefaults.myJid)")
//        NSLog("#VOIP myjid Count ***\(FlyDefaults.myJid.count)")
//        NSLog("#VOIP myjid Count ***\(try? FlyUtils.getMyJid())")
//        NSLog("#VOIP isLogged In \(FlyDefaults.isLoggedIn)")
//
//
//        VOIPManager.sharedInstance.processPayload(payload.dictionaryPayload)
//        NSLog("\(tag) After Voip Complete")
//        completion()
//
//    }
//
//}

