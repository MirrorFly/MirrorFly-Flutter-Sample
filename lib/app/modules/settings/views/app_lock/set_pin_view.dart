import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../common/app_localizations.dart';
import '../../../../common/widgets.dart';

import '../../../../common/constants.dart';
import '../../../../data/utils.dart';
import '../../../../extensions/extensions.dart';
import 'app_lock_controller.dart';

class SetPinView extends NavView<AppLockController> {
  const SetPinView({Key? key}) : super(key: key);

  @override
AppLockController createController({String? tag}) => AppLockController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(controller.modifyPin.value ? getTranslated("changePin") : getTranslated("pinLock"),
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
                  child: passwordField(title: getTranslated("enterOldPIN"),
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
              passwordField(title: getTranslated("enterNewPIN"),
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
              passwordField(title: getTranslated("confirmNewPIN"),
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
                  child: Text(
                    getTranslated("save"),style: const TextStyle(color: Colors.white),
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
              AppUtils.svgIcon(icon:lockOutlineBlack, width: 24, height: 24,),
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
              IconButton(icon: AppUtils.assetIcon(assetName:
                secure ? eyeOff : eyeOn, width: 24, height: 24,),
                onPressed: eyeTap,)
            ],
          ),
          const AppDivider()
          /* ListItem(leading:AppUtils.svgIcon(icon:lockOutlineBlack,width: 24,height: 24,),
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
          ),dividerPadding: EdgeInsets.zero,trailing: IconButton(icon: AppUtils.assetIcon(assetName:secure ? eyeOff : eyeOn,width: 24,height: 24,), onPressed: eyeTap,))*/
        ],
      ),
    );
  }
}
