import 'package:get/get.dart';

class JoinCallController extends GetxController {


  final _users = <String>[].obs;
  get users => _users;

  final videoMuted = false.obs;
  // get videoMuted => _videoMuted.value;

  final muted = false.obs;
  // get muted => _muted.value;

  muteAudio() {}

  videoMute() {}
}