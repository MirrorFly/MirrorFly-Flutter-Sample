import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/call_kit/call_log_info/call_log_info_controller.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart' show CallLog;
import 'package:mirrorfly_plugin/model/user_list_model.dart';
import 'package:mirrorfly_plugin/model/call_constants.dart';
import 'package:mirrorfly_plugin/model/call_log_model.dart';

import '../../app_style_config.dart';
import '../../call_modules/call_utils.dart';
import '../../common/app_localizations.dart';
import '../../common/constants.dart';
import '../../common/widgets.dart';
import '../../data/helper.dart';
import '../../data/utils.dart';
import '../../extensions/extensions.dart';
import '../../modules/dashboard/widgets.dart';
import '../../widgets/custom_action_bar_icons.dart';
import '../callkit_logger.dart';


class CallLogInfoView extends NavViewStateful<CallLogInfoController> {
  const CallLogInfoView({super.key});

  @override
  CallLogInfoController createController({String? tag}) => Get.put(CallLogInfoController());

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
                      controller.itemDeleteCallKitCall();
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
                    final callKitData = controller.callKitLogData.value;
                    final callKitDataGroupId = callKitData.chatId.checkNull();

                    final bool isGroupIdEmpty = callKitDataGroupId.isEmpty;

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
                          future:  _getProfileDetailsFromCallKit(id: controller.callKitLogData.value.chatId ?? "", isGroup: true),
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
                          future:
                               CallUtils.getCallKitLogUserNames(controller.callKitLogData.value.callParticipants ?? [], controller.callKitLog),
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
                          future:  _getProfileDetailsFromCallKit(
                              id: controller.callKitLogData.value.callId
                                  .toString(),
                              isGroup: true)
                              ,
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
                        child: _callLogTimeForCallKit(
                            "${DateTimeUtils.getCallLogDate(microSeconds: controller.callKitLogData.value.callTime ?? 0)} "
                            " ${controller.callKitLogData.value.duration ?? "0"}",
                            controller.callKitLog.isCaller == 0,
                            controller.callKitLog.missedStatus == 1,
                            AppStyleConfig.callInfoPageStyle
                                .callHistoryItemStyle.durationTextStyle),
                      ),
                      trailing: SizedBox(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              getCallLogDuration(controller.callKitLogData.value.startTime ?? 0 ,  controller.callKitLogData.value.endTime ?? 0 ),
                              style: AppStyleConfig.callInfoPageStyle.callHistoryItemStyle.subtitleTextStyle,
                              // style: const TextStyle(color: Colors.black),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                          callKitCallIcon(
                                controller.callKitLogData.value.callType,
                                controller.callKitLogData.value,
                                controller.callKitLogData.value.callMode,
                                AppStyleConfig.callInfoPageStyle
                                    .callHistoryItemStyle.iconColor
                            )
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
                      itemCount:  controller.callKitLogData.value.callParticipants?.length ,
                      itemBuilder: (context, index) {
                        var item =  CallUtils.getJidFromUserId(userId: controller.callKitLogData.value.callParticipants![index], isGroup: false);
                        var style = AppStyleConfig.callInfoPageStyle.contactItemStyle;
                        callkitLogger.info("${controller.tag} - Building participant item for ${item}");
                        return ListTile(
                          leading: FutureBuilder(
                              future:   _getProfileDetailsFromCallKit(id: controller.callKitLogData.value.callParticipants![index], isGroup: true) ,
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

  Future<ProfileDetails> _getProfileDetailsFromCallKit({required String id, required bool isGroup}) async {
    final String jid = isGroup ? CallUtils.getGroupJidFromGroupId(id) : CallUtils.getJidFromUserId(userId: id, isGroup: false);
    callkitLogger.info("${controller.tag} - getProfileDetailsFromCallKit | jid: $jid, isGroup: $isGroup");
    return getProfileDetails(jid);
  }

  Widget callKitCallIcon(String? callType, CallLog item, String? callMode, Color iconColor) {
    return callType!.toLowerCase() == CallType.video
        ? IconButton(
      onPressed: () {
       controller.makeCallKitCall();
      },
      icon: AppUtils.svgIcon(
        icon: videoCallIcon,
        colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
      ),
    )
        : IconButton(
        onPressed: () {
          controller.makeCallKitCall();
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
}
