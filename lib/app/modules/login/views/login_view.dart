import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/widgets.dart';
import 'package:mirror_fly_demo/app/routes/app_pages.dart';

import '../../../common/constants.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({Key? key}) : super(key: key);

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
        body: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(12.0),
              height: MediaQuery
                  .of(context)
                  .size
                  .height-25,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 30),
                        child: SvgPicture.asset(registerIcon),
                      ),
                      const Text(
                        'Register Your Number',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w600),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(top: 10.0, right: 8, left: 8),
                        child: Text(
                          'Please choose your country code and enter your mobile number to get the verification code.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w300,
                              color: textColor),
                        ),
                      ),
                    ],
                  )),
                  Expanded(child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Obx(() => Padding(
                        padding: const EdgeInsets.only(left : 10.0 , right: 10.0,top: 10.0),
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(controller.selectedCountry.value.name ?? "",
                              style: const TextStyle(color: Colors.black,fontSize: 16,fontWeight: FontWeight.w500)),
                          trailing: const Icon(Icons.keyboard_arrow_down_outlined),
                          onTap: (){
                            Get.toNamed(Routes.countries)?.then((value) => value!=null ? controller.selectedCountry.value = value : controller.india);
                          },
                        ),
                      )),
                      const AppDivider(),
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                        child: IntrinsicHeight(
                          child: Row(
                            children: [
                              Obx(
                                    ()=> Text(
                                  controller.selectedCountry.value.dialCode ?? "",
                                  style: const TextStyle(fontSize: 15),
                                ),
                              ),
                              const VerticalDivider(
                                color: Colors.grey,
                                thickness: 0.3,
                              ),
                              Flexible(
                                child: TextField(
                                  controller: controller.mobileNumber,
                                  keyboardType: TextInputType.phone,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(13)
                                  ],
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Enter Mobile Number',
                                    //hintStyle: TextStyle(color: Colors.black26)
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: buttonBgColor,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 10),
                            textStyle: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500),
                            shape: const StadiumBorder()),
                        onPressed: () {
                          controller.registerUser();
                        },
                        child: const Text(
                          'Continue',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text('By clicking continue you agree to MirrorFly',style: TextStyle(color: textColor,fontSize: 13,fontWeight: FontWeight.w300),),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            child: const Text(
                              'Terms and Condition,',
                              style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  color: buttonBgColor),
                            ),
                            onTap:()=>launchWeb(Constants.termsConditions),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          InkWell(
                            child: const Text(
                              'Privacy Policy.',
                              style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  color: buttonBgColor),
                            ),
                            onTap: ()=>launchWeb(Constants.privacyPolicy),
                          ),
                        ],
                      )
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
