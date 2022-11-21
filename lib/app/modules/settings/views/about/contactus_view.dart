import 'package:flutter/material.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';
import 'package:mirror_fly_demo/app/nativecall/fly_chat.dart';

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
  TextEditingController title = TextEditingController();
  TextEditingController description = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About us'),
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
              decoration: const InputDecoration(
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: dividercolor)),
                border: UnderlineInputBorder(borderSide: BorderSide(color: dividercolor,width: 0)),
              ),
              style: const TextStyle(fontWeight: FontWeight.bold),
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
              decoration: const InputDecoration(
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: dividercolor)),
                disabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: dividercolor)),
                border: UnderlineInputBorder(borderSide: BorderSide(color: dividercolor,width: 0)),
              ),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 40,
            ),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: buttonbgcolor,
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


