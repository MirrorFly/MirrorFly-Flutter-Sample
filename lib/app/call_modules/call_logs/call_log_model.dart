import 'dart:convert';
import 'dart:io';

CallLogModel callLogListFromJson(String str) => CallLogModel.fromJson(json.decode(str));

String callLogListToJson(CallLogModel data) => json.encode(data.toJson());

class CallLogModel {
  List<CallLogData>? data;

  CallLogModel({this.data});

  CallLogModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <CallLogData>[];
      json['data'].forEach((v) {
        data!.add(new CallLogData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CallLogData {
  String? callMode;
  int? callState;
  int? callTime;
  String? callType;
  String? callerDevice;
  int? endTime;
  String? fromUser;
  String? groupId;
  List<Null>? inviteUserList;
  bool? isCarbonAnswered;
  bool? isDeleted;
  bool? isDisplay;
  bool? isSync;
  String? roomId;
  int? rowId;
  String? sessionStatus;
  int? startTime;
  String? toUser;
  List<String>? userList;

  CallLogData(
      {this.callMode,
        this.callState,
        this.callTime,
        this.callType,
        this.callerDevice,
        this.endTime,
        this.fromUser,
        this.groupId,
        this.inviteUserList,
        this.isCarbonAnswered,
        this.isDeleted,
        this.isDisplay,
        this.isSync,
        this.roomId,
        this.rowId,
        this.sessionStatus,
        this.startTime,
        this.toUser,
        this.userList});

  CallLogData.fromJson(Map<String, dynamic> json) {
    callMode = json['callMode'];
    callState = json['callState'];
    callTime = json['callTime'];
    callType = json['callType'];
    callerDevice = json['callerDevice'];
    endTime = json['endTime'];
    fromUser = json['fromUser'];
    groupId = json['groupId'];
    isCarbonAnswered = json['isCarbonAnswered'];
    isDeleted = json['isDeleted'];
    isDisplay = json['isDisplay'];
    isSync = json['isSync'];
    roomId = json['roomId'];
    rowId = json['rowId'];
    sessionStatus = json['sessionStatus'];
    startTime = json['startTime'];
    toUser = json['toUser'];
    userList = json['userList'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['callMode'] = this.callMode;
    data['callState'] = this.callState;
    data['callTime'] = this.callTime;
    data['callType'] = this.callType;
    data['callerDevice'] = this.callerDevice;
    data['endTime'] = this.endTime;
    data['fromUser'] = this.fromUser;
    data['groupId'] = this.groupId;
    data['isCarbonAnswered'] = this.isCarbonAnswered;
    data['isDeleted'] = this.isDeleted;
    data['isDisplay'] = this.isDisplay;
    data['isSync'] = this.isSync;
    data['roomId'] = this.roomId;
    data['rowId'] = this.rowId;
    data['sessionStatus'] = this.sessionStatus;
    data['startTime'] = this.startTime;
    data['toUser'] = this.toUser;
    data['userList'] = this.userList;
    return data;
  }
}
