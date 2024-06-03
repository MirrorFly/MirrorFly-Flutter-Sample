
import 'package:flutter/material.dart';
import 'package:mirror_fly_demo/app/extensions/extensions.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';

import '../../../common/constants.dart';
import '../../../common/widgets.dart';
import '../../../data/helper.dart';
import '../widgets.dart';

class ContactItem extends StatelessWidget {
  const ContactItem({
    Key? key,
    required this.item,
    this.onAvatarClick,
    this.spanTxt = "",
    this.isCheckBoxVisible = false,
    required this.checkValue,
    required this.onCheckBoxChange,
    this.onListItemPressed,
  }) : super(key: key);
  final ProfileDetails item;
  final Function()? onAvatarClick;
  final String spanTxt;
  final bool isCheckBoxVisible;
  final bool checkValue;
  final Function(bool?) onCheckBoxChange;
  final Function()? onListItemPressed;
  @override
  Widget build(BuildContext context) {
    // LogMessage.d("Contact item", item.toJson());
    // LogMessage.d("Contact item name", getName(item));
    return Opacity(
      opacity: item.isBlocked.checkNull() ? 0.3 : 1.0,
      child: InkWell(
        onTap: onListItemPressed,
        child: Row(
          children: [
            InkWell(
              onTap: onAvatarClick,
              child: Container(
                  margin: const EdgeInsets.only(left: 19.0, top: 10, bottom: 10, right: 10),
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: item.image.checkNull().isEmpty ? iconBgColor : buttonBgColor,
                    shape: BoxShape.circle,
                  ),
                  child: ImageNetwork(
                    url: item.image.toString(),
                    width: 48,
                    height: 48,
                    clipOval: true,
                    errorWidget: getName(item) //item.nickName
                        .checkNull()
                        .isNotEmpty
                        ? ProfileTextImage(text: getName(item))
                        : const Icon(
                      Icons.person,
                      color: Colors.white,
                    ),
                    blocked: item.isBlockedMe.checkNull() || item.isAdminBlocked.checkNull(),
                    unknown: (!item.isItSavedContact.checkNull() || item.isDeletedContact()),
                    isGroup: item.isGroupProfile.checkNull(),
                  )), //controller.showProfilePopup(item.obs);
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  spanTxt.isEmpty
                      ? Text(
                    getName(item),
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                      : spannableText(
                      getName(item),
                      //item.profileName.checkNull(),
                      spanTxt.trim(),
                      const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w700, fontFamily: 'sf_ui', color: textHintColor),Colors.blue),
                  Text(
                    item.status.toString(),
                    style: Theme.of(context).textTheme.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                ],
              ),
            ),
            Visibility(
              visible: isCheckBoxVisible,
              child: Checkbox(
                value: checkValue, //controller.selectedUsersJIDList.contains(item.jid),
                onChanged: (value) {
                  onCheckBoxChange(value);
                  //controller.onListItemPressed(item);
                },
                activeColor: AppColors.checkBoxChecked,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2), side: const BorderSide(color: AppColors.checkBoxBorder)),
              ),
            ),
          ],
        ),
        // onTap: () {
        //   controller.onListItemPressed(item);
        // },
      ),
    );
  }
}