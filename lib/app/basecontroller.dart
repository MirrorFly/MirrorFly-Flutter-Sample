import 'package:get/get.dart';
import 'package:meta/meta.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';

import 'nativecall/platformRepo.dart';

class BaseController extends GetxController {

  final _obj = ''.obs;
  set obj(value) => _obj.value = value;
  get obj => _obj.value;

  @override
  void onInit() {
    super.onInit();
    initListeners();
  }

  initListeners(){
    PlatformRepo().onMessageReceived.listen(onMessageReceived);
    PlatformRepo().onMessageStatusUpdated.listen(onMessageStatusUpdated);
    PlatformRepo().onMediaStatusUpdated.listen(onMediaStatusUpdated);
    PlatformRepo().onGroupProfileFetched.listen(onGroupProfileFetched);
    PlatformRepo().onNewGroupCreated.listen(onNewGroupCreated);
    PlatformRepo().onGroupProfileUpdated.listen(onGroupProfileUpdated);
    PlatformRepo().onNewMemberAddedToGroup.listen(onNewMemberAddedToGroup);
    PlatformRepo().onMemberRemovedFromGroup.listen(onMemberRemovedFromGroup);
    PlatformRepo().onFetchingGroupMembersCompleted.listen(onFetchingGroupMembersCompleted);
    PlatformRepo().onDeleteGroup.listen(onDeleteGroup);
    PlatformRepo().onFetchingGroupListCompleted.listen(onFetchingGroupListCompleted);
    PlatformRepo().onMemberMadeAsAdmin.listen(onMemberMadeAsAdmin);
    PlatformRepo().onMemberRemovedAsAdmin.listen(onMemberRemovedAsAdmin);
    PlatformRepo().onLeftFromGroup.listen(onLeftFromGroup);
    PlatformRepo().onGroupNotificationMessage.listen(onGroupNotificationMessage);
    PlatformRepo().onGroupDeletedLocally.listen(onGroupDeletedLocally);
  }

  void onMessageReceived(event){
    Log("flutter onMessageReceived", event.toString());
  }
  void onMessageStatusUpdated(event){
    Log("flutter onMessageStatusUpdated", event.toString());
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
  void onLeftFromGroup(event){

  }
  void onGroupNotificationMessage(event){

  }
  void onGroupDeletedLocally(groupJid){

  }
}