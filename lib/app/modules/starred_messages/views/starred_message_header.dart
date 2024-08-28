
import 'package:flutter/material.dart';
import '../../../common/app_localizations.dart';
import '../../../data/helper.dart';
import '../../../extensions/extensions.dart';
import 'package:mirrorfly_plugin/mirrorflychat.dart';

import '../../../common/constants.dart';
import '../../../common/widgets.dart';
import '../../../model/chat_message_model.dart';
import '../../../stylesheet/stylesheet.dart';
import '../controllers/starred_messages_controller.dart';

class StarredMessageHeader extends StatelessWidget {
  const StarredMessageHeader(
      {Key? key, required this.chatList, required this.isTapEnabled, required this.controller,this.style = const StarredMessageUserHeaderStyle()})
      : super(key: key);
  final ChatMessageModel chatList;
  final bool isTapEnabled;
  final StarredMessagesController controller;// = StarredMessagesController().get();
  final StarredMessageUserHeaderStyle style;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      margin: const EdgeInsets.all(2),
      child: getHeader(context),
    );
  }

  Future<ProfileDetails> getProfile() async {
    /*var value = await Mirrorfly.getProfileDetails(chatList.chatUserJid);
    return Profile.fromJson(json.decode(value.toString()));*/
    return await getProfileDetails(chatList.chatUserJid);
  }

  getHeader(BuildContext context) {
    return FutureBuilder(
        future: getProfile(),
        builder: (context, d) {
          var userProfile = d.data;
          if (userProfile != null) {
            if (chatList.isMessageSentByMe) {
              return Row(
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  getChatTime(chatList.messageSentTime.toInt(), context),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Flexible(
                          child: Text(
                            userProfile.name.checkNull(),
                            style: style.profileNameStyle,
                            // style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                            decoration: const BoxDecoration(
                              color: statusBarColor,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(2)),
                            ),
                            margin: const EdgeInsets.all(5),
                            // padding: const EdgeInsets.all(1),
                            child: const Icon(
                              Icons.arrow_left,
                              color: Colors.black,
                              size: 14,
                            )),
                        Text(getTranslated("you"),
                            style: style.profileNameStyle,
                            // style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                      ],
                    ),
                  ),
                  getProfileImage(userProfile),
                ],
              );
            } else {
              return Row(
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  getProfileImage(userProfile),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Text(
                        userProfile.isGroupProfile.checkNull() ? chatList.senderNickName : userProfile.name.checkNull(),
                            style: style.profileNameStyle,
                            // style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                            decoration: const BoxDecoration(
                              color: statusBarColor,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(2)),
                            ),
                            margin: const EdgeInsets.all(5),
                            child: const Icon(
                              Icons.arrow_right,
                              color: Colors.black,
                              size: 14,
                            )),
                        userProfile.isGroupProfile.checkNull()
                            ? Flexible(
                                child: Text(
                                  userProfile.name.checkNull(),
                                  style: style.profileNameStyle,
                                  /*style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),*/
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              )
                            : Text(getTranslated("you"),
                                style: style.profileNameStyle,
                                // style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                      ],
                    ),
                  ),
                  getChatTime(chatList.messageSentTime.toInt(), context),
                ],
              );
            }
          } else {
            return const SizedBox.shrink();
          }
        });
  }

  getChatTime(int messageSentTime, BuildContext context) {
    return Text(
      controller.getChatTime(context, messageSentTime),
      style: style.dateTextStyle,
      // style: const TextStyle(fontSize: 12, color: Color(0xff959595)),
    );
  }

  getProfileImage(ProfileDetails userProfile) {
    if (userProfile.image.checkNull().isNotEmpty) {
      return ImageNetwork(
        url: userProfile.image.checkNull(),
        width: style.profileImageSize.width,
        height: style.profileImageSize.height,
        clipOval: true,
        errorWidget: ProfileTextImage(
          text: userProfile.name.checkNull().isEmpty
              ? userProfile.mobileNumber.checkNull()
              : userProfile.name.checkNull(),
          radius: style.profileImageSize.width/2,
        ),
        isGroup: userProfile.isGroupProfile.checkNull(),
        blocked: userProfile.isBlockedMe.checkNull() || userProfile.isAdminBlocked.checkNull(),
        unknown: (!userProfile.isItSavedContact.checkNull() || userProfile.isDeletedContact()),
      );
    } else {
      return ProfileTextImage(
        text: userProfile.name.checkNull().isEmpty
            ? userProfile.mobileNumber.checkNull()
            : userProfile.name.checkNull(),
        radius: style.profileImageSize.width/2,
      );
    }
  }
}
