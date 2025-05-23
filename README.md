# [MirrorFly](https://mirrorfly.com) Chat App Sample for Flutter

If you're looking for the fastest way in action with CONTUS TECH [MirrorFly Plugin](https://pub.dev/packages/mirrorfly_plugin), then you need to build your app on top of our sample version. Simply download the sample app and commence your app development.

## Configuration

Replace the `licence key`  with yours in `main.dart` file. to run before.

```dart
  Mirrorfly.initializeSDK(
    licenseKey: 'Your_License_Key_Here',
    iOSContainerID: 'group.com.mirrorfly.flutter', //Container ID should be same as App Groups 
    chatHistoryEnable: true,
    flyCallback: (response) async {
        
    }
);
```
## Google Services

If you are going to check Location sharing feature,

# Android
Specify your API key in the application manifest android/app/src/main/AndroidManifest.xml:
```dart
    <meta-data android:name="com.google.android.geo.API_KEY"
    android:value="YOUR GOOGLE KEY HERE"/>

    <meta-data android:name="com.google.android.geo.API_THUMP_KEY"
    android:value="YOUR GOOGLE KEY HERE"/>
```

# iOS
Specify your API key in the AppDelegate.swift and info.plist

```dart
  GMSServices.provideAPIKey("YOUR GOOGLE KEY HERE")
```
```dart
  <key>API_THUMP_KEY</key>
  <string>YOUR GOOGLE KEY HERE</string>
```

## Run project
- flutter pub get
- flutter run

## Getting Help

Check out the Official MirrorFly [Flutter docs](https://www.mirrorfly.com/docs/chat/flutter-plugin/v1/quick-start/) and MirrorFly [Developer Portal](https://www.mirrorfly.com/docs/) for tutorials and videos. If you need any help in resolving any issues or have questions, Drop a mail to (integration@contus.in).
