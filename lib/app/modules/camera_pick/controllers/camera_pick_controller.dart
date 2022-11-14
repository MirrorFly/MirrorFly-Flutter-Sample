import 'dart:math';

import 'package:camera/camera.dart';
import 'package:get/get.dart';

class CameraPickController extends GetxController {

  late CameraController cameraController;
  // late Future<void> cameraValue;
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

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  Future<void> initCamera() async {
    cameras = await availableCameras();
    cameraController = CameraController(cameras[0], ResolutionPreset.high);
    cameraController.initialize().then((value) => cameraInitialized(true));
  }

   toggleFlash() {
     flash.value = !flash.value;
     flash.value ? cameraController.setFlashMode(FlashMode.torch) : cameraController.setFlashMode(FlashMode.off);

   }

  Future<void> takePhoto(context) async {
    XFile file = await cameraController.takePicture();
  }

  void toggleCamera() {
    cameraInitialized(false);
    isFrontCamera.value = !isFrontCamera.value;
    transform = transform * pi;
    int cameraPos = isFrontCamera.value ? 0 : 1;
    cameraController = CameraController(cameras[cameraPos], ResolutionPreset.high);
    cameraController.initialize().then((value) => cameraInitialized(true));
  }



}
