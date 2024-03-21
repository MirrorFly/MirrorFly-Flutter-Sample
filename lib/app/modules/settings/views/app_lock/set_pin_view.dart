import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/widgets.dart';

import '../../../../common/constants.dart';
import 'app_lock_controller.dart';

class SetPinView extends GetView<AppLockController> {
  const SetPinView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(controller.modifyPin.value ? 'Change PIN' : 'PIN Lock',
          style: const TextStyle(fontWeight: FontWeight.bold,
              color: appbarTextColor,
              fontSize: 20.0),),
        automaticallyImplyLeading: true,
        backgroundColor: const Color(0XffF2F2F2),
      ),
      body: SingleChildScrollView(
        child: Obx(() {
          return Column(
            children: [
              Visibility(visible: controller.modifyPin.value,
                  child: passwordField(title: 'Enter old PIN',
                      controller: controller.oldPin,
                      secure: controller.oldPinSecure.value,
                      focusNode: controller.oldPinFocus,
                      textAction: TextInputAction.next,
                      eyeTap: () {
                    controller.oldPinSecure(!controller.oldPinSecure.value);
                      }, onSubmit: (String value) {
                    controller.newPinFocus.requestFocus();
                      })),
              Visibility(
                visible: controller.modifyPin.value,
                child: const SizedBox(
                  height: 10,
                ),
              ),
              passwordField(title: 'Enter new PIN',
                  controller: controller.newPin,
                  secure: controller.newPinSecure.value,
                  focusNode: controller.newPinFocus,
                  textAction: TextInputAction.next,
                  eyeTap: () {
                    controller.newPinSecure(!controller.newPinSecure.value);
                  }, onSubmit: (String value) {
                    controller.confirmPinFocus.requestFocus();
                  }),
              const SizedBox(
                height: 10,
              ),
              passwordField(title: 'Confirm new PIN',
                  controller: controller.confirmPin,
                  secure: controller.confirmPinSecure.value,
                  focusNode: controller.confirmPinFocus,
                  textAction: TextInputAction.done,
                  eyeTap: () {
                    controller.confirmPinSecure(!controller.confirmPinSecure.value);
                  }, onSubmit: (String value) {
                    controller.confirmPinFocus.unfocus();
                  }),
              const SizedBox(
                height: 40,
              ),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: buttonBgColor,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 15),
                      textStyle: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15.0),
                      shape: const StadiumBorder()),
                  onPressed: () {
                    controller.savePin();
                  },
                  child: const Text(
                    'Save',style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget passwordField(
      {required String title, TextEditingController? controller, required bool secure, required FocusNode focusNode,required TextInputAction textAction, required Function(String value) onSubmit, required Function() eyeTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
            ),
          ),
          Row(
            children: [
              SvgPicture.asset(lockOutlineBlack, width: 24, height: 24,),
              Expanded(
                child: TextFormField(
                  textInputAction: textAction,
                  controller: controller,
                  onChanged: (value) {},
                  obscureText: secure,
                  focusNode: focusNode,
                  maxLength: 4,
                  autofocus: true,
                  enableSuggestions: false,
                  autocorrect: false,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                  ],
                  decoration: const InputDecoration(
                      border: InputBorder.none,
                      counterText: "",
                      contentPadding: EdgeInsets.symmetric(horizontal: 8),
                      isDense: true,
                  ),
                  onFieldSubmitted: onSubmit,
                  style: const TextStyle(fontWeight: FontWeight.normal,
                      fontSize: 20,
                      letterSpacing: 16.0,
                      color: textColor),
                ),
              ),
              IconButton(icon: Image.asset(
                secure ? eyeOff : eyeOn, width: 24, height: 24,),
                onPressed: eyeTap,)
            ],
          ),
          const AppDivider()
          /* ListItem(leading:SvgPicture.asset(lockOutlineBlack,width: 24,height: 24,),
              title: TextField(
                controller: controller,
                onChanged: (value) {},
                obscureText: secure,
                autofocus: true,
                maxLength: 4,
                enableSuggestions: false,
                autocorrect: false,
                keyboardType: TextInputType.number,
                inputFormatters: [ FilteringTextInputFormatter.allow(RegExp('[0-9]')),],
                decoration: const InputDecoration(
                    border: InputBorder.none,
                    counterText: ""
                ),
                style: const TextStyle(fontWeight: FontWeight.normal,fontSize: 20),
          ),dividerPadding: EdgeInsets.zero,trailing: IconButton(icon: Image.asset(secure ? eyeOff : eyeOn,width: 24,height: 24,), onPressed: eyeTap,))*/
        ],
      ),
    );
  }
}
