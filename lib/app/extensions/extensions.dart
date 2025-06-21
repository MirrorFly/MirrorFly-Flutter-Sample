import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mirror_fly_demo/app/model/arguments.dart';
import 'package:mirror_fly_demo/mention_text_field/mention_tag_text_field.dart';
import '../common/constants.dart';
import '../data/helper.dart';
import '../data/mention_utils.dart';
import '../data/session_management.dart';
import '../model/chat_message_model.dart';
import 'package:mirrorfly_plugin/mirrorflychat.dart';
import 'package:permission_handler/permission_handler.dart';

import '../common/app_localizations.dart';
import '../data/utils.dart';

part 'chat_message_extension.dart';
part 'data_type_extension.dart';
part 'permission_extension.dart';
part 'profile_parsing_extension.dart';
part 'recent_chat_extension.dart';
part 'scroll_controller_extension.dart';


extension FileFormatter on num {
  String readableFileSize({bool base1024 = true}) {
    final base = base1024 ? 1024 : 1000;
    if (this <= 0) return "0";
    final units = ["bytes", "KB", "MB", "GB", "TB"];
    int digitGroups = (log(this) / log(base)).round();
    return "${NumberFormat("#,##0.#").format(this / pow(base, digitGroups))} ${units[digitGroups]}";
  }
}


extension GetHelper on GetxController {
  T get<T extends GetxController>({String? tag}) {
    if (GetInstance().isRegistered<T>(tag: tag)) {
      LogMessage.d("Creating Controller: ", "$T found, use a old instance.");
      return GetInstance().find<T>(tag: tag);
    } else {
      LogMessage.d("Creating Controller: ", "$T not found, initializing a new instance.");
      GetInstance().lazyPut<T>(()=>this as T,tag: tag); // Use the provided factory function to create a new instance
      return GetInstance().find<T>(tag: tag);
    }
  }
}

// Abstract class for StatelessWidget
abstract class NavView<T extends GetxController> extends StatelessWidget {
  const NavView({super.key});

  final String? tag = null;

  T get controller => createController().get();
  dynamic get arguments => NavUtils.arguments;

  T createController({String? tag});

  @override
  Widget build(BuildContext context);

}

// Abstract class for StatefulWidget
abstract class NavViewStateful<T extends GetxController> extends StatefulWidget {
  final String? tag;
  const NavViewStateful({Key? key, this.tag}) : super(key: key);

  T get controller => Get.find<T>(tag: tag);
  T controllerWithTag(String tag){
    return Get.find<T>(tag:tag);
  }
  dynamic get arguments => NavUtils.arguments;

  T createController({String? tag});

  @override
  NavViewState<T> createState() {
    return NavViewState<T>();
  }

  void onInit() {}
  void onDispose() {}

  Widget build(BuildContext context);
}

class NavViewState<T extends GetxController> extends State<NavViewStateful<T>> {

  @override
  void initState() {
    debugPrint("NavViewState key ${widget.tag}");
    widget.createController(tag: widget.tag);
    super.initState();
    widget.onInit();
    LogMessage.d("NavViewState : initState", T.toString());
    // LogMessage.d("NavViewState : isRegistered", {Get.isRegistered<T>()});
    // LogMessage.d("NavViewState : isRegistered tag", {Get.isRegistered<T>(tag: widget.tag)});

  }

  @override
  void dispose() {
    widget.onDispose();
    // LogMessage.d("NavViewState : dispose isRegistered", {Get.isRegistered<T>()});
    // LogMessage.d("NavViewState : dispose isRegistered tag", {Get.isRegistered<T>(tag: widget.tag)});

    ///
    /// If the tag is different, it means we are navigating to a different chat,
    /// controller so we can safely dispose the existing controller.
    ///
    /// If the tag is the same, it means the app was backgrounded and brought
    /// back via notification *to the same chat*, so we **should not dispose**
    /// the controller to prevent 'controller not found' or unregistered errors.
    ///

    final nextArgs = NavUtils.arguments as ChatViewArguments?;
    final bool isSameTag = widget.tag == nextArgs?.chatJid;

    if (widget.tag != null) {
      if (!isSameTag) {
        LogMessage.d("NavViewState: ", "dispose controller: ${T.toString()} with key: ${widget.tag}" );
        Get.delete<T>(tag: widget.tag);
      }
    } else {
      LogMessage.d("NavViewState: ", "dispose controller ${T.toString()}");
      Get.delete<T>();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    return widget.build(context);
  }

}

extension Regexparesing on RegExp {
  Iterable<RegExpMatch> matcher(String text){
    return allMatches(text);
  }
  List<RegExpMatch> findMatchedPosition(String text){
    var list = <RegExpMatch>[];
    allMatches(text).forEach((match) {
      list.add(match);
    });
    return list;
  }
}
extension RegexpMatcharesing on RegExpMatch {
  String string(){
    return "groupNames : $groupNames, pattern : $pattern, start : $start, end : $end, input : $input";
  }
}

extension MentionTagTextEditingControllerExtension on MentionTagTextEditingController{
  String get formattedText {
    const replaceString = "@[?]";
    debugPrint(text);

    return text.replaceAll(Constants.mentionEscape, replaceString);
  }

  List<String> get getTags {
    var tags = mentions;
    // // Sort tags by startIndex to avoid overlapping replacements
    // tags.sort((a, b) => a.startIndex.compareTo(b.startIndex));
    return List<String>.from(tags.map((item)=>item));
  }

  /*setCustomText(String content,List<ProfileDetails> profileDetails){
    var allMatches = MentionUtils.mentionRegex.allMatches(content).toList();
    debugPrint("setText : $allMatches");
    int index = 0;
    int lastMatchEnd = 0;
    text="";
    setText = text;
    for (var currentMatch in allMatches) {
      text += content.substring(lastMatchEnd,currentMatch.start+1);
      // _rebuild(text);
      setText = text;
      String id = profileDetails[index].jid.checkNull().split("@")[0];
      String name = profileDetails[index].getName();
      addMention(label: name,data: id,stylingWidget: Text('@${name}',style: const TextStyle(color: Colors.blueAccent),));
      lastMatchEnd = currentMatch.end;
      index++;
    }
    if (lastMatchEnd < content.length) {
      text += content.substring(lastMatchEnd);
      setText = text;
      // _rebuild(text);
    }
    print("setText : $text $getText");

  }*/

  List<(String, Object?, Widget?)> getInitialMentions(String content,List<ProfileDetails> profileDetails){
    List<(String, Object?, Widget?)> tuples = [];
    var allMatches = MentionUtils.mentionRegex.allMatches(content).toList();
    int index = 0;
    int lastMatchEnd = 0;
    var text="";
    for (var currentMatch in allMatches) {
      text += content.substring(lastMatchEnd,currentMatch.start+1);
      String id = profileDetails[index].jid.checkNull().split("@")[0];
      String name = profileDetails[index].getName();
      tuples.add((name,id,Text('@$name',style: const TextStyle(color: Colors.blueAccent),)));
      lastMatchEnd = currentMatch.end;
      index++;
    }
    if (lastMatchEnd < content.length) {
      text += content.substring(lastMatchEnd);
    }
    debugPrint("getInitialMentions : $content , $text , $tuples");
    initialMentions = tuples;
    return tuples;
  }



}