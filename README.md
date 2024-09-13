<center><p>
  <img  src="https://dasa7d6hxd0bp.cloudfront.net/images/mirrorfly.webp" data-canonical-src="https://dasa7d6hxd0bp.cloudfront.net/images/mirrorfly.webp" width="400"  alt=""/>
</p></center>

<h1 style="text-align: center">
  Customizable, Low-code Flutter Sample App For Android
</h1>


<b>MirrorFly’s Flutter Sample App</b> is a basic product with all the assets and libraries needed to develop a communication platform. All you need to do is, use the [MirrorFly Plugin](https://www.mirrorfly.com/) to add 1000+ real-time communication capabilities and deliver a fully-built communication platform in Flutter.


The platform is fully customizable, enabling you to personalize it to your customer experience. You can add your company logo, color and other brand elements to your Flutter chat app without any limitations. You will have access to the full source code giving you the full freedom to amend any part of the solution to meet your business needs.



# ⚒️ Key Product Offerings

MirrorFly’s Flutter Sample App & MirrorFly Flutter Chat Plugin allows you to add the following capabilities to your platform.


💬 [In-app Messaging](https://www.mirrorfly.com/chat-api-solution.php) - real-time chat features for private or group interactions

🎯 [HD Video Calling](https://www.mirrorfly.com/video-call-solution.php)- High-definition video calling for face to face conversations

🦾 [HQ Voice Calling](https://www.mirrorfly.com/voice-call-solution.php) - Crystal-clear audio calling for voice calling experiences

🦾 [Live Streaming](https://www.mirrorfly.com/live-streaming-sdk.php) - Broadcasting functionality to take content to millions of audience.

You can also add 1000+ real-time communication capabilities. Check out our other offerings [here](https://www.mirrorfly.com/chat-features.php).


# ☁️ Deployment Models - Self-hosted and Cloud

MirrorFly offers full freedom with the hosting options:
Self-hosted: Host your Flutter client app on your own data centers, private cloud servers or third-party servers.
[Check out our multi-tenant cloud hosting](https://www.mirrorfly.com/self-hosted-chat-solution.php)
Cloud: Deploy your Flutter client platform on MirrorFly’s multi-tenant cloud servers.
[Check out our multi-tenant cloud hosting](https://www.mirrorfly.com/multi-tenant-chat-for-saas.php)


# 📱 Mobile Client

MirrorFly offers a fully-built client <b>SafeTalk</b> that is available in:

<a href="https://play.google.com/store/apps/details?id=com.mirrorfly&hl=en"><img src="./GetItOnGooglePlay_Badge_Web_color_English.png" alt="image" width="140" height="auto"></a>  &nbsp;   [![appstore](./Download_on_the_App_Store_Badge_US-UK_RGB_blk_092917.svg)](https://apps.apple.com/app/safetalk/id1442769177)

You can use this client as a messaging app, or customize, rebrand & white-label it as your chat client.

# ⚙️ Configuration

Replace the license key with yours in the main.dart file. to run before.
```dart
Mirrorfly.initializeSDK(
    licenseKey: 'Your_License_Key_Here',
    iOSContainerID: 'group.com.mirrorfly.flutter', //Use your own Container ID, matching the App Group added in Xcode. 
    chatHistoryEnable: true,
    flyCallback: (response) async {
        
    }
);
```

<b>Android</b>

Specify your Google key in the application manifest android/app/src/main/AndroidManifest.xml:
```dart
<meta-data android:name="com.google.android.geo.API_KEY"
    android:value="YOUR GOOGLE KEY HERE"/>

<meta-data android:name="com.google.android.geo.API_THUMP_KEY"
    android:value="YOUR GOOGLE KEY HERE"/>
```

<b>iOS</b>

Specify your API key in the AppDelegate.swift and info.plist
```dart
In AppDelegate file, inside the didFinishLaunchingWithOptions function add the below line
GMSServices.provideAPIKey("YOUR GOOGLE KEY HERE")


In Info.plist, add the below key


 <key>API_THUMP_KEY</key>
  <string>YOUR GOOGLE KEY HERE</string>

```

# ▶️ Run project

- flutter pub get
  To Run in iOS, make sure to POD install.

open terminal(from the project root folder) and type
- cd ios
- Add [pod hooks](https://www.mirrorfly.com/docs/chat/flutter-plugin/v1/quick-start/#create-ios-dependency) inside the pod file.
- pod install
- flutter run

# 🤝 Getting Help
If you need any further help with our Flutter Sample App, check out our resources

- [Flutter API](https://www.mirrorfly.com/flutter-chat-sdk.php)
- [Flutter Tutorial](https://www.mirrorfly.com/tutorials/build-chat-app-using-flutter.php)
- [Flutter docs](https://www.mirrorfly.com/docs/chat/flutter-plugin/v1/quick-start/)
- [Developer Portal](https://www.mirrorfly.com/docs/)

If you need any help in resolving any issues or have questions, Drop a mail to <b>integration@contus.in</b>


# 📚 Learn More

- [Developer Documentation](https://www.mirrorfly.com/docs/)
- [Product Tutorials](https://www.mirrorfly.com/tutorials/)
- [Dart Documentation](https://pub.dev/packages/mirrorfly_plugin)
- [Pubdev Documentation](https://pub.dev/packages/mirrorfly_plugin)
- [Npmjs Documentation](https://www.npmjs.com/~contus)
- [On-premise Deployment](https://www.mirrorfly.com/on-premises-chat-server.php)
- [See who's using MirrorFly](https://www.mirrorfly.com/chat-use-cases.php)


# 🧑‍💻 Hire Experts

Looking for a tech team to develop your enterprise app in Flutter? [Hire a team of seasoned](https://www.mirrorfly.com/hire-video-chat-developer.php) professionals who manage the entire process from concept to launch. We’ll deliver a high-quality app, expertly crafted and ready for launch.



# ⏱️ Round-the-clock Support

If you’d like to take help when working with our solution, feel free to [contact our experts](https://www.mirrorfly.com/contact-sales.php) who will be available to help you anytime of the day or night.


# 💼 Become a Part of our amazing team

We're always on the lookout for talented developers, support specialists, and product managers. Visit our [careers page](https://www.contus.com/careers.php) to explore current opportunities.


# 🗞️ Get the Latest Updates

- [Blog](https://www.mirrorfly.com/blog/)
- [Facebook](https://www.facebook.com/MirrorFlyofficial/)
- [Twitter](https://twitter.com/mirrorflyteam)
- [LinkedIn](https://www.linkedin.com/showcase/mirrorfly-official/)
- [Youtube](https://www.youtube.com/@mirrorflyofficial)
- [Instagram](https://www.instagram.com/mirrorflyofficial/)
