import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/app_localizations.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';

import '../../../data/utils.dart';
import '../../../extensions/extensions.dart';
import '../controllers/country_controller.dart';

class CountryListView extends NavViewStateful<CountryController> {
  const CountryListView({Key? key}) : super(key: key);

  @override
CountryController createController({String? tag}) => Get.put(CountryController());

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
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
                  onChanged: (text) => controller.countrySearchFilter(text),
                  controller: controller.searchQuery,
                  style: const TextStyle(fontSize: 18),
                  decoration: InputDecoration(
                      hintText: getTranslated("searchPlaceholder"), border: InputBorder.none),
                )
              : Text(getTranslated("selectCountry")),
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
                      controller.search.value=true;
                    },
                  ),
          ],
        ),
        body: controller.countryList.isNotEmpty ? ListView.builder(
              itemCount: controller.countryList.length,
              physics: const AlwaysScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                var item = controller.countryList[index];
                return ListTile(
                  title: Text(item.name ?? "",
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w500)),
                  trailing: Text(
                    item.dialCode ?? "",
                    style: const TextStyle(color: textHintColor),
                  ),
                  onTap: () {
                    NavUtils.back(result: item);
                  },
                );
              }) : Center(child: Text(getTranslated("noCountryFound")),)
      ),
    );
  }
}
