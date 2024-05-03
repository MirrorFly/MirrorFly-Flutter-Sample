import 'package:flutter/material.dart';
import 'package:mirror_fly_demo/app/common/app_localizations.dart';

import '../../../../common/constants.dart';

class AboutUsView extends StatelessWidget {
  const AboutUsView({Key? key}) : super(key: key);
  static const TextStyle textStyle = TextStyle(
      color: Colors.black,
      fontSize: 17,
      fontWeight: FontWeight.w400);
  static const TextStyle textMsgStyle = TextStyle(
      color: Colors.black,
      fontSize: 16,
      fontWeight: FontWeight.w400);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(getTranslated("aboutUs", context)),
        automaticallyImplyLeading: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(getTranslated("titleContactMsg", context),style: textMsgStyle,),
            const SizedBox(height: 16,),
            Text(getTranslated("contactUs", context),style: textStyle,),
            const SizedBox(height: 16,),
            Text(getTranslated("titleContactMsg", context),style: textMsgStyle,),
            const SizedBox(height: 16,),
            Text(getTranslated("titleFaq", context),style: textStyle,),
            const SizedBox(height: 16,),
            Text(getTranslated("titleFaqMsg", context),style: textMsgStyle,),
            const SizedBox(height: 16,),
            InkWell(child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text.rich(TextSpan(text: mirrorFly,style: TextStyle(fontSize: 17, decoration: TextDecoration.underline,color: Color(
                  0xffa2a1a1)))),
            ),onTap: ()=>launchWeb(getTranslated("aboutUsLink", context)),)
          ],
        ),
      ),
    );
  }
}


