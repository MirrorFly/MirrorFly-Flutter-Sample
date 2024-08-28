import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app_style_config.dart';
import '../../../call_modules/call_info/controllers/call_info_controller.dart';
import '../../../common/constants.dart';
import '../../../common/widgets.dart';
import '../../../data/helper.dart';
import '../../../data/utils.dart';
import '../../../extensions/extensions.dart';
import 'package:mirrorfly_plugin/model/call_constants.dart';
import 'package:mirrorfly_plugin/model/call_log_model.dart';

import '../../../common/app_localizations.dart';
import '../../../modules/dashboard/widgets.dart';
import '../../../widgets/custom_action_bar_icons.dart';
import '../../call_utils.dart';

class CallInfoView extends NavViewStateful<CallInfoController> {
  const CallInfoView({super.key});

  @override
CallInfoController createController({String? tag}) => Get.put(CallInfoController());

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(appBarTheme: AppStyleConfig.callInfoPageStyle.appBarTheme),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            getTranslated("callInfo"),
          ),
          actions: [
            CustomActionBarIcons(
              availableWidth: NavUtils.width / 2, // half the screen width
              actionWidth: 48,
              popupMenuThemeData: AppStyleConfig.callInfoPageStyle.popupMenuThemeData,
              actions: [
                CustomAction(
                  visibleWidget: IconButton(
                      onPressed: () {}, icon: const Icon(Icons.delete)),
                  overflowWidget: InkWell(
                    child: Text(getTranslated("removeFromCallLog")),
                    onTap: () {
                      NavUtils.back();
                      controller.itemDeleteCallLog([controller.callLogData.roomId.checkNull()]);
                    },
                  ),
                  showAsAction: ShowAsAction.never,
                  keyValue: 'Refresh',
                  onItemClick: () {},
                )
              ],
            ),
            /*IconButton(
                onPressed: () {
                  showPopupMenu(context, controller.callLogData);
                },
                icon: const Icon(Icons.more_vert))*/
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
                        leading: controller.callLogData.groupId.checkNull().isEmpty
                            ? ClipOval(
                                child: AppUtils.assetIcon(assetName:
                                  groupImg,
                                  height: AppStyleConfig.callInfoPageStyle.callHistoryItemStyle.profileImageSize.height,
                                  width: AppStyleConfig.callInfoPageStyle.callHistoryItemStyle.profileImageSize.width,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : FutureBuilder(
                                future: getProfileDetails(controller.callLogData.groupId.checkNull()),
                                builder: (context, snap) {
                                  return snap.hasData && snap.data != null
                                      ? ImageNetwork(
                                          url: snap.data!.image.checkNull(),
                                          width: AppStyleConfig.callInfoPageStyle.callHistoryItemStyle.profileImageSize.width,
                                          height: AppStyleConfig.callInfoPageStyle.callHistoryItemStyle.profileImageSize.height,
                                          clipOval: true,
                                          errorWidget: ClipOval(
                                            child: AppUtils.assetIcon(assetName:
                                              groupImg,
                                              height: AppStyleConfig.callInfoPageStyle.callHistoryItemStyle.profileImageSize.height,
                                              width: AppStyleConfig.callInfoPageStyle.callHistoryItemStyle.profileImageSize.width,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          isGroup: false,
                                          blocked: false,
                                          unknown: false,
                                        )
                                      : ClipOval(
                                          child: AppUtils.assetIcon(assetName:
                                            groupImg,
                                            height: AppStyleConfig.callInfoPageStyle.callHistoryItemStyle.profileImageSize.height,
                                            width: AppStyleConfig.callInfoPageStyle.callHistoryItemStyle.profileImageSize.width,
                                            fit: BoxFit.cover,
                                          ),
                                        );
                                }),
                        title: controller.callLogData.groupId.checkNull().isEmpty
                            ? FutureBuilder(
                                future: CallUtils.getCallLogUserNames(controller.callLogData.userList!, controller.callLogData),
                                builder: (context, snap) {
                                  if (snap.hasData) {
                                    return Text(
                                      snap.data.checkNull(),
                                      style: AppStyleConfig.callInfoPageStyle.callHistoryItemStyle.titleTextStyle,
                                      // style: const TextStyle(color: Colors.black),
                                    );
                                  } else {
                                    return const Offstage();
                                  }
                                })
                            : FutureBuilder(
                                future: getProfileDetails(controller.callLogData.groupId.checkNull()),
                                builder: (context, snap) {
                                  if (snap.hasData) {
                                    return Text(
                                      snap.data!.name.checkNull(),
                                      style: AppStyleConfig.callInfoPageStyle.callHistoryItemStyle.titleTextStyle,
                                      // style: const TextStyle(color: Colors.black),
                                    );
                                  } else {
                                    return const Offstage();
                                  }
                                }),
                        subtitle: SizedBox(
                          child: callLogTime(
                              "${DateTimeUtils.getCallLogDate(microSeconds: controller.callLogData.callTime!)}  ${getChatTime(context, controller.callLogData.callTime)}",
                              controller.callLogData.callState,AppStyleConfig.callInfoPageStyle.callHistoryItemStyle.durationTextStyle),
                        ),
                        trailing: SizedBox(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                getCallLogDuration(controller.callLogData.startTime!, controller.callLogData.endTime!),
                                style: AppStyleConfig.callInfoPageStyle.callHistoryItemStyle.subtitleTextStyle,
                                // style: const TextStyle(color: Colors.black),
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              groupCallIcon(controller.callLogData.callType, controller.callLogData, controller.callLogData.callMode,
                                  controller.callLogData.userList,AppStyleConfig.callInfoPageStyle.callHistoryItemStyle.iconColor),
                            ],
                          ),
                        ),
                      )),
                  Divider(
                    color: AppStyleConfig.callInfoPageStyle.callHistoryItemStyle.dividerColor,
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
                        var style = AppStyleConfig.callInfoPageStyle.contactItemStyle;
                        return ListTile(
                          leading: FutureBuilder(
                              future: getProfileDetails(item),
                              builder: (context, snap) {
                                return snap.hasData && snap.data != null
                                    ? ImageNetwork(
                                        url: snap.data!.image.checkNull(),
                                        width: style.profileImageSize.width,
                                        height: style.profileImageSize.height,
                                        clipOval: true,
                                        errorWidget: getName(snap.data!).checkNull().isNotEmpty
                                            ? ProfileTextImage(text: getName(snap.data!),radius: style.profileImageSize.height/2,)
                                            : const Icon(
                                                Icons.person,
                                                color: Colors.white,
                                              ),
                                        isGroup: false,
                                        blocked: false,
                                        unknown: false,
                                      )
                                    : const Offstage();
                              }),
                          title: FutureBuilder(
                              future: getProfileDetails(item),
                              builder: (context, snap) {
                                return snap.hasData && snap.data != null
                                    ? Text(
                                        snap.data!.name.checkNull(),
                                        style: style.titleStyle,
                                        // style: const TextStyle(color: Colors.black),
                                      )
                                    : const Offstage();
                              }),
                        );
                      })
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget groupCallIcon(String? callType, CallLogData item, String? callMode, List<String>? userList,Color iconColor) {
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
            icon: AppUtils.svgIcon(icon:
              videoCallIcon,
              colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
            ),
          )
        : IconButton(
            onPressed: () {
              controller.makeCall(localUserList, callType, item);
            },
            icon: AppUtils.svgIcon(icon:
              audioCallIcon,
              colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
            ));
  }

  /*void showPopupMenu(BuildContext context, CallLogData callLogData) {
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
  }*/
}
