import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/camera_pick_controller.dart';

class CameraPickView extends GetView<CameraPickController> {
  const CameraPickView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Obx(() {
              return controller.cameraInitialized.value ? SizedBox(
                width: MediaQuery
                    .of(context)
                    .size
                    .width,
                height: MediaQuery
                    .of(context)
                    .size
                    .height,
                child: CameraPreview(controller.cameraController),
              ) : const Center(
                child: CircularProgressIndicator(),
              );
            }),
            Positioned(
                bottom: 0.0,
                child: Container(
                  color: Colors.black,
                  padding: const EdgeInsets.only(top: 5, bottom: 5),
                  width: MediaQuery
                      .of(context)
                      .size
                      .width,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Obx(() {
                            return IconButton(
                              onPressed: () {
                                controller.toggleFlash();
                              },
                              icon: controller.flash.value
                                  ? const Icon(Icons.flash_on, size: 30,)
                                  : const Icon(Icons.flash_off, size: 30,),
                              color: Colors.white,
                            );
                          }),
                          GestureDetector(
                            onLongPress: () async {
                              controller.cameraController.startVideoRecording();
                              controller.isRecording(true);
                            },
                            onLongPressUp: () async {
                              // to preview
                            },
                            onTap: () {
                              if (!controller.isRecording.value) {
                                controller.takePhoto(context);
                              }
                            },
                            child: controller.isRecording.value
                                ? const Icon(
                              Icons.radio_button_on,
                              color: Colors.red,
                              size: 80,
                            )
                                : const Icon(
                              Icons.panorama_fish_eye,
                              color: Colors.white,
                              size: 70,
                            ),
                          ),
                          IconButton(
                              onPressed: () async {
                                controller.toggleCamera();
                              },
                              icon: const Icon(
                                Icons.flip_camera_ios,
                                color: Colors.white,
                                size: 30,
                              ))
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text(
                        "Hold for Video, tap for photo",
                        style: TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
