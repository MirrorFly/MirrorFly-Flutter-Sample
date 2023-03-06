# [MirrorFly](https://mirrorfly.com) Chat App Sample for Flutter

If you're looking for the fastest way in action with CONTUS TECH [MirrorFly Plugin](https://pub.dev/packages/mirrorfly_plugin), then you need to build your app on top of our sample version. Simply download the sample app and commence your app development.

## Configuration

Replace the `licence key` with yours in `main.dart` file.

```dart
  Mirrorfly.init(
      baseUrl: 'https://api-preprod-sandbox.mirrorfly.com/api/v1/',
      licenseKey: 'Please enter your License key',
      iOSContainerID: 'group.com.mirrorfly.qa')
```

## Run project
- flutter pub get
- flutter run

## Getting Help

Check out the Official MirrorFly [Flutter docs](https://www.mirrorfly.com/docs/chat/flutter/quick-start/) and MirrorFly [Developer Portal](https://www.mirrorfly.com/docs/) for tutorials and videos. If you need any help in resolving any issues or have questions, Drop a mail to (integration@contus.in).

## Configuration

``
buildConfigField 'String', 'LICENSE', '"Please enter your License key"'
``
Replace the licence with yours in android app level build.gradle file


<br />
