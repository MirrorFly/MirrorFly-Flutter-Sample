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
        title: const Text('Contact Us'),
        automaticallyImplyLeading: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(title_contact_msg,style: textMsgStyle,),
            const SizedBox(height: 16,),
            const Text(title_contact_us,style: textStyle,),
            const SizedBox(height: 16,),
            const Text(title_contact_msg,style: textMsgStyle,),
            const SizedBox(height: 16,),
            const Text(title_faq,style: textStyle,),
            const SizedBox(height: 16,),
            const Text(title_faq_msg,style: textMsgStyle,),
            const SizedBox(height: 16,),
            InkWell(child: const Text.rich(TextSpan(text: title_contus_fly,style: TextStyle(fontSize: 17, decoration: TextDecoration.underline,))),onTap: ()=>launchWeb(website_mirrorfly),)
          ],
        ),
      ),
    );
  }
}


