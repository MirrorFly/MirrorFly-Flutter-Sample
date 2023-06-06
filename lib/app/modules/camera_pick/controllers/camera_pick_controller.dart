import 'dart:async';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';

class CameraPickController extends GetxController with WidgetsBindingObserver  {
  RxDouble scale = 1.0.obs;
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
  var min = 1.0;
  var max = 8.0;
  var pointers =0;
  Future<void> initCamera() async {
    cameras = await availableCameras();
    cameraController = CameraController(cameras[0], ResolutionPreset.high);
    cameraController?.initialize().then((value)async {
      cameraInitialized(true);
      min = (await cameraController?.getMinZoomLevel())!;
      max = (await cameraController?.getMaxZoomLevel())!;
      debugPrint("min : $min");
      debugPrint("max : $max");
    });

  }

   toggleFlash() {
     flash.value = !flash.value;
     flash.value ? cameraController?.setFlashMode(FlashMode.torch) : cameraController?.setFlashMode(FlashMode.off);

   }

  double _currentScale = 1.0;
  double _baseScale = 1.0;
  void handleScaleStart(ScaleStartDetails details) {
    _baseScale = _currentScale;
  }

  Future<void> handleScaleUpdate(ScaleUpdateDetails details) async {
    // When there are not exactly two fingers on screen don't scale
    if (cameraController == null || pointers != 2) {
      return;
    }

    _currentScale = (_baseScale * details.scale)
        .clamp(min, max);

    await cameraController!.setZoomLevel(_currentScale);
  }

  void onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
    if (cameraController == null) {
      return;
    }

    //final CameraController cameraController = controller!;

    final Offset offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );
    cameraController?.setExposurePoint(offset);
    cameraController?.setFocusPoint(offset);
  }

  Timer? countdownTimer;
  Duration myDuration = const Duration(seconds: 300);
  int maxVideoDuration = 300;
  void startTimer() {
    countdownTimer =
        Timer.periodic(const Duration(seconds: 1), (_) => setCountDown());
  }
  var minutesStr = '00'.obs;
  var secondsStr = '00'.obs;
  var counter =0;
  var timeStr = "".obs;
  var progress = 0.obs;
  get timeString => timeStr("${minutesStr.value}:${secondsStr.value}");
  void setCountDown() {
    counter++;
    minutesStr(((counter / 60) % 60).floor().toString().padLeft(2, '0'));
    secondsStr((counter % 60).floor().toString().padLeft(2, '0'));
    progress(counter);
    debugPrint(counter.toString());
    if(counter==maxVideoDuration){
      // stopVideoRecording();
      stopRecord();
    }
  }

  Future<void> startVideoRecording() async {
    //final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController!.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return;
    }

    if (cameraController!.value.isRecordingVideo) {
      // A recording is already started, do nothing.
      return;
    }

    try {
      await cameraController?.startVideoRecording();
      startTimer();
      isRecording(true);
    } on CameraException catch (e) {
      _showCameraException(e);
      return;
    }
  }
  void _showCameraException(CameraException e) {
    _logError(e.code, e.description);
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }
  void _logError(String code, String? message) {
    // ignore: avoid_print
    print('Error: $code${message == null ? '' : '\nError Message: $message'}');
  }

  void showInSnackBar(String message) {
    ScaffoldMessenger.of(Get.context!)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<XFile?> stopVideoRecording() async {
    //final CameraController? cameraController = controller;
    countdownTimer?.cancel();
    if (cameraController == null || !cameraController!.value.isRecordingVideo) {
      return null;
    }

    try {
      return cameraController?.stopVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
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
      //Helper.showLoading();
      XFile? file = await stopVideoRecording();
      debugPrint("file : ${file?.path}");
      //Helper.hideLoading();
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
