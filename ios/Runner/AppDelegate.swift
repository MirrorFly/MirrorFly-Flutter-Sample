import UIKit
import Flutter
import FlyCore


let BASE_URL = "https://api-uikit-qa.contus.us/api/v1/"
let LICENSE_KEY = "ckIjaccWBoMNvxdbql8LJ2dmKqT5bp"
let CONTAINER_ID = "group.com.mirror.flyflutter"

let MIRRORFLY_METHOD_CHANNEL = "contus.mirrorfly/sdkCall"

let IS_LIVE = false

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      
//      let groupConfig = try? GroupConfig.Builder.enableGroupCreation(groupCreation: true)
//          .onlyAdminCanAddOrRemoveMembers(adminOnly: true)
//          .setMaximumMembersInAGroup(membersCount: 200)
//          .build()
//      assert(groupConfig != nil)

      try? ChatSDK.Builder.setAppGroupContainerID(containerID: CONTAINER_ID)
          .setLicenseKey(key: LICENSE_KEY)
          .isTrialLicense(isTrial: !IS_LIVE)
          .setDomainBaseUrl(baseUrl: BASE_URL)
//          .setGroupConfiguration(groupConfig: groupConfig!)
          .buildAndInitialize()
      
      
      let controller : FlutterViewController = window?.rootViewController as! FlutterViewController

      let methodChannel = FlutterMethodChannel(name: MIRRORFLY_METHOD_CHANNEL, binaryMessenger: controller.binaryMessenger)
      
      FlyMethodChannel.prepareMethodHandler(methodChannel: methodChannel)
      
    
      GeneratedPluginRegistrant.register(with: self)
      
      return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

}
