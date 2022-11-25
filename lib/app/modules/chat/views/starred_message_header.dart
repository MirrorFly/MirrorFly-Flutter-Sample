import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';
import 'package:flysdk/flysdk.dart';

import '../../../common/widgets.dart';
import '../../starred_messages/controllers/starred_messages_controller.dart';

class StarredMessageHeader extends StatefulWidget {
  const StarredMessageHeader(
      {Key? key, required this.chatList, required this.isTapEnabled})
      : super(key: key);

  final ChatMessageModel chatList;
  final bool isTapEnabled;

  @override
  State<StarredMessageHeader> createState() => _StarredMessageHeaderState();
}

class _StarredMessageHeaderState extends State<StarredMessageHeader> {
  var controller = Get.find<StarredMessagesController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 0, 0, 0),
      margin: const EdgeInsets.all(2),
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10))),
      child: Column(
        children: [
          const Divider(thickness: 1),
          const SizedBox(height: 10,),
          getHeader(widget.chatList, context),
        ],
      ),
    );
  }

  getHeader(ChatMessageModel chatList, BuildContext context) {
    var userProfile = Profile().obs;
    FlyChat.getProfileDetails(chatList.senderUserJid, true).then((value) {
      userProfile.value = Profile.fromJson(json.decode(value.toString()));
      debugPrint("Image==>${userProfile.value.image}");
    });
    if (chatList.isMessageSentByMe) {
      return Row(
        children: [
          getChatTime(chatList.messageSentTime),
          const Spacer(),
          Obx(() {
            return Text("You --> ${userProfile.value.name}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),);
          }),
          const SizedBox(width: 10,),
          getProfileImage(userProfile),
          const SizedBox(width: 10,),
        ],
      );
    }else{
      return Row(
        children: [
          getProfileImage(userProfile),
          const SizedBox(width: 10,),
          Obx(() {
            return Text("${userProfile.value.name} --> You", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),);
          }),
          const Spacer(),
          getChatTime(chatList.messageSentTime),
        ],
      );
    }
  }

  getChatTime(int messageSentTime) {
    return Text(controller.getChatTime(context, messageSentTime));
  }

  getProfileImage(Rx<Profile> userProfile) {
    return ImageNetwork(
      url: userProfile.value.image.checkNull(),
      width: 55,
      height: 55,
      clipOval: true,
      errorWidget: ProfileTextImage(
        text: userProfile.value.name.checkNull().isEmpty
            ? userProfile.value.mobileNumber.checkNull()
            : userProfile.value.name.checkNull(),
        radius: 25,
      ),
    );
  }
}
