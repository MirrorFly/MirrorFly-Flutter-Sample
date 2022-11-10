import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meta/meta.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';
import 'package:mirror_fly_demo/app/nativecall/platformRepo.dart';

import '../../../common/cropimage.dart';
import '../../../model/groupmembers_model.dart';
import '../../../model/userlistModel.dart';
import '../../../routes/app_pages.dart';
import '../views/namechange_view.dart';

class GroupInfoController extends GetxController {
  ScrollController scrollController = ScrollController();
  var groupMembers = <Member>[].obs;
  var _mute = false.obs;
  set mute(value) => _mute.value=value;
  bool get mute => _mute.value;

  var _isAdmin = false.obs;
  set isAdmin(value) => _isAdmin.value=value;
  bool get isAdmin => _isAdmin.value;

  var _isMemberOfGroup = true.obs;
  set isMemberOfGroup(value) => _isMemberOfGroup.value=value;
  bool get isMemberOfGroup => _isMemberOfGroup.value;

  var profile_ = Profile().obs;
  //set profile(value) => _profile.value = value;
  Profile get profile => profile_.value;

  final _isSliverAppBarExpanded = true.obs;
  set isSliverAppBarExpanded(value) => _isSliverAppBarExpanded.value = value;
  bool get isSliverAppBarExpanded => _isSliverAppBarExpanded.value;

  @override
  void onInit(){
    super.onInit();
    profile_((Get.arguments as Profile));
    _mute(profile.isMuted!);
    scrollController.addListener(_scrollListener);
    getGroupMembers(false);
    getGroupMembers(null);
    groupAdmin();
    MemberOfGroup();

    namecontroller.text=profile.nickName.checkNull();
  }
  _scrollListener() {
    if (scrollController.hasClients) {
      _isSliverAppBarExpanded(scrollController.offset < (250 - kToolbarHeight));
      //Log("isSliverAppBarExpanded", isSliverAppBarExpanded.toString());
    }
  }
  groupAdmin(){
    PlatformRepo().isAdmin(profile.jid.checkNull()).then((bool? value){
      if(value!=null){
        _isAdmin(value);
      }
    });
  }
  MemberOfGroup(){
    PlatformRepo().isMemberOfGroup(profile.jid.checkNull(),null).then((bool? value){
      if(value!=null){
        _isMemberOfGroup(value);
      }
    });
  }
  onToggleChange(bool value){
    Log("change", value.toString());
    _mute(value);
    PlatformRepo().groupMute(profile.jid.checkNull(),value);
  }

  getGroupMembers(bool? server){
    PlatformRepo().getGroupMembers(profile.jid.checkNull(),server).then((value) {
      if(value!=null){
        var list = memberFromJson(value);
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
            PlatformRepo().reportUserOrMessages(profile.jid.checkNull(),Constants.TYPE_GROUP_CHAT).then((value) {
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
            Helper.progressLoading();
            PlatformRepo().leaveFromGroup(profile.jid.checkNull()).then((value) {
              Helper.hideLoading();
              if(value!=null){
                if(value){
                  _isMemberOfGroup(!value);
                }
              }
            }).catchError((error) {
              Helper.hideLoading();
            });
          },
          child: const Text("LEAVE")),
    ]);
  }
  deleteGroup(){
    Helper.showAlert(message: "Are you sure you want to delete this group?.",actions: [
      TextButton(
          onPressed: () {
            Get.back();
          },
          child: const Text("CANCEL")),
      TextButton(
          onPressed: () {
            Get.back();
            Helper.progressLoading();
            PlatformRepo().deleteGroup(profile.jid.checkNull()).then((value) {
              Helper.hideLoading();
              if(value!=null){
                if(value){
                  Get.offAllNamed(Routes.DASHBOARD);
                }
              }
            }).catchError((error) {
              Helper.hideLoading();
            });
          },
          child: const Text("DELETE")),
    ]);
  }

  var imagepath = "".obs;
  Future ImagePicker(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(allowMultiple: false, type: FileType.image);
    if (result != null) {
      Get.to(CropImage(
        imageFile: File(result.files.single.path!),
      ))?.then((value) {
        value as MemoryImage;
        var name = "${DateTime.now().millisecondsSinceEpoch}.jpg";
        writeImageTemp(value.bytes, name).then((value) {
            imagepath(value.path);
            updateGroupProfileImage(value.path);
        });
      });
    } else {
      // User canceled the picker
    }
  }

  Camera(XFile? result) {
    if (result != null) {
      Get.to(CropImage(
        imageFile: File(result.path),
      ))?.then((value) {
        value as MemoryImage;
        var name = "${DateTime.now().millisecondsSinceEpoch}.jpg";
        writeImageTemp(value.bytes, name).then((value) {
            imagepath(value.path);
            updateGroupProfileImage(value.path);
        });
      });
    } else {
      // User canceled the Camera
    }
  }

  updateGroupProfileImage(String path){
    showLoader();
    PlatformRepo().updateGroupProfileImage(profile.jid.checkNull(),path).then((bool? value){
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
    PlatformRepo().updateGroupName(profile.jid.checkNull(),name).then((bool? value){
      hideLoader();
      if(value!=null){
        if(value){
          profile_.value.name=name;
          profile_.value.nickName=name;
          profile_.refresh();
        }
      }
    });
  }

  remomveProfileImage() {
    Helper.showAlert(message: "Are you sure you want to remove the group photo?.",actions: [
      TextButton(
          onPressed: () {
            Get.back();
          },
          child: const Text("CANCEL")),
      TextButton(
          onPressed: () {
            Get.back();
            showLoader();
            PlatformRepo().removeGroupProfileImage(profile.jid.checkNull()).then((bool? value) {
              hideLoader();
              if (value != null) {
                if(value){
                  profile_.value.image=Constants.EMPTY_STRING;
                  profile_.refresh();
                }
              }
            }).catchError((onError) {
              hideLoader();
            });
          },
          child: const Text("REMOVE")),
    ]);
  }

  showLoader(){
    Helper.progressLoading();
  }
  hideLoader(){
    Helper.hideLoading();
  }

  gotoAddParticipants(){
    Get.toNamed(Routes.CONTACTS, arguments: {"forward" : false,"group":true,"groupJid":profile.jid })?.then((value){
      if(value!=null){
        showLoader();
        PlatformRepo().addUsersToGroup(profile.jid.checkNull(),value as List<String>).then((value){
          hideLoader();
          if(value!=null && value){
            getGroupMembers(false);
          }else{
            toToast("Error while adding Members in this group");
          }
        });
      }
    });
  }

  removeUser(String userjid){
    if(isMemberOfGroup){
      showLoader();
      PlatformRepo().removeMemberFromGroup(profile.jid.checkNull(), userjid).then((value){
        hideLoader();
        if(value!=null && value){
          getGroupMembers(false);
        }else{
          toToast("Error while Removing this member");
        }
      });
    }
  }

  makeAdmin(String userjid){
    if(isMemberOfGroup){
      showLoader();
      PlatformRepo().makeAdmin(profile.jid.checkNull(), userjid).then((value){
        hideLoader();
        if(value!=null && value){
          getGroupMembers(false);
        }else{
          toToast("Error while make admin this member");
        }
      });
    }
  }

  //New Name Change
  gotoNameEdit(){
    if(isMemberOfGroup) {
      Get.to(NameChangeView())?.then((value) {
        if (value != null) {
          updateGroupName(namecontroller.text);
        }
      });
    }else{
      toToast("You're no longer a participant in this group");
    }
  }
  var namecontroller = TextEditingController();
  FocusNode focusNode = FocusNode();
  var showEmoji = false.obs;
  var count= 25.obs;

  onChanged(){
    count.value = (25 - namecontroller.text.length);
  }
}
