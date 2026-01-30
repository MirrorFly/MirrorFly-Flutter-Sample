import UIKit
import PushKit
import Flutter
import GoogleMaps
import UserNotifications
import FirebaseAuth
import Firebase
import MirrorFlySDK
import mirrorfly_plugin
import mirrorfly_flutter_call_kit

import CallKit
import QuickLook


#if DEBUG
    let ISEXPORT = false
#else
    let ISEXPORT = true
#endif

@main
@objc class AppDelegate: FlutterAppDelegate {
    
    let googleApiKey = "AIzaSyDnjPEs86MRsnFfW1sVPKvMWjqQRnSa7Ts"
   
    var postNotificationdidEnterBackground : NotificationCenter? = nil
    
    let XMPP_DOMAIN = "xmpp-uikit-qa.contus.us"
    
    let tag = "#Mirrorfly call"
    
    /*private lazy var sharedEngine: FlutterEngine = {
        if let reused = MirrorFlyHeadlessBridge.sharedEngine() {
            NSLog("[MirrorFly] Engine: Re-Using shared engine")
            return reused
        }
        NSLog("[MirrorFly] Engine: Creating new shared engine")
        let engine = FlutterEngine(name: "mirrorfly_main")
        engine.run()
        GeneratedPluginRegistrant.register(with: engine)
        return engine
    }()*/

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      
              /*let controller = FlutterViewController(engine: sharedEngine, nibName: nil, bundle: nil)
              window = UIWindow(frame: UIScreen.main.bounds)
              window?.rootViewController = controller
              window?.makeKeyAndVisible()*/
      let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
      
      let channel = FlutterMethodChannel(name: "app.preview",
                                             binaryMessenger: controller.binaryMessenger)
          channel.setMethodCallHandler { call, result in
            guard call.method == "dismissPreview" else { result(FlutterMethodNotImplemented); return }
            guard let root = self.window?.rootViewController else { result(false); return }
            if let ql = root.presentedViewController as? QLPreviewController {
              ql.dismiss(animated: true) { result(true) }; return
            }
            if let nav = root.presentedViewController as? UINavigationController,
               nav.topViewController is QLPreviewController {
              nav.dismiss(animated: true) { result(true) }; return
            }
            result(false)
          }
           
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



