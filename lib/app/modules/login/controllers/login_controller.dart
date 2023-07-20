import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';
import 'package:otp_text_field/otp_field.dart';

import '../../../common/constants.dart';
import '../../../data/apputils.dart';
import '../../../data/session_management.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';
import '../../../routes/app_pages.dart';

class LoginController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  var india = CountryData(name: "India", dialCode: "+91", code: "IN");
  var selectedCountry =
      CountryData(name: "India", dialCode: "+91", code: "IN").obs;
  TextEditingController mobileNumber = TextEditingController();
  OtpFieldController otpController = OtpFieldController();

  Timer? countdownTimer;
  Duration myDuration = const Duration(seconds: 31);

  String? get countryCode => selectedCountry.value.dialCode;
  String? get regionCode => selectedCountry.value.code;
  var verificationId = "";
  int? resendingToken;
  Rx<bool> timeout = false.obs;

  var seconds = 0.obs;

  final _smsCode = "".obs;

  String get smsCode => _smsCode.value;

  set smsCode(String val) => _smsCode.value = val;

  // void registerUser(BuildContext context) {

  showLoading() {
    Helper.showLoading(message: "Please Wait...");
  }

  hideLoading() {
    Helper.hideLoading();
  }

  void startTimer() {
    countdownTimer =
        Timer.periodic(const Duration(seconds: 1), (_) => setCountDown());
  }

  void setCountDown() {
    const reduceSecondsBy = 1;
    seconds(myDuration.inSeconds - reduceSecondsBy);
    if (seconds.value == 0) {
      countdownTimer!.cancel();
      timeout(true);
    } else {
      myDuration = Duration(seconds: seconds.value);
      debugPrint(seconds.value.toString());
    }
  }
  /*@override
  void onReady() {
    super.onReady();
    // Mirrorfly.isTrailLicence().then((value) => SessionManagement.setIsTrailLicence(value.checkNull()));
  }*/

  @override
  void dispose() {
    stopTimer();
    super.dispose();
  }

  void stopTimer() {
    countdownTimer!.cancel();
  }

  void registerUser() {
    if (mobileNumber.text.isEmpty) {
      toToast("Please Enter Mobile Number");
    } else {
      // phoneAuth();
      registerAccount();
    }
  }

  setUserJID(String username) {
    // Mirrorfly.getAllGroups(true); // chat history enabled so this no longer need
    Mirrorfly.getJid(username).then((value) {
      if (value != null) {
        SessionManagement.setUserJID(value);
        Helper.hideLoading();
        Get.offAllNamed(Routes.profile, arguments: {
          "mobile": mobileNumber.text.toString(),
          "from": Routes.login
        });
      }
    }).catchError((error) {
      debugPrint(error.message);
    });
  }

  Future<void> phoneAuth() async {
    if(await AppUtils.isNetConnected()) {
      showLoading();
      if (kIsWeb) {
        final confirmationResult =
        await _auth.signInWithPhoneNumber(mobileNumber.text);
        final smsCode =
        otpController.toString(); //await getSmsCodeFromUser(context);

        await confirmationResult.confirm(smsCode);
      } else {
        await _auth.verifyPhoneNumber(
          phoneNumber: countryCode! + mobileNumber.text,
          timeout: const Duration(seconds: 30),
          verificationCompleted: _onVerificationCompleted,
          verificationFailed: (FirebaseAuthException e) {
            timeout(true);

            mirrorFlyLog("verificationFailed", e.toString());
            mirrorFlyLog("verificationFailed", e.message!);
            mirrorFlyLog("verificationFailed", e.code);
            toToast("Please Enter Valid Mobile Number");
            hideLoading();
          },
          codeSent: (String verificationId, int? resendToken) {
            mirrorFlyLog("codeSent", verificationId);
            this.verificationId = verificationId;
            resendingToken = resendToken;

            seconds(0);
            startTimer();

            if (verificationId.isNotEmpty) {
              hideLoading();
              Get.toNamed(Routes.otp)?.then((value) {
                //Change Number
                if (value != null) {
                  mirrorFlyLog("change number", "initiated");
                } else {
                  Get.back();
                }
              });
            }
          },
          forceResendingToken: resendingToken,
          codeAutoRetrievalTimeout: (String verificationId) {
            mirrorFlyLog("codeAutoRetrievalTimeout", verificationId);
            timeout(true);
          },
        );
      }
    }else{
      toToast(Constants.noInternetConnection);
    }
  }

  resend(){
    timeout(false);
    phoneAuth();
  }

  Future<void> verifyOTP() async {
    if (await AppUtils.isNetConnected()) {
      if (smsCode.length == 6) {
        PhoneAuthCredential credential = PhoneAuthProvider.credential(
            verificationId: verificationId, smsCode: smsCode);
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

  _onVerificationCompleted(PhoneAuthCredential credential) async {
    timeout(true);
    mirrorFlyLog(
        "verificationCompleted providerId", credential.providerId.toString());
    mirrorFlyLog("verificationCompleted signInMethod",
        credential.signInMethod.toString());
    mirrorFlyLog("verificationCompleted verificationId",
        credential.verificationId.toString());
    mirrorFlyLog(
        "verificationCompleted smsCode", credential.smsCode.toString());
    mirrorFlyLog("verificationCompleted token", credential.token.toString());
    // need otp so i can autofill in a text box
    if (credential.smsCode != null) {
      otpController.set(credential.smsCode!.split(""));
      verifyOTP();
    }
  }

  signIn(PhoneAuthCredential credential) async {
    showLoading();
    try {
      await _auth.signInWithCredential(credential).then((value) {
        if(Mirrorfly.isTrialLicence) {
          sendTokenToServer(); // for Mirrorfly user list purpose verify the user
        }else{
          validateDeviceToken('');
          //registerAccount();//for get registered user purpose
        }
        stopTimer();
        mirrorFlyLog("sign in ", value.toString());
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

  sendTokenToServer() async {
    var mUser = FirebaseAuth.instance.currentUser;
    if (mUser != null) {
      await mUser.getIdToken(true).then((value) {
        verifyTokenWithServer(value!);
      }).catchError((er) {
        mirrorFlyLog("sendTokenToServer", er.toString());
        hideLoading();
      });
    } else {
      hideLoading();
    }
  }

  verifyTokenWithServer(String token) async {
    if(await AppUtils.isNetConnected()) {
      var userName = (countryCode!.replaceAll('+', '') + mobileNumber.text.toString()).replaceAll("+", "");
      //make api call
      Mirrorfly.verifyToken(userName, token).then((value) {
        if (value != null) {
          validateDeviceToken(value);
        } else {
          hideLoading();
        }
      }).catchError((error) {
        debugPrint("issue===> $error");
        debugPrint(error.message);
        hideLoading();
      });
    }else{
      toToast(Constants.noInternetConnection);
    }
  }

  validateDeviceToken(String deviceToken) async {
    if(await AppUtils.isNetConnected()) {
      var firebaseToken = SessionManagement.getToken().checkNull();
      if (firebaseToken.isEmpty) {
        FirebaseMessaging.instance.getToken().then((value) {
          if (value != null) {
            firebaseToken = value;
            mirrorFlyLog("firebase_token", firebaseToken);
            SessionManagement.setToken(firebaseToken);
            navigateToUserRegisterMethod(deviceToken, firebaseToken);
          } else {}
        }).catchError((er) {
          mirrorFlyLog("FirebaseInstallations", er.toString());
          hideLoading();
        });
      } else {
        navigateToUserRegisterMethod(deviceToken, firebaseToken);
      }
    }else{
      toToast(Constants.noInternetConnection);
    }
    // navigateToUserRegisterMethod(deviceToken, firebaseToken);
  }

  navigateToUserRegisterMethod(String? deviceToken, String? firebaseToken) {
    //OTP validated successfully
    if (deviceToken.checkNull().isEmpty || deviceToken == "null" || deviceToken == firebaseToken) {
      registerAccount();
    } else {
      showUserAccountDeviceStatus();
    }
  }

  registerAccount() async {
    if (await AppUtils.isNetConnected()) {
      if(mobileNumber.text.length < 5){
        toToast("Mobile number too short");
        return;
      }
      if(mobileNumber.text.length < 10){
        toToast("Please enter valid mobile number");
        return;
      }
      // if(mobileNumber.text.length > 9) {
        showLoading();
        Mirrorfly.registerUser(
            countryCode!.replaceAll('+', '') + mobileNumber.text, token: SessionManagement.getToken().checkNull())
            .then((value) {
          if (value.contains("data")) {
            var userData = registerModelFromJson(value); //message
            SessionManagement.setLogin(userData.data!.username!.isNotEmpty);
            SessionManagement.setUser(userData.data!);
            // Mirrorfly.setNotificationSound(true);
            // SessionManagement.setNotificationSound(true);
            // userData.data.
            enableArchive();
            Mirrorfly.setRegionCode(regionCode ?? 'IN');

            ///if its not set then error comes in contact sync delete from phonebook.
            SessionManagement.setCountryCode((countryCode ?? "").replaceAll('+', ''));
            setUserJID(userData.data!.username!);
          }
        }).catchError((error) {
          debugPrint("issue===> $error");
          debugPrint(error.message);
          hideLoading();
          if (error.code == 403) {
            Get.offAllNamed(Routes.adminBlocked);
          } else {
            toToast(error.message);
          }
        });
      }else{
        toToast("Mobile Number too short");
      }
    // } else {
    //   toToast(Constants.noInternetConnection);
    // }
  }

  void enableArchive() async{
    if(await AppUtils.isNetConnected()) {
      Mirrorfly.enableDisableArchivedSettings(true);
    }else{
      toToast(Constants.noInternetConnection);
    }
  }

  var verifyVisible = true.obs;

  showUserAccountDeviceStatus() {
    //Already Logged Popup
    hideLoading();
    verifyVisible(false);
    mirrorFlyLog("showUserAccountDeviceStatus", "Already Login");
    //PlatformRepo.logout();
    Helper.showAlert(
        message:
            "You have logged-in another device. Do you want to continue here?",
        actions: [
          TextButton(
              onPressed: () {
                Get.back();
                gotoLogin();
              },
              child: const Text("NO")),
          TextButton(
              onPressed: () {
                Get.back();
                registerAccount();
              },
              child: const Text("YES")),
        ]);
  }

  gotoLogin() {
    Get.offAllNamed(Routes.login);
  }
}
