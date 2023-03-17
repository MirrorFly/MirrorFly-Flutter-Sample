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
        title: Text(controller.modifyPin.value ? 'Change PIN' : 'PIN Lock'),
        automaticallyImplyLeading: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Visibility(visible:controller.modifyPin.value,child: passwordField(title: 'Enter old PIN',controller: controller.oldPin,secure: true,eyeTap: (){})),
            Visibility(
              visible: controller.modifyPin.value,
              child: const SizedBox(
                height: 10,
              ),
            ),
            passwordField(title: 'Enter new PIN',controller:controller.newPin,secure: true,eyeTap: (){}),
            const SizedBox(
              height: 10,
            ),
            passwordField(title: 'Confirm new PIN',controller: controller.confirmPin,secure: true,eyeTap: (){}),
            const SizedBox(
              height: 40,
            ),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: buttonBgColor,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 10),
                    textStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500),
                    shape: const StadiumBorder()),
                onPressed: () {
                  controller.savePin();
                },
                child: const Text(
                  'Save',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget passwordField({required String title,TextEditingController? controller,required bool secure,required Function() eyeTap}){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0,left: 16.0,top: 16.0),
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
          ),
        ),
        ListItem(leading:SvgPicture.asset(lockIcon,width: 24,height: 24,),
            title: TextField(
              controller: controller,
              onChanged: (value) {},
              obscureText: secure,
              maxLength: 4,
              enableSuggestions: false,
              autocorrect: false,
              keyboardType: TextInputType.number,
              inputFormatters: [ FilteringTextInputFormatter.allow(RegExp('[0-9]')),],
              decoration: const InputDecoration(
                  border: InputBorder.none,
                  counterText: ""
              ),
              style: const TextStyle(fontWeight: FontWeight.normal,fontSize: 16),
        ),dividerPadding: EdgeInsets.zero,trailing: IconButton(icon: Image.asset(secure ? eyeOff : eyeOn,width: 24,height: 24,), onPressed: eyeTap,))

      ],
    );
  }
}
