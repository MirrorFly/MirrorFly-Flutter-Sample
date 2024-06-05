import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/call_modules/call_info/controllers/call_info_controller.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirror_fly_demo/app/common/widgets.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';
import 'package:mirror_fly_demo/app/data/utils.dart';
import 'package:mirror_fly_demo/app/extensions/extensions.dart';
import 'package:mirrorfly_plugin/model/call_constants.dart';
import 'package:mirrorfly_plugin/model/call_log_model.dart';

import '../../../common/app_localizations.dart';
import '../../../modules/dashboard/widgets.dart';
import '../../call_utils.dart';

class CallInfoView extends NavView<CallInfoController> {
  const CallInfoView({super.key});

  @override
  CallInfoController createController() {
    return CallInfoController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          getTranslated("callInfo"),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
              onPressed: () {
                showPopupMenu(context, controller.callLogData);
              },
              icon: const Icon(Icons.more_vert))
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Obx(() => ListTile(
                      leading: controller.callLogData.groupId!.checkNull().isEmpty
                          ? ClipOval(
                              child: Image.asset(
                                groupImg,
                                height: 48,
                                width: 48,
                                fit: BoxFit.cover,
                              ),
                            )
                          : FutureBuilder(
                              future: getProfileDetails(controller.callLogData.groupId!),
                              builder: (context, snap) {
                                return snap.hasData && snap.data != null
                                    ? ImageNetwork(
                                        url: snap.data!.image!,
                                        width: 48,
                                        height: 48,
                                        clipOval: true,
                                        errorWidget: ClipOval(
                                          child: Image.asset(
                                            groupImg,
                                            height: 48,
                                            width: 48,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        isGroup: false,
                                        blocked: false,
                                        unknown: false,
                                      )
                                    : ClipOval(
                                        child: Image.asset(
                                          groupImg,
                                          height: 48,
                                          width: 48,
                                          fit: BoxFit.cover,
                                        ),
                                      );
                              }),
                      title: controller.callLogData.groupId!.checkNull().isEmpty
                          ? FutureBuilder(
                              future: CallUtils.getCallLogUserNames(controller.callLogData.userList!, controller.callLogData),
                              builder: (context, snap) {
                                if (snap.hasData) {
                                  return Text(
                                    snap.data!,
                                    style: const TextStyle(color: Colors.black),
                                  );
                                } else {
                                  return const SizedBox.shrink();
                                }
                              })
                          : FutureBuilder(
                              future: getProfileDetails(controller.callLogData.groupId!),
                              builder: (context, snap) {
                                if (snap.hasData) {
                                  return Text(
                                    snap.data!.name!,
                                    style: const TextStyle(color: Colors.black),
                                  );
                                } else {
                                  return const SizedBox.shrink();
                                }
                              }),
                      subtitle: SizedBox(
                        child: callLogTime(
                            "${DateTimeUtils.getCallLogDate(microSeconds: controller.callLogData.callTime!)}  ${getChatTime(context, controller.callLogData.callTime)}",
                            controller.callLogData.callState,null),
                      ),
                      trailing: SizedBox(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              getCallLogDuration(controller.callLogData.startTime!, controller.callLogData.endTime!),
                              style: const TextStyle(color: Colors.black),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            groupCallIcon(controller.callLogData.callType, controller.callLogData, controller.callLogData.callMode,
                                controller.callLogData.userList),
                          ],
                        ),
                      ),
                    )),
                const Divider(
                  color: Colors.grey,
                  height: 1,
                ),
                const SizedBox(
                  height: 8,
                ),
                ListView.builder(
                    physics: const ClampingScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: controller.callLogData.userList!.length,
                    itemBuilder: (context, index) {
                      var item = controller.callLogData.userList![index];
                      return ListTile(
                        leading: FutureBuilder(
                            future: getProfileDetails(item),
                            builder: (context, snap) {
                              return snap.hasData && snap.data != null
                                  ? ImageNetwork(
                                      url: snap.data!.image!,
                                      width: 48,
                                      height: 48,
                                      clipOval: true,
                                      errorWidget: getName(snap.data!).checkNull().isNotEmpty
                                          ? ProfileTextImage(text: getName(snap.data!))
                                          : const Icon(
                                              Icons.person,
                                              color: Colors.white,
                                            ),
                                      isGroup: false,
                                      blocked: false,
                                      unknown: false,
                                    )
                                  : const SizedBox.shrink();
                            }),
                        title: FutureBuilder(
                            future: getProfileDetails(item),
                            builder: (context, snap) {
                              return snap.hasData && snap.data != null
                                  ? Text(
                                      snap.data!.name!,
                                      style: const TextStyle(color: Colors.black),
                                    )
                                  : const SizedBox.shrink();
                            }),
                      );
                    })
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget groupCallIcon(String? callType, CallLogData item, String? callMode, List<String>? userList) {
    List<String>? localUserList = [];
    if (item.callState == CallState.missedCall || item.callState == CallState.incomingCall) {
      localUserList.addAll(item.userList!);
      if (!item.userList!.contains(item.fromUser)) {
        localUserList.add(item.fromUser!);
      }
    } else {
      localUserList.addAll(item.userList!);
    }
    return callType!.toLowerCase() == CallType.video
        ? IconButton(
            onPressed: () {
              controller.makeCall(localUserList, callType, item);
            },
            icon: SvgPicture.asset(
              videoCallIcon,
              colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
            ),
          )
        : IconButton(
            onPressed: () {
              controller.makeCall(localUserList, callType, item);
            },
            icon: SvgPicture.asset(
              audioCallIcon,
              colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
            ));
  }

  void showPopupMenu(BuildContext context, CallLogData callLogData) {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    showMenu(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromPoints(
          overlay.localToGlobal(overlay.size.topRight(Offset.zero)),
          overlay.localToGlobal(overlay.size.topRight(Offset.zero)) + const Offset(50.0, 0.0),
        ),
        Offset.zero & overlay.size,
      ),
      items: <PopupMenuEntry>[
        PopupMenuItem(
          value: 0,
          child: Text(getTranslated("removeFromCallLog")),
        ),
      ],
    ).then((value) {
      if (value != null) {
        List<String> callLogRoomId = [];
        callLogRoomId.clear();
        callLogRoomId.add(callLogData.roomId!);
        controller.itemDeleteCallLog(callLogRoomId);
      }
    });
  }
}
