import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/app_localizations.dart';

import '../../../app_style_config.dart';
import '../../../common/widgets.dart';
import '../../../extensions/extensions.dart';
import '../controllers/preview_contact_controller.dart';

class PreviewContactView extends NavViewStateful<PreviewContactController> {
  const PreviewContactView({Key? key}) : super(key: key);

  @override
PreviewContactController createController({String? tag}) => Get.put(PreviewContactController());

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
          appBarTheme: AppStyleConfig.localContactPreviewPageStyle.appBarTheme,
          floatingActionButtonTheme: AppStyleConfig.localContactPreviewPageStyle.floatingActionButtonThemeData),
      child: Scaffold(
          appBar: AppBar(
            title: controller.from == "contact_pick"
                ? Text(getTranslated("sendContacts"))
                : Text(getTranslated("contactDetails")),
          ),
          body: SafeArea(
            child: Stack(
              children: [
                Obx(() {
                  return SizedBox(
                    height: double.infinity,
                    child: ListView.builder(
                        itemCount: controller.contactList.length,
                        // shrinkWrap: true,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemBuilder: (BuildContext context, int index) {
                          // var parentIndex = index;
                          var contactItem = controller.contactList[index];
                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(10, 10, 10, 5),
                                child: Row(
                                  children: [
                                    ProfileTextImage(
                                      text: contactItem.userName,
                                      radius: AppStyleConfig.localContactPreviewPageStyle.contactItemStyle.profileImageSize.width / 2,
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Flexible(
                                      child: Text(
                                        contactItem.userName,
                                       style: AppStyleConfig.localContactPreviewPageStyle.contactItemStyle.titleStyle,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Divider(
                                color: AppStyleConfig.localContactPreviewPageStyle.contactItemStyle.dividerColor,
                                thickness: 0.1,
                              ),
                              ListView.builder(
                                  itemCount: contactItem.contactNo.length,
                                  physics: const ClampingScrollPhysics(),
                                  shrinkWrap: true,
                                  itemBuilder:
                                      (BuildContext context, int childIndex) {
                                    var phoneItem =
                                        contactItem.contactNo[childIndex];
                                    var style = AppStyleConfig.localContactPreviewPageStyle.listItemStyle;
                                    return ListTile(
                                      onTap: () {
                                        controller.changeStatus(phoneItem);
                                      },
                                      title: Text(
                                        phoneItem.mobNo,
                                        style: style.titleTextStyle,
                                        // style: const TextStyle(fontSize: 13),
                                      ),
                                      subtitle: Text(
                                        phoneItem.mobNoType,
                                        style: style.descriptionTextStyle,
                                        // style: const TextStyle(fontSize: 12),
                                      ),
                                      leading: Icon(
                                        Icons.phone,
                                        color: style.leadingIconColor,
                                        // color: Colors.blue,
                                        size: 20,
                                      ),
                                      trailing: Visibility(
                                        visible:
                                            contactItem.contactNo.length > 1 &&
                                                controller.from != "chat",
                                        child: Checkbox(
                                          activeColor: style.trailingIconColor,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(4)),
                                          value: phoneItem.isSelected,
                                          onChanged: (bool? value) {
                                            controller.changeStatus(phoneItem);
                                          },
                                        ),
                                      ),
                                    );
                                  }),
                              Divider(
                                color: AppStyleConfig.localContactPreviewPageStyle.contactItemStyle.dividerColor,
                                thickness: 0.8,
                              ),
                            ],
                          );
                        }),
                  );
                }),
                controller.from == "contact_pick"
                    ? Positioned(
                        bottom: 25,
                        right: 20,
                        child: FloatingActionButton(
                            onPressed: () {
                              controller.shareContact();
                            },
                            child: const Icon(
                              Icons.send,
                            )))
                    : const Offstage()
              ],
            ),
          )),
    );
  }
}
