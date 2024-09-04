import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:focus_detector/focus_detector.dart';
import '../../../../common/app_localizations.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';

import '../../../../common/constants.dart';
import '../../../../data/utils.dart';

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
  final titleFocus = FocusNode();
  final descFocus = FocusNode();
  @override
  Widget build(BuildContext context) {
    return FocusDetector(
      onFocusGained: (){
        if (!KeyboardVisibilityController().isVisible) {
          if (titleFocus.hasFocus) {
            titleFocus.unfocus();
            Future.delayed(const Duration(milliseconds: 100), () {
              titleFocus.requestFocus();
            });
          }else if (descFocus.hasFocus) {
            descFocus.unfocus();
            Future.delayed(const Duration(milliseconds: 100), () {
              descFocus.requestFocus();
            });
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(getTranslated("contactUs")),
          automaticallyImplyLeading: true,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  getTranslated("title"),
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                TextField(
                  controller: title,
                  focusNode: titleFocus,
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
                Text(
                  getTranslated("description"),
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                TextField(
                  controller: description,
                  focusNode: descFocus,
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
                        DialogUtils.progressLoading();
                        Mirrorfly.sendContactUsInfo(title: title.text.trim(),description: description.text.trim(),flyCallBack: (response){
                          DialogUtils.hideLoading();
                          if(response.isSuccess){
                            toToast(getTranslated("thankYou"));
                            title.clear();
                            description.clear();
                          }
                        });
                      }else{
                        toToast(getTranslated("titleAndDescRequired"));
                      }
                    },
                    child: Text(
                      getTranslated("send"),
                      style: const TextStyle(fontWeight: FontWeight.w600,color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


