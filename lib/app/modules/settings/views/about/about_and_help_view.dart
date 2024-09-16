import 'package:flutter/material.dart';
import '../../../../common/app_localizations.dart';
import '../../../../common/widgets.dart';
import '../../../../modules/settings/views/about/contactus_view.dart';

import '../../../../common/constants.dart';
import '../../../../data/utils.dart';
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
        title: Text(getTranslated("aboutAndHelp")),
        automaticallyImplyLeading: true,
      ),
      body: Column(
        children: [
          ListItem(title: Text(getTranslated("aboutUs"), style: textStyle),trailing: const Icon(Icons.keyboard_arrow_right),dividerPadding: const EdgeInsets.only(top: 8), onTap: () async {
            if(await AppUtils.isNetConnected()){
              NavUtils.to(const AboutUsView());
            }else{
              toToast(getTranslated("noInternetConnection"));
            }
          }),
          ListItem(title: Text(getTranslated("contactUs"), style: textStyle),trailing: const Icon(Icons.keyboard_arrow_right),dividerPadding: const EdgeInsets.only(top:8), onTap: ()=>NavUtils.to(ContactusView())),
          ListItem(title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(getTranslated("termsAndPolicy"), style: textStyle),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  InkWell(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        "${getTranslated("termsAndCondition")},",
                        style: const TextStyle(
                            decoration: TextDecoration.underline,
                            color: buttonBgColor),
                      ),
                    ),
                    onTap:()=>AppUtils.launchWeb(Uri.parse(getTranslated("termsConditionsLink"))),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  InkWell(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        '${getTranslated("privacyPolicy")}.',
                        style: const TextStyle(
                            decoration: TextDecoration.underline,
                            color: buttonBgColor),
                      ),
                    ),
                    onTap: ()=>AppUtils.launchWeb(Uri.parse(getTranslated("privacyPolicyLink"))),
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


