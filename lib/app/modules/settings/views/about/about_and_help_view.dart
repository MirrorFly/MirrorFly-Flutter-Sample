import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/app_localizations.dart';
import 'package:mirror_fly_demo/app/common/widgets.dart';
import 'package:mirror_fly_demo/app/modules/settings/views/about/contactus_view.dart';

import '../../../../common/constants.dart';
import '../../../../data/apputils.dart';
import 'about_us_view.dart';

class AboutAndHelpView extends StatelessWidget {
  const AboutAndHelpView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = const TextStyle(
        color: Colors.black,
        fontSize: 16,
        fontWeight: FontWeight.w400);
    return Scaffold(
      appBar: AppBar(
        title: Text(getTranslated("aboutAndHelp", context)),
        automaticallyImplyLeading: true,
      ),
      body: Column(
        children: [
          ListItem(title: Text(getTranslated("aboutUs", context), style: textStyle),trailing: const Icon(Icons.keyboard_arrow_right),dividerPadding: const EdgeInsets.only(top: 8), onTap: () async {
            if(await AppUtils.isNetConnected()){
              Get.to(const AboutUsView());
            }else{
              toToast(Constants.noInternetConnection);
            }
          }),
          ListItem(title: Text(getTranslated("contactUs", context), style: textStyle),trailing: const Icon(Icons.keyboard_arrow_right),dividerPadding: const EdgeInsets.only(top:8), onTap: ()=>Get.to(ContactusView())),
          ListItem(title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(getTranslated("termsAndPolicy", context), style: textStyle),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  InkWell(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        "${getTranslated("termsAndCondition", context)},",
                        style: const TextStyle(
                            decoration: TextDecoration.underline,
                            color: buttonBgColor),
                      ),
                    ),
                    onTap:()=>launchWeb(getTranslated("termsConditionsLink", context)),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  InkWell(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        '${getTranslated("privacyPolicy", context)}.',
                        style: const TextStyle(
                            decoration: TextDecoration.underline,
                            color: buttonBgColor),
                      ),
                    ),
                    onTap: ()=>launchWeb(getTranslated("privacyPolicyLink", context)),
                  ),
                ],
              )
            ],
          ),dividerPadding: const EdgeInsets.all(15)),
        ],
      ),
    );
  }
}


