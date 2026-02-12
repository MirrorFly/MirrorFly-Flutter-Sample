
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';

import '../../common/app_localizations.dart';
import '../../common/constants.dart';
import '../../data/permissions.dart';
import '../../data/utils.dart';
import '../../routes/route_settings.dart';
import '../callkit_event_buffer.dart';

class SipCallController extends GetxController {

  final sipNumber = ''.obs;
  var india = CountryData(name: "India", dialCode: "+91", code: "IN");
  var selectedCountry = CountryData(name: "India", dialCode: "+91", code: "IN").obs;
  late TextEditingController dialTextController = TextEditingController();

  @override
  Future<void> onInit() async {
    super.onInit();
    // sipNumber(NavUtils.arguments["sipNumber"] ?? '');
    ever(sipNumber, (value) {
      dialTextController.text = value;
      dialTextController.selection = TextSelection.collapsed(
        offset: dialTextController.text.length,
      );
    });
  }

  @override
  void onClose() {
    dialTextController.dispose();
    super.onClose();
  }

  void cancelCallTimeout() {
    NavUtils.back();
  }


  /// ------------------ ///
  /// SIP call related ///
  /// ------------------ ///


  void addDialledNumber(String digit) {
    if (sipNumber.value.length >= 13) {
      return;
    }
    sipNumber.value += digit;
  }

  void removeLastDigit() {

    if (sipNumber.value.isEmpty) {
      return;
    }

    sipNumber.value = sipNumber.value.substring(0, sipNumber.value.length - 1);
  }

  void clearDialPad() {
    sipNumber.value = '';
  }

  void makeSIPCall() async{
    if (sipNumber.value.isEmpty) {
      toToast("Please enter a SIP number");
      return;
    }

    if((await MirrorFlyCallKit.isOngoingCall())){
      toToast(getTranslated("msgOngoingCallAlert"));
      return;
    }
    debugPrint('Calling ${sipNumber.value}');

    if (await AppUtils.isNetConnected()) {
      if (await AppPermission.askAudioCallPermissions()) {
        CallKitEventBuffer.flushAllEvents();
        MirrorFlyCallKit.makeSIPCall(sipNumber: "${selectedCountry.value.dialCode}${sipNumber.value}", flyResult: (FlyResult response) {
          if (response.isSuccess) {
            debugPrint('SIP Call initiated successfully');
            NavUtils.toNamed(Routes.callKitOutGoingCallView, arguments: {
              "callType": CallType.audio,
              "callMode": "ONE-TO-ONE",
              "chatId": ''
            });
          } else {
            debugPrint('SIP Call initiation failed: ${response.message}');
            toToast(response.message ?? response.data);
          }
        });
      } else {
        toToast("Permission is not granted");
        debugPrint("permission not given");
      }
    } else {
      toToast(getTranslated("noInternetConnection"));
    }
  }

  showCountryCodePicker() {
    NavUtils.toNamed(Routes.countries).then((value) => value!=null ? selectedCountry.value = value : india);
  }
}