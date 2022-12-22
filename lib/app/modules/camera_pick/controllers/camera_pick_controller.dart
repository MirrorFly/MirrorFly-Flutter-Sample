import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';

class CameraPickController extends GetxController with WidgetsBindingObserver  {

  CameraController? cameraController;
  var cameraInitialized = false.obs;
  var isRecording = false.obs;
  var flash = false.obs;
  var isFrontCamera = true.obs;
  double transform = 0;
  late List<CameraDescription> cameras;
  @override
  void onInit() {
    super.onInit();
    initCamera();
  }

  // #docregion AppLifecycle
  /*@override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    //final CameraController? cameraController = controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      //onNewCameraSelected(cameraController.description);
    }
  }*/

  @override
  void dispose() {
    cameraController?.dispose();
    super.dispose();
  }

  Future<void> initCamera() async {
    cameras = await availableCameras();
    cameraController = CameraController(cameras[0], ResolutionPreset.high);
    cameraController?.initialize().then((value) => cameraInitialized(true));
  }

   toggleFlash() {
     flash.value = !flash.value;
     flash.value ? cameraController?.setFlashMode(FlashMode.torch) : cameraController?.setFlashMode(FlashMode.off);

   }

  Future<void> takePhoto(context) async {
    if(cameraInitialized.value) {
      Helper.showLoading();
      XFile? file = await cameraController?.takePicture();
      debugPrint("file : ${file?.path}");
      Helper.hideLoading();
      Get.back(result: file);
    }
  }

  stopRecord()async{
    if(cameraInitialized.value) {
      Helper.showLoading();
      XFile? file = await cameraController?.stopVideoRecording();
      debugPrint("file : ${file?.path}");
      Helper.hideLoading();
      Get.back(result: file);
      isRecording(false);
    }
  }

  void toggleCamera() {
    cameraInitialized(false);
    isFrontCamera.value = !isFrontCamera.value;
    transform = transform * pi;
    int cameraPos = isFrontCamera.value ? 0 : 1;
    cameraController = CameraController(cameras[cameraPos], ResolutionPreset.high);
    cameraController?.initialize().then((value) => cameraInitialized(true));
  }



}
