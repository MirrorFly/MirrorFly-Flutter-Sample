import 'package:flutter/material.dart';

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
        title: const Text('About Us'),
        automaticallyImplyLeading: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(titleContactMsg,style: textMsgStyle,),
            const SizedBox(height: 16,),
            const Text(titleContactUs,style: textStyle,),
            const SizedBox(height: 16,),
            const Text(titleContactMsg,style: textMsgStyle,),
            const SizedBox(height: 16,),
            const Text(titleFaq,style: textStyle,),
            const SizedBox(height: 16,),
            const Text(titleFaqMsg,style: textMsgStyle,),
            const SizedBox(height: 16,),
            InkWell(child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text.rich(TextSpan(text: mirrorFly,style: TextStyle(fontSize: 17, decoration: TextDecoration.underline,color: Color(
                  0xffa2a1a1)))),
            ),onTap: ()=>launchWeb(websiteMirrorFly),)
          ],
        ),
      ),
    );
  }
}


