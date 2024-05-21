import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirror_fly_demo/app/modules/settings/views/chat_settings/language/language_controller.dart';

import '../../../../../extensions/extensions.dart';


class LanguageListView extends NavView<LanguageController> {
  const LanguageListView({Key? key}) : super(key: key);

  @override
  LanguageController createController() {
    return LanguageController();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Obx(
            () =>
            Scaffold(
                appBar: AppBar(
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: iconColor),
                    onPressed: () {
                      controller.backFromSearch();
                    },
                  ),
                  title: controller.search.value
                      ? TextField(
                    focusNode: controller.focusNode,
                    onChanged: (text) => controller.languageSearchFilter(text),
                    controller: controller.searchQuery,
                    style: const TextStyle(fontSize: 18),
                    decoration: const InputDecoration(
                        hintText: "Search...", border: InputBorder.none),
                  )
                      : const Text('Choose Language'),
                  actions: [
                    controller.search.value
                        ? const SizedBox()
                        : IconButton(
                      icon: SvgPicture.asset(
                        searchIcon,
                        width: 18,
                        height: 18,
                        fit: BoxFit.contain,
                      ),
                      onPressed: () {
                        controller.focusNode.requestFocus();
                        controller.search.value = true;
                      },
                    ),
                  ],
                ),
                body: ListView.builder(
                    itemCount: controller.languageList.length,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemBuilder: (BuildContext context, int index) {
                      var item = controller.languageList[index];
                        return ListTile(
                          title: Text(item.languageName,
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500)),
                          trailing: Visibility(visible: item.languageName ==
                              controller.translationLanguage.value,
                              child: SvgPicture.asset(tickRoundBlue)),
                          onTap: () {
                            controller.selectLanguage(item);
                          },
                        );
                    })
            ),
      ),
    );
  }
}
