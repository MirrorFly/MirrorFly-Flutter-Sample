import 'dart:convert';

import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';

import 'nativecall/fly_chat.dart';

abstract class BaseController extends GetxController {

  final _obj = ''.obs;
  set obj(value) => _obj.value = value;
  get obj => _obj.value;

  @override
  void onInit() {
    super.onInit();
    initListeners();
  }


  initListeners(){
    FlyChat.onMessageReceived.listen(onMessageReceived);
    FlyChat.onMessageStatusUpdated.listen(onMessageStatusUpdated);
    FlyChat.onMediaStatusUpdated.listen(onMediaStatusUpdated);

    FlyChat.onGroupProfileFetched.listen(onGroupProfileFetched);
    FlyChat.onNewGroupCreated.listen(onNewGroupCreated);
    FlyChat.onGroupProfileUpdated.listen(onGroupProfileUpdated);
    FlyChat.onNewMemberAddedToGroup.listen(onNewMemberAddedToGroup);
    FlyChat.onMemberRemovedFromGroup.listen(onMemberRemovedFromGroup);
    FlyChat.onFetchingGroupMembersCompleted.listen(onFetchingGroupMembersCompleted);
    FlyChat.onDeleteGroup.listen(onDeleteGroup);
    FlyChat.onFetchingGroupListCompleted.listen(onFetchingGroupListCompleted);
    FlyChat.onMemberMadeAsAdmin.listen(onMemberMadeAsAdmin);
    FlyChat.onMemberRemovedAsAdmin.listen(onMemberRemovedAsAdmin);
    FlyChat.onLeftFromGroup.listen((event){
      if(event!=null) {
        var data = json.decode(event.toString());
        var groupJid = data["groupJid"] ?? "";
        var leftUserJid = data["leftUserJid"] ?? "";
        onLeftFromGroup(groupJid: groupJid,userJid: leftUserJid);
      }
    });
    FlyChat.onGroupNotificationMessage.listen(onGroupNotificationMessage);
    FlyChat.onGroupDeletedLocally.listen(onGroupDeletedLocally);
  }

  void onMessageReceived(chatMessage){
    //Log("flutter onMessageReceived", ChatMessage.toString());
  }
  void onMessageStatusUpdated(event){
    //Log("flutter onMessageStatusUpdated", event.toString());
  }
  void onMediaStatusUpdated(event){

  }
  void onGroupProfileFetched(groupJid){

  }
  void onNewGroupCreated(groupJid){

  }
  void onGroupProfileUpdated(groupJid){
    Log("flutter GroupProfileUpdated", groupJid.toString());
  }
  void onNewMemberAddedToGroup(event){

  }
  void onMemberRemovedFromGroup(event){

  }
  void onFetchingGroupMembersCompleted(groupJid){

  }
  void onDeleteGroup(groupJid){

  }
  void onFetchingGroupListCompleted(noOfGroups){

  }
  void onMemberMadeAsAdmin(event){

  }
  void onMemberRemovedAsAdmin(event){

  }
  void onLeftFromGroup({required String groupJid,required String userJid}){

  }
  void onGroupNotificationMessage(event){

  }
  void onGroupDeletedLocally(groupJid){

  }
}