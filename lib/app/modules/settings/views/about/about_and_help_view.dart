import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
        title: const Text('About and Help'),
        automaticallyImplyLeading: true,
      ),
      body: Column(
        children: [
          ListItem(title: Text("About us", style: textStyle),trailing: const Icon(Icons.keyboard_arrow_right),dividerPadding: const EdgeInsets.only(top: 8), onTap: () async {
            if(await AppUtils.isNetConnected()){
              Get.to(const AboutUsView());
            }else{
              toToast(Constants.noInternetConnection);
            }
          }),
          ListItem(title: Text("Contact us", style: textStyle),trailing: const Icon(Icons.keyboard_arrow_right),dividerPadding: const EdgeInsets.only(top:8), onTap: ()=>Get.to(ContactusView())),
          ListItem(title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Terms and Privacy Policy", style: textStyle),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  InkWell(
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'Terms and Condition,',
                        style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: buttonBgColor),
                      ),
                    ),
                    onTap:()=>launchWeb(Constants.termsConditions),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  InkWell(
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'Privacy Policy.',
                        style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: buttonBgColor),
                      ),
                    ),
                    onTap: ()=>launchWeb(Constants.privacyPolicy),
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


