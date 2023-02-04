import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/widgets.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';

import '../../../common/constants.dart';
import '../../chat/chat_widgets.dart';

//import '../../chat/views/message_content.dart';
import '../controllers/message_info_controller.dart';

class MessageInfoView extends GetView<MessageInfoController> {
  const MessageInfoView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Message Info'),
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
                          maxWidth: MediaQuery
                              .of(context)
                              .size
                              .width * 0.6),
                      decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                              bottomLeft: Radius.circular(10)),
                          color: chatSentBgColor,
                          border: Border.all(color: chatSentBgColor)),
                      child: Obx(() {
                        return Column(
                          children: [
                            (controller.chatMessage[0].replyParentChatMessage ==
                                null)
                                ? const SizedBox.shrink()
                                : ReplyMessageHeader(
                                chatMessage: controller.chatMessage[0]),
                            SenderHeader(
                                isGroupProfile: controller.isGroupProfile,
                                chatList: controller.chatMessage,
                                index: 0),
                            //getMessageContent(index, context, chatList),
                            MessageContent(chatList: controller.chatMessage,
                              index: 0,
                              onPlayAudio: (){
                                controller.playAudio(controller.chatMessage[0]);
                              },)
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
        ));
  }

  Widget statusView(BuildContext context) {
    return controller.isGroupProfile ? Obx(() {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppDivider(),
          ListItem(
            leading: !controller.visibleDeliveredList.value ? SvgPicture
                .asset(icExpand) : SvgPicture.asset(icCollapse),
            title: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 15.0, vertical: 10.0),
              child: Text("Delivered to ${controller.messageDeliveredList
                  .length} of ${controller.statusCount.value}",
                style: const TextStyle(
                    fontSize: 18.0, fontWeight: FontWeight.w600),
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
                        .memberProfileDetails!;
                    return memberItem(name: member.name.checkNull(),
                        image: member.image.checkNull(),
                        status: controller.chatDate(context,
                            controller.messageDeliveredList[index]),
                        onTap: () {});
                  }) : emptyDeliveredSeen(
                  context, 'Message sent, not delivered yet')),
          const AppDivider(),
          ListItem(
            leading: !controller.visibleReadList.value ? SvgPicture.asset(
                icExpand) : SvgPicture.asset(icCollapse),
            title: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 15.0, vertical: 10.0),
              child: Text(
                "Read by ${controller.messageReadList.length} of ${controller
                    .statusCount.value}",
                style: const TextStyle(
                    fontSize: 18.0, fontWeight: FontWeight.w600),
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
                        .memberProfileDetails!;
                    return memberItem(name: member.name.checkNull(),
                        image: member.image.checkNull(),
                        status: controller.chatDate(context,
                            controller.messageDeliveredList[index]),
                        onTap: () {});
                  }) : emptyDeliveredSeen(context, "Your message is not read")),
          const AppDivider(),
        ],
      );
    }) :
    Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const Text(
          "Delivered",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(
          height: 10,
        ),
        Obx(() {
          return Text(controller.deliveredTime.value == ""
              ? "Message sent, not delivered yet"
              : controller.getChatTime(
              context, int.parse(controller.deliveredTime.value)));
        }),
        const SizedBox(
          height: 10,
        ),
        const Divider(),
        const Text(
          "Read",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(
          height: 10,
        ),
        Obx(() {
          return Text(controller.readTime.value == ""
              ? "Your message is not read"
              : controller.getChatTime(
              context, int.parse(controller.readTime.value)));
        }),
        const SizedBox(
          height: 10,
        ),
        const Divider(),
      ],
    );
  }

  Widget emptyDeliveredSeen(BuildContext context, String text) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            noChatIcon,
            width: 200,
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14.0, color: Color(0xff7C7C7C)),
            ),
          ),
        ],
      ),
    );
  }
}
