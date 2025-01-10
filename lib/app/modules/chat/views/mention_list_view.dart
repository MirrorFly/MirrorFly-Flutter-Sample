import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/mention_text_field/mention_tag_text_field.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';
import 'package:mirror_fly_demo/app/data/session_management.dart';
import 'package:mirror_fly_demo/app/extensions/extensions.dart';
import 'package:mirror_fly_demo/app/modules/dashboard/dashboard_widgets/contact_item.dart';
import 'package:mirror_fly_demo/app/stylesheet/stylesheet.dart';
import 'package:mirrorfly_plugin/mirrorflychat.dart';

class MentionUsersList extends NavViewStateful<MentionController> {
  const MentionUsersList(this.tags,
      {Key? key, required this.groupJid, this.mentionUserBgDecoration, this.mentionUserStyle = const ContactItemStyle(), required this.chatTaggerController, this.onListItemPressed,})
      : super(key: key, tag: tags);
  final Decoration? mentionUserBgDecoration;
  final ContactItemStyle mentionUserStyle;
  final MentionTagTextEditingController chatTaggerController;
  final String groupJid;
  final String tags;
  final Function(ProfileDetails profile)? onListItemPressed;

  @override
  createController({String? tag}) =>
      MentionController().get(tag: tag);

  @override
  void onInit() {
    controller.getGroupMembers(groupJid);
    super.onInit();
  }


  @override
  Widget build(BuildContext context) {
    return KeyboardVisibilityBuilder(
        builder: (context, isKeyboardVisible) {
          LogMessage.d("KeyboardVisibilityBuilder","isKeyboardVisible:$isKeyboardVisible");
          return Obx(() {
            return controller.filteredItems.isNotEmpty &&
                controller.showMentionUserList.value ? Container(
              decoration: mentionUserBgDecoration,
              height: isKeyboardVisible
                  ? controller.filteredItems.length > 2 ? 100 : null
                  : null,
              child: ListView.builder(
                  key: const PageStorageKey("mentionUsers"),
                  shrinkWrap: true,
                  itemCount: controller.filteredItems.length,
                  itemBuilder: (ct, index) {
                    return ContactItem(item: controller.filteredItems[index],
                      checkValue: false,
                      onCheckBoxChange: (val) {},
                      showStatus: false,
                      contactItemStyle: mentionUserStyle,
                      onListItemPressed: onListItemPressed,);
                  }),
            ) : const Offstage();
          });
        }
    );
  }

}

class MentionController extends GetxController {
  ///All Group Members
  var groupMembers = List<ProfileDetails>.empty(growable: true).obs;

  ///Filtering group members based on search
  var filteredItems = List<ProfileDetails>.empty(growable: true).obs;

  ///Show or Hide the mention user list in the view
  var showMentionUserList = false.obs;

  var groupJid = "";
  void getGroupMembers(String groupJid) {
    this.groupJid = groupJid;
    if (Mirrorfly.isValidGroupJid(groupJid)) {
      Mirrorfly.getGroupMembersList(
          jid: groupJid,
          fetchFromServer: false,
          flyCallBack: (FlyResponse response) {
            if (response.isSuccess && response.hasData) {
              LogMessage.d("getGroupMembersList-->", response.toString());
              groupMembers(memberFromJson(response.data));
            }
          });
    } else {
      LogMessage.d("MentionController",
          "this is not a group so no need to get group members list");
    }
  }

  ///filter the group members from [groupMembers]
  ///with [triggerCharacter] and [query] of the search character
  void filterMentionUsers(String triggerCharacter, String? query) {
    if (query == null) {
      filteredItems.clear();
      showMentionUserList(false);
      return;
    }
    if (triggerCharacter == '@') {
      var groupMembersWithoutMe = groupMembers.where((item) =>
      item.jid != SessionManagement.getUserJID()).toList();

      // log('Mention detected: $keyword',name: "onMentionTextChanged");
      debugPrint("filterMentionUsers $query");
      if (query.isEmpty) {
        filteredItems(groupMembersWithoutMe);
        showMentionUserList(true);
      } else {
        var filter = groupMembersWithoutMe
            .where((item) => item.getName().toLowerCase().contains(query))
            .toList();
        debugPrint("filter ${filter.length}");
        filteredItems(filter);
        showMentionUserList(true);
      }
    } else {
      // log('No mention detected.',name: "onMentionTextChanged");
      filteredItems.clear();
      showMentionUserList(true);
    }
  }

  ///show or hide the list based the trigger character
  void showOrHideTagListView(bool show) {
    if (showMentionUserList.value != show) {
      filteredItems(groupMembers.where((item) => (item.jid !=
          SessionManagement.getUserJID())).toList());
      showMentionUserList(show);
    }
  }

  void sortGroupMembers(List<ProfileDetails> list){
    list.sort((a,b)=>a.getName().toLowerCase().compareTo(b.getName().toLowerCase()));
    groupMembers.value=(list);
    groupMembers.refresh();
  }

  void onNewMemberAddedToGroup({required String groupJid, required String newMemberJid, required String addedByMemberJid}) {
    if(this.groupJid==groupJid) {
      var index = groupMembers.indexWhere((element) => element.jid == newMemberJid);
      if(index.isNegative) {
        if(newMemberJid.checkNull().isNotEmpty) {
          getProfileDetails(newMemberJid).then((value) {
            List<ProfileDetails> list = [];//groupMembers;
            list.addAll(groupMembers);
            list.add(value);
            sortGroupMembers(list);
          });
        }
      }
    }
  }

  void onMemberRemovedFromGroup({required String groupJid, required String removedMemberJid, required String removedByMemberJid}) {
    if(this.groupJid==groupJid) {
        var index = groupMembers.indexWhere((element) => element.jid == removedMemberJid);
        var filterIndex = filteredItems.indexWhere((element) => element.jid == removedMemberJid);
        if(!index.isNegative) {
          debugPrint('user removed ${groupMembers[index].name}');
          groupMembers.removeAt(index);
          groupMembers.refresh();
        }
        if(!filterIndex.isNegative){
          filteredItems.removeAt(filterIndex);
        }
    }
  }
}