import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../common/constants.dart';
import '../controllers/call_timeout_controller.dart';

class CallTimeoutView extends GetView<CallTimeoutController> {
  const CallTimeoutView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.callerBackground,
      body: Stack(
        alignment: Alignment.center,
        children: [
          Text('Unavailable, Try again later'),
          Text('Caller Name'),
          ClipOval(
            child: Image.asset(
              groupImg,
              height: 48,
              width: 48,
              fit: BoxFit.cover,
            ),
          ),
          Container(
            color: AppColors.bottomCallOptionBackground,
            height: 100,
            width: MediaQuery.of(context).size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    ClipOval(
                      child: Image.asset(
                        groupImg,
                        height: 48,
                        width: 48,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Text('Cancel')
                  ],
                ),
                Column(
                  children: [
                    ClipOval(
                      child: Image.asset(
                        groupImg,
                        height: 48,
                        width: 48,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Text('Call Again')
                  ],
                )
              ],
            ),
          )
        ],
      )
    );
  }
}
