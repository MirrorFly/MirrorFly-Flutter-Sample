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
    return Scaffold(
      /*appBar: AppBar(
        title: const Text('Register'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),*/
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: SvgPicture.asset(registericon),
                ),
                const Text(
                  'Register Your Number',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20,fontWeight: FontWeight.w600),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: const Text(
                    'Please choose your country code and enter your mobile number to get the verification code.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13,fontWeight: FontWeight.w300),
                  ),
                ),
                const SizedBox(
                  height: 50,
                ),
                Obx(() => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(controller.selectedCountry.value.name,
                          style: TextStyle(color: Colors.black,fontSize: 16,fontWeight: FontWeight.w500)),
                      trailing: Icon(Icons.keyboard_arrow_down_outlined),
                  onTap: (){
                        Get.toNamed(Routes.COUNTRIES)?.then((value) => value!=null ? controller.selectedCountry.value = value : controller.india);
                  },
                    )),
                AppDivider(padding: 0,),
                IntrinsicHeight(
                  child: Row(
                    children: [
                      Obx(
                        ()=> Text(
                          controller.selectedCountry.value.dialCode,
                          style: TextStyle(fontSize: 15),
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
                            FilteringTextInputFormatter.digitsOnly
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
                const SizedBox(
                  height: 50,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 15),
                      textStyle: const TextStyle(fontSize: 14),
                      shape: const StadiumBorder()),
                  onPressed: () {
                    controller.registerUser(context);
                  },
                  child: const Text(
                    'Continue',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(
                  height: 50,
                ),
                const Text('By clicking continue you agree to MirroFly'),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      child: Text(
                        'Terms and Condition,',
                        style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: Colors.blue),
                      ),
                      onTap:()=>launchWeb(Constants.Terms_Conditions),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    InkWell(
                      child: Text(
                        'Privacy Policy.',
                        style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: Colors.blue),
                      ),
                      onTap: ()=>launchWeb(Constants.Privacy_Policy),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
