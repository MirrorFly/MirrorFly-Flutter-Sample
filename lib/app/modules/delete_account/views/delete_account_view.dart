import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get/get.dart';

import '../../../common/constants.dart';
import '../../../routes/app_pages.dart';
import '../controllers/delete_account_controller.dart';

class DeleteAccountView extends GetView<DeleteAccountController> {
  const DeleteAccountView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delete My Account'),
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
                  SvgPicture.asset(
                    warningIcon,
                  fit: BoxFit.contain,
                ),
                    const SizedBox(width: 15),
                    const Text(
                      'Deleting your account will:',
                      style: TextStyle(color: Colors.red, fontSize: 17),
                    ),
                  ],
                ),
                const SizedBox(height: 10,),
                Row(
                  children: const [
                    SizedBox(width: 30,),
                    Text(Constants.bulletPoint, style: TextStyle(fontSize: 18),),
                    Text("Delete your account from MirrorFly"),
                  ],
                ),
                const SizedBox(height: 10,),
                Row(
                  children: const [
                    SizedBox(width: 30,),
                    Text(Constants.bulletPoint, style: TextStyle(fontSize: 18),),
                    Text("Erase your message history"),
                  ],
                ),
                const SizedBox(height: 10,),
                Row(
                  children: const [
                    SizedBox(width: 30,),
                    Text(Constants.bulletPoint, style: TextStyle(fontSize: 18),),
                    Text("Delete you from all of your MirrorFly groups"),
                  ],
                ),
                const SizedBox(height: 15,),
                const Text(
                  'To delete your account, confirm your country and enter your phone number.',
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
                const SizedBox(height: 10,),
                const Text(
                  'Country',
                  style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Obx(() => Padding(
                  padding: const EdgeInsets.only(left : 10.0 , right: 10.0,top: 10.0),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(controller.selectedCountry.value.name ?? "",
                        style: const TextStyle(color: Colors.black,fontSize: 16,fontWeight: FontWeight.w500)),
                    trailing: const Icon(Icons.keyboard_arrow_down_outlined),
                    onTap: (){
                      Get.toNamed(Routes.countries)?.then((value) => value!=null ? controller.selectedCountry.value = value : controller.india);
                    },
                  ),
                )),
                const SizedBox(height: 10,),
                const Text(
                  'Mobile number',
                  style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
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
                            style: const TextStyle(fontSize: 15),
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
                            decoration: const InputDecoration(
                              counterText: '',
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: buttonBgColor),
                              ),
                              hintText: "Mobile Number"
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
                    child: const Text(
                      'Continue',
                      style: TextStyle(fontWeight: FontWeight.w600),
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
