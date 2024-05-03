import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/app_localizations.dart';
import 'package:mirror_fly_demo/app/common/widgets.dart';
import '../../../routes/route_settings.dart';

import '../../../common/constants.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        /*FocusScopeNode currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus) {
                currentFocus.unfocus();
              }*/
        controller.focusNode.unfocus();
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    child: SvgPicture.asset(registerIcon),
                  ),
                  Text(
                    getTranslated("registerYourNumber", context),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0, right: 8, left: 8),
                    child: Text(
                      getTranslated("registerMessage",context),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w300,
                          color: textColor),
                    ),
                  ),
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
                              focusNode: controller.focusNode,
                              cursorColor: buttonBgColor,
                              controller: controller.mobileNumber,
                              keyboardType: TextInputType.phone,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(13)
                              ],
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: getTranslated("enterMobileNumber", context),
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
                    child: Text(
                      getTranslated("continue", context),
                      style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(getTranslated("agree", context),style: const TextStyle(color: textColor,fontSize: 13,fontWeight: FontWeight.w300),),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        child: Text(
                          '${getTranslated("termsAndCondition", context)},',
                          style: const TextStyle(
                              decoration: TextDecoration.underline,
                              color: buttonBgColor),
                        ),
                        onTap:()=>launchWeb(Constants.termsConditions),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      InkWell(
                        child: Text(
                          '${getTranslated("privacyPolicy", context)}.',
                          style: const TextStyle(
                              decoration: TextDecoration.underline,
                              color: buttonBgColor),
                        ),
                        onTap: ()=>launchWeb(Constants.privacyPolicy),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
