import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/modules/login/controllers/login_controller.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/otp_field_style.dart';
import 'package:otp_text_field/style.dart';

import '../../../common/constants.dart';

class OtpView extends GetView<LoginController> {
  const OtpView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Verify'),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(10.0),
              height: MediaQuery
                  .of(context)
                  .size
                  .height - 80,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: SvgPicture.asset(registerIcon),
                        ),
                        const Text(
                          'Verify OTP',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w600),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 8.0, right: 8, left: 8),
                          child: Text(
                            'We have sent you the SMS. To complete the registration enter the 6 digit verification code below',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w300,
                                color: textColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          OTPTextField(
                              controller: controller.otpController,
                              length: 6,
                              width: MediaQuery
                                  .of(context)
                                  .size
                                  .width,
                              textFieldAlignment: MainAxisAlignment.center,
                              margin: const EdgeInsets.all(4),
                              fieldWidth: 40,
                              fieldStyle: FieldStyle.box,
                              outlineBorderRadius: 10,
                              style: const TextStyle(fontSize: 16),
                              otpFieldStyle: OtpFieldStyle(),
                              onChanged: (String pin) {
                                controller.smsCode = (pin);
                              }),
                          const SizedBox(
                            height: 25,
                          ),
                          Obx(() {
                            return Visibility(
                              visible: controller.verifyVisible.value,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: buttonBgColor,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 40, vertical: 10),
                                    textStyle: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500),
                                    shape: const StadiumBorder()),
                                onPressed: () {
                                  // controller.verifyOTP();
                                },
                                child: const Text(
                                  'Verify OTP',
                                ),
                              ),
                            );
                          }),
                          const SizedBox(
                            height: 15,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Obx(() {
                              //   return
                          InkWell(
                                  onTap: //controller.timeout.value ? () {
                              (){controller.gotoLogin();},
                                  //} : controller.gotoLogin(),
                                  child: const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      'Change Number',
                                      style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ),
                              // }),
                              Container(
                                color: dividerColor,
                                width: 1,
                                height: 15,
                              ),
                              Obx(() {
                                return InkWell(
                                  onTap: controller.timeout.value ? () {
                                    controller.resend();
                                  } : null,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      controller.timeout.value ? 'Resend OTP' : '00:${controller.seconds.value.toStringAsFixed(0).padLeft(2,'0')}',
                                      style: const TextStyle(
                                          color: textHintColor,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ],
                      ))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
