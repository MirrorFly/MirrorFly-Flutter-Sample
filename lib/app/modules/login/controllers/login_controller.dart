
import 'package:firebase_app_installations/firebase_app_installations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';
import 'package:mirror_fly_demo/app/model/countryModel.dart';
import 'package:mirror_fly_demo/app/model/statusModel.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/SessionManagement.dart';
import '../../../model/registerModel.dart';
import '../../../nativecall/platformRepo.dart';
import '../../../routes/app_pages.dart';

class LoginController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  var india = CountryData(name: "India", dialCode: "+91", code: "IN");
  var selectedCountry = CountryData(name: "India", dialCode: "+91", code: "IN").obs;
  TextEditingController mobileNumber = TextEditingController();
  OtpFieldController otpController = OtpFieldController();

  String get countryCode => selectedCountry.value.dialCode;
  var verificationId = "";
  int? resendingToken;
  Rx<bool> timeout=false.obs;

  final _smsCode = "".obs;
  String get smsCode => _smsCode.value;
  set smsCode(String val) => _smsCode.value = val;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    super.onClose();

  }

  showLoading(){
    Helper.showLoading(message: "Please Wait...");
  }

  hideLoading(){
    Helper.hideLoading();
  }

  void registerUser() {
    if(mobileNumber.text.isEmpty){
      toToast("Please Enter Mobile Number");
    }else {
      phoneAuth();
    }
  }

  setUserJID(String username) {
    PlatformRepo().getUserJID(username).then((value) {
      if(value != null){
        SessionManagement.setUserJID(value);
        Helper.hideLoading();
        Get.offAllNamed(Routes.PROFILE,arguments: {"mobile":mobileNumber.text.toString(),"from":Routes.LOGIN});
      }
    }).catchError((error) {
      debugPrint(error.message);
    });
  }

  Future<void> phoneAuth() async {
    showLoading();
    if (kIsWeb) {
      final confirmationResult =
      await _auth.signInWithPhoneNumber(mobileNumber.text);
      final smsCode = otpController.toString();//await getSmsCodeFromUser(context);

      if (smsCode != null) {
        await confirmationResult.confirm(smsCode);
      }
    } else {
      await _auth.verifyPhoneNumber(
        phoneNumber: countryCode+mobileNumber.text,
        timeout: const Duration(seconds: 60),
        verificationCompleted: _onVerificationCompleted,
        verificationFailed: (FirebaseAuthException e) {
          timeout(true);
          Log("verificationFailed", e.toString());
          toToast("Please Enter Valid Mobile Number");
          hideLoading();
        },
        codeSent: (String _verificationId, int? resendToken) {
          Log("codeSent", _verificationId+" "+resendToken.toString());
          verificationId = _verificationId;
          resendingToken = resendToken;
          if(_verificationId.isNotEmpty){
            hideLoading();
            Get.toNamed(Routes.OTP)?.then((value) {
              //Change Number
              if(value!=null) {
                Log("change number", "initiated");
              }else{
                Get.back();
              }
            });
          }
        },
        forceResendingToken: resendingToken,
        codeAutoRetrievalTimeout: (String verificationId) {
          Log("codeAutoRetrievalTimeout", verificationId);
          timeout(true);
        },
      );
    }
  }

  resend(){
    timeout(false);
    phoneAuth();
  }

  Future<void> verifyOTP() async {
    if(smsCode.length==6) {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: smsCode);
      // Sign the user in (or link) with the credential
      signIn(credential);
    }else{
      toToast("InValid OTP");
    }
  }

  _onVerificationCompleted(PhoneAuthCredential credential) async {
    timeout(true);
    Log("verificationCompleted providerId", credential.providerId.toString());
    Log("verificationCompleted signInMethod", credential.signInMethod.toString());
    Log("verificationCompleted verificationId", credential.verificationId.toString());
    Log("verificationCompleted smsCode", credential.smsCode.toString());
    Log("verificationCompleted token", credential.token.toString());
    // need otp so i can autofill in a textbox
    if (credential.smsCode != null) {
      otpController.set(credential.smsCode!.split(""));
    }
  }

  signIn(PhoneAuthCredential credential) async {
    showLoading();
    try {
      await _auth.signInWithCredential(credential).then((value){
        sendTokenToServer();
        Log("sigin ", value.toString());
      }).catchError((){
        hideLoading();
      });
    } on FirebaseAuthException catch (e) {
      Log("sigin error", e.toString());
      toToast("Enter Valid Otp");
      hideLoading();
    }
  }

  sendTokenToServer() async {
    var mUser = FirebaseAuth.instance.currentUser;
    if(mUser!=null) {
      await mUser.getIdToken(true).then((value) {
        verifyTokenWithServer(value);
      }).catchError((er){
        Log("sendTokenToServer", er.toString());
        hideLoading();
      });
    }else{
      hideLoading();
    }
  }

  verifyTokenWithServer(String token){
    var userName = (countryCode+mobileNumber.text.toString()).replaceAll("+", "");
    //make api call
    PlatformRepo().verifyToken(userName,token).then((value) {
      if (value!=null) {
        validateDeviceToken(value);
      }else{
        hideLoading();
      }
    }).catchError((error) {
      debugPrint("issue===> $error");
      debugPrint(error.message);
      hideLoading();
    });
  }

  validateDeviceToken(String deviceToken) {
    var firebaseToken = SessionManagement().getToken().checkNull();
    if (firebaseToken.isEmpty) {
      FirebaseMessaging.instance.getToken().then((value) {
        if(value!=null) {
          firebaseToken = value;
          Log("firebase_token", firebaseToken);
          SessionManagement.setToken(firebaseToken);
          navigateToUserRegisterMethod(deviceToken, firebaseToken);
        }else{

        }
      }).catchError((er){
        Log("FirebaseInstallations", er.toString());
        hideLoading();
      });
    } else {
      navigateToUserRegisterMethod(deviceToken, firebaseToken);
    }
  }

  navigateToUserRegisterMethod(String? deviceToken, String? firebaseToken) {
    //OTP validated successfully
    if (deviceToken.checkNull().isEmpty || deviceToken == firebaseToken) {
      registerAccount();
    } else {
      showUserAccountDeviceStatus();
    }
  }

  registerAccount(){
    showLoading();
    PlatformRepo().registerUser(mobileNumber.text,SessionManagement().getToken().checkNull()).then((value) {
      if (value.contains("data")) {
        var userData = registerModelFromJson(value);//message
        SessionManagement.setLogin(userData.data!.username!.isNotEmpty);
        SessionManagement.setUser(userData.data!);
        setUserJID(userData.data!.username!);
      }
    }).catchError((error) {
      debugPrint("issue===> $error");
      debugPrint(error.message);
      hideLoading();
    });
  }

  var verify_visible = true.obs;
  showUserAccountDeviceStatus() {
    //Already Logged Popup
    hideLoading();
    verify_visible(false);
    Log("showUserAccountDeviceStatus", "Already Login");
    PlatformRepo().logout();
    Helper.showAlert(message: "You have logged-in another device. Do you want to continue here?",actions: [
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

  gotoLogin(){
    Get.offAllNamed(Routes.LOGIN);
  }

}
