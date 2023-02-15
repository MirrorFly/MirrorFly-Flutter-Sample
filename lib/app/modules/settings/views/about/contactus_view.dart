import 'package:flutter/material.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';
import 'package:flysdk/flysdk.dart';

import '../../../../common/constants.dart';

class ContactusView extends StatelessWidget {
  ContactusView({Key? key}) : super(key: key);
  static const TextStyle textStyle = TextStyle(
      color: Colors.black,
      fontSize: 17,
      fontWeight: FontWeight.w400);
  static const TextStyle textMsgStyle = TextStyle(
      color: Colors.black,
      fontSize: 16,
      fontWeight: FontWeight.w400);
  final TextEditingController title = TextEditingController();
  final TextEditingController description = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact us'),
        automaticallyImplyLeading: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Title',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            TextField(
              controller: title,
              onChanged: (value) {},
              maxLines: null,
              maxLength: 100,
              keyboardType: TextInputType.multiline,
              decoration: const InputDecoration(
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: dividerColor)),
                border: UnderlineInputBorder(borderSide: BorderSide(color: dividerColor,width: 0)),
                counterText: ''
              ),
              style: const TextStyle(fontWeight: FontWeight.normal,fontSize: 14,color: textColor),
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              'Description',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            TextField(
              controller: description,
              onChanged: (value) {},
              maxLines: null,
              maxLength: 460,
              keyboardType: TextInputType.multiline,
              decoration: const InputDecoration(
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: dividerColor)),
                disabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: dividerColor)),
                border: UnderlineInputBorder(borderSide: BorderSide(color: dividerColor,width: 0)),
                counterText: ''
              ),
              style: const TextStyle(fontWeight: FontWeight.normal,fontSize: 14,color: textColor),
            ),
            const SizedBox(
              height: 40,
            ),
            Center(
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
                  if(title.text.trim().isNotEmpty&&description.text.trim().isNotEmpty) {
                    Helper.progressLoading();
                    FlyChat.sendContactUsInfo(title.text.trim(),description.text.trim()).then((value){
                      Helper.hideLoading();
                      if(value!=null){
                        if(value){
                          toToast("Thank you for contacting us!");
                          title.clear();
                          description.clear();
                        }
                      }
                    });
                  }else{
                    toToast("Title and Description is Required");
                  }
                },
                child: const Text(
                  'Send',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


