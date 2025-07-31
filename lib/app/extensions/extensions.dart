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
      LogMessage.d("Creating Controller: ",
          "$T not found, initializing a new instance.");
      GetInstance().lazyPut<T>(() => this as T,
          tag:
              tag); // Use the provided factory function to create a new instance
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
abstract class NavViewStateful<T extends GetxController>
    extends StatefulWidget {
  final String? tag;
  const NavViewStateful({Key? key, this.tag}) : super(key: key);

  T get controller => Get.find<T>(tag: tag);
  T controllerWithTag(String tag) {
    return Get.find<T>(tag: tag);
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
    /// If the tag is different, it means we are navigating to a different chat
    /// controller so we can safely dispose the existing controller.
    ///
    /// If the tag is the same, it means the app was backgrounded and brought
    /// back via notification *to the same chat*, so we **should not dispose**
    /// the controller to prevent 'controller not found' or unregistered errors.
    ///

    final dynamic navArgs = NavUtils.arguments;
    final ChatViewArguments? nextArgs = navArgs is ChatViewArguments ? navArgs : null;
    LogMessage.d("NavViewState: ", "nextArgs?.chatJid: ${nextArgs?.chatJid}" );
    final bool isSameTag = widget.tag == nextArgs?.chatJid;
    LogMessage.d("NavViewState: ", "widget.tag: ${widget.tag}" );

    if (widget.tag != null) {
      bool isControllerAvailable = Get.isRegistered<T>(tag: widget.tag);
      LogMessage.d("NavViewState: ",
          "isControllerAvailable: ${T.toString()} with key: ${widget.tag} : $isControllerAvailable");
      if (!isSameTag && isControllerAvailable) {
        LogMessage.d("NavViewState: ",
            "dispose controller: ${T.toString()} with key: ${widget.tag}");
        Get.delete<T>(tag: widget.tag);
        SessionManagement.setCurrentChatJID(
            nextArgs?.chatJid ?? Constants.emptyString);
      } else {
        LogMessage.d("NavViewState: ",
            "isSameTag ==> no need to dispose the controller || $T controller not registered");
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

/*
abstract class NavViewStateful<T extends GetxController> extends StatefulWidget {
  const NavViewStateful({Key? key}) : super(key: key);

  final String? tag = null;

  T get controller => createController({String? tag}).get();
  dynamic get arguments => NavUtils.arguments;

  T createController({String? tag});

  @override
  NavViewState<NavViewStateful<T>, T> createState();
}

abstract class NavViewState<V extends NavViewStateful<T>, T extends GetxController> extends State<V> {
  late T controller;

  @override
  void initState() {
    super.initState();
    controller = widget.createController({String? tag});
    // Initialize the controller
    if (widget.tag == null) {
      Get.put<T>(controller);
    } else {
      Get.put<T>(controller, tag: widget.tag);
    }
  }

  @override
  void dispose() {
    // Dispose of the controller
    if (widget.tag == null) {
      Get.delete<T>();
    } else {
      Get.delete<T>(tag: widget.tag);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context);
}*/
