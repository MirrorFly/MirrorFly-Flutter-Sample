# [MirrorFly](https://mirrorfly.com) Chat App Sample for Flutter

If you're looking for the fastest way in action with CONTUS TECH [MirrorFly Plugin](https://pub.dev/packages/mirrorfly_plugin), then you need to build your app on top of our sample version. Simply download the sample app and commence your app development.

## Configuration

Replace the `licence key` , `ios Container ID` with yours in `main.dart` file.

```dart
  Mirrorfly.init(
      baseUrl: 'https://api-preprod-sandbox.mirrorfly.com/api/v1/',
      licenseKey: 'Please enter your License key',
      iOSContainerID: 'Please enter your Container ID') //Container ID should be same as App Groups 
```
## Google Services

If you are going to check Location sharing feature,

# Android
Specify your API key in the application manifest android/app/src/main/AndroidManifest.xml:
```dart
    <meta-data android:name="com.google.android.geo.API_KEY"
    android:value="YOUR GOOGLE KEY HERE"/>
```
Specify your API key in the application Constant dart file lib/app/common/constants.dart
```dart
  static const String googleMapKey = "YOUR GOOGLE KEY HERE";
```
# iOS
Specify your API key in the AppDelegate.swift

```dart
  GMSServices.provideAPIKey("YOUR GOOGLE KEY HERE")
```

## Run project
- flutter pub get
- flutter run

## Getting Help

Check out the Official MirrorFly [Flutter docs](https://www.mirrorfly.com/docs/chat/flutter_plugin/quick-start/) and MirrorFly [Developer Portal](https://www.mirrorfly.com/docs/) for tutorials and videos. If you need any help in resolving any issues or have questions, Drop a mail to (integration@contus.in).



