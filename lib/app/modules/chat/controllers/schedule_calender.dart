import 'package:device_calendar/device_calendar.dart';
import 'package:device_calendar/device_calendar.dart' as tz;
import 'package:flutter/material.dart';
import 'package:mirror_fly_demo/app/common/app_localizations.dart';
import 'package:mirror_fly_demo/app/data/session_management.dart';
import 'package:mirrorfly_plugin/internal_models/chat_messages_model.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../data/utils.dart';

class ScheduleCalender {
  final DeviceCalendarPlugin _deviceCalendarPlugin = DeviceCalendarPlugin();
  Future<bool> requestCalendarPermission() async {
    var status = await Permission.calendarFullAccess.status;
    if (status.isGranted) {
      return true;
    } else if (status.isDenied) {
      var newStatus = await Permission.calendarFullAccess.request();
      return newStatus.isGranted;
    }
    return false;
  }

  tz.TZDateTime toTZDateTime(DateTime dateTime) {
    return tz.TZDateTime.from(dateTime, tz.local);
  }

  Future<void> selectCalendarId() async {
    bool isGranted = await Permission.calendarFullAccess.isGranted;
    if (!isGranted) return;
    final calendarId = await SessionManagement.getCalenderId("calendarId");
    if (calendarId?.isNotEmpty ?? false) return;
    final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
    if (!(calendarsResult.isSuccess && calendarsResult.data?.isNotEmpty == true)) return;
    List<Calendar> writableCalendars = calendarsResult.data!
        .where((c) => !(c.isReadOnly ?? false) && c.name != "Holidays in India")
        .toList();
    if (writableCalendars.isEmpty) {
      debugPrint("No writable calendars found");
      return;
    }
    debugPrint("calendarsResult $calendarsResult");
    if(writableCalendars.length == 1){
      await SessionManagement.setCalenderId(writableCalendars[0].id??"");
      await SessionManagement.setCalenderName(writableCalendars[0].name??"");
      return ;
    }
    if(NavUtils.currentContext.mounted) {
      Calendar? calendar = (await showDialog(
        context: NavUtils.currentContext,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(getTranslated("selectCalender")),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: writableCalendars.length,
                itemBuilder: (context, index) {
                  final calendar = writableCalendars[index];
                  String calendarName = calendar.name ?? "Unnamed";
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue,
                      // Choose a color based on preference
                      child: Text(
                        calendarName[0].toUpperCase(),
                        // First letter of calendar name
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(calendarName),
                    onTap: () => Navigator.pop(context, calendar),
                  );
                },
              ),
            ),
          );
        },
      )) as Calendar?;
      if (calendar != null) {
        await SessionManagement.setCalenderId(calendar.id ?? "");
        await SessionManagement.setCalenderName(calendar.name ?? "");
      }
    }
  }

  Future<void> addEvent(MeetChatMessage meetMessage) async {
    String calenderId = await SessionManagement.getCalenderId("calenderId");
    bool exists = await isEventAlreadyAdded(meetMessage);
    if(exists) return;
    final startTime = DateTime.fromMillisecondsSinceEpoch(meetMessage.scheduledDateTime);
    final event = Event(
      calenderId,
      eventId: meetMessage.messageId,
      title: meetMessage.title.isEmpty ? "" : meetMessage.title,
      description: meetMessage.link,
      // location: "Online - Click the link",
      start: toTZDateTime(startTime),
      end: toTZDateTime(startTime.add(const Duration(hours: 1))),
      reminders: [Reminder(minutes: 10)],
    );
    final result = await _deviceCalendarPlugin.createOrUpdateEvent(event);
    if (result!.isSuccess) {
      debugPrint("Event added successfully to calendar!");
    } else {
      debugPrint("Failed to add event");
    }
  }

  Future<bool> isEventAlreadyAdded(MeetChatMessage meetMessage) async {
    String? calendarId = await SessionManagement.getCalenderId("calenderId");
    if (calendarId == null) {
      debugPrint("No valid calendar ID found.");
      return false;
    }
    final startTime = DateTime.fromMillisecondsSinceEpoch(meetMessage.scheduledDateTime);
    final endTime = startTime.add(const Duration(hours: 1));
    final result = await _deviceCalendarPlugin.retrieveEvents(
      calendarId,
      RetrieveEventsParams(startDate: startTime.subtract(const Duration(minutes: 1)), endDate: endTime.add(const Duration(minutes: 1))),
    );
    if (!(result.isSuccess && result.data != null)) {
      debugPrint("Failed to retrieve events.");
      return false;
    }
    for (Event event in result.data!) {
      if (event.description == meetMessage.link && event.start == toTZDateTime(startTime)) {
        debugPrint("Event already exists: ${event.title}");
        return true;
      }
    }
    return false;
  }
}
