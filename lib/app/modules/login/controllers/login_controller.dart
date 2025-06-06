import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_libphonenumber/flutter_libphonenumber.dart'
as lib_phone_number;
import 'package:get/get.dart';
import '../../../common/main_controller.dart';
import '../../../data/helper.dart';
import '../../../data/permissions.dart';
import '../../../extensions/extensions.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';
import 'package:otp_text_field/otp_field.dart';

import '../../../app_style_config.dart';
import '../../../common/app_localizations.dart';
import '../../../common/constants.dart';
import '../../../data/session_management.dart';
import '../../../data/utils.dart';
import '../../../routes/route_settings.dart';
import '../views/otp_view.dart';

class LoginController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  var india = CountryData(name: "India", dialCode: "+91", code: "IN");
  var selectedCountry = CountryData(name: "India", dialCode: "+91", code: "IN").obs;
  TextEditingController mobileNumber = TextEditingController();
  OtpFieldController otpController = OtpFieldController();

  FocusNode focusNode = FocusNode();

  Timer? countdownTimer;
  Duration myDuration = const Duration(seconds: 31);

  String? get countryCode => selectedCountry.value.dialCode;

  String? get regionCode => selectedCountry.value.code;
  var verificationId = "";
  int? resendingToken;
  Rx<bool> timeout = false.obs;

  bool isForceRegister = false;

  var seconds = 0.obs;

  final _smsCode = "".obs;

  String get smsCode => _smsCode.value;

  set smsCode(String val) => _smsCode.value = val;

  // void registerUser(BuildContext context) {

  showLoading() {
    DialogUtils.showLoading(message: getTranslated("pleaseWait"),dialogStyle: AppStyleConfig.dialogStyle);
  }

  hideLoading() {
    DialogUtils.hideLoading();
  }

  void startTimer() {
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) => setCountDown());
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

  Future<void> registerUser() async {
    if (mobileNumber.text.isEmpty) {
      toToast(getTranslated("plsEnterMobileNumber"));
    } else {
      if(await validMobileNumber(selectedCountry.value.dialCode!,mobileNumber.text)) {
        // phoneAuth();
        if (Constants.isOTPViewEnabled) {
          DialogUtils.bottomSheet(
            OtpView(controller: this),
            ignoreSafeArea: true,
            isScrollControlled: true,
            enableDrag: false,
          );
        }else{
          registerAccount();
        }
        // NavUtils.toNamed(Routes.otp);
      }else{
        toToast(getTranslated("plsEnterValidMobileNumber"));
      }
    }
  }

  Future<bool> validMobileNumber(String dialCode,String mobileNumber) async {
    try {
      LogMessage.d("validMobileNumber",
          "dialCode : $dialCode, mobileNumber : $mobileNumber");
      lib_phone_number.init();
      var parse = await lib_phone_number.parse(dialCode+mobileNumber);
      LogMessage.d("validMobileNumber", "parse : $parse");
      return true;
    }catch(e){
      LogMessage.d("validMobileNumber", "error : $e");
      return false;
    }
  }

  setUserJID(String username) {
    Mirrorfly.getJid(username: username).then((value) {
      if (value != null) {
        SessionManagement.setUserJID(value);
        DialogUtils.hideLoading();
        if (Constants.isBackupFeatureEnabled) {
          NavUtils.offAllNamed(Routes.restoreBackup,
              arguments: {"mobile": mobileNumber.text.toString()});
        }else {
          NavUtils.offAllNamed(Routes.profile, arguments: {"mobile": mobileNumber.text.toString(), "from": Routes.login});
        }
      }
    }).catchError((error) {
      debugPrint(error);
    });
  }

  Future<void> phoneAuth() async {
    if (await AppUtils.isNetConnected()) {
      showLoading();
      if (kIsWeb) {
        final confirmationResult = await _auth.signInWithPhoneNumber(mobileNumber.text);
        final smsCode = otpController.toString(); //await getSmsCodeFromUser(context);

        await confirmationResult.confirm(smsCode);
      } else {
        await _auth.verifyPhoneNumber(
          phoneNumber: countryCode! + mobileNumber.text,
          timeout: const Duration(seconds: 30),
          verificationCompleted: _onVerificationCompleted,
          verificationFailed: (FirebaseAuthException e) {
            timeout(true);

            LogMessage.d("verificationFailed", e.toString());
            LogMessage.d("verificationFailed", e.message!);
            LogMessage.d("verificationFailed", e.code);
            toToast(getTranslated("plsEnterValidMobileNumber"));
            hideLoading();
          },
          codeSent: (String verificationId, int? resendToken) {
            LogMessage.d("codeSent", verificationId);
            this.verificationId = verificationId;
            resendingToken = resendToken;

            seconds(0);
            startTimer();

            if (verificationId.isNotEmpty) {
              hideLoading();
              NavUtils.toNamed(Routes.otp)?.then((value) {
                //Change Number
                if (value != null) {
                  LogMessage.d("change number", "initiated");
                } else {
                  NavUtils.back();
                }
              });
            }
          },
          forceResendingToken: resendingToken,
          codeAutoRetrievalTimeout: (String verificationId) {
            LogMessage.d("codeAutoRetrievalTimeout", verificationId);
            timeout(true);
          },
        );
      }
    } else {
      toToast(getTranslated("noInternetConnection"));
    }
  }

  resend() {
    timeout(false);
    phoneAuth();
  }

  Future<void> verifyOTP() async {
    if (await AppUtils.isNetConnected()) {
      if (smsCode.length == 6) {
        PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: smsCode);
        // Sign the user in (or link) with the credential
        debugPrint("Verification ID $verificationId");
        debugPrint("smsCode $smsCode");
        signIn(credential);
      } else {
        toToast(getTranslated("inValidOTP"));
      }
    } else {
      toToast(getTranslated("noInternetConnection"));
    }
  }

  _onVerificationCompleted(PhoneAuthCredential credential) async {
    timeout(true);
    LogMessage.d("verificationCompleted providerId", credential.providerId.toString());
    LogMessage.d("verificationCompleted signInMethod", credential.signInMethod.toString());
    LogMessage.d("verificationCompleted verificationId", credential.verificationId.toString());
    LogMessage.d("verificationCompleted smsCode", credential.smsCode.toString());
    LogMessage.d("verificationCompleted token", credential.token.toString());
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
        if (!Constants.enableContactSync) {
          sendTokenToServer(); // for Mirrorfly user list purpose verify the user
        } else {
          validateDeviceToken('');
          //registerAccount();//for get registered user purpose
        }
        stopTimer();
        LogMessage.d("sign in ", value.toString());
      }).catchError((error) {
        debugPrint("Firebase Verify Error $error");
        toToast(getTranslated("inValidOTP"));
        hideLoading();
      });
    } on FirebaseAuthException catch (e) {
      LogMessage.d("sign in error", e.toString());
      toToast(getTranslated("enterValidOTP"));
      hideLoading();
    }
  }

  sendTokenToServer() async {
    var mUser = FirebaseAuth.instance.currentUser;
    if (mUser != null) {
      await mUser.getIdToken(true).then((value) {
        verifyTokenWithServer(value!);
      }).catchError((er) {
        LogMessage.d("sendTokenToServer", er.toString());
        hideLoading();
      });
    } else {
      hideLoading();
    }
  }

  verifyTokenWithServer(String token) async {
    if (await AppUtils.isNetConnected()) {
      // var userName = (countryCode!.replaceAll('+', '') + mobileNumber.text.toString()).replaceAll("+", "");
      //make api call
      //verifyToken not available iOS so commented it
      /*Mirrorfly.verifyToken(userName, token).then((value) {
        if (value != null) {
          validateDeviceToken(value);
        } else {
          hideLoading();
        }
      }).catchError((error) {
        debugPrint("issue===> $error");
        debugPrint(error.message);
        hideLoading();
      });*/
    } else {
      toToast(getTranslated("noInternetConnection"));
    }
  }

  validateDeviceToken(String deviceToken) async {
    if (await AppUtils.isNetConnected()) {
      var firebaseToken = SessionManagement.getToken().checkNull();
      if (firebaseToken.isEmpty) {
        FirebaseMessaging.instance.getToken().then((value) {
          if (value != null) {
            firebaseToken = value;
            LogMessage.d("firebase_token", firebaseToken);
            SessionManagement.setToken(firebaseToken);
            navigateToUserRegisterMethod(deviceToken, firebaseToken);
          } else {}
        }).catchError((er) {
          LogMessage.d("FirebaseInstallations", er.toString());
          hideLoading();
        });
      } else {
        navigateToUserRegisterMethod(deviceToken, firebaseToken);
      }
    } else {
      toToast(getTranslated("noInternetConnection"));
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
    LogMessage.d("Mirrorfly.isSDKInitialized", Mirrorfly.isSDKInitialized);
    if (await AppUtils.isNetConnected()) {
      if (mobileNumber.text.length < 5) {
        toToast(getTranslated("mobileNumberTooShort"));
        return;
      }
      if (mobileNumber.text.length < 10) {
        toToast(getTranslated("plsEnterValidMobileNumber"));
        return;
      }
      if (Platform.isAndroid && !(await AppPermission.askNotificationPermission())) {
        return;
      }
      // if(mobileNumber.text.length > 9) {
      if(!Mirrorfly.isSDKInitialized){
        initializeSDK();
        return;
      }
      showLoading();
      login();
    } else {
      toToast(getTranslated("noInternetConnection"));
    }
    // } else {
    //   toToast(getTranslated("noInternetConnection"));
    // }
  }
  Future<void> initializeSDK() async {
    var builder = Constants.chatBuilder;
    if(Constants.useDeprecatedInit) {
      //We no need to re init the SDK because Sdk init success from main.dart file since this method is doesn't need internet for the first time.
      // showLoading();
      // await Mirrorfly.init(baseUrl: builder.domainBaseUrl,
      //     licenseKey: builder.licenseKey,
      //     iOSContainerID: builder.iOSContainerID,
      //     enableDebugLog: builder.enableDebugLog,
      //     enableMobileNumberLogin: builder.enableMobileNumberLogin,
      //     chatHistoryEnable: builder.chatHistoryEnable,
      //     storageFolderName: builder.storageFolderName,
      //     isTrialLicenceKey: builder.isTrialLicenceKey
      // );
      // login();
    }else {
      showLoading();
      Mirrorfly.initializeSDK(
          licenseKey: builder.licenseKey,
          iOSContainerID: builder.iOSContainerID,
          chatHistoryEnable: builder.chatHistoryEnable,
          enableDebugLog: builder.enableDebugLog,
          storageFolderName: builder.storageFolderName,
          enablePrivateStorage: Constants.enablePrivateStorage,
          enableMobileNumberLogin: builder.enableMobileNumberLogin,
          flyCallback: (response) async {
            if (response.isSuccess) {
              login();
            } else {
              hideLoading();
              toToast(response.errorMessage.toString());
            }
          });
    }
  }

  void login(){
    var userIdentifier = countryCode!.replaceAll('+', '') + mobileNumber.text;
    Mirrorfly.login(userIdentifier: countryCode!.replaceAll('+', '') + mobileNumber.text,
        fcmToken: SessionManagement.getToken().checkNull(),
        isForceRegister: isForceRegister,
        // identifierMetaData: [IdentifierMetaData(key: "platform", value: "flutter")],//#metaData
        flyCallback: (FlyResponse response) async {
          if (response.isSuccess) {
            if (response.hasData) {
              var userData = registerModelFromJson(response.data); //message
              SessionManagement.setLogin(userData.data!.username!.isNotEmpty);
              SessionManagement.setUser(userData.data!);
              SessionManagement.setUserIdentifier(userIdentifier);
              SessionManagement.setAdminBlocked(false);
              SessionManagement.setAuthToken(userData.data!.token.checkNull());
              if (Get.isRegistered<MainController>()) {
                Get.find<MainController>().currentAuthToken(userData.data!.token.checkNull());
              }
              // Mirrorfly.setNotificationSound(true);
              // SessionManagement.setNotificationSound(true);
              // userData.data.
              enableArchive();
              Mirrorfly.setRegionCode(regionCode:regionCode ?? 'IN');

              ///if its not set then error comes in contact sync delete from phonebook.
              SessionManagement.setCountryCode((countryCode ?? "").replaceAll('+', ''));
              if (!Constants.chatBuilder.chatHistoryEnable){
                await Mirrorfly.getAllGroups(fetchFromServer: true, flyCallBack: (FlyResponse response) {
                  LogMessage.d("Login Controller getAllGroups", response.data);
                });
              }
              setUserJID(userData.data!.username!);
            }

          } else {
            debugPrint("issue===> ${response.errorMessage.toString()}");
            hideLoading();
            if (response.exception?.code == "403") {
              debugPrint("issue 403 ===> ${response.errorMessage }");
              NavUtils.offAllNamed(Routes.adminBlocked);
            } else if (response.exception?.code  == "405") {
              debugPrint("issue 405 ===> ${response.errorMessage }");
              sessionExpiredDialogShow(getTranslated("maximumLoginReached"));
            } else {
              debugPrint("issue else code ===> ${response.exception?.code }");
              debugPrint("issue else ===> ${response.errorMessage }");
              toToast(getErrorDetails(response));
            }
          }
        });
  }

  void enableArchive() async {
    if (await AppUtils.isNetConnected()) {
      Mirrorfly.enableDisableArchivedSettings(enable: true,flyCallBack: (_){});
    } else {
      toToast(getTranslated("noInternetConnection"));
    }
  }

  var verifyVisible = true.obs;

  showUserAccountDeviceStatus() {
    //Already Logged Popup
    hideLoading();
    verifyVisible(false);
    LogMessage.d("showUserAccountDeviceStatus", "Already Login");
    //PlatformRepo.logout();
    DialogUtils.showAlert(dialogStyle: AppStyleConfig.dialogStyle,message: getTranslated("deviceConfirmation"), actions: [
      TextButton(style: AppStyleConfig.dialogStyle.buttonStyle,
          onPressed: () {
            NavUtils.back();
            gotoLogin();
          },
          child: Text(getTranslated("no").toUpperCase(), )),
      TextButton(style: AppStyleConfig.dialogStyle.buttonStyle,
          onPressed: () {
            NavUtils.back();
            registerAccount();
          },
          child: Text(getTranslated("yes").toUpperCase(), )),
    ]);
  }

  sessionExpiredDialogShow(message) {
    //Already Logged Popup
    hideLoading();
    verifyVisible(false);
    LogMessage.d("sessionExpiredDialogShow", "Already Login");
    //PlatformRepo.logout();
    DialogUtils.showAlert(dialogStyle: AppStyleConfig.dialogStyle,message: message.toString(), actions: [
      TextButton(style: AppStyleConfig.dialogStyle.buttonStyle,
          onPressed: () {
            NavUtils.back();
            isForceRegister = false;
          },
          child: Text(getTranslated("cancel"), )),
      TextButton(style: AppStyleConfig.dialogStyle.buttonStyle,
          onPressed: () {
            NavUtils.back();
            isForceRegister = true;
            // registerUser();
            registerAccount();
          },
          child: Text(getTranslated("continue"), )),
    ]);
  }

  gotoLogin() {
    // Future.delayed(const Duration(milliseconds: 500),(){
    //   NavUtils.offAllNamed(Routes.login);
    // });

    NavUtils.back();
  }

  void verifyDummyOTP() {
    if (smsCode.length == 6 && smsCode == "123456") {
      registerAccount();
    } else {
      toToast(getTranslated("inValidOTP"));
    }
  }
}
