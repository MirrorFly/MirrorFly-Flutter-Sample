import 'package:flutter/material.dart';
import '../../common/app_localizations.dart';

import '../../common/constants.dart';
import '../../data/utils.dart';
import '../../routes/route_settings.dart';

class AdminBlockedView extends StatelessWidget {
  const AdminBlockedView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
        onFinish(context);
        return;
      },
      child: SafeArea(child: Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 55.0,left: 55.0),
                child: AppUtils.assetIcon(assetName:icLogo),
              ),
              Padding(
                padding: const EdgeInsets.only(top:20.0),
                child: AppUtils.svgIcon(icon:icAdminBlocked),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 15.0,right: 55.0,left: 55.0),
                child: Text(getTranslated("adminBlockedMessage"),style: const TextStyle(decoration: TextDecoration.none,color: textColorBlack,fontSize: 18.0,fontWeight: FontWeight.w600),textAlign: TextAlign.center,),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0,right: 55.0,left: 55.0),
                child: Text(getTranslated("adminBlockedMessageLabel"),style: const TextStyle(decoration: TextDecoration.none,color: textColor,fontSize: 16.0,fontWeight: FontWeight.w200),textAlign: TextAlign.center,),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0,right: 55.0,left: 55.0),
                child: Text(getTranslated("supportMail"),style: const TextStyle(decoration: TextDecoration.underline,color: buttonBgColor,fontSize: 16.0,fontWeight: FontWeight.w400),textAlign: TextAlign.center,),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 15.0,right: 55.0,left: 55.0),
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
                    onFinish(context);
                  },
                  child: Text(
                    getTranslated("ok"),
                    style: const TextStyle(fontWeight: FontWeight.w600,color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      )),
    );
  }

  onFinish(BuildContext context){
    // NavUtils.offAllNamed(Routes.login);
    Navigator.pushNamedAndRemoveUntil(context, Routes.login, (Route<dynamic> route) => false);
  }
}
