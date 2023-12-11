import 'dart:convert';
import 'dart:io';

CallLogModel callLogListFromJson(String str) => CallLogModel.fromJson(json.decode(str));

String callLogListToJson(CallLogModel data) => json.encode(data.toJson());

CallLogData callLogDataListFromJson(String str) => CallLogData.fromJson(json.decode(str));

String callLogDataListToJson(CallLogData data) => json.encode(data.toJson());

class CallLogModel {
  List<CallLogData>? data;
  int? totalPages;

  CallLogModel({this.data});

  CallLogModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <CallLogData>[];
      json['data'].forEach((v) {
        data!.add( CallLogData.fromJson(v));
      });
    }
    totalPages = json['total_pages'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['total_pages'] = totalPages;
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
  String? nickName;

  CallLogData(
      {this.callMode,
        this.callState,
        this.callTime,
        this.callType,
        this.callerDevice,
        this.endTime,
        this.fromUser,
        this.groupId,
        this.isCarbonAnswered,
        this.isDeleted,
        this.isDisplay,
        this.isSync,
        this.roomId,
        this.rowId,
        this.sessionStatus,
        this.startTime,
        this.toUser,
        this.userList,this.nickName});

  CallLogData.fromJson(Map<String, dynamic> json) {
    callMode = json['callMode'];
    callState = Platform.isAndroid ? json['callState'] : getCallState(stateValue: json['callState']);
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
    nickName = json['nickName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['callMode'] = callMode;
    data['callState'] = callState;
    data['callTime'] = callTime;
    data['callType'] = callType;
    data['callerDevice'] = callerDevice;
    data['endTime'] = endTime;
    data['fromUser'] = fromUser;
    data['groupId'] = groupId;
    data['isCarbonAnswered'] = isCarbonAnswered;
    data['isDeleted'] = isDeleted;
    data['isDisplay'] = isDisplay;
    data['isSync'] = isSync;
    data['roomId'] = roomId;
    data['rowId'] = rowId;
    data['sessionStatus'] = sessionStatus;
    data['startTime'] = startTime;
    data['toUser'] = toUser;
    data['userList'] = userList;
    data['nickName'] = nickName;
    return data;
  }

  int getCallState({required String stateValue}) {
    switch(stateValue){
      case "MissedCall": return 2;
      case "OutgoingCall": return 1;
      case "IncomingCall": return 0;
      default: return 1;
    }
  }
}
