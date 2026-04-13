import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart' show CallLog;
import 'package:mirrorfly_plugin/model/user_list_model.dart';
import '../../../app_style_config.dart';
import '../../../call_kit/callkit_logger.dart';
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
                      if (controller.isFromCallKit.value) {
                        controller.itemDeleteCallKitCall();
                      } else {
                        controller.itemDeleteCallLog([controller.callLogData.roomId.checkNull()
                        ]);
                      }
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
                  Obx(() {

                    final callData = controller.callLogData;
                    final callDataGroupId = callData.groupId.checkNull();

                    final callKitData = controller.callKitLogData.value;
                    final callKitDataGroupId = callKitData.chatId.checkNull();

                    final bool isGroupIdEmpty = controller.isFromCallKit.value ? (callKitDataGroupId.isEmpty)
                        : callDataGroupId.isEmpty;

                    return ListTile(
                      leading: isGroupIdEmpty
                          ? ClipOval(
                        child: AppUtils.assetIcon(assetName:
                        groupImg,
                          height: AppStyleConfig.callInfoPageStyle.callHistoryItemStyle.profileImageSize.height,
                          width: AppStyleConfig.callInfoPageStyle.callHistoryItemStyle.profileImageSize.width,
                          fit: BoxFit.cover,
                        ),
                      )
                          : FutureBuilder(
                              future: controller.isFromCallKit.value
                                  ? _getProfileDetailsFromCallKit(id: controller?.callKitLogData?.value?.chatId ?? "", isGroup: true)
                                  : getProfileDetails(controller
                                      .callLogData.groupId
                                      .checkNull()),
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
                      title: isGroupIdEmpty
                          ? FutureBuilder(
                              future: controller.isFromCallKit.value
                                  ? CallUtils.getCallKitLogUserNames(controller.callKitLogData.value.callParticipants ?? [], controller.callLog)
                                  : CallUtils.getCallLogUserNames(
                                      controller.callLogData.userList!,
                                      controller.callLogData),
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
                              future: controller.isFromCallKit.value
                                  ? _getProfileDetailsFromCallKit(
                                      id: controller.callKitLogData.value.callId
                                              .toString(),
                                      isGroup: true)
                                  : getProfileDetails(controller
                                      .callLogData.groupId
                                      .checkNull()),
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
                        child: controller.isFromCallKit.value
                            ? _callLogTimeForCallKit(
                                "${DateTimeUtils.getCallLogDate(
                                    microSeconds: controller.callKitLogData.value.callTime ?? 0)} "
                                    " ${controller.callKitLogData.value.duration ?? "0"}",

                                controller.callLogData.callState == 0,
                                controller.callLogData.callState == CallState.missedCall,
                                AppStyleConfig.callInfoPageStyle.callHistoryItemStyle.durationTextStyle)
                            : callLogTime(
                                "${DateTimeUtils.getCallLogDate(microSeconds: controller.isFromCallKit.value ? controller.callKitLogData.value.callTime ?? 0 : controller.callLogData.callTime!)}  ${getChatTime(context, controller.callLogData.callTime)}",
                                controller.callLogData.callState,
                                AppStyleConfig.callInfoPageStyle
                                    .callHistoryItemStyle.durationTextStyle),
                      ),
                      trailing: SizedBox(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              getCallLogDuration(controller.isFromCallKit.value ? controller.callKitLogData.value.startTime ?? 0 : controller.callLogData.startTime ?? 0, controller.isFromCallKit.value ? controller.callKitLogData.value.endTime ?? 0 : controller.callLogData.endTime!),
                              style: AppStyleConfig.callInfoPageStyle.callHistoryItemStyle.subtitleTextStyle,
                              // style: const TextStyle(color: Colors.black),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            controller.isFromCallKit.value
                                ? callKitCallIcon(
                              controller.callKitLogData.value.callType,
                              controller.callKitLogData.value,
                              controller.callKitLogData.value.callMode,
                                AppStyleConfig.callInfoPageStyle
                                    .callHistoryItemStyle.iconColor
                            ) :
                                 groupCallIcon(
                                    controller.callLogData.callType,
                                    controller.callLogData,
                                    controller.callLogData.callMode,
                                    controller.callLogData.userList,
                                    AppStyleConfig.callInfoPageStyle
                                        .callHistoryItemStyle.iconColor),
                          ],
                        ),
                      ),
                    );
                  }),
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
                      itemCount: controller.isFromCallKit.value ? controller.callKitLogData.value.callParticipants?.length : controller.callLogData.userList!.length,
                      itemBuilder: (context, index) {
                        var item = controller.isFromCallKit.value ? CallUtils.getJidFromUserId(userId: controller.callKitLogData.value.callParticipants![index], isGroup: false) : controller.callLogData.userList![index];
                        var style = AppStyleConfig.callInfoPageStyle.contactItemStyle;
                        callkitLogger.info("${controller.tag} - Building participant item for ${item}, isFromCallKit: ${controller.isFromCallKit.value}");
                        return ListTile(
                          leading: FutureBuilder(
                              future:  controller.isFromCallKit.value
                                  ? _getProfileDetailsFromCallKit(id: controller.callKitLogData.value.callParticipants![index], isGroup: true) :
                              getProfileDetails(item),
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

  Future<ProfileDetails> _getProfileDetailsFromCallKit({required String id, required bool isGroup}) async {
    final String jid = isGroup ? CallUtils.getGroupJidFromGroupId(id) : CallUtils.getJidFromUserId(userId: id, isGroup: false);
    callkitLogger.info("${controller.tag} - getProfileDetailsFromCallKit | jid: $jid, isGroup: $isGroup");
    return getProfileDetails(jid);
  }

  Widget callKitCallIcon(String? callType, CallLog item, String? callMode, Color iconColor) {
    return callType!.toLowerCase() == CallType.video
        ? IconButton(
      onPressed: () {
        // controller.makeCallKitVideoCall(
            // callersId: item.callParticipants ?? [],
            // chatId: item.chatId ?? "",
            // isOneToOne: item.callMode?.isOneToOneCall == true);
      },
      icon: AppUtils.svgIcon(
        icon: videoCallIcon,
        colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
      ),
    )
        : IconButton(
        onPressed: () {
          // controller.makeCallKitAudioCall(
          //     callersId: item.callParticipants ?? [],
          //     chatId: item.chatId ?? "",
          //     isOneToOne: item.callMode?.isOneToOneCall == true);
        },
        icon: AppUtils.svgIcon(
          icon: audioCallIcon,
          colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
        ));
  }

  Widget _callLogTimeForCallKit(
      String time,
      bool isCaller,
      bool isMissedCall,
      TextStyle? textStyle,
      ) {
    Widget iconWidget;

    if (isMissedCall) {
      iconWidget = AppUtils.svgIcon(
        icon: arrowDropDown,
        colorFilter: const ColorFilter.mode(Colors.red, BlendMode.srcIn),
      );
    } else if (isCaller) {
      iconWidget = AppUtils.svgIcon(
        icon: arrowDownIcon,
        colorFilter: const ColorFilter.mode(Colors.green, BlendMode.srcIn),
      );
    } else {
      iconWidget = AppUtils.svgIcon(
        icon: arrowUpIcon,
        colorFilter: const ColorFilter.mode(Colors.green, BlendMode.srcIn),
      );
    }

    return Row(
      children: [
        iconWidget,
        const SizedBox(width: 5),
        Text(
          time,
          style: textStyle,
        ),
      ],
    );
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
