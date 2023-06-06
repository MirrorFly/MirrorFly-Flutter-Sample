import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';

import '../../../common/crop_image.dart';
import '../../../data/apputils.dart';
import '../../../data/session_management.dart';
import '../../../routes/app_pages.dart';
import '../views/name_change_view.dart';

class GroupInfoController extends GetxController {
  ScrollController scrollController = ScrollController();
  var groupMembers = <Profile>[].obs;
  final _mute = false.obs;
  set mute(value) => _mute.value=value;
  bool get mute => _mute.value;

  final _isAdmin = false.obs;
  set isAdmin(value) => _isAdmin.value=value;
  bool get isAdmin => _isAdmin.value;

  final _isMemberOfGroup = true.obs;
  set isMemberOfGroup(value) => _isMemberOfGroup.value=value;
  bool get isMemberOfGroup => _isMemberOfGroup.value;

  var profile_ = Profile().obs;
  //set profile(value) => _profile.value = value;
  Profile get profile => profile_.value;

  final _isSliverAppBarExpanded = true.obs;
  set isSliverAppBarExpanded(value) => _isSliverAppBarExpanded.value = value;
  bool get isSliverAppBarExpanded => _isSliverAppBarExpanded.value;
  final muteable = false.obs;
  @override
  void onInit(){
    super.onInit();
    profile_((Get.arguments as Profile));
    _mute(profile.isMuted!);
    scrollController.addListener(_scrollListener);
    getGroupMembers(false);
    getGroupMembers(null);
    groupAdmin();
    memberOfGroup();
    muteAble();
    nameController.text=profile.nickName.checkNull();
  }
  muteAble() async {
    muteable(await Mirrorfly.isUserUnArchived(profile.jid.checkNull()));
  }

  void onGroupProfileUpdated(String groupJid) {
    if (groupJid.checkNull().isNotEmpty) {
      if (profile.jid.checkNull() == groupJid.toString()) {
        mirrorFlyLog("group info", groupJid.toString());
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
    Mirrorfly.isAdmin(SessionManagement.getUserJID()! ,profile.jid.checkNull()).then((bool? value){
      if(value!=null){
        _isAdmin(value);
      }
    });
  }
  memberOfGroup(){
    Mirrorfly.isMemberOfGroup(profile.jid.checkNull(),null).then((bool? value){
      if(value!=null){
        _isMemberOfGroup(value);
      }
    });
  }
  onToggleChange(bool value){
    if(muteable.value) {
      mirrorFlyLog("change", value.toString());
      _mute(value);
      Mirrorfly.updateChatMuteStatus(profile.jid.checkNull(), value);
    }
  }

  getGroupMembers(bool? server){
    Mirrorfly.getGroupMembersList(profile.jid.checkNull(),server).then((value) {
      mirrorFlyLog("getGroupMembersList", value);
      if(value!=null){
        var list = profileFromJson(value);
        groupMembers.value=(list);
        groupMembers.refresh();
      }
    });
  }

  reportGroup(){
    Helper.showAlert(title: "Report this group?",message: "The last 5 messages from this group will be forwarded to admin. No one in this group will be notified.",actions: [
      TextButton(
          onPressed: () {
            Get.back();
          },
          child: const Text("CANCEL")),
      TextButton(
          onPressed: () {
            Get.back();
            Helper.progressLoading();
            Mirrorfly.reportUserOrMessages(profile.jid.checkNull(),Constants.typeGroupChat, "").then((value) {
              Helper.hideLoading();
              if(value!=null){
                if(value){
                  toToast("Report sent");
                }else{
                  toToast("There are no messages available");
                }
              }
            }).catchError((error) {
              Helper.hideLoading();
            });
          },
          child: const Text("REPORT")),
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
    Helper.showAlert(message: "Are you sure you want to leave from group?.",actions: [
      TextButton(
          onPressed: () {
            Get.back();
          },
          child: const Text("CANCEL")),
      TextButton(
          onPressed: () {
            Get.back();
            exitFromGroup();
          },
          child: const Text("LEAVE")),
    ]);
  }
  exitFromGroup()async{
    if(await AppUtils.isNetConnected()) {
      Helper.progressLoading();
      Mirrorfly.leaveFromGroup(SessionManagement.getUserJID() ,profile.jid.checkNull()).then((value) {
        Helper.hideLoading();
        if(value!=null){
          if(value){
            _isMemberOfGroup(!value);
          }
        }
      }).catchError((error) {
        Helper.hideLoading();
      });
    }else{
      toToast(Constants.noInternetConnection);
    }
  }
  deleteGroup(){
    Helper.showAlert(message: "Are you sure you want to delete this group?.",actions: [
      TextButton(
          onPressed: () {
            Get.back();
          },
          child: const Text("CANCEL")),
      TextButton(
          onPressed: () async {
            if(await AppUtils.isNetConnected()) {
              Get.back();
              Helper.progressLoading();
              Mirrorfly.deleteGroup(profile.jid.checkNull()).then((value) {
                Helper.hideLoading();
                if(value!=null){
                  if(value){
                    Get.offAllNamed(Routes.dashboard);
                  }
                }
              }).catchError((error) {
                Helper.hideLoading();
              });
            }else{
              toToast(Constants.noInternetConnection);
            }

          },
          child: const Text("DELETE")),
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
      toToast(Constants.noInternetConnection);
    }
  }

  final ImagePicker _picker = ImagePicker();
  camera() async {
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
      toToast(Constants.noInternetConnection);
    }
  }

  updateGroupProfileImage(String path){
    showLoader();
    Mirrorfly.updateGroupProfileImage(profile.jid.checkNull(),path).then((bool? value){
      hideLoader();
      if(value!=null){
        if(value){
          profile_.value.image=path;
          profile_.refresh();
        }
      }
    });
  }

  updateGroupName(String name){
    showLoader();
    Mirrorfly.updateGroupName(profile.jid.checkNull(),name).then((bool? value){
      hideLoader();
      if(value!=null){
        if(value){
          profile_.value.name = name;
          profile_.value.nickName = name;
          profile_.refresh();
        }
      }
    });
  }

  removeProfileImage() {
    Helper.showAlert(message: "Are you sure you want to remove the group photo?",actions: [
      TextButton(
          onPressed: () {
            Get.back();
          },
          child: const Text("CANCEL")),
      TextButton(
          onPressed: () {
            Get.back();
            revokeAccessForProfileImage();
          },
          child: const Text("REMOVE")),
    ]);
  }

  revokeAccessForProfileImage()async{
    if(await AppUtils.isNetConnected()) {
      showLoader();
      Mirrorfly.removeGroupProfileImage(profile.jid.checkNull()).then((bool? value) {
        hideLoader();
        if (value != null) {
          if(value){
            profile_.value.image=Constants.emptyString;
            profile_.refresh();
          }
        }
      }).catchError((onError) {
        hideLoader();
      });
    }else{
      toToast(Constants.noInternetConnection);
    }
  }

  showLoader(){
    Helper.progressLoading();
  }
  hideLoader(){
    Helper.hideLoading();
  }

  gotoAddParticipants(){
    Get.toNamed(Routes.contacts, arguments: {"forward" : false,"group":true,"groupJid":profile.jid })?.then((value){
      if(value!=null){
        addUsers(value);
      }
    });
  }

  addUsers(dynamic value)async{
    if(await AppUtils.isNetConnected()) {
      showLoader();
      Mirrorfly.addUsersToGroup(profile.jid.checkNull(),value as List<String>).then((value){
        hideLoader();
        if(value!=null && value){
          //getGroupMembers(false);
        }else{
          toToast("Error while adding Members in this group");
        }
      });
    }else{
      toToast(Constants.noInternetConnection);
    }
  }

  gotoViewAllMedia(){
    Get.toNamed(Routes.viewMedia,arguments: {"name":profile.name,"jid":profile.jid,"isgroup":profile.isGroupProfile});
  }

  removeUser(String userJid) async {
    if(isMemberOfGroup){
      if(await AppUtils.isNetConnected()) {
        showLoader();
        Mirrorfly.removeMemberFromGroup(profile.jid.checkNull(), userJid).then((value){
          hideLoader();
          if(value!=null && value){
            //getGroupMembers(false);
          }else{
            toToast("Error while Removing this member");
          }
        });
      }else{
        toToast(Constants.noInternetConnection);
      }
    }
  }

  makeAdmin(String userJid) async {
    if(isMemberOfGroup){
      if(await AppUtils.isNetConnected()) {
        showLoader();
        Mirrorfly.makeAdmin(profile.jid.checkNull(), userJid).then((value){
          hideLoader();
          if(value!=null && value){
            //getGroupMembers(false);
          }else{
            toToast("Error while make admin this member");
          }
        });
      }else{
        toToast(Constants.noInternetConnection);
      }
    }
  }

  //New Name Change
  gotoNameEdit(){
    if(isMemberOfGroup) {
      Get.to(const NameChangeView())?.then((value) {
        if (value != null) {
          updateGroupName(nameController.text);
        }
      });
    }else{
      toToast("You're no longer a participant in this group");
    }
  }
  var nameController = TextEditingController();
  FocusNode focusNode = FocusNode();
  var showEmoji = false.obs;
  var count= 25.obs;

  onChanged(){
    count.value = (25 - nameController.text.length);
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
}
