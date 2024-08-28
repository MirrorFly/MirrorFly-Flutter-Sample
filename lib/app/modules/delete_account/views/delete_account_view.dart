import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../common/app_localizations.dart';
import '../../../common/widgets.dart';

import '../../../common/constants.dart';
import '../../../data/utils.dart';
import '../../../extensions/extensions.dart';
import '../../../routes/route_settings.dart';
import '../controllers/delete_account_controller.dart';

class DeleteAccountView extends NavViewStateful<DeleteAccountController> {
  const DeleteAccountView({Key? key}) : super(key: key);

  @override
DeleteAccountController createController({String? tag}) => Get.put(DeleteAccountController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(getTranslated("deleteMyAccount")),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                  AppUtils.svgIcon(icon:
                    warningIcon,
                  fit: BoxFit.contain,
                ),
                    const SizedBox(width: 15),
                    Text(
                      getTranslated("deletingYourAccount"),
                      style: const TextStyle(color: Colors.red, fontSize: 17),
                    ),
                  ],
                ),
                const SizedBox(height: 10,),
                Row(
                  children: [
                    const SizedBox(width: 30,),
                    const Text(Constants.bulletPoint, style: TextStyle(fontSize: 12),),
                    Text(getTranslated("deletingYourAccountDescription1"),style: const TextStyle(color: textColor),),
                  ],
                ),
                const SizedBox(height: 10,),
                Row(
                  children: [
                    const SizedBox(width: 30,),
                    const Text(Constants.bulletPoint, style: TextStyle(fontSize: 12),),
                    Text(getTranslated("deletingYourAccountDescription2"),style: const TextStyle(color: textColor),),
                  ],
                ),
                const SizedBox(height: 10,),
                Row(
                  children: [
                    const SizedBox(width: 30,),
                    const Text(Constants.bulletPoint, style: TextStyle(fontSize: 12),),
                    Text(getTranslated("deletingYourAccountDescription3"),style: const TextStyle(color: textColor),),
                  ],
                ),
                const SizedBox(height: 15,),
          Text(getTranslated("deleteConfirmation"),
                  style: const TextStyle(color: textHintColor, fontSize: 15),
                ),
                const SizedBox(height: 10,),
                Text(
                  getTranslated("country"),
                  style: const TextStyle(color: textHintColor, fontSize: 14, fontWeight: FontWeight.w600),
                ),
                Obx(() => countryItem(
                  // contentPadding: EdgeInsets.zero,
                  title: Text(controller.selectedCountry.value.name ?? "",
                      style: const TextStyle(color: textHintColor,fontSize: 16,fontWeight: FontWeight.normal)),
                  trailing: const Icon(Icons.keyboard_arrow_down_outlined),
                  onTap: (){
                    NavUtils.toNamed(Routes.countries)?.then((value) => value!=null ? controller.selectedCountry.value = value : controller.india);
                  },
                )),
                const SizedBox(height: 10,),
                Text(
                  getTranslated("mobileNumber"),
                  style: const TextStyle(color: textHintColor, fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10,),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                  child: IntrinsicHeight(
                    child: Row(
                      children: [
                        Obx(
                              ()=> Text(
                            controller.selectedCountry.value.dialCode ?? "",
                            style: const TextStyle(fontSize: 15,color: textHintColor,fontWeight: FontWeight.normal),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                          child: VerticalDivider(
                            color: Colors.grey,
                            thickness: 0.3,
                          ),
                        ),
                        Flexible(
                          child: TextField(
                            controller: controller.mobileNumber,
                            keyboardType: TextInputType.phone,
                            maxLength: 15,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            style: const TextStyle(color: textHintColor,fontWeight: FontWeight.normal),
                            decoration: InputDecoration(
                              counterText: '',
                              enabledBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: buttonBgColor),
                              ),
                              hintText: getTranslated("mobileNumber")
                            ),
                          ),
                        ),

                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30,),
                Center(
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
                      getTranslated("continue"),
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

  Widget countryItem({Function()? onTap, required Widget title, Widget? trailing,EdgeInsetsGeometry? dividerPadding }){
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0,top: 10.0,bottom: 10.0),
            child: Row(
              children: [
                Expanded(
                  child: title,
                ),
                trailing ?? const SizedBox()
              ],
            ),
          ),
          dividerPadding != null
              ? AppDivider(padding: dividerPadding)
              : const SizedBox()
        ],
      ),
    );
  }
}
