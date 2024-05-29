import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/app_localizations.dart';
import 'package:mirror_fly_demo/app/extensions/extensions.dart';

import '../../../data/utils.dart';
import '../controllers/camera_pick_controller.dart';

class CameraPickView extends NavView<CameraPickController> {
  const CameraPickView({Key? key}) : super(key: key);

  @override
  CameraPickController createController() {
    return CameraPickController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Obx(() {
          return controller.cameraInitialized.value ? Stack(
            alignment: Alignment.topCenter,
            children: [
              Listener(
                onPointerDown: (_) => controller.pointers++,
                onPointerUp: (_) => controller.pointers--,
                child: CameraPreview(
                  controller.cameraController!, child: LayoutBuilder(
                    builder: (BuildContext context,
                        BoxConstraints constraints) {
                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onScaleStart: controller.handleScaleStart,
                        onScaleUpdate: controller.handleScaleUpdate,
                        onTapDown: (TapDownDetails details) =>
                            controller.onViewFinderTap(
                                details, constraints),
                      );
                    }),),
              ),
              Row(
          mainAxisSize : MainAxisSize.max,
                children: [
                  IconButton(
                    icon: const Icon(Icons.clear,
                        color: Colors.white),
                    onPressed: () {
                      NavUtils.back();
                    },
                  ),
                  Expanded(
                    child: controller.isRecording.value ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height:12,width: 12,child: CircularProgressIndicator(backgroundColor: Colors.red,value: controller.progress/controller.maxVideoDuration,valueColor: const AlwaysStoppedAnimation<Color>(Colors.white))),
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Text(controller.timeString,style: const TextStyle(color: Colors.white),),
                        )
                      ],) : const SizedBox.shrink(),
                  )
                ],
              ),
              Positioned(
                bottom: 0,
                child: Container(
                  width: NavUtils.size.width,
                  color: Colors.transparent,
                  padding: const EdgeInsets.only(top: 5, bottom: 5),
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
                          Obx(() {
                            return GestureDetector(
                              onLongPress: () async {
                                controller.startVideoRecording();
                              },
                              onLongPressUp: () async {
                                // to preview
                                controller.stopRecord();
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
                            );
                          }),
                          IconButton(
                              onPressed: () async {
                                if (!controller.isRecording.value) {
                                  controller.toggleCamera();
                                }
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
                      Text(
                        getTranslated("holdToRecord"),
                        style: const TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
              ),
            ]
          ) : const Center(
            child: CircularProgressIndicator(),
          );
        }),
      ),
    );
  }
}
