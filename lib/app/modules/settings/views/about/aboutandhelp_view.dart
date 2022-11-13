import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/widgets.dart';
import 'package:mirror_fly_demo/app/modules/settings/views/about/contactus_view.dart';

import '../../../../common/constants.dart';
import 'aboutus_view.dart';

class AboutAndHelpView extends StatelessWidget {
  AboutAndHelpView({Key? key}) : super(key: key);
  TextStyle textStyle = const TextStyle(
      color: Colors.black,
      fontSize: 16,
      fontWeight: FontWeight.w400);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About and Help'),
        automaticallyImplyLeading: true,
      ),
      body: Column(
        children: [
          ListItem(title: Text("About us", style: textStyle),trailing: const Icon(Icons.keyboard_arrow_right),dividerpadding: const EdgeInsets.only(top: 8), onTap: ()=>Get.to(AboutusView())),
          ListItem(title: Text("Contact us", style: textStyle),trailing: const Icon(Icons.keyboard_arrow_right),dividerpadding: const EdgeInsets.only(top:8), onTap: ()=>Get.to(ContactusView())),
          ListItem(title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Terms and Privacy Policy", style: textStyle),
              SizedBox(height: 8,),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  InkWell(
                    child: const Text(
                      'Terms and Condition,',
                      style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: buttonbgcolor),
                    ),
                    onTap:()=>launchWeb(Constants.Terms_Conditions),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  InkWell(
                    child: const Text(
                      'Privacy Policy.',
                      style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: buttonbgcolor),
                    ),
                    onTap: ()=>launchWeb(Constants.Privacy_Policy),
                  ),
                ],
              )
            ],
          ),dividerpadding: const EdgeInsets.all(15), onTap: (){}),
        ],
      ),
    );
  }
}


