
import 'package:flutter/material.dart';
import '../../../extensions/extensions.dart';
import '../../../stylesheet/stylesheet.dart';
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
    this.onListItemPressed,this.contactItemStyle = const ContactItemStyle(),
  }) : super(key: key);
  final ProfileDetails item;
  final Function()? onAvatarClick;
  final String spanTxt;
  final bool isCheckBoxVisible;
  final bool checkValue;
  final Function(bool?) onCheckBoxChange;
  final Function()? onListItemPressed;
  final ContactItemStyle contactItemStyle;
  @override
  Widget build(BuildContext context) {
    // LogMessage.d("Contact item", item.toJson());
    // LogMessage.d("Contact item name", getName(item));
    return Opacity(
      opacity: item.isBlocked.checkNull() ? 0.3 : 1.0,
      child: InkWell(
        onTap: onListItemPressed,
        child: Column(
          children: [
            Row(
              children: [
                InkWell(
                  onTap: onAvatarClick,
                  child: Container(
                      margin: const EdgeInsets.only(left: 18.0, top: 10, bottom: 10, right: 10),
                      width: contactItemStyle.profileImageSize.width,
                      height: contactItemStyle.profileImageSize.height,
                      decoration: BoxDecoration(
                        color: item.image.checkNull().isEmpty ? iconBgColor : buttonBgColor,
                        shape: BoxShape.circle,
                      ),
                      child: ImageNetwork(
                        url: item.image.toString(),
                        width: contactItemStyle.profileImageSize.width - 2,
                        height: contactItemStyle.profileImageSize.height - 2,
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
                        style: contactItemStyle.titleStyle,
                        // style: Theme.of(context).textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                          : spannableText(
                          getName(item),
                          //item.profileName.checkNull(),
                          spanTxt.trim(),
                          contactItemStyle.titleStyle,
                          // const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w700, fontFamily: 'sf_ui', color: textHintColor),
                          contactItemStyle.spanTextColor),
                      const SizedBox(height: 5,),
                      Text(
                        item.status.toString(),
                        style: contactItemStyle.descriptionStyle,
                        // style: Theme.of(context).textTheme.titleSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
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
                    shape: contactItemStyle.checkBoxShape,
                  ),
                ),
              ],
            ),
            AppDivider(color: contactItemStyle.dividerColor,padding: EdgeInsets.only(left: contactItemStyle.profileImageSize.width),)
          ],
        ),
        // onTap: () {
        //   controller.onListItemPressed(item);
        // },
      ),
    );
  }
}