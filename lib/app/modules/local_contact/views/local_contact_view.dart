import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/app_localizations.dart';
import '../../../model/local_contact_model.dart';
import '../../../stylesheet/stylesheet.dart';

import '../../../app_style_config.dart';
import '../../../common/constants.dart';
import '../../../common/widgets.dart';
import '../../../data/utils.dart';
import '../../../extensions/extensions.dart';
import '../controllers/local_contact_controller.dart';

class LocalContactView extends NavViewStateful<LocalContactController> {
  const LocalContactView({Key? key}) : super(key: key);

  @override
  LocalContactController createController({String? tag}) =>
      Get.put(LocalContactController());

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
          appBarTheme: AppStyleConfig.localContactPageStyle.appBarTheme,
          floatingActionButtonTheme: AppStyleConfig.localContactPageStyle
              .floatingActionButtonThemeData),
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 0.0,
          title: Obx(() {
            return controller.search.value
                ? TextField(
              controller: controller.searchTextController,
              onChanged: (text) => controller.onSearchTextChanged(text),
              autofocus: true,
              style: AppStyleConfig.localContactPageStyle.searchTextFieldStyle
                  .editTextStyle,
              decoration: InputDecoration(
                  hintText: getTranslated("searchPlaceholder"),
                  border: InputBorder.none,
                  hintStyle: AppStyleConfig.localContactPageStyle
                      .searchTextFieldStyle.editTextHintStyle),
            ) : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  getTranslated("contactToSend"),
                  style: AppStyleConfig.localContactPageStyle.appBarTheme
                      .titleTextStyle,
                ),
                Text(getTranslated("selectedCount").replaceAll("%d",
                    '${controller.contactsSelected.length}'),
                  style: AppStyleConfig.localContactPageStyle.appBarTheme
                      .toolbarTextStyle,
                ),
              ],
            );
          }),
          actions: [
            Obx(() =>
            controller.search.value
                ? const Offstage()
                : IconButton(
              icon: AppUtils.svgIcon(icon:
                searchIcon,
                width: 18,
                height: 18,
                fit: BoxFit.contain,
                colorFilter: ColorFilter.mode(AppStyleConfig.localContactPageStyle.appBarTheme.actionsIconTheme
                    ?.color ?? Colors.black, BlendMode.srcIn),
              ),
              onPressed: () {
                if (controller.search.value) {
                  controller.search.value = false;
                } else {
                  controller.search.value = true;
                }
              },
            )
            ),
          ],
        ),
        body: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) {
              return;
            }
            if (controller.search.value) {
              controller.searchTextController.text = "";
              controller.onSearchCancelled();
              controller.search.value = false;
              return;
            } else {
              NavUtils.back();
            }
          },
          child: SafeArea(
            child: Obx(() =>
            controller.contactList.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : contactListView(context,
                AppStyleConfig.localContactPageStyle.selectedContactItemStyle,
                AppStyleConfig.localContactPageStyle.contactItemStyle)),
          ),

        ),
        floatingActionButton: Obx(() {
          return Visibility(
            visible: controller.contactsSelected.isNotEmpty,
            child: FloatingActionButton(
              onPressed: () {
                controller.shareContact();
              },
              child: const Icon(
                  Icons.arrow_forward,
              ),
            ),
          );
        }),
      ),
    );
  }

  selectedListView(RxList<LocalContact> contactsSelected,
      LocalContactItem selectedContactItemStyle) {
    return contactsSelected.isNotEmpty
        ? SizedBox(
      height: 70,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: contactsSelected.length,
          itemBuilder: (context, index) {
            var item = contactsSelected.elementAt(index);
            return InkWell(
              onTap: () {
                controller.contactSelected(item);
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        ProfileTextImage(
                          text: controller.name(item.contact),
                          radius: selectedContactItemStyle.profileImageSize
                              .width / 2,
                        ),
                        Positioned(
                            right: 2,
                            bottom: 2,
                            child: AppUtils.svgIcon(icon:
                              closeContactIcon,
                              width: 15,
                            )),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
    )
        : const SizedBox.shrink();
  }

  contactListView(BuildContext context,
      LocalContactItem selectedContactItemStyle,
      LocalContactItem contactItemStyle) {
    return Obx(() {
      return Column(
        children: [
          selectedListView(
              controller.contactsSelected, selectedContactItemStyle),
          controller.searchList.isEmpty &&
              controller.searchTextController.text.isNotEmpty
              ? Center(child: Text(getTranslated("noResultFound"),
            style: AppStyleConfig.localContactPageStyle.noDataTextStyle,))
              : Expanded(
            child: ListView.builder(
                itemCount: controller.searchList.length,
                itemBuilder: (context, index) {
                  var item = controller.searchList.elementAt(index);
                  return InkWell(
                    onTap: () {
                      controller.contactSelected(
                          controller.searchList.elementAt(index));
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 15),
                      child: Row(
                        children: [
                          Stack(
                            children: [
                              ProfileTextImage(
                                text: controller.name(item.contact),
                                radius: contactItemStyle.profileImageSize
                                    .width / 2,
                              ),
                              Visibility(
                                visible: item.isSelected,
                                child: Positioned(
                                    right: 0,
                                    bottom: 0,
                                    child: AppUtils.svgIcon(icon:
                                      contactSelectTick,
                                      width: 12,
                                    )),
                              ),
                            ],
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Flexible(
                              child: Text(
                                controller.name(item.contact),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: contactItemStyle.titleStyle,
                              )),
                        ],
                      ),
                    ),
                  );
                }),
          ),
        ],
      );
    });
  }
}
