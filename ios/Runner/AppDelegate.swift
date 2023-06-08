import UIKit
import Flutter
// import FlyCore
// import FlyCommon
 import GoogleMaps
// import UserNotifications
// import FirebaseAuth
// import Firebase


@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate{
    

    
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      
      GMSServices.provideAPIKey("YOUR GOOGLE KEY HERE")
      
      let _ : FlutterViewController = window?.rootViewController as! FlutterViewController

      
      
      GeneratedPluginRegistrant.register(with: self)
      
      return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

   
    
}



