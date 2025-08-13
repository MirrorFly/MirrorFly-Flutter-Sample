import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/app_localizations.dart';

import '../../../common/constants.dart';
import '../../../extensions/extensions.dart';
import '../controllers/delete_account_reason_controller.dart';

class DeleteAccountReasonView
    extends NavViewStateful<DeleteAccountReasonController> {
  const DeleteAccountReasonView({Key? key}) : super(key: key);

  @override
  DeleteAccountReasonController createController({String? tag}) =>
      Get.put(DeleteAccountReasonController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(getTranslated("deleteMyAccount")),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    getTranslated("deleteAccountReason"),
                    style: const TextStyle(
                        color: textHintColor,
                        fontSize: 15,
                        fontWeight: FontWeight.normal),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Obx(() {
                    return DropdownButton(
                      isExpanded: true,
                      value: controller.reasonValue.value == ""
                          ? null
                          : controller.reasonValue.value,
                      icon: const Icon(Icons.keyboard_arrow_down),
                      hint: Text(
                        getTranslated("selectReason"),
                        style: const TextStyle(fontWeight: FontWeight.normal),
                      ),
                      items: controller.deleteReasons.map((String items) {
                        return DropdownMenuItem(
                          value: items,
                          child: Text(
                            items,
                            style:
                                const TextStyle(fontWeight: FontWeight.normal),
                          ),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        controller.reasonValue(newValue.toString());
                      },
                    );
                  }),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    keyboardType: TextInputType.multiline,
                    maxLength: 250,
                    maxLines: null,
                    focusNode: controller.focusNode,
                    controller: controller.feedback,
                    decoration: InputDecoration(
                      hintText: getTranslated("tellUsImprove"),
                      hintStyle: const TextStyle(fontWeight: FontWeight.normal),
                      counterText: '',
                      focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: dividerColor)),
                      border: const UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: dividerColor, width: 0)),
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Text(
                    getTranslated("feedbackDesc"),
                    style: const TextStyle(
                        color: textColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w300),
                  ),
                  const SizedBox(
                    height: 55,
                  ),
                  Obx(() {
                    return controller.reasonValue.value == ""
                        ? const SizedBox.shrink()
                        : Center(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 40, vertical: 10),
                                  textStyle: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500),
                                  shape: const StadiumBorder()),
                              onPressed: () {
                                controller.deleteAccount();
                              },
                              child: Text(
                                getTranslated("deleteMyAccount"),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white),
                              ),
                            ),
                          );
                  }),
                ],
              ),
            ),
          ),
        ));
  }
}
