import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meta/meta.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirror_fly_demo/app/data/SessionManagement.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';
import 'package:mirror_fly_demo/app/modules/settings/views/applock/setpin_view.dart';

import '../../../../routes/app_pages.dart';

class AppLockController extends GetxController {
  final _pinenabled = false.obs;

  set pinenabled(value) => _pinenabled.value = value;

  get pinenabled => _pinenabled.value;

  final _bioenabled = false.obs;

  set bioenabled(value) => _bioenabled.value = value;

  get bioenabled => _bioenabled.value;

  @override
  void onInit() {
    super.onInit();
    _pinenabled(SessionManagement().getEnablePin());
    _bioenabled(SessionManagement().getEnableBio());
  }

  final changepin = false.obs;
  final TextEditingController newpin = TextEditingController();
  final TextEditingController confimpin = TextEditingController();
  final TextEditingController oldpin = TextEditingController();
  var frombio = false;
  var offpin = false;

  enablePin() {
    if (SessionManagement().getEnablePin()) {
      //to confirm pin to off pin
      offpin = true;
      Get.toNamed(Routes.PIN);
    } else {
      Get.toNamed(Routes.SET_PIN);
    }
  }

  enableBio() {
    if (SessionManagement().getEnablePin()) {
      if (SessionManagement().getEnableBio()) {
        //to confirm pin to off bio
        SessionManagement.setEnableBio(false);
        _bioenabled(false);
      } else {
        SessionManagement.setEnableBio(true);
        _bioenabled(true);
      }
    } else {
      //enable pin to enable bio alert popup
      Helper.showAlert(
          message:
              "You need to set pin first in order to enable bio metric authentication",
          actions: [
            TextButton(
                onPressed: () {
                  frombio = true;
                  enablePin();
                },
                child: const Text("OK")),
          ]);
    }
  }

  changePin() {
    changepin(true);
    Get.toNamed(Routes.PIN);
  }

  savePin() {
    if (changepin.value) {
      if (oldpin.text.isNotEmpty) {
        if (oldpin.text == SessionManagement().getPin()) {
          setPin();
        } else {
          toToast("Old PIN not Matched");
        }
      } else {
        toToast("Enter Old PIN");
      }
    } else {
      setPin();
    }
  }

  setPin() {
    if (newpin.text.isNotEmpty && confimpin.text.isNotEmpty) {
      if (newpin.text == confimpin.text) {
        SessionManagement.setPIN(newpin.text);
        SessionManagement.setEnablePIN(true);
        SessionManagement.setEnableBio(frombio);
        _pinenabled(true);
        _bioenabled(frombio);
        changepin(false);
        Get.back();
      } else {
        toToast("PIN not Matched");
      }
    } else {
      toToast("Enter New and Confirm PIN");
    }
  }

  disablePIN() {
    if (SessionManagement().getEnablePin()) {
      //to confirm pin to off pin
      SessionManagement.setPIN("");
      SessionManagement.setEnablePIN(false);
      SessionManagement.setEnableBio(false);
      _pinenabled(false);
      _bioenabled(false);
      Get.back();
    }
  }

  final _pin1 = false.obs;

  get pin1 => _pin1.value;
  final _pin2 = false.obs;

  get pin2 => _pin2.value;
  final _pin3 = false.obs;

  get pin3 => _pin3.value;
  final _pin4 = false.obs;

  get pin4 => _pin4.value;

  var text = <int>[];

  numberClick(int num) {
    if (num != 10) {
      if (!pin1) {
        _pin1(true);
        text.add(num);
      } else if (!pin2) {
        _pin2(true);
        text.add(num);
      } else if (!pin3) {
        _pin3(true);
        text.add(num);
      } else if (!pin4) {
        _pin4(true);
        text.add(num);
        validateAndUnlock();
      }
    } else {
      removeClick();
    }
    Log("add text", text.join().toString());
  }

  removeClick() {
    if (pin4) {
      _pin4(false);
      text.removeLast();
    } else if (pin3) {
      _pin3(false);
      text.removeLast();
    } else if (pin2) {
      _pin2(false);
      text.removeLast();
    } else if (pin1) {
      _pin1(false);
      text.removeLast();
    } else {}
    Log("rem text", text.join().toString());
  }

  validateAndUnlock() {
    if (text.isNotEmpty && text.length == 4) {
      if (SessionManagement().getPin() == text.join()) {
        if (offpin) {
          offpin = false;
          disablePIN();
        } else if(changepin.value){
          Get.offNamed(Routes.SET_PIN);
        }
        else {
          Get.offAllNamed(getIntialRoute());
        }
      } else {
        toToast("Invalid PIN! Try again");
      }
    }
  }

  String getIntialRoute() {
    if (SessionManagement().getLogin()) {
      if (SessionManagement().getName().checkNull().isNotEmpty &&
          SessionManagement().getMobileNumber().checkNull().isNotEmpty) {
        return AppPages.DASHBOARD;
      } else {
        return AppPages.PROFILE;
      }
    } else {
      return AppPages.INITIAL;
    }
  }
}
