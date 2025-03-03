// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:googleapis_auth/auth_io.dart';
// import 'package:googleapis_auth/googleapis_auth.dart' as auth;
// import 'package:http/http.dart' as http;
// import 'package:googleapis/calendar/v3.dart' as calendar;
// import 'package:http/http.dart';
// import 'package:mirrorfly_plugin/mirrorfly.dart';
//
// // Future<auth.AuthClient?> signInWithGoogle() async {
// //   final GoogleSignIn googleSignIn = GoogleSignIn(
// //     scopes: ['https://www.googleapis.com/auth/calendar.events'],
// //   );
// //
// //   final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
// //   if (googleUser == null) return null;
// //
// //   final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
// //
// //   final auth.AccessCredentials credentials = auth.AccessCredentials(
// //     auth.AccessToken(
// //       'Bearer',
// //       googleAuth.accessToken!,
// //       DateTime.now().add(Duration(seconds: 3600)), // 1-hour expiry
// //     ),
// //     googleAuth.idToken,
// //     ['https://www.googleapis.com/auth/calendar.events'],
// //   );
// //
// //   return auth.authenticatedClient(http.Client(), credentials);
// // }
// final GoogleSignIn googleSignIn = GoogleSignIn(
//   scopes: ['https://www.googleapis.com/auth/drive.file'],
// );
//
// GoogleSignInAccount? get getGoogleAccountSignedIn => googleSignIn.currentUser;
// Future<auth.AuthClient?> assignAccountAuth(GoogleSignInAccount account) async {
//   // Get authentication credentials
//   final GoogleSignInAuthentication auth = await account.authentication;
//   LogMessage.d("BackupRestoreManager", "GoogleSignInAuthentication $auth");
//   // Create authenticated HTTP client
//   final authClient = authenticatedClient(
//     Client(),
//     AccessCredentials(
//       AccessToken('Bearer', auth.accessToken!, DateTime.now().toUtc()),
//       null, // No refresh token needed for a single use
//       ['https://www.googleapis.com/auth/drive.file'],
//     ),
//   );
//   LogMessage.d("BackupRestoreManager", "authClient $authClient");
//
//   // Initialize Google Drive API
//   return authClient;
// }
// Future<void> addEventToGoogleCalendar() async {
//   final GoogleSignInAccount? account = getGoogleAccountSignedIn;
//   if (account != null) {
//     LogMessage.d("BackupRestoreManager", "Account $account");
//
//   }
//   final authClient = await assignAccountAuth(account!);
//   if (authClient == null) {
//     print("Google Sign-In failed");
//     return;
//   }
//
//   final calendarApi = calendar.CalendarApi(authClient);
//
//   final event = calendar.Event()
//     ..summary = "Flutter Meeting"
//     ..description = "This is a test event from Flutter."
//     ..start = (calendar.EventDateTime()
//       ..dateTime = DateTime.now().add(Duration(days: 1))
//       ..timeZone = "GMT")
//     ..end = (calendar.EventDateTime()
//       ..dateTime = DateTime.now().add(Duration(days: 1, hours: 1))
//       ..timeZone = "GMT")
//     ..conferenceData = (calendar.ConferenceData()
//       ..createRequest = (calendar.CreateConferenceRequest()
//         ..requestId = DateTime.now().millisecondsSinceEpoch.toString()));
//
//   final createdEvent = await calendarApi.events.insert(event, "primary",
//       conferenceDataVersion: 1);
//
//   print("Event created: ${createdEvent.htmlLink}");
// }

import 'package:device_calendar/device_calendar.dart';
import 'package:device_calendar/device_calendar.dart'as tz;
import 'package:permission_handler/permission_handler.dart';

final DeviceCalendarPlugin _deviceCalendarPlugin = DeviceCalendarPlugin();
Future<bool> requestCalendarPermission() async {
  var status = await Permission.calendarFullAccess.request();
  return status.isGranted;
}
Future<void> getCalendars() async {
  final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();

  if (calendarsResult.isSuccess && calendarsResult.data != null) {
    for (var calendar in calendarsResult.data!) {
      print("Calendar Name: ${calendar.name}, ID: ${calendar.id}");
    }
  } else {
    print("No calendars found");
  }
}

tz.TZDateTime toTZDateTime(DateTime dateTime) {
  return tz.TZDateTime.from(dateTime, tz.local);
}
Future<void> addEvent() async {
  if (!await requestCalendarPermission()) {
    print("Calendar permission denied");
    return;
  }

  final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();

  if (calendarsResult.isSuccess && calendarsResult.data!.isNotEmpty) {
    // Find the writable calendar (ignore holidays)
    final calendar = calendarsResult.data!.firstWhere(
          (c) {
            print("name:${c.name} and is readOnly ${c.isReadOnly}");
            return !(c.isReadOnly ?? false) && (c.name != "Holidays in India");},
      orElse: () => calendarsResult.data!.first, // Fallback to any available
    );

    if (calendar == null) {
      print("No writable calendars found");
      return;
    }

    final event = Event(
      calendar.id,
      title: "Team one",
      description: "Join the meeting at: https://meet.example.com/xyz123",
      location: "Online - Click the link",
      start: toTZDateTime(DateTime.now().add(Duration(hours: 1))),
      end: toTZDateTime(DateTime.now().add(Duration(hours: 2))),
      reminders: [Reminder(minutes: 10)],
    );

    // final result = await _deviceCalendarPlugin.createOrUpdateEvent(event);
  //   if (result!.isSuccess) {
  //     print("Event added successfully to ${calendar.name}!");
  //   } else {
  //     print("Failed to add event");
  //   }
  // } else {
  //   print("No calendars found");
  }
}

Future<void> debugCalendarFetch() async {
  final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();

  if (calendarsResult.isSuccess && calendarsResult.data!.isNotEmpty) {
    for (var calendar in calendarsResult.data!) {
      print("Calendar Found: ${calendar.name} (ID: ${calendar.id})");
    }
  } else {
    print("No calendars found on this device.");
  }}