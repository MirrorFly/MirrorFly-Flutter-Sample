import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/modules/login/controllers/login_controller.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/otp_field_style.dart';
import 'package:otp_text_field/style.dart';

import '../../../common/constants.dart';

class OtpView extends GetView<LoginController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(12.0),
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
                        padding: const EdgeInsets.symmetric(vertical: 30),
                        child: SvgPicture.asset(registericon),
                      ),
                      const Text(
                        'Verify OTP',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w600),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(top: 10.0, right: 8, left: 8),
                        child: Text(
                          'We have sent you the SMS. To complete the registration enter the 6 digit verification code below',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w300,
                              color: textcolor),
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
                          height: 30,
                        ),
                        Obx(() {
                          return Visibility(
                            visible: controller.verify_visible.value,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: buttonbgcolor,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 40, vertical: 10),
                                  textStyle: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500),
                                  shape: const StadiumBorder()),
                              onPressed: () {
                                controller.verifyOTP();
                              },
                              child: const Text(
                                'Verify OTP',
                              ),
                            ),
                          );
                        }),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InkWell(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: const Text(
                                  'Change Number',
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                              onTap: controller.timeout.value ? () {
                                controller.gotoLogin();
                              } : null,
                            ),
                            Container(
                              color: dividercolor,
                              width: 1,
                              height: 15,
                            ),
                            Obx(() {
                              return InkWell(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: const Text(
                                    'Resend OTP',
                                    style: TextStyle(
                                        color: texthintcolor,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                                onTap: controller.timeout.value ? () {
                                  controller.resend();
                                } : null,
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
    );
  }
}
