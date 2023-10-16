import 'package:flutter/material.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirror_fly_demo/app/common/widgets.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';
import 'package:mirrorfly_plugin/mirrorflychat.dart';
import 'package:mirrorfly_plugin/model/user_list_model.dart';

Widget buildProfileImage(Profile item) {
  return ImageNetwork(
    url: item.image.toString(),
    width: 105,
    height: 105,
    clipOval: true,
    errorWidget: item.isGroupProfile.checkNull()
        ? ClipOval(
            child: Image.asset(
              groupImg,
              height: 48,
              width: 48,
              fit: BoxFit.cover,
            ),
          )
        : ProfileTextImage(
            text: item.getName(),
            radius: 50,
          ),
    isGroup: item.isGroupProfile.checkNull(),
    blocked: item.isBlockedMe.checkNull() || item.isAdminBlocked.checkNull(),
    unknown: (!item.isItSavedContact.checkNull() || item.isDeletedContact()),
  );
}

/*
class SpeakingDots extends StatefulWidget {
  const SpeakingDots({Key? key, required this.audioLevel, required this.bgColor}) : super(key: key);
  final int audioLevel;
  final Color bgColor;

  @override
  State<SpeakingDots> createState() => _SpeakingDotsState();
}

class _SpeakingDotsState extends State<SpeakingDots> {
  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: widget.bgColor,
      radius: 13,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: showAudioLevel(widget.audioLevel),
      ),
    );
  }

  List<Widget> showAudioLevel(int audioLevel) {
    switch (audioLevel.getAudioLevel()) {
      case AudioLevel.audioTooLow:
        return tooLowAudioLevel();
      case AudioLevel.audioLow:
        return lowAudioLevel();
      case AudioLevel.audioMedium:
        return mediumAudioLevel();
      case AudioLevel.audioHigh:
        return highAudioLevel();
      case AudioLevel.audioPeak:
        return peakAudioLevel();
      default:
        return tooLowAudioLevel();
    }
  }

  List<Widget> tooLowAudioLevel() {
    return [
      Container(
        width: 4,
        height: 4,
        decoration:
            BoxDecoration(color: Colors.white, shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(10)),
      ),
      const SizedBox(
        width: 2,
      ),
      Container(
        width: 4,
        height: 4,
        decoration:
            BoxDecoration(color: Colors.white, shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(10)),
      ),
      const SizedBox(
        width: 2,
      ),
      Container(
        width: 4,
        height: 4,
        decoration:
            BoxDecoration(color: Colors.white, shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(10)),
      ),
    ];
  }

  List<Widget> lowAudioLevel() {
    return [
      Container(
        width: 4,
        height: 4,
        decoration:
            BoxDecoration(color: Colors.white, shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(10)),
      ),
      const SizedBox(
        width: 2,
      ),
      Container(
        width: 4,
        height: 8,
        decoration:
            BoxDecoration(color: Colors.white, shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(10)),
      ),
      const SizedBox(
        width: 2,
      ),
      Container(
        width: 4,
        height: 4,
        decoration:
            BoxDecoration(color: Colors.white, shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(10)),
      ),
    ];
  }

  List<Widget> mediumAudioLevel() {
    return [
      Container(
        width: 4,
        height: 6,
        decoration:
            BoxDecoration(color: Colors.white, shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(10)),
      ),
      const SizedBox(
        width: 2,
      ),
      Container(
        width: 4,
        height: 10,
        decoration:
            BoxDecoration(color: Colors.white, shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(10)),
      ),
      const SizedBox(
        width: 2,
      ),
      Container(
        width: 4,
        height: 6,
        decoration:
            BoxDecoration(color: Colors.white, shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(10)),
      ),
    ];
  }

  List<Widget> highAudioLevel() {
    return [
      Container(
        width: 4,
        height: 8,
        decoration:
            BoxDecoration(color: Colors.white, shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(10)),
      ),
      const SizedBox(
        width: 2,
      ),
      Container(
        width: 4,
        height: 12,
        decoration:
            BoxDecoration(color: Colors.white, shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(10)),
      ),
      const SizedBox(
        width: 2,
      ),
      Container(
        width: 4,
        height: 8,
        decoration:
            BoxDecoration(color: Colors.white, shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(10)),
      ),
    ];
  }

  List<Widget> peakAudioLevel() {
    return [
      Container(
        width: 4,
        height: 10,
        decoration:
            BoxDecoration(color: Colors.white, shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(10)),
      ),
      const SizedBox(
        width: 2,
      ),
      Container(
        width: 4,
        height: 12,
        decoration:
            BoxDecoration(color: Colors.white, shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(10)),
      ),
      const SizedBox(
        width: 2,
      ),
      Container(
        width: 4,
        height: 10,
        decoration:
            BoxDecoration(color: Colors.white, shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(10)),
      ),
    ];
  }
}*/
