import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get/get.dart';

import '../../../common/constants.dart';
import '../../call_widgets.dart';
import '../controllers/call_timeout_controller.dart';

class CallTimeoutView extends GetView<CallTimeoutController> {
  const CallTimeoutView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.callOptionBackground,
        body: SafeArea(
          child: Stack(
            children: [
              SizedBox(
                width: MediaQuery
                    .of(context)
                    .size
                    .width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10,),
                    const Text(Constants.unavailableTryAgain, style: TextStyle(
                        fontSize: 14, color: AppColors.callerStatus),),
                    const SizedBox(height: 16,),
                    Obx(() {
                      return Text(controller.calleeName.value,
                        style: const TextStyle(fontSize: 18, color: Colors.white),);
                    }),
                    const SizedBox(height: 13,),
                    Obx(() {
                      return buildProfileImage(controller.profile.value);
                    }),
                    /*ClipOval(
                      child: Image.asset(
                        groupImg,
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                      ),
                    ),*/
                  ],
                ),
              ),

              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: AppColors.bottomCallOptionBackground,
                  width: MediaQuery
                      .of(context)
                      .size
                      .width,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => controller.cancelCallTimeout(),
                          child: Column(
                            children: [
                              FloatingActionButton(
                                heroTag: "cancelTimeout",
                                elevation: 0,
                                backgroundColor: Colors.white,
                                onPressed: () { controller.cancelCallTimeout(); },
                                child: SvgPicture.asset(callCancel),
                              ),
                              const SizedBox(height: 13,),
                              const Text(Constants.cancel, style: TextStyle(
                                  fontSize: 12, color: Colors.white))
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => controller.callAgain(),
                          child: Column(
                            children: [
                              FloatingActionButton(
                                heroTag: "callAgain",
                                elevation: 0,
                                backgroundColor: AppColors.callAgainButtonBackground,
                                onPressed: () { controller.callAgain(); },
                                child: controller.callType.value.toUpperCase() ==
                                    Constants.mAudio ?
                                SvgPicture.asset(audioCallAgain) : SvgPicture
                                    .asset(videoCallAgain),
                              ),
                              const SizedBox(height: 13,),
                              const Text(Constants.callAgain, style: TextStyle(
                                  fontSize: 12, color: Colors.white))
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        )
    );
  }
}
