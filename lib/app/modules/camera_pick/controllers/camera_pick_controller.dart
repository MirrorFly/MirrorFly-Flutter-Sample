import 'dart:async';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/constants.dart';
import 'package:mirrorfly_plugin/mirrorflychat.dart';

import '../../../app_style_config.dart';
import '../../../common/app_localizations.dart';
import '../../../data/utils.dart';

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
    debugPrint("cameraController disposed");
    super.dispose();
  }
  var min = 1.0;
  var max = 5.0;
  var pointers =0;
  Future<void> initCamera() async {
    cameras = await availableCameras();
    cameraController = CameraController(cameras[0], ResolutionPreset.high);
    cameraController?.initialize().then((value)async {
      cameraInitialized(true);
      min = (await cameraController?.getMinZoomLevel())!;
      var maxZoom = (await cameraController?.getMaxZoomLevel())!;
      //Setting this max zoom, due to iOS devices are stuck when capturing stating - CameraException(setFocusPointFailed, Device does not have focus point capabilities)
      max = maxZoom * 0.35;
      debugPrint("zoom min : $min");
      debugPrint("zoom max : $max");
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
      LogMessage.d("startVideoRecording", "$e");
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
    ScaffoldMessenger.of(NavUtils.currentContext)
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
      LogMessage.d("stopVideoRecording", "$e");
      _showCameraException(e);
      return null;
    }
  }

  Future<void> takePhoto(context) async {
    if(cameraInitialized.value) {
      DialogUtils.showLoading(dialogStyle: AppStyleConfig.dialogStyle);
      XFile? file;
      try {
        file = await cameraController?.takePicture();
      }catch(e){
        LogMessage.d("takePhoto", "$e");
        DialogUtils.hideLoading();
        toToast(getTranslated("insufficientMemoryError"));//CameraException(IOError, Failed saving image)
      }finally{
        debugPrint("file : ${file?.path}");
        DialogUtils.hideLoading();
        NavUtils.back(result: file);
      }
    }
  }

  stopRecord()async{
    if(cameraInitialized.value) {
      //DialogUtils.showLoading();
      DialogUtils.showLoading(dialogStyle: AppStyleConfig.dialogStyle);
      XFile? file;
      try {
       file = await stopVideoRecording();
      }catch(e){
        LogMessage.d("stopRecord", "$e");
        DialogUtils.hideLoading();
        toToast(getTranslated("insufficientMemoryError"));
      }finally{
        // debugPrint("file : ${file?.path}, ${file?.length()},");
        DialogUtils.hideLoading();
        NavUtils.back(result: file);
        isRecording(false);
      }

    }
  }

  void toggleCamera() {
    cameraInitialized(false);
    flash(false);
    isFrontCamera.value = !isFrontCamera.value;
    transform = transform * pi;
    int cameraPos = isFrontCamera.value ? 0 : 1;
    cameraController = CameraController(cameras[cameraPos], ResolutionPreset.high);
    cameraController?.initialize().then((value){
      cameraInitialized(true);
    });

  }



}
