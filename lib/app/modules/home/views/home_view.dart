import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 50,),
            TextFormField(
              controller: controller.userIdentifier,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter your Mobile Number',
              ),
            ),
            const SizedBox(height: 25,),
            ElevatedButton(
              onPressed: () async {
                String? registerResp = await controller.registerUser();
              },
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  textStyle: const TextStyle(
                      fontWeight: FontWeight.bold)),
              child: const Text('Register User'),
            ),
          ],
        ),
      ),
    );
  }
}
