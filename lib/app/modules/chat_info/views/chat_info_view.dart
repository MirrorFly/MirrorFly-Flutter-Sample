import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/chat_info_controller.dart';

class ChatInfoView extends GetView<ChatInfoController> {
  const ChatInfoView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ChatInfoView'),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          'ChatInfoView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
