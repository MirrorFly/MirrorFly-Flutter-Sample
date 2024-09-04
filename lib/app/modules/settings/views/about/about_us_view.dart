import 'package:flutter/material.dart';
import '../../../../common/app_localizations.dart';

import '../../../../common/constants.dart';
import '../../../../data/utils.dart';

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
        title: Text(getTranslated("aboutUs")),
        automaticallyImplyLeading: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(getTranslated("titleContactMsg"),style: textMsgStyle,),
            const SizedBox(height: 16,),
            Text(getTranslated("contactUs"),style: textStyle,),
            const SizedBox(height: 16,),
            Text(getTranslated("titleContactMsg"),style: textMsgStyle,),
            const SizedBox(height: 16,),
            Text(getTranslated("titleFaq"),style: textStyle,),
            const SizedBox(height: 16,),
            Text(getTranslated("titleFaqMsg"),style: textMsgStyle,),
            const SizedBox(height: 16,),
            InkWell(child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text.rich(TextSpan(text: mirrorFly,style: TextStyle(fontSize: 17, decoration: TextDecoration.underline,color: Color(
                  0xffa2a1a1)))),
            ),onTap: ()=>AppUtils.launchWeb(Uri.parse(getTranslated("aboutUsLink"))),)
          ],
        ),
      ),
    );
  }
}


