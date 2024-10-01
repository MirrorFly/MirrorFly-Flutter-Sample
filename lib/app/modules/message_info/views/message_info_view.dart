import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app_style_config.dart';
import '../../../common/app_localizations.dart';
import '../../../common/widgets.dart';
import '../../../data/utils.dart';
import '../../../extensions/extensions.dart';

import '../../../common/constants.dart';
import '../../chat/widgets/chat_widgets.dart';
import '../../chat/widgets/message_content.dart';
import '../../chat/widgets/reply_message_widgets.dart';
import '../../chat/widgets/sender_header.dart';
import '../controllers/message_info_controller.dart';

class MessageInfoView extends NavViewStateful<MessageInfoController> {
  const MessageInfoView({super.key,this.appbar});
  final PreferredSizeWidget? appbar;

  @override
MessageInfoController createController({String? tag}) => Get.put(MessageInfoController());

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(appBarTheme: AppStyleConfig.messageInfoPageStyle.appBarTheme),
      child: Scaffold(
          appBar: appbar ?? AppBar(
            title: Text(getTranslated("messageInfo")),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        constraints: BoxConstraints(
                            maxWidth: NavUtils.width * 0.75),
                        decoration: AppStyleConfig.messageInfoPageStyle.senderChatBubbleStyle.decoration/*BoxDecoration(
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                                bottomLeft: Radius.circular(10)),
                            color: chatSentBgColor,
                            border: Border.all(color: chatSentBgColor))*/,
                        child: Obx(() {
                          return Column(
                            children: [
                              controller.chatMessage[0].isThisAReplyMessage ? controller.chatMessage[0].replyParentChatMessage == null
                                  ? messageNotAvailableWidget(controller.chatMessage[0])
                                  : ReplyMessageHeader(
                                  chatMessage: controller.chatMessage[0],
                                replyHeaderMessageViewStyle: AppStyleConfig.messageInfoPageStyle.senderChatBubbleStyle.replyHeaderMessageViewStyle) : const Offstage(),
                              SenderHeader(
                                  isGroupProfile: controller.isGroupProfile,
                                  chatList: controller.chatMessage,
                                  index: 0,textStyle: null,),
                              //getMessageContent(index, context, chatList),
                              MessageContent(chatList: controller.chatMessage,
                                index: 0,
                                onPlayAudio: (){
                                  controller.playAudio(controller.chatMessage[0]);
                                },
                                onSeekbarChange:(value){
                                  controller.onSeekbarChange(value, controller.chatMessage[0]);
                                },senderChatBubbleStyle: AppStyleConfig.messageInfoPageStyle.senderChatBubbleStyle,)
                              //MessageHeader(chatList: controller.chatMessage, isTapEnabled: false,),
                              //MessageContent(chatList: controller.chatMessage, isTapEnabled: false,),
                            ],
                          );
                        }),
                      ),
                    ),
                    statusView(context),
                  ],
                ),
              ),
            ),
          )),
    );
  }

  Widget statusView(BuildContext context) {
    return controller.isGroupProfile ? Obx(() {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppDivider(),
          ListItem(
            leading: !controller.visibleDeliveredList.value ? AppUtils.svgIcon(icon:icExpand) : AppUtils.svgIcon(icon:icCollapse),
            title: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 15.0, vertical: 10.0),
              child: Text(getTranslated("deliveredTo").replaceAll("%d","${controller.messageDeliveredList
                  .length}").replaceAll("%s", "${controller.statusCount.value}"),
                style: AppStyleConfig.messageInfoPageStyle.deliveredTitleStyle, //const TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600),
                textAlign: TextAlign.left,),
            ), onTap: () {
            controller.onDeliveredClick();
          },),
          Visibility(
              visible: controller.visibleDeliveredList.value,
              child: controller.messageDeliveredList.isNotEmpty ? ListView
                  .builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.messageDeliveredList.length,
                  itemBuilder: (cxt, index) {
                    var member = controller.messageDeliveredList[index]
                        .profileDetails!;
                    return MemberItem(name: member.name.checkNull().isNotEmpty ? member.name.checkNull() : member.nickName.checkNull(),
                        image: member.image.checkNull(),
                        status: controller.chatDate(context, controller.messageDeliveredList[index]),
                        onTap: () {},
                      blocked: member.isBlockedMe.checkNull() || member.isAdminBlocked.checkNull(),
                      unknown: (!member.isItSavedContact.checkNull() || member.isDeletedContact()),
                    itemStyle: AppStyleConfig.messageInfoPageStyle.deliveredItemStyle,);
                  }) : emptyDeliveredSeen(
                  context, getTranslated("sentNotDelivered"),AppStyleConfig.messageInfoPageStyle.deliveredMsgTitleStyle)),
          const AppDivider(),
          ListItem(
            leading: !controller.visibleReadList.value ? AppUtils.svgIcon(icon:
                icExpand) : AppUtils.svgIcon(icon:icCollapse),
            title: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 15.0, vertical: 10.0),
              child: Text(
      getTranslated("readBy").replaceAll("%d","${controller.messageReadList.length}").replaceAll("%s", "${controller
                    .statusCount.value}"),
                style: AppStyleConfig.messageInfoPageStyle.readTitleStyle, //const TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600),
                textAlign: TextAlign.left,),
            ), onTap: () {
            controller.onReadClick();
          },),
          Visibility(
              visible: controller.visibleReadList.value,
              child: controller.messageReadList.isNotEmpty ? ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.messageReadList.length,
                  itemBuilder: (cxt, index) {
                    var member = controller.messageReadList[index]
                        .profileDetails!;
                    return MemberItem(name: member.name.checkNull().isNotEmpty ? member.name.checkNull() : member.nickName.checkNull(),
                        image: member.image.checkNull(),
                        status: controller.chatDate(context,
                            controller.messageDeliveredList[index]),
                        onTap: () {},
                      blocked: member.isBlockedMe.checkNull() || member.isAdminBlocked.checkNull(),
                      unknown: (!member.isItSavedContact.checkNull() || member.isDeletedContact()),
                    itemStyle: AppStyleConfig.messageInfoPageStyle.readItemStyle,);
                  }) : emptyDeliveredSeen(context, getTranslated("notRead"),AppStyleConfig.messageInfoPageStyle.readMsgTitleStyle)),
          const AppDivider(),
        ],
      );
    }) :
    Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        Text(
          getTranslated("delivered"),
          style: AppStyleConfig.messageInfoPageStyle.deliveredTitleStyle,
          // style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(
          height: 10,
        ),
        Obx(() {
          return Text(controller.deliveredTime.value == ""
              ? getTranslated("sentNotDelivered")
              : controller.getChatTime(
              context, int.parse(controller.deliveredTime.value)),
          style: AppStyleConfig.messageInfoPageStyle.deliveredMsgTitleStyle,);
        }),
        const SizedBox(
          height: 10,
        ),
        const Divider(),
        Text(
          getTranslated("read"),
          style: AppStyleConfig.messageInfoPageStyle.readTitleStyle,
          // style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(
          height: 10,
        ),
        Obx(() {
          return Text(controller.readTime.value == ""
              ? getTranslated("notRead")
              : controller.getChatTime(
              context, int.parse(controller.readTime.value)),
          style: AppStyleConfig.messageInfoPageStyle.readMsgTitleStyle,);
        }),
        const SizedBox(
          height: 10,
        ),
        const Divider(),
      ],
    );
  }

  Widget emptyDeliveredSeen(BuildContext context, String text,TextStyle textStyle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AppUtils.assetIcon(assetName:
            noChatIcon,
            width: 200,
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: textStyle.copyWith(fontSize: 14,fontWeight: FontWeight.normal),
              // style: const TextStyle(fontSize: 14.0, color: Color(0xff7C7C7C)),
            ),
          ),
        ],
      ),
    );
  }
}
