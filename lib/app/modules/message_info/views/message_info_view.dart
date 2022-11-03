import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../common/constants.dart';
import '../../chat/views/message_content.dart';
import '../../chat/views/message_header.dart';
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
                          maxWidth: MediaQuery.of(context).size.width * 0.6),
                      decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                              bottomLeft: Radius.circular(10)),
                          color: chatsentbgcolor,
                          border: Border.all(color: chatsentbgcolor)),
                      child: Column(
                        children: [
                          MessageHeader(chatList: controller.chatMessage, isTapEnabled: false,),
                          MessageContent(chatList: controller.chatMessage, isTapEnabled: false,),
                        ],
                      ),
                    ),
                  ),
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
                        : controller.getChatTime(context, int.parse(controller.deliveredTime.value)));
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
                        : controller.getChatTime(context, int.parse(controller.readTime.value)));
                  }),
                  const SizedBox(
                    height: 10,
                  ),
                  const Divider(),
                ],
              ),
            ),
          ),
        ));
  }
}
