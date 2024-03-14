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
    
    let googleApiKey = "Your_Googlr_API_KEY"
   
    var postNotificationdidEnterBackground : NotificationCenter? = nil
    
    let XMPP_DOMAIN = "xmpp-uikit-qa.contus.us"
    
    let tag = "#Mirrorfly call"
    
    
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      
      let _ : FlutterViewController = window?.rootViewController as! FlutterViewController
           
      GMSServices.provideAPIKey(googleApiKey)

      
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

      GeneratedPluginRegistrant.register(with: self)
      
      return true
  }

    override func application(_ application: UIApplication, didReceiveRemoteNotification notification: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
            // Handle the silent push notification and perform necessary tasks in the background
            NSLog("#Mirrorfly Appdelegate didReceiveRemoteNotification \(notification)")
            // Call the completion handler when finished processing the notification
            completionHandler(.newData)
    }


}



