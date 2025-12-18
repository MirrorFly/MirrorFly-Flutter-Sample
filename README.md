<p align="center">
  <img  src="https://dasa7d6hxd0bp.cloudfront.net/images/mirrorfly.webp" data-canonical-src="https://dasa7d6hxd0bp.cloudfront.net/images/mirrorfly.webp" width="400"  alt=""/>
</p>

# **MirrorFly Flutter SDK For Video Chat & Calls**
![Static Badge](https://img.shields.io/badge/Flutter%20Video%20SDK-blue?link=https%3A%2F%2Fwww.mirrorfly.com%2Fflutter-chat-sdk.php) ![Static Badge](https://img.shields.io/badge/Docs-grey?link=https%3A%2F%2Fwww.mirrorfly.com%2Fdocs%2Faudio-video%2Fflutter%2Fv1%2Fquick-start%2F)



MirrorFly Flutter Plugin is a custom real-time communication solution that adds 1000+ features including video, voice, chat, live streaming and activity feeds into any app. The solution is fully customizable and comprises over 500+ AI-powered features like  AI voice agents, chatbots, speech-to-text API, AI contact centers and AI video KYC.

This custom plug-and-play solution helps build a white-label Flutter app in just 10 mins with full data control. Choose self-hosting, on-premise server or cloud deployment to host and maintain your Flutter app anywhere you prefer. 

# **🤹 Key Product Offerings** 

MirrorFly helps build omni-channel communication apps for any kind of business

**💬 [In-app Messaging](https://www.mirrorfly.com/chat-api-solution.php)** \- Connect users individually or as groups via instant messaging features.  
**🎯 [HD Video Calling](https://www.mirrorfly.com/video-call-solution.php)**\- Engage users over face-to-face conversations anytime, and from anywhere.   
**🦾 [HQ Voice Calling](https://www.mirrorfly.com/voice-call-solution.php)** \- Deliver crystal clear audio calling experiences with latency as low as 3ms.   
🤖 [**AI Voice Agent**](https://www.mirrorfly.com/conversational-ai/voice-agent/) \- Build custom  AI voicebots that can understand, act and respond to user questions.   
**🤖 [AI Chatbot](https://www.mirrorfly.com/conversational-ai/chatbot/)** \- Deploy white-label AI chatbots that drive autonomous conversations across any web or mobile app.  
**🦾 [Live Streaming](https://www.mirrorfly.com/live-streaming-sdk.php)** \- Broadcast video content to millions of viewers around the world, within your own enterprise app. 

### **⚒️MirrorFly Flutter Chat & Video Calls Plugin** 

### [**Requirements**](https://www.mirrorfly.com/docs/chat/flutter-plugin/v1/quick-start#requirements)

The requirements for Android

* Android Lollipop 5.0 (API Level 21\) or above  
* Java 8 or higher  
* Gradle 4.1.0 or higher  
* targetSdkVersion 34 or above  
* compileSdk 34

The minimum requirements for iOS

* iOS 13.0

### [**Get MirrorFly License Key**](https://www.mirrorfly.com/docs/chat/flutter-plugin/v1/quick-start#mirrorfly-license-key)

To obtain your license key, follow these steps:

* **Sign up** for a free MirrorFly account at [MirrorFly Console](https://console.mirrorfly.com/register). If you already have an account, simply sign in.  
* **Access your account:** Navigate to the Overview page in your MirrorFly account to view your license key.  
* **Copy the license key** from the Application Info section for use in the integration process.

<img  src="https://www.mirrorfly.com/docs/assets/images/license-key-a1173e922ebff14b6ae1a2428f822eec.png" data-canonical-src="https://www.mirrorfly.com/docs/assets/images/license-key-a1173e922ebff14b6ae1a2428f822eec.png" width="100%"  alt=""/>

### [**Create Android Dependency**](https://www.mirrorfly.com/docs/chat/flutter-plugin/v1/quick-start#create-android-dependency)

Add the following to your root build.gradle file in your Android folder.

```txt
allprojects {
  repositories {
    ...
    ...
    jcenter()
    maven {
      url "https://repo.mirrorfly.com/release"
    }
  }
}

android {
  compileSdk 34
  ...
  defaultConfig {
    ...
    minSdkVersion 21
    targetSdkVersion 34 // or higher
  }
}
```

### [**Create iOS dependency**](https://www.mirrorfly.com/docs/chat/flutter-plugin/v1/quick-start#create-ios-dependency)

Check and Add the following code at end of your ios/Podfile

```txt
post_install do |installer|
  installer.aggregate_targets.each do |target|
    target.xcconfigs.each do |variant, xcconfig|
      xcconfig_path = target.client_root + target.xcconfig_relative_path(variant)
      IO.write(
        xcconfig_path,
        IO.read(xcconfig_path).gsub("DT_TOOLCHAIN_DIR", "TOOLCHAIN_DIR")
      )
    end
  end

  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET']        = '12.1'
      config.build_settings['ENABLE_BITCODE']                     = 'NO'
      config.build_settings['APPLICATION_EXTENSION_API_ONLY']     = 'No'
      config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION']     = 'YES'
      config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = 'arm64'

      shell_script_path = "Pods/Target Support Files/#{target.name}/#{target.name}-frameworks.sh"

      if File::exist?(shell_script_path)
        shell_script_input_lines  = File.readlines(shell_script_path)
        shell_script_output_lines = shell_script_input_lines.map { |line|
          line.sub(
            "source=\"$(readlink \"${source}\")\"",
            "source=\"$(readlink -f \"${source}\")\""
          )
        }

        File.open(shell_script_path, 'w') do |f|
          shell_script_output_lines.each do |line|
            f.write line
          end
        end
      end
    end
  end
end
```

Now, enable all the below mentioned capabilities into your project.

<img  src="https://www.mirrorfly.com/assets/images/tutorials/build-chat-app-using-flutter/app-group.webp" data-canonical-src="https://www.mirrorfly.com/assets/images/tutorials/build-chat-app-using-flutter/app-group.webp" width="100%"  alt=""/>


```txt
Goto Project -> Target -> Signing & Capabilities -> Click + at the top left corner -> Search for the capabilities below
```


## [Create Flutter dependency](https://www.mirrorfly.com/docs/chat/flutter-plugin/v1/quick-start#create-flutter-dependency)

Add the below dependencies in pubspec.yaml.

```txt
dependencies:
  mirrorfly_plugin: ^1.5.0
```

Run the flutter pub get command in your project directory. You can then access all classes and methods using the following import statement.

```txt
import 'package:mirrorfly_plugin/mirrorfly.dart';
```

## [Initialize MirrorFly Plugin](https://www.mirrorfly.com/docs/chat/flutter-plugin/v1/quick-start#initialize-mirrorfly-plugin)

To initialize the plugin, add the following code in your **main.dart** file inside the main function before calling **runApp()**.

```txt
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Mirrorfly.initializeSDK(
    licenseKey: LICENSE_KEY,
    iOSContainerID: iOS_APP_GROUP_ID,
    chatHistoryEnable: ENABLE_CHAT_HISTORY,
    enableDebugLog: ENABLE_DEBUG_LOG, // to enable logs for debug
    flyCallback: (FlyResponse response) {
      runApp(const MyApp());
    },
  );
}
```

#### [**Chat init Function Description**](https://www.mirrorfly.com/docs/chat/flutter-plugin/v1/quick-start#chat-init-function-description)

**Note:** The **Chat History** feature lets you retrieve conversation history whenever you log in on a new device. Chat history is stored securely, ensuring users can access the same conversation threads across devices without any data loss.

## [Login](https://www.mirrorfly.com/docs/chat/flutter-plugin/v1/quick-start#login)

Use the following method to log in a user in sandbox Live mode.

**Important:** Do not call the login method more than once in an application unless you have logged out the current session.

**Note:** During registration, this login method can optionally accept the FCM_TOKEN parameter. The connection will be established automatically upon registration completion, so a separate login is not required.

```txt
Mirrorfly.login(
  userIdentifier: userIdentifier,
  fcmToken: token,
  isForceRegister: isForceRegister,
  identifierMetaData: identifierMetaData,
  flyCallback: (FlyResponse response) {
    if (response.isSuccess && response.hasData) {
      // you will get the user registration response
      var userData = registerModelFromJson(value);
    }
  },
);
```

## [Send a One-to-One Message](https://www.mirrorfly.com/docs/chat/flutter-plugin/v1/quick-start#send-a-one-to-one-message)

Use the below method to send a text message to other user,

```txt
var textMessage = MessageParams.text(
  toJid: toJid,
  replyMessageId: replyMessageId, // Optional
  topicId: topicId,               // Optional
  textMessageParams: TextMessageParams(
    messageText: messageText,
  ),
);

Mirrorfly.sendMessage(
  messageParams: textMessage,
  flyCallback: (response) {
    if (response.isSuccess) {
      // message sent
    }
  },
);
```

## [Receive a One-to-One Message](https://www.mirrorfly.com/docs/chat/flutter-plugin/v1/quick-start#receive-a-one-to-one-message)

These listeners are triggered only when a new message is received from another user. For more details, refer to the [callback listeners](https://www.mirrorfly.com/docs/chat/flutter-plugin/v1/callback-listeners/#observing-the-message-events) documentation.

```txt
Mirrorfly.onMessageReceived.listen((result) {
  // you will get the new messages
  var chatMessage = sendMessageModelFromJson(result);
});
```

# **Voice & Video Call Integration**

## [Make a call](https://www.mirrorfly.com/docs/audio-video/flutter/v1/making-a-call/#make-a-call)

The Call feature is essential for modern communication. The Call SDK enables users to make one-to-one audio or video calls with another SDK user.

**Note:** Ensure all required permissions are granted before using the call feature.

## [**Required permissions**](https://www.mirrorfly.com/docs/audio-video/flutter/v1/making-a-call/#required-permissions)

For audio call, the below permissions:

```txt
Microphone Permission
```

For video call, we need below permissions:

```txt
Microphone Permission
Camera Permission
```

### [**Make a Voice Call**](https://www.mirrorfly.com/docs/audio-video/flutter/v1/making-a-call/#make-a-voice-call)

To make a one to one voice call, call the below method.

```txt
Mirrorfly.makeVoiceCall(
  toUserJid: USER_JID,
  flyCallBack: (FlyResponse response) {
    if (response.isSuccess) {
      // voice call initiated
    }
  },
);
```

### [**Make a video call**](https://www.mirrorfly.com/docs/audio-video/flutter/v1/making-a-call/#make-a-video-call)

The Video Call feature allows users to make a one-to-one video call with another SDK user. Use the following method to initiate a video call.

```txt
Mirrorfly.makeVideoCall(
  toUserJid: USER_JID,
  flyCallBack: (FlyResponse response) {
    if (response.isSuccess) {
      // video call initiated
    }
  },
);
```

### [**Make a group voice call**](https://www.mirrorfly.com/docs/audio-video/flutter/v1/making-a-call/#make-a-group-voice-call)

Make group voice call feature allows users to make a voice call with multiple users. You can make a group voice call using the below method.

```txt
Mirrorfly.makeGroupVoiceCall(
  groupJid: GROUP_JID,
  toUserJidList: USER_LIST,
  flyCallBack: (FlyResponse response) {
    if (response.isSuccess) {
      // group voice call initiated
    }
  },
);
```

### [**Make a group video call**](https://www.mirrorfly.com/docs/audio-video/flutter/v1/making-a-call/#make-a-group-video-call)

The Group Video Call feature allows users to initiate a video call with multiple participants. You can start a group video call using the following method.

```txt
Mirrorfly.makeGroupVideoCall(
  groupJid: GROUP_JID,
  toUserJidList: USER_LIST,
  flyCallBack: (FlyResponse response) {
    if (response.isSuccess) {
      // group video call initiated
    }
  },
);
```

### [**Add participants to the call**](https://www.mirrorfly.com/docs/audio-video/flutter/v1/making-a-call/#add-participants-to-the-call)

After a call is connected, you can add more users to the ongoing session. Use the following methods to invite users; once they accept the incoming call, they will join the ongoing call.

```txt
Mirrorfly.inviteUsersToOngoingCall(
  jidList: USER_LIST,
  flyCallback: (FlyResponse response) {
    if (response.isSuccess) {
      // users invited to ongoing call
    }
  },
);
```

### [**Receiving an incoming audio/video call**](https://www.mirrorfly.com/docs/audio-video/flutter/v1/making-a-call/#receiving-a-incoming-audiovideo-call)

When you receive an audio or video call from another SDK user, the SDK reports the call, and the plugin displays an Incoming Call Notification.

### [**Answer the incoming call**](https://www.mirrorfly.com/docs/audio-video/flutter/v1/making-a-call/#answer-the-incoming-call)

When a call is presented with Accept and Reject buttons, you can either accept or reject it. If you accept the call, the onCallStatusUpdated event listener is triggered, and the call status will be set to Attended.

```txt
Mirrorfly.onCallStatusUpdated.listen((event) {
  var statusUpdateReceived = jsonDecode(event);
  var callMode   = statusUpdateReceived["callMode"].toString();
  var userJid    = statusUpdateReceived["userJid"].toString();
  var callType   = statusUpdateReceived["callType"].toString();
  var callStatus = statusUpdateReceived["callStatus"].toString();
});
```

### [**Disconnect the ongoing call**](https://www.mirrorfly.com/docs/audio-video/flutter/v1/making-a-call/#disconnect-the-ongoing-call)

When making an audio or video call to another SDK user, you may need to disconnect the call either before the connection is established or after the conversation ends. Whenever the user presses the disconnect button in your call UI, call the following SDK method to disconnect the call and notify the other party.

```txt
Mirrorfly.disconnectCall(
  flyCallBack: (FlyResponse response) {
    if (response.isSuccess) {
      // call disconnected
    }
  },
);
```

# **☁️ Deployment Models \- Self-hosted and Cloud**

MirrorFly offers full freedom with the hosting options:  
**Self-hosted:** Deploy your client on your own data centers, private cloud or third-party servers.  
[Check out our multi-tenant cloud hosting](https://www.mirrorfly.com/self-hosted-chat-solution.php)  
**Cloud:** Host your client on MirrorFly’s multi-tenant cloud servers.   
[Check out our multi-tenant cloud hosting](https://www.mirrorfly.com/multi-tenant-chat-for-saas.php)

# **📱 Mobile Client**

MirrorFly offers a fully-built client SafeTalk that is available in:
- iOS
- Android
  
You can use this client as a messaging app, or customize, rebrand & white-label it as your chat client. 

# **📚 Learn More**

* [Developer Documentation](https://www.mirrorfly.com/docs/)  
* [Product Tutorials](https://www.mirrorfly.com/tutorials/)  
* [MirrorFly Flutter Solution](https://www.mirrorfly.com/flutter-chat-sdk.php)  
* [Dart Documentation](https://pub.dev/packages/mirrorfly_plugin)  
* [Pubdev Documentation](https://pub.dev/packages/mirrorfly_plugin)  
* [Npmjs Documentation](https://www.npmjs.com/~contus)  
* [On-premise Deployment](https://www.mirrorfly.com/on-premises-chat-server.php)   
* [See who's using MirrorFly](https://www.mirrorfly.com/chat-use-cases.php)

# **🧑‍💻 Hire Experts**

Need a tech team to build your enterprise app? [Hire a full team of experts](https://www.mirrorfly.com/hire-video-chat-developer.php). From concept to launch, we handle every step of the development process. Get a high-quality, fully-built app ready to launch, carefully built by industry experts

# **⏱️ Round-the-clock Support**

If you’d like to take help when working with our solution, feel free to [contact our experts](https://www.mirrorfly.com/contact-sales.php) who will be available to help you anytime of the day or night. 

## **💼 Become a Part of our amazing team**

We're always on the lookout for talented developers, support specialists, and product managers. Visit our [careers page](https://www.contus.com/careers.php) to explore current opportunities.

## **🗞️ Get the Latest Updates**

* [Blog](https://www.mirrorfly.com/blog/)  
* [Facebook](https://www.facebook.com/MirrorFlyofficial/)  
* [Twitter](https://twitter.com/mirrorflyteam)  
* [LinkedIn](https://www.linkedin.com/showcase/mirrorfly-official/)  
* [Youtube](https://www.youtube.com/@mirrorflyofficial)  
* [Instagram](https://www.instagram.com/mirrorflyofficial/)
