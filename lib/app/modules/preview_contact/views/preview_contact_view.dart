import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../common/constants.dart';
import '../../../common/widgets.dart';
import '../controllers/preview_contact_controller.dart';

class PreviewContactView extends GetView<PreviewContactController> {
  const PreviewContactView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: controller.from == "contact_pick" ? Text('Send Contacts') : Text('Contact Details'),
        ),
        body: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.only(left: 18.0, top: 18.0, bottom: 5),
                  child: Row(
                    children: [
                      SizedBox(child: ProfileTextImage(text: controller.contactName,),width: 50,height: 50,),
                      /*Image.asset(
                        profile_img,
                        width: 50,
                        height: 50,
                      ),*/
                      SizedBox(
                        width: 10,
                      ),
                      Text(controller.contactName),
                    ],
                  ),
                ),
                Divider(
                  color: Colors.grey,
                  thickness: 0.5,
                ),
                Expanded(
                  child: ListView.builder(
                      itemCount: controller.contactList.length,
                      physics: AlwaysScrollableScrollPhysics(),
                      itemBuilder: (BuildContext context, int index) {
                          return Column(
                            children: [
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(18.0,10,18,10),
                                    child: Icon(Icons.phone, color: Colors.blue,),
                                  ),
                                  Text(
                                    controller.contactList[index].toString(),
                                  ),

                                ],
                              ),
                              Divider(
                                color: Colors.grey,
                                thickness: 0.8,
                              ),
                            ],
                          );

                      }),
                ),
              ],
            ),
            controller.from == "contact_pick" ? Positioned(
                bottom: 25,
                right: 20,
                child: InkWell(
                  onTap: (){
                    controller.shareContact();
                  },
                  child: CircleAvatar(
                    backgroundColor: Colors.blueAccent,
                      radius: 25,
                      child: Icon(Icons.send, color: Colors.white,)),
                )) : SizedBox.shrink()
          ],
        ));
  }
}
