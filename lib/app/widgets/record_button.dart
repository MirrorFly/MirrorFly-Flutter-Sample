import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import '../common/constants.dart';
import '../modules/chat/controllers/chat_controller.dart';
import 'flow_shader.dart';
import 'lottie_animation.dart';
// import 'package:record/record.dart';

class RecordButton extends StatefulWidget {
  const RecordButton({
    Key? key,
    required this.controller,
  }) : super(key: key);

  final AnimationController controller;

  @override
  State<RecordButton> createState() => _RecordButtonState();
}

class _RecordButtonState extends State<RecordButton> {
  static const double size = 55;

  final double lockerHeight = 200;
  double timerWidth = 0;

  late Animation<double> buttonScaleAnimation;
  late Animation<double> timerAnimation;
  late Animation<double> lockerAnimation;

  DateTime? startTime;
  Timer? timer;
  String recordDuration = "00:00";
  // late Record record;
  var recordTime;

  bool isLocked = false;
  bool showLottie = false;
  var documentPath;

  @override
  void initState() {
    super.initState();
    buttonScaleAnimation = Tween<double>(begin: 1, end: 2).animate(
      CurvedAnimation(
        parent: widget.controller,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticInOut),
      ),
    );
    widget.controller.addListener(() {
      setState(() {});
    });
    setAudioPath();
    // record = Record();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    timerWidth =
        MediaQuery.of(context).size.width - 2 * Constants.defaultPadding - 4;
    timerAnimation =
        Tween<double>(begin: timerWidth + Constants.defaultPadding, end: 0)
            .animate(
      CurvedAnimation(
        parent: widget.controller,
        curve: const Interval(0.2, 1, curve: Curves.easeIn),
      ),
    );
    lockerAnimation =
        Tween<double>(begin: lockerHeight + Constants.defaultPadding, end: 0)
            .animate(
      CurvedAnimation(
        parent: widget.controller,
        curve: const Interval(0.2, 1, curve: Curves.easeIn),
      ),
    );
  }

  @override
  void dispose() {
    // record.dispose();
    timer?.cancel();
    timer = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // lockSlider(),
        cancelSlider(),
        audioButton(),
        // if (isLocked) timerLocked(),
      ],
    );
  }

  Widget lockSlider() {
    return Positioned(
      bottom: -lockerAnimation.value,
      child: Container(
        height: lockerHeight,
        width: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Constants.borderRadius),
          color: Colors.black,
        ),
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Icon(Icons.lock, size: 20),
            const SizedBox(height: 8),
            FlowShader(
              direction: Axis.vertical,
              child: Column(
                children: const [
                  Icon(Icons.keyboard_arrow_up),
                  Icon(Icons.keyboard_arrow_up),
                  Icon(Icons.keyboard_arrow_up),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget cancelSlider() {
    return Positioned(
      right: -timerAnimation.value,
      child: Container(
        height: size,
        width: timerWidth,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Constants.borderRadius),
          border: Border.all(
            color: textcolor,
          ),
          color: Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              // showLottie ? const LottieAnimation(lottieJson: deleteDustbin) : Text(recordDuration),
              const SizedBox(width: size),
              FlowShader(
                duration: const Duration(seconds: 3),
                flowColors: const [Colors.white, Colors.grey],
                child: Row(
                  children: const [
                    Icon(Icons.keyboard_arrow_left),
                    Text("Slide to cancel")
                  ],
                ),
              ),
              const SizedBox(width: size),
            ],
          ),
        ),
      ),
    );
  }

  Widget timerLocked() {
    return Positioned(
      right: 0,
      child: Container(
        height: size,
        width: timerWidth,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Constants.borderRadius),
          color: Colors.black,
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 15, right: 25),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () async {
              // Vibrate.feedback(FeedbackType.success);
              timer?.cancel();
              timer = null;
              startTime = null;
              recordDuration = "00:00";

              // var filePath = await Record().stop();
              // AudioState.files.add(filePath!);
              // Globals.audioListKey.currentState!
              //     .insertItem(AudioState.files.length - 1);

              // debugPrint(filePath);
              // debugPrint(filePath);
              setState(() {
                isLocked = false;
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                Text(recordDuration),
                FlowShader(
                  child: const Text("Tap lock to stop"),
                  duration: const Duration(seconds: 3),
                  flowColors: const [Colors.white, Colors.grey],
                ),
                const Center(
                  child: Icon(
                    Icons.lock,
                    size: 18,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget audioButton() {
    return GestureDetector(
      child: Transform.scale(
        scale: buttonScaleAnimation.value,
        child: Container(
          height: size,
          width: size,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).primaryColor,
          ),
          child: const Icon(
            Icons.mic,
            color: Colors.white,
          ),
        ),
      ),
      onLongPressDown: (_) {
        debugPrint("onLongPressDown");
        widget.controller.forward();
      },
      onLongPressEnd: (details) async {
        debugPrint("onLongPressEnd");

        if (isCancelled(details.localPosition, context)) {
          // Vibrate.feedback(FeedbackType.heavy);

          timer?.cancel();
          timer = null;
          startTime = null;
          recordDuration = "00:00";

          setState(() {
            showLottie = true;
          });

          Timer(const Duration(milliseconds: 1440), () async {
            widget.controller.reverse();
            debugPrint("Cancelled recording");
            // var filePath = await record.stop();
            // debugPrint(filePath);
            // File(filePath!).delete();
            // debugPrint("Deleted $filePath");
            showLottie = false;
          });
        } else if (checkIsLocked(details.localPosition)) {
          widget.controller.reverse();

          // Vibrate.feedback(FeedbackType.heavy);
          debugPrint("Locked recording");
          debugPrint(details.localPosition.dy.toString());
          setState(() {
            isLocked = true;
          });
        } else {
          widget.controller.reverse();

          // Vibrate.feedback(FeedbackType.success);

          final format = DateFormat('mm:ss');
          final dt = format.parse(recordDuration, true);
          final millisec = dt.millisecondsSinceEpoch;
          debugPrint("Audio duration $millisec");

          // recordTime = timer.
          timer?.cancel();
          timer = null;
          startTime = null;
          recordDuration = "00:00";

          // await Record().stop().then((filePath) async {
          //   if (File(filePath!).existsSync()) {
          //     var response = await Get.find<ChatController>()
          //         .sendAudioMessage(filePath, true,millisec.toString() );
          //     debugPrint("Preview View ==> $response");
          //     if (response != null) {
          //       Get.back();
          //     }
          //   } else {
          //     debugPrint("File Not Found For Image Uplaod");
          //   }
          //
          //   debugPrint(filePath);
          // });

          // AudioState.files.add(filePath!);
          // Globals.audioListKey.currentState!
          //     .insertItem(AudioState.files.length - 1);

        }
      },
      onLongPressCancel: () {
        debugPrint("onLongPressCancel");
        widget.controller.reverse();
      },
      onLongPress: () async {
        debugPrint("onLongPress");
        // Vibrate.feedback(FeedbackType.success);
        // if (await Record().hasPermission()) {
        //
        //   await record.start(
        //     path: documentPath + "/" +
        //         "audio_${DateTime.now().millisecondsSinceEpoch}.m4a",
        //     encoder: AudioEncoder.AAC,
        //     bitRate: 128000,
        //     samplingRate: 44100,
        //   );
        //   startTime = DateTime.now();
        //   timer = Timer.periodic(const Duration(seconds: 1), (_) {
        //     final minDur = DateTime.now().difference(startTime!).inMinutes;
        //     final secDur = DateTime.now().difference(startTime!).inSeconds % 60;
        //     String min = minDur < 10 ? "0$minDur" : minDur.toString();
        //     String sec = secDur < 10 ? "0$secDur" : secDur.toString();
        //     setState(() {
        //       recordDuration = "$min:$sec";
        //     });
        //   });
        // }
      },
    );
  }

  bool checkIsLocked(Offset offset) {
    return (offset.dy < -35);
  }

  bool isCancelled(Offset offset, BuildContext context) {
    return (offset.dx < -(MediaQuery.of(context).size.width * 0.2));
  }

  Future<void> setAudioPath() async {

    documentPath = (await getExternalStorageDirectory())!.path;
    debugPrint(documentPath);
  }
}
