import 'package:flutter/material.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirror_fly_demo/app/common/widgets.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';
import 'package:mirrorfly_plugin/model/user_list_model.dart';

Widget buildProfileImage(Profile item) {
  return ImageNetwork(
    url: item.image.toString(),
    width: 105,
    height: 105,
    clipOval: true,
    errorWidget: item.isGroupProfile!
        ? ClipOval(
      child: Image.asset(
        groupImg,
        height: 48,
        width: 48,
        fit: BoxFit.cover,
      ),
    )
        : ProfileTextImage(
      text: item.getName(),
      radius: 50,
    ),
    isGroup: item.isGroupProfile.checkNull(),
    blocked: item.isBlockedMe.checkNull() || item.isAdminBlocked.checkNull(),
    unknown: (!item.isItSavedContact.checkNull() || item.isDeletedContact()),
  );
}