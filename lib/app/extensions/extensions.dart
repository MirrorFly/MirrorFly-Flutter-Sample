import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';
import 'package:mirror_fly_demo/app/data/session_management.dart';
import 'package:mirror_fly_demo/app/model/chat_message_model.dart';
import 'package:mirror_fly_demo/app/modules/chat/controllers/chat_controller.dart';
import 'package:mirrorfly_plugin/mirrorflychat.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import '../common/app_localizations.dart';
import '../data/utils.dart';
import '../routes/route_settings.dart';

part 'recent_chat_extension.dart';
part 'profile_parsing_extension.dart';
part 'chat_message_extension.dart';
part 'scroll_controller_extension.dart';
part 'permission_extension.dart';
part 'data_type_extension.dart';


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
  T get<T extends GetxController>() {
    if (GetInstance().isRegistered<T>()) {
      LogMessage.d("Creating Controller: ", "$T found, use a old instance.");
      return GetInstance().find<T>();
    } else {
      LogMessage.d("Creating Controller: ", "$T not found, initializing a new instance.");
      GetInstance().lazyPut<T>(()=>this as T); // Use the provided factory function to create a new instance
      return GetInstance().find<T>();
    }
  }
}

abstract class NavView<T extends GetxController> extends StatelessWidget {
  const NavView({super.key});

  final String? tag = null;

  T get controller => createController().get();
  dynamic get arguments => NavUtils.arguments;

  T createController();

  @override
  Widget build(BuildContext context);

}

// Abstract class for StatefulWidget
abstract class NavViewStateful<T extends GetxController> extends StatefulWidget {
  const NavViewStateful({Key? key}) : super(key: key);

  T get controller => Get.find<T>();
  dynamic get arguments => NavUtils.arguments;

  T createController();

  @override
  NavViewState<T> createState() {
    return NavViewState<T>();
  }

  void onInit() {}
  void onDispose() {}

  Widget build(BuildContext context);
}

class NavViewState<T extends GetxController> extends State<NavViewStateful<T>> {
  // late T controller;

  @override
  void initState() {
    widget.createController();
    // Get.put<T>(controller);
    super.initState();
    widget.onInit();
    LogMessage.d("NavViewState : initState", T.toString());
  }

  @override
  void dispose() {
    Get.delete<T>();
    widget.onDispose();
    super.dispose();
    LogMessage.d("NavViewState :  dispose", T.toString());
  }

  @override
  Widget build(BuildContext context){
    return widget.build(context);
  }

  // Widget buildPage(BuildContext context);
}

/*
abstract class NavViewStateful<T extends GetxController> extends StatefulWidget {
  const NavViewStateful({Key? key}) : super(key: key);

  final String? tag = null;

  T get controller => createController().get();
  dynamic get arguments => NavUtils.arguments;

  T createController();

  @override
  NavViewState<NavViewStateful<T>, T> createState();
}

abstract class NavViewState<V extends NavViewStateful<T>, T extends GetxController> extends State<V> {
  late T controller;

  @override
  void initState() {
    super.initState();
    controller = widget.createController();
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
