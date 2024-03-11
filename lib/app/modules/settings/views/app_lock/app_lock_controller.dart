import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirror_fly_demo/app/data/session_management.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';
import 'package:mirror_fly_demo/main.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/otp_field_style.dart';
import 'package:otp_text_field/style.dart';
import 'package:mirror_fly_demo/app/common/extensions.dart';

import '../../../../data/apputils.dart';
import '../../../../routes/app_pages.dart';

class AppLockController extends FullLifeCycleController
    with FullLifeCycleMixin,GetTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _pinEnabled = false.obs;

  set pinEnabled(value) => _pinEnabled.value = value;

  get pinEnabled => _pinEnabled.value;

  final _bioEnabled = false.obs;

  set bioEnabled(value) => _bioEnabled.value = value;

  get bioEnabled => _bioEnabled.value;

  @override
  void onInit() {
    super.onInit();
    _pinEnabled(SessionManagement.getEnablePin());
    _bioEnabled(SessionManagement.getEnableBio());
  }

  @override
  void onReady() {
    super.onReady();
    if (Get.currentRoute == Routes.pin) {
      setUpPinExpiryDialog();
    }
  }

  final modifyPin = false.obs;
  final TextEditingController newPin = TextEditingController();
  final TextEditingController confirmPin = TextEditingController();
  final TextEditingController oldPin = TextEditingController();

  FocusNode newPinFocus = FocusNode();
  FocusNode confirmPinFocus = FocusNode();
  FocusNode oldPinFocus = FocusNode();
  RxBool newPinSecure = true.obs;
  RxBool confirmPinSecure = true.obs;
  RxBool oldPinSecure = true.obs;
  var fromBio = false;
  var offPin = false;

  enablePin() {
    if (SessionManagement.getEnablePin()) {
      //to confirm pin to off pin
      offPin = true;
      Get.toNamed(Routes.pin);
    } else {
      if (SessionManagement.getPin().isNotEmpty) {
        //if pin Available
        SessionManagement.setEnablePIN(true);
        SessionManagement.setPIN(SessionManagement.getPin());
        _pinEnabled(true);
      } else {
        Get.toNamed(Routes.setPin);
      }
    }
  }

  enableBio() {
    if (SessionManagement.getEnablePin()) {
      if (SessionManagement.getEnableBio()) {
        //to confirm pin to off bio
        SessionManagement.setEnableBio(false);
        _bioEnabled(false);
      } else {
        SessionManagement.setEnableBio(true);
        _bioEnabled(true);
      }
    } else {
      //enable pin to enable bio alert popup
      Helper.showAlert(
          message:
              "You need to set pin first in order to enable bio metric authentication",
          actions: [
            TextButton(
                onPressed: () {
                  fromBio = true;
                  enablePin();
                },
                child: const Text("OK")),
          ]);
    }
  }

  changePin() {
    modifyPin(true);
    clearTextViews();
    Get.toNamed(Routes.setPin)?.then((value) {
      Future.delayed(const Duration(milliseconds: 100), () {
        setUpPinExpiryDialog();
      });
    });
  }

  savePin() {
    if (validateOldAndNewPin()) {
      if (validatePin()) {
        setPin();
      } else {
        toToast(errorMessage);
      }
    } else {
      toToast(errorMessage);
    }
    /*if (modifyPin.value) {
      if (oldPin.text.isNotEmpty) {
        if (oldPin.text == SessionManagement.getPin()) {
          setPin();
        } else {
          toToast("Old PIN not Matched");
        }
      } else {
        toToast("Enter Old PIN");
      }
    } else {
      setPin();
    }*/
  }

  clearTextViews() {
    newPin.clear();
    confirmPin.clear();
    oldPin.clear();
  }

  setPin() {
    if (newPin.text.isNotEmpty && confirmPin.text.isNotEmpty) {
      if (newPin.text == confirmPin.text) {
        SessionManagement.setPIN(newPin.text);
        SessionManagement.setChangePinNext(newPin.text);
        SessionManagement.setEnablePIN(true);
        SessionManagement.setEnableBio(fromBio);
        (modifyPin.value)
            ? toToast('PIN changed successfully')
            : toToast('PIN set successfully');
        _pinEnabled(true);
        _bioEnabled(fromBio);
        modifyPin(false);
        Get.back(result: true);
      } else {
        toToast("PIN not Matched");
      }
    } else {
      toToast("Enter New and Confirm PIN");
    }
  }

  /// to validate the pin
  var errorMessage = '';

  bool validateOldAndNewPin() {
    if (modifyPin.value) {
      if (oldPin.text.toString() != SessionManagement.getPin()) {
        errorMessage = "Invalid old PIN";
        return false;
      }
      return validatePin();
    }
    return true;
  }

  bool validatePin() {
    if (newPin.text.isEmpty) {
      errorMessage = "Enter the PIN";
      return false;
    } else if (newPin.text.length < 4) {
      errorMessage = "PIN must be of 4 digits";
      return false;
    } else if (confirmPin.text.isEmpty) {
      errorMessage = "Enter the Confirm PIN";
      return false;
    } else if (confirmPin.text.length < 4) {
      errorMessage = "Confirm PIN must be of 4 digits";
      return false;
    } else if (newPin.text.toString() != confirmPin.text.toString()) {
      errorMessage = "PIN and Confirm PIN must be same";
      return false;
    } else if (modifyPin.value &&
            oldPin.text.toString() == confirmPin.text.toString() ||
        SessionManagement.getPin() == confirmPin.text.toString()) {
      errorMessage = "Old PIN and new PIN should not be same";
      return false;
    } else if (!modifyPin.value &&
        newPin.text.toString() == SessionManagement.getChangePinNext()) {
      errorMessage = "PIN should not be same as immediate previous PIN";
      return false;
    } else {
      errorMessage = '';
      return true;
    }
  }

  disablePIN() {
    if (SessionManagement.getEnablePin()) {
      //to confirm pin to off pin
      //SessionManagement.setPIN("");
      SessionManagement.setEnablePIN(false);
      SessionManagement.setEnableBio(false);
      _pinEnabled(false);
      _bioEnabled(false);
      if (Get.previousRoute.isEmpty || Get.previousRoute == Routes.pin) {
        Get.offNamed(getInitialRoute());
      } else {
        Get.back(result: true);
      }
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
        Future.delayed(const Duration(milliseconds: 200),(){
          validateAndUnlock();
        });
      }
    } else {
      removeClick();
    }
    mirrorFlyLog("add text", text.join().toString());
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
    mirrorFlyLog("rem text", text.join().toString());
  }

  int wrongPinCount = 0;

  validateAndUnlock() {
    if (text.isNotEmpty && text.length == 4) {
      if (SessionManagement.getPin() == text.join()) {
        clearFields();
        if (offPin || disablePin) {
          offPin = false;
          disablePIN();
        } else if (modifyPin.value) {
          Get.offNamed(Routes.setPin);
        } else {
          debugPrint('route ${Get.previousRoute}');
          if (Get.previousRoute.isEmpty || Get.previousRoute == Routes.pin) {
            Get.offNamed(getInitialRoute());
          } else {
            Get.back(result: true);
          }
        }
      } else {
        wrongPinCount++;
        if (wrongPinCount > 5) {
          forgetPin(fromInvalid: true);
        }
        if (wrongPinCount <= 6) {
          toToast("Invalid PIN! Try again");
        }
        clearFields();
      }
    }
  }

  void clearFields() {
    _pin1(false);
    _pin2(false);
    _pin3(false);
    _pin4(false);
    text.clear();
  }

  void forgetPin({bool fromInvalid = false}) {
    Get.dialog(AlertDialog(
      titlePadding: const EdgeInsets.only(top: 20, right: 20, left: 20),
      contentPadding: EdgeInsets.zero,
      title: Text(
        fromInvalid ? Constants.invalidPinOTPText : Constants.forgetPinOTPText,
        style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      actions: [
        TextButton(
            onPressed: () {
              Get.back();
            },
            child: const Text(
              'CANCEL',
              style: TextStyle(color: buttonBgColor),
            )),
        TextButton(
            onPressed: () {
              Get.back();
              sendOtp();
            },
            child: const Text(
              'GENERATE OTP',
              style: TextStyle(color: buttonBgColor),
            )),
      ],
    ));
  }

  @override
  void onDetached() {}

  @override
  void onInactive() {}

  @override
  void onPaused() {}

  @override
  void onResumed() {
    if (Get.currentRoute == Routes.setPin) {
      if (!KeyboardVisibilityController().isVisible) {
        if (oldPinFocus.hasFocus) {
          oldPinFocus.unfocus();
          Future.delayed(const Duration(milliseconds: 100), () {
            oldPinFocus.requestFocus();
          });
        } else if (newPinFocus.hasFocus) {
          newPinFocus.unfocus();
          Future.delayed(const Duration(milliseconds: 100), () {
            newPinFocus.requestFocus();
          });
        } else if (confirmPinFocus.hasFocus) {
          confirmPinFocus.unfocus();
          Future.delayed(const Duration(milliseconds: 100), () {
            confirmPinFocus.requestFocus();
          });
        }
      }
    }
  }

  void setUpPinExpiryDialog() {
    var lastSession = SessionManagement.appLastSession();
    var lastPinChangedAt = SessionManagement.lastPinChangedAt();
    var sessionDifference = DateTime.now()
        .difference(DateTime.fromMillisecondsSinceEpoch(lastSession,isUtc: true));
    var lockSessionDifference = DateTime.now()
        .difference(DateTime.fromMillisecondsSinceEpoch(lastPinChangedAt,isUtc: true));
    debugPrint('sessionDifference seconds ${sessionDifference.inSeconds}');
    debugPrint('lockSessionDifference days ${lockSessionDifference.inDays}');
    if (Constants.pinAlert <= lockSessionDifference.inDays &&
        Constants.pinExpiry >= lockSessionDifference.inDays) {
      //Alert Day
      debugPrint('Alert Day');
      if(SessionManagement.showAlert()) {
        showAlertDateDialog(
            (Constants.pinExpiry - lockSessionDifference.inDays) + 1);
      }
    } else if (Constants.pinExpiry < lockSessionDifference.inDays) {
      //Already Expired day
      debugPrint('Already Expired');
      showExpiredDialog();
    } else {
      //if 30 days not completed
      debugPrint('Not Expired');
      if (Constants.sessionLockTime <= sessionDifference.inSeconds) {
        //Show Pin if App Lock Enabled
        debugPrint('Show Pin');
      }
    }
  }

  void showAlertDateDialog(int daysBetween) {
    Get.dialog(AlertDialog(
      titlePadding: const EdgeInsets.only(top: 20, right: 20, left: 20),
      contentPadding: EdgeInsets.zero,
      title: Text(
        'Your PIN will be expired in $daysBetween day(s)',
        style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      actions: [
        TextButton(
            onPressed: () {
              Get.back();
              changePin();
            },
            child: const Text(
              'Change PIN',
              style: TextStyle(color: buttonBgColor),
            )),
        TextButton(
            onPressed: () {
              Get.back();
              SessionManagement.setDontShowAlert();
            },
            child: const Text(
              'OK',
              style: TextStyle(color: buttonBgColor),
            )),
      ],
    ));
  }

  var disablePin = false;

  void showExpiredDialog() {
    Get.dialog(
        PopScope(
            canPop: false,
            onPopInvoked: (didPop) {
              if (didPop) {
                return;
              }},
          child: AlertDialog(
            titlePadding: const EdgeInsets.only(top: 20.0, right: 20, left: 20),
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'Your current PIN has been expired. Please set a new PIN to continue further',
              style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
            ),
            insetPadding: const EdgeInsets.symmetric(horizontal: 20),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                        onPressed: () {
                          toToast(
                              'Enter Current Pin To Disable Pin And FingerPrint');
                          disablePin = true;
                          Get.back();
                        },
                        child: const Text(
                          'Disable PIN',
                          style: TextStyle(
                            color: buttonBgColor,
                            fontSize: 16,
                          ),
                        )),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                        onPressed: () {
                          Get.back();
                          changePin();
                        },
                        child: const Text(
                          'Change PIN',
                          style: TextStyle(
                            color: buttonBgColor,
                            fontSize: 16,
                          ),
                        )),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                        onPressed: () {
                          Get.back();
                          sendOtp();
                        },
                        child: const Text(
                          'Forgot PIN?',
                          style: TextStyle(
                            color: Color(0XFFFF0000),
                            fontSize: 16,
                          ),
                        )),
                  ),
                ],
              ),
            ],
          ),
        ),
        barrierDismissible: false);
  }

  Future<void> sendOtp({bool fromInvalid = false}) async {
    if (await AppUtils.isNetConnected()) {
      Helper.showLoading(message: 'Sending OTP to your Mobile Number');
      sendVerificationCode();
    } else {
      toToast(Constants.noInternetConnection);
    }
  }

  Timer? countdownTimer;
  var myDuration = const Duration(seconds: 60).obs;
  final OtpFieldController otpController = OtpFieldController();
  String smsCode = '';
  var seconds = 60;
  RxBool timeout = false.obs;

  showOtpView() {
    if(!Get.isBottomSheetOpen.checkNull()) {
      Get.bottomSheet(
        isDismissible: false,
        isScrollControlled: true,
        BottomSheet(
            enableDrag: true,
            animationController: BottomSheet.createAnimationController(this),
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30))),
            onClosing: () {},
            builder: (builder) {
              return PopScope(
                  canPop: false,
                  onPopInvoked: (didPop) {
                    if (didPop) {
                      return;
                    }},
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.only(
                        top: 16.0,
                        left: 16.0,
                        right: 16.0,
                        bottom: MediaQuery
                            .of(Get.context!)
                            .viewInsets
                            .bottom),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Forget PIN ?',
                          textAlign: TextAlign.center,
                          style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 16.0, right: 8, left: 8),
                          child: Text(
                            'We have sent you the OTP to the registered mobile number enter the 6 digit verification code below',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w300,
                                color: Color(0Xff737373)),
                          ),
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        OTPTextField(
                            width: MediaQuery
                                .of(Get.context!)
                                .size
                                .width,
                            controller: otpController,
                            length: 6,
                            textFieldAlignment: MainAxisAlignment.center,
                            margin: const EdgeInsets.all(4),
                            fieldWidth: 40,
                            fieldStyle: FieldStyle.box,
                            outlineBorderRadius: 10,
                            style: const TextStyle(fontSize: 16),
                            otpFieldStyle: OtpFieldStyle(),
                            onChanged: (String pin) {
                              smsCode = (pin);
                            }),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Obx(() {
                            return InkWell(
                              onTap: () {
                                if (timeout.value) {
                                  resend();
                                }
                              },
                              child: Text(
                                timeout.value
                                    ? 'Resend OTP'
                                    : '00:${(myDuration.value.inSeconds.remainder(
                                    60).toStringAsFixed(0).padLeft(2, '0'))}',
                                style: TextStyle(
                                    color: timeout.value
                                        ? const Color(0XFFFF0000)
                                        : buttonBgColor,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500),
                              ),
                            );
                          }),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                                onPressed: () {
                                  Get.back();
                                },
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(
                                      color: Color(0XFFFF0000),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700),
                                )),
                            TextButton(
                                onPressed: () {
                                  verifyOTP();
                                },
                                child: const Text(
                                  'Verify OTP',
                                  style: TextStyle(
                                      color: buttonBgColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700),
                                ))
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              );
            }),
      );
    }
  }

  void startTimer() {
    timeout(false);
    seconds = (60);
    countdownTimer =
        Timer.periodic(const Duration(seconds: 1), (_) => setCountDown());
  }

  void setCountDown() {
    const reduceSecondsBy = 1;
    seconds = (seconds - reduceSecondsBy);
    if (seconds == 0 || seconds.isNegative) {
      countdownTimer!.cancel();
      timeout(true);
    } else {
      myDuration(Duration(seconds: seconds));
      debugPrint(seconds.toString());
    }
  }

  @override
  void dispose() {
    stopTimer();
    super.dispose();
  }

  void stopTimer() {
    countdownTimer!.cancel();
  }

  hideLoading() {
    Helper.hideLoading();
  }

  int? resendingToken;
  String? verificationId;

  Future<void> sendVerificationCode() async {
    var mobileNumber =
    /*${(SessionManagement.getCountryCode() ?? '').replaceAll('+', '')}*/'+${SessionManagement.getMobileNumber() ?? ''}';
    debugPrint('mobileNumber $mobileNumber');
    /*Future.delayed(const Duration(milliseconds: 500), () {
      hideLoading();
      showOtpView();
      startTimer();
    });*/

    if (kIsWeb) {
      final confirmationResult =
          await _auth.signInWithPhoneNumber(mobileNumber);
      final smsCode =
          otpController.toString(); //await getSmsCodeFromUser(context);
      await confirmationResult.confirm(smsCode);
    } else {
      await _auth.verifyPhoneNumber(
        phoneNumber: mobileNumber,
        timeout: const Duration(seconds: 30),
        verificationCompleted: _onVerificationCompleted,
        verificationFailed: (FirebaseAuthException e) {
          timeout(true);
          mirrorFlyLog("verificationFailed", e.toString());
          //verificationFailed==>[firebase_auth/too-many-requests] We have blocked all requests from this device due to unusual activity. Try again later.
          toToast("OTP sent failed");
          hideLoading();
        },
        codeSent: (String verificationId, int? resendToken) {
          mirrorFlyLog("codeSent", verificationId);
          this.verificationId = verificationId;
          resendingToken = resendToken;
          startTimer();
          toToast('OTP sent Successfully');
          if (verificationId.isNotEmpty) {
            hideLoading();
            showOtpView();
          }
        },
        forceResendingToken: resendingToken,
        codeAutoRetrievalTimeout: (String verificationId) {
          mirrorFlyLog("codeAutoRetrievalTimeout", verificationId);
          timeout(true);
        },
      );
    }
  }

  resend() {
    sendOtp();
  }

  Future<void> verifyOTP() async {
    if (await AppUtils.isNetConnected()) {
      if (smsCode.length == 6) {
        Helper.showLoading(message: 'verifying OTP');
        PhoneAuthCredential credential = PhoneAuthProvider.credential(
            verificationId: verificationId!, smsCode: smsCode);
        // Sign the user in (or link) with the credential
        debugPrint("Verification ID $verificationId");
        debugPrint("smsCode $smsCode");
        signIn(credential);
      } else {
        toToast("InValid OTP");
      }
    } else {
      toToast(Constants.noInternetConnection);
    }
  }

  signIn(PhoneAuthCredential credential) async {
    try {
      await _auth.signInWithCredential(credential).then((value) {
        stopTimer();
        mirrorFlyLog("sign in ", value.toString());
        hideLoading();
        Get.toNamed(Routes.setPin)?.then((value) {
          if (Get.isBottomSheetOpen.checkNull()) {
            otpController.clear();
            Get.back(); //for bottomsheetdialog close
          }
          Future.delayed(const Duration(milliseconds: 100), () {
            setUpPinExpiryDialog();
          });
        });
      }).catchError((error) {
        debugPrint("Firebase Verify Error $error");
        toToast("Invalid OTP");
        hideLoading();
      });
    } on FirebaseAuthException catch (e) {
      mirrorFlyLog("sign in error", e.toString());
      toToast("Enter Valid Otp");
      hideLoading();
    }
  }

  _onVerificationCompleted(PhoneAuthCredential credential) async {
    // need otp so i can autofill in a text box
    if (credential.smsCode != null) {
      //timeout(true);
      otpController.set(credential.smsCode!.split(""));
      verifyOTP();
    }
  }

  @override
  void onHidden() {

  }
}
