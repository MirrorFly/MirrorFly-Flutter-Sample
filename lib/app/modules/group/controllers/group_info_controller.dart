import 'dart:io';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirror_fly_demo/app/common/main_controller.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';
import 'package:mirror_fly_demo/app/extensions/extensions.dart';
import '../../../common/app_localizations.dart';
import '../../../common/crop_image.dart';
import '../../../data/apputils.dart';
import '../../../data/session_management.dart';
import '../../../routes/route_settings.dart';
import '../../dashboard/controllers/dashboard_controller.dart';
import '../views/name_change_view.dart';

class GroupInfoController extends GetxController {
  var availableFeatures = Get.find<MainController>().availableFeature;
  ScrollController scrollController = ScrollController();
  var groupMembers = <ProfileDetails>[].obs;
  final _mute = false.obs;
  set mute(value) => _mute.value=value;
  bool get mute => _mute.value;

  final _isAdmin = false.obs;
  set isAdmin(value) => _isAdmin.value=value;
  bool get isAdmin => _isAdmin.value;

  final _isMemberOfGroup = true.obs;
  set isMemberOfGroup(value) => _isMemberOfGroup.value = value;
  bool get isMemberOfGroup => availableFeatures.value.isGroupChatAvailable.checkNull() && _isMemberOfGroup.value;

  var profile_ = ProfileDetails().obs;
  //set profile(value) => _profile.value = value;
  ProfileDetails get profile => profile_.value;

  final _isSliverAppBarExpanded = true.obs;
  set isSliverAppBarExpanded(value) => _isSliverAppBarExpanded.value = value;
  bool get isSliverAppBarExpanded => _isSliverAppBarExpanded.value;
  final muteable = false.obs;
  @override
  void onInit(){
    super.onInit();
    profile_((Get.arguments as ProfileDetails));
    _mute(profile.isMuted!);
    scrollController.addListener(_scrollListener);
    getGroupMembers(false);
    // if(availableFeatures.value.isGroupChatAvailable.checkNull()){
      // getGroupMembers(null);
    // }
    groupAdmin();
    memberOfGroup();
    muteAble();
    nameController.text=profile.nickName.checkNull();
  }
  muteAble() async {
    muteable(await Mirrorfly.isChatUnArchived(jid: profile.jid.checkNull()));
  }

  void onGroupProfileUpdated(String groupJid) {
    if (groupJid.checkNull().isNotEmpty) {
      if (profile.jid.checkNull() == groupJid.toString()) {
        LogMessage.d("group info", groupJid.toString());
        getProfileDetails(profile.jid.checkNull()).then((value) {
          if (value.jid != null) {
            var member = value;//Profile.fromJson(json.decode(value.toString()));
            profile_(member);
            _mute(profile.isMuted!);
            nameController.text=profile.nickName.checkNull();
          }
        });
      }
    }
  }

  void userUpdatedHisProfile(String jid) {
    // debugPrint("userUpdatedHisProfile : $jid");
    if(jid.checkNull().isNotEmpty) {
      getProfileDetails(jid).then((value) {
        var index = groupMembers.indexWhere((element) => element.jid == jid);
        // debugPrint("profile : $index");
        if (!index.isNegative) {
          value.isGroupAdmin = groupMembers[index].isGroupAdmin;
          groupMembers[index] = value;
          groupMembers.refresh();
        }
      });
    }
  }

  void onLeftFromGroup({required String groupJid, required String userJid}) {
    if (profile.isGroupProfile.checkNull()) {
      if (groupJid == profile.jid) {
        var index = groupMembers.indexWhere((element) => element.jid == userJid);
        if(!index.isNegative) {
          debugPrint('user left ${groupMembers[index].name}');
          var isAdmin = groupMembers[index].isGroupAdmin;
          groupMembers.removeAt(index);
          if(isAdmin.checkNull()){
            getGroupMembers(false);
          }else {
            groupMembers.refresh();
          }
        }
      }
    }
  }

  void onMemberMadeAsAdmin({required String groupJid,
    required String newAdminMemberJid, required String madeByMemberJid}) {
    if (profile.isGroupProfile.checkNull()) {
      debugPrint('onMemberMadeAsAdmin $newAdminMemberJid');
      if (groupJid == profile.jid) {
        var index = groupMembers.indexWhere((element) => element.jid == newAdminMemberJid);
        if(!index.isNegative) {
          debugPrint('user admin ${groupMembers[index].name}');
          groupMembers[index].isGroupAdmin=true;
          groupMembers.refresh();
        }
      }
    }
  }

  void onMemberRemovedFromGroup({required String groupJid,
    required String removedMemberJid, required String removedByMemberJid}) {
    if (profile.isGroupProfile.checkNull()) {
      debugPrint('onMemberRemovedFromGroup $removedMemberJid');
      if (groupJid == profile.jid) {
        var index = groupMembers.indexWhere((element) => element.jid == removedMemberJid);
        if(!index.isNegative) {
          debugPrint('user removed ${groupMembers[index].name}');
          groupMembers.removeAt(index);
          groupMembers.refresh();
        }
        loadGroupExistence();
      }
    }
  }

  void onNewMemberAddedToGroup({required String groupJid,
    required String newMemberJid, required String addedByMemberJid}) {
    if (profile.isGroupProfile.checkNull()) {
      debugPrint('onNewMemberAddedToGroup $newMemberJid');
      if (groupJid == profile.jid) {
        var index = groupMembers.indexWhere((element) => element.jid == newMemberJid);
        if(index.isNegative) {
          if(newMemberJid.checkNull().isNotEmpty) {
            getProfileDetails(newMemberJid).then((value) {
              groupMembers.add(value);
              groupMembers.refresh();
            });
          }
        }
      }
    }
  }

  _scrollListener() {
    if (scrollController.hasClients) {
      _isSliverAppBarExpanded(scrollController.offset < (250 - kToolbarHeight));
      //Log("isSliverAppBarExpanded", isSliverAppBarExpanded.toString());
    }
  }
  groupAdmin(){
    Mirrorfly.isGroupAdmin(userJid: SessionManagement.getUserJID()! ,groupJid: profile.jid.checkNull()).then((bool? value){
      if(value!=null){
        _isAdmin(value);
      }
    });
  }
  memberOfGroup(){
    Mirrorfly.isMemberOfGroup(groupJid:profile.jid.checkNull(),userJid: SessionManagement.getUserJID().checkNull()).then((bool? value){
      if(value!=null){
        _isMemberOfGroup(value);
      }
    });
  }
  onToggleChange(bool value) async {
    if (isMemberOfGroup) {
      if (muteable.value) {
        LogMessage.d("change", value.toString());
        _mute(value);
        Mirrorfly.updateChatMuteStatus(jid:profile.jid.checkNull(), muteStatus: value);
        notifyDashboardUI();
      }
    }else{
      toToast(getTranslated("youAreNoLonger"));
    }
  }

  getGroupMembers(bool? server){
    Mirrorfly.getGroupMembersList(jid: profile.jid.checkNull(),fetchFromServer: server, flyCallBack: (FlyResponse response) {
      LogMessage.d("getGroupMembersList", response.data);
      if(response.isSuccess && response.hasData){
        var list = profileFromJson(response.data);
        list.sort((a, b) => (a.jid==SessionManagement.getUserJID()) ? 1 : (b.jid==SessionManagement.getUserJID()) ? -1 : 0);
        groupMembers.value=(list);
        groupMembers.refresh();
      }
    });
  }

  reportGroup(){
    if(!availableFeatures.value.isGroupChatAvailable.checkNull()){
      Helper.showFeatureUnavailable();
      return;
    }
    Helper.showAlert(title: getTranslated("reportThisGroup"),message: getTranslated("reportThisGroupContent"),actions: [
      TextButton(
          onPressed: () {
            Get.back();
          },
          child: Text(getTranslated("cancel").toUpperCase(),style: const TextStyle(color: buttonBgColor))),
      TextButton(
          onPressed: () {
            Get.back();
            Helper.progressLoading();
            Mirrorfly.reportUserOrMessages(jid: profile.jid.checkNull(),type: ChatType.groupChat, messageId: "", flyCallBack: (FlyResponse response) {
              Helper.hideLoading();
              if(response.isSuccess){
                toToast(getTranslated("reportSentSuccess"));
              }else{
                toToast(getTranslated("thereNoMessagesAvailable"));
              }
            });
          },
          child: Text(getTranslated("report").toUpperCase(),style: const TextStyle(color: buttonBgColor))),
    ]);
  }
  exitOrDeleteGroup(){
    if(!isMemberOfGroup){
      deleteGroup();
    }else{
      if(profile.isGroupProfile!) {
        leaveGroup();
      }
    }
  }
  leaveGroup(){
    if(!availableFeatures.value.isGroupChatAvailable.checkNull()){
      Helper.showFeatureUnavailable();
      return;
    }
    Helper.showAlert(message: getTranslated("areYouLeaveGroup"),actions: [
      TextButton(
          onPressed: () {
            Get.back();
          },
          child: Text(getTranslated("cancel").toUpperCase(),style: const TextStyle(color: buttonBgColor))),
      TextButton(
          onPressed: () {
            Get.back();
            exitFromGroup();
          },
          child: Text(getTranslated("leave").toUpperCase(),style: const TextStyle(color: buttonBgColor))),
    ]);
  }
  var leavedGroup = false.obs;
  exitFromGroup()async{
    if(!availableFeatures.value.isGroupChatAvailable.checkNull()){
      Helper.showFeatureUnavailable();
      return;
    }
    if(await AppUtils.isNetConnected()) {
      Helper.progressLoading();
      Mirrorfly.leaveFromGroup(userJid: SessionManagement.getUserJID().checkNull() ,groupJid: profile.jid.checkNull(), flyCallBack: (FlyResponse response) {
        Helper.hideLoading();
        if(response.isSuccess){
          _isMemberOfGroup(!response.isSuccess);
          leavedGroup(response.isSuccess);
        }else{
          toToast(getTranslated("errorTryAgain"));
        }
      });
    }else{
      toToast(getTranslated("noInternetConnection"));
    }
  }
  deleteGroup(){
    if(!availableFeatures.value.isGroupChatAvailable.checkNull() || !availableFeatures.value.isDeleteChatAvailable.checkNull()){
      Helper.showFeatureUnavailable();
      return;
    }
    Helper.showAlert(message: getTranslated("areYouDeleteGroup"),actions: [
      TextButton(
          onPressed: () {
            Get.back();
          },
          child: Text(getTranslated("cancel").toUpperCase(),style: const TextStyle(color: buttonBgColor))),
      TextButton(
          onPressed: () async {
            if(await AppUtils.isNetConnected()) {
              Get.back();
              if(!availableFeatures.value.isGroupChatAvailable.checkNull() || !availableFeatures.value.isDeleteChatAvailable.checkNull()){
                Helper.showFeatureUnavailable();
                return;
              }
              Helper.progressLoading();
              Mirrorfly.deleteGroup(jid: profile.jid.checkNull(), flyCallBack: (FlyResponse response) {
                Helper.hideLoading();
                if(response.isSuccess){
                  Get.offAllNamed(Routes.dashboard);
                }else{
                  toToast(getTranslated("errorTryAgain"));
                }
              });
            }else{
              toToast(getTranslated("noInternetConnection"));
            }

          },
          child: Text(getTranslated("delete").toUpperCase(),style: const TextStyle(color: buttonBgColor))),
    ]);
  }

  var imagePath = "".obs;
  Future imagePicker(BuildContext context) async {
    if(await AppUtils.isNetConnected()) {
      FilePickerResult? result = await FilePicker.platform
          .pickFiles(allowMultiple: false, type: FileType.image);
      if (result != null) {
        Get.to(CropImage(
          imageFile: File(result.files.single.path!),
        ))?.then((value) {
          value as MemoryImage;
          var name = "${DateTime.now().millisecondsSinceEpoch}.jpg";
          writeImageTemp(value.bytes, name).then((value) {
            imagePath(value.path);
            updateGroupProfileImage(value.path);
          });
        });
      } else {
        // User canceled the picker
      }
    }else{
      toToast(getTranslated("noInternetConnection"));
    }
  }

  final ImagePicker _picker = ImagePicker();
  camera() async {
    if(!availableFeatures.value.isGroupChatAvailable.checkNull()){
      Helper.showFeatureUnavailable();
      return;
    }
    if(await AppUtils.isNetConnected()) {
      final XFile? photo = await _picker.pickImage(
          source: ImageSource.camera);
      if (photo != null) {
        Get.to(CropImage(
          imageFile: File(photo.path),
        ))?.then((value) {
          value as MemoryImage;
          var name = "${DateTime.now().millisecondsSinceEpoch}.jpg";
          writeImageTemp(value.bytes, name).then((value) {
            imagePath(value.path);
            updateGroupProfileImage(value.path);
          });
        });
      } else {
        // User canceled the Camera
      }
    }else{
      toToast(getTranslated("noInternetConnection"));
    }
  }

  updateGroupProfileImage(String path){
    if(!availableFeatures.value.isGroupChatAvailable.checkNull()){
      Helper.showFeatureUnavailable();
      return;
    }
    showLoader();
    Mirrorfly.updateGroupProfileImage(jid:profile.jid.checkNull(),file: path, flyCallBack: (FlyResponse response) {
      hideLoader();
      if(response.isSuccess){
        profile_.value.image=path;
        profile_.refresh();
      }
    });
  }

  updateGroupName(String name){
    if(!availableFeatures.value.isGroupChatAvailable.checkNull()){
      Helper.showFeatureUnavailable();
      return;
    }
    showLoader();
    Mirrorfly.updateGroupName(jid: profile.jid.checkNull(),name: name, flyCallBack: (FlyResponse response) {
      hideLoader();
      if(response.isSuccess){
        profile_.value.name = name;
        profile_.value.nickName = name;
        profile_.refresh();
      }
    });
  }

  removeProfileImage() {
    Helper.showAlert(message: getTranslated("areYouRemoveGroupPhoto"),actions: [
      TextButton(
          onPressed: () {
            Get.back();
          },
          child: Text(getTranslated("cancel").toUpperCase(),style: const TextStyle(color: buttonBgColor))),
      TextButton(
          onPressed: () {
            Get.back();
            revokeAccessForProfileImage();
          },
          child: Text(getTranslated("remove").toUpperCase(),style: const TextStyle(color: buttonBgColor))),
    ]);
  }

  revokeAccessForProfileImage()async{
    if(!availableFeatures.value.isGroupChatAvailable.checkNull()){
      Helper.showFeatureUnavailable();
      return;
    }
    if(await AppUtils.isNetConnected()) {
      showLoader();
      Mirrorfly.removeGroupProfileImage(jid: profile.jid.checkNull(), flyCallBack: (FlyResponse response) {
        hideLoader();
        if (response.isSuccess) {
          profile_.value.image=Constants.emptyString;
          profile_.refresh();
        }
      });
    }else{
      toToast(getTranslated("noInternetConnection"));
    }
  }

  showLoader(){
    Helper.progressLoading();
  }
  hideLoader(){
    Helper.hideLoading();
  }

  gotoAddParticipants(){
    if(!availableFeatures.value.isGroupChatAvailable.checkNull()){
      Helper.showFeatureUnavailable();
      return;
    }
    Get.toNamed(Routes.contacts, arguments: {"forward" : false,"group":true,"groupJid":profile.jid })?.then((value){
      if(value!=null){
        addUsers(value);
      }
    });
  }

  addUsers(dynamic value)async{
    if(await AppUtils.isNetConnected()) {
      showLoader();
      Mirrorfly.addUsersToGroup(jid: profile.jid.checkNull(),userList: value as List<String>, flyCallBack: (FlyResponse response) {
        hideLoader();
        if(response.isSuccess){
          //getGroupMembers(false);
        }else{
          toToast(getTranslated("errorWhileAddingMember"));
        }
      });
    }else{
      toToast(getTranslated("noInternetConnection"));
    }
  }

  gotoViewAllMedia(){
    Get.toNamed(Routes.viewMedia,arguments: {"name":profile.name,"jid":profile.jid,"isgroup":profile.isGroupProfile});
  }

  removeUser(String userJid) async {
    if(!availableFeatures.value.isGroupChatAvailable.checkNull()){
      Helper.showFeatureUnavailable();
      return;
    }
    if(isMemberOfGroup){
      if(await AppUtils.isNetConnected()) {
        showLoader();
        Mirrorfly.removeMemberFromGroup(groupJid: profile.jid.checkNull(), userJid: userJid, flyCallBack: (FlyResponse response) {
          hideLoader();
          if(response.isSuccess){
            //getGroupMembers(false);
          }else{
            toToast(getTranslated("errorWhileRemovingMember"));
          }
        });
      }else{
        toToast(getTranslated("noInternetConnection"));
      }
    }else{
      toToast(getTranslated("youAreNoLonger"));
    }
  }

  makeAdmin(String userJid) async {
    if(!availableFeatures.value.isGroupChatAvailable.checkNull()){
      Helper.showFeatureUnavailable();
      return;
    }
    if(isMemberOfGroup){
      if(await AppUtils.isNetConnected()) {
        showLoader();
        Mirrorfly.makeAdmin(groupJid: profile.jid.checkNull(),userJid: userJid, flyCallBack: (FlyResponse response) {
          hideLoader();
          if(response.isSuccess){
            //getGroupMembers(false);
          }else{
            toToast(getTranslated("errorWhileMakeAdmin"));
          }
        });
      }else{
        toToast(getTranslated("noInternetConnection"));
      }
    }else{
      toToast(getTranslated("youAreNoLonger"));
    }
  }

  //New Name Change
  gotoNameEdit(){
    if(!availableFeatures.value.isGroupChatAvailable.checkNull()){
      Helper.showFeatureUnavailable();
      return;
    }
    if(isMemberOfGroup) {
      Get.to(const NameChangeView())?.then((value) {
        if (value != null) {
          updateGroupName(nameController.text);
        }
      });
    }else{
      toToast(getTranslated("youAreNoLonger"));
    }
  }
  var nameController = TextEditingController();
  FocusNode focusNode = FocusNode();
  var showEmoji = false.obs;
  var count= 25.obs;

  onChanged(){
    count.value = (25 - nameController.text.length);
  }

  onEmojiBackPressed(){
    var text = nameController.text;
    var cursorPosition = nameController.selection.base.offset;

    // If cursor is not set, then place it at the end of the textfield
    if (cursorPosition < 0) {
      nameController.selection = TextSelection(
        baseOffset: nameController.text.length,
        extentOffset: nameController.text.length,
      );
      cursorPosition = nameController.selection.base.offset;
    }

    if (cursorPosition >= 0) {
      final selection = nameController.value.selection;
      final newTextBeforeCursor =
      selection.textBefore(text).characters.skipLast(1).toString();
      LogMessage.d("newTextBeforeCursor", newTextBeforeCursor);
      nameController
        ..text = newTextBeforeCursor + selection.textAfter(text)
        ..selection = TextSelection.fromPosition(
            TextPosition(offset: newTextBeforeCursor.length));
    }
    count((25 - nameController.text.characters.length));
  }

  onEmojiSelected(Emoji emoji){
    if(nameController.text.characters.length < 25){
      final controller = nameController;
      final text = controller.text;
      final selection = controller.selection;
      final cursorPosition = controller.selection.base.offset;

      if (cursorPosition < 0) {
        controller.text += emoji.emoji;
        // widget.onEmojiSelected?.call(category, emoji);
        return;
      }

      final newText =
      text.replaceRange(selection.start, selection.end, emoji.emoji);
      final emojiLength = emoji.emoji.length;
      controller
        ..text = newText
        ..selection = selection.copyWith(
          baseOffset: selection.start + emojiLength,
          extentOffset: selection.start + emojiLength,
        );
    }
    count((25 - nameController.text.characters.length));
  }

  showHideEmoji(BuildContext context){
    if (!showEmoji.value) {
      focusNode.unfocus();
    }else{
      focusNode.requestFocus();
      return;
    }
    Future.delayed(const Duration(milliseconds: 500), () {
      showEmoji(!showEmoji.value);
    });
  }

  void userDeletedHisProfile(String jid) {
    userUpdatedHisProfile(jid);
  }

  void loadGroupExistence() {
    memberOfGroup();
  }

  void unblockedThisUser(String jid) {
    userUpdatedHisProfile(jid);
  }

  void userBlockedMe(String jid) {
    userUpdatedHisProfile(jid);
  }

  void onAvailableFeaturesUpdated(AvailableFeatures features) {
    LogMessage.d("GroupInfo", "onAvailableFeaturesUpdated ${features.toJson()}");
    availableFeatures(features);
    _isMemberOfGroup.refresh();
    // loadGroupExistence();
  }
  void notifyDashboardUI(){
    if(Get.isRegistered<DashboardController>()){
      Get.find<DashboardController>().chatMuteChangesNotifyUI(profile.jid.checkNull());
    }
  }

  onBackPressed() {
    if (showEmoji.value) {
      showEmoji(false);
    } else {
      nameController.text = profile.nickName.checkNull();
      Get.back();
    }
  }
}
