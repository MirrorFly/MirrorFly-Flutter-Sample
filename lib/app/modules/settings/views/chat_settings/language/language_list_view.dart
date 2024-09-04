import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../common/constants.dart';
import '../../../../../modules/settings/views/chat_settings/language/language_controller.dart';

import '../../../../../data/utils.dart';
import '../../../../../extensions/extensions.dart';


class LanguageListView extends NavViewStateful<LanguageController> {
  const LanguageListView({Key? key}) : super(key: key);

  @override
  LanguageController createController({String? tag}) =>
      Get.put(LanguageController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: iconColor),
                  onPressed: () {
                    controller.backFromSearch();
                  },
                ),
                title: Obx(() {
                  return controller.search.value
                      ? TextField(
                    focusNode: controller.focusNode,
                    onChanged: (text) => controller.languageSearchFilter(text),
                    controller: controller.searchQuery,
                    style: const TextStyle(fontSize: 18),
                    decoration: const InputDecoration(
                        hintText: "Search...", border: InputBorder.none),
                  ) : const Text('Choose Language');
                }),
                actions: [
                  Obx(() {
                    return controller.search.value
                        ? const Offstage() : IconButton(
                      icon: AppUtils.svgIcon(icon:
                        searchIcon,
                        width: 18,
                        height: 18,
                        fit: BoxFit.contain,
                      ),
                      onPressed: () {
                        controller.focusNode.requestFocus();
                        controller.search.value = true;
                      },
                    );
                  }),
                ],
              ),
              body: SafeArea(
                child: Obx(() {
                  return ListView.builder(
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
                              child: AppUtils.svgIcon(icon:tickRoundBlue)),
                          onTap: () {
                            controller.selectLanguage(item);
                          },
                        );
                      });
                }),
              )
          );
  }
}
