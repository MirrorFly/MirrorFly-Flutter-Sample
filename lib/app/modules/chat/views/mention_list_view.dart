import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/data/utils.dart';
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
    controller.initListeners();
    super.onInit();
  }


  @override
  Widget build(BuildContext context) {
    return KeyboardVisibilityBuilder(
        builder: (context, isKeyboardVisible) {
          LogMessage.d("KeyboardVisibilityBuilder","isKeyboardVisible:$isKeyboardVisible");
          final double height = NavUtils.size.height;
          // LogMessage.d("KeyboardVisibilityBuilder","height:$height ${height * 0.7}");
          // final double currentKeyboardHeight = MediaQuery.of(context).viewInsets.bottom;
          // LogMessage.d("KeyboardVisibilityBuilder","currentKeyboardHeight:$currentKeyboardHeight");

          return Obx(() {
            return controller.filteredItems.isNotEmpty &&
                controller.showMentionUserList.value ? ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: getHeight(isKeyboardVisible,height,controller.filteredItems.length)),
                  child: Container(
                    decoration: mentionUserBgDecoration,
                    //             height: isKeyboardVisible
                    // ? controller.filteredItems.length > 2  ? 100 : null
                    // : null,
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
                              ),
                ) : const Offstage();
          });
        }
    );
  }

  double getHeight(bool isKeyboardVisible,double height,int count){
    if(isKeyboardVisible){
      if(height<641){
        //small mobiles
        return 100;
      }else if(height<801){
        //medium mobiles
        return 200;
      }else{
        return 250;
      }
    }else{
      return height * 0.4;
    }
  }

}

class MentionController extends GetxController {
  ///All Group Members
  var groupMembers = List<ProfileDetails>.empty(growable: true).obs;

  ///Filtering group members based on search
  var filteredItems = List<ProfileDetails>.empty(growable: true).obs;

  ///Show or Hide the mention user list in the view
  var showMentionUserList = false.obs;
  Rx<String> mTriggerCharacter="".obs;
  Rx<String?> mQuery="".obs;

  StreamSubscription? _newMemberAddedSubscription;
  StreamSubscription? _memberRemovedSubscription;

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
              sortGroupMembers(memberFromJson(response.data));
            }
          });
    } else {
      LogMessage.d("MentionController",
          "this is not a group so no need to get group members list");
    }
  }

  void initListeners() {
    _newMemberAddedSubscription = Mirrorfly.onNewMemberAddedToGroup.listen((event) {
      if (event != null) {
        var data = json.decode(event.toString());
        var groupJid = data["groupJid"] ?? "";
        var newMemberJid = data["newMemberJid"] ?? "";
        var addedByMemberJid = data["addedByMemberJid"] ?? "";
          onNewMemberAddedToGroup(
            groupJid: groupJid,
            newMemberJid: newMemberJid,
            addedByMemberJid: addedByMemberJid,
          );
      }
    });

    _memberRemovedSubscription = Mirrorfly.onMemberRemovedFromGroup.listen((event) {
      if (event != null) {
        var data = json.decode(event.toString());
        var groupJid = data["groupJid"] ?? "";
        var removedMemberJid = data["removedMemberJid"] ?? "";
        var removedByMemberJid = data["removedByMemberJid"] ?? "";
        onMemberRemovedFromGroup(
          groupJid: groupJid,
          removedMemberJid: removedMemberJid,
          removedByMemberJid: removedByMemberJid,
        );
      }
    });
  }

  @override
  void onClose() {
    super.onClose();
    _memberRemovedSubscription?.cancel();
    _newMemberAddedSubscription?.cancel();
  }

  ///filter the group members from [groupMembers]
  ///with [triggerCharacter] and [query] of the search character
  void filterMentionUsers(String triggerCharacter, String? query) {
    if (query == null) {
      filteredItems.clear();
      showMentionUserList(false);
      mTriggerCharacter("");
      mQuery(null);
      return;
    }
    mTriggerCharacter(triggerCharacter);
    mQuery(query);
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
            .where((item) => item.getName().toLowerCase().contains(query.toLowerCase()))
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

  void sortGroupMembers(List<ProfileDetails>list){
    list.sort((a,b)=>a.getName().toLowerCase().compareTo(b.getName().toLowerCase()));
    groupMembers.value=(list);
    groupMembers.refresh();
    if(mQuery.value != null ) {
      filterMentionUsers(mTriggerCharacter.value, mQuery.value);
    }
  }

  void onNewMemberAddedToGroup({required String groupJid, required String newMemberJid, required String addedByMemberJid}) {
    if(this.groupJid==groupJid) {
      var index = groupMembers.indexWhere((element) => element.jid == newMemberJid);
      if(index.isNegative) {
        if(newMemberJid.checkNull().isNotEmpty) {
          getProfileDetails(newMemberJid).then((value) {
            List<ProfileDetails> list = [];//groupMembers;
            list.addAll(groupMembers);
            if(!list.any((element) => element.jid ==value.jid,)) {
              list.add(value);
            }
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