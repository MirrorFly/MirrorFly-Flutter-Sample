import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../extensions/extensions.dart';
import '../../../modules/dashboard/controllers/dashboard_controller.dart';
import '../../../stylesheet/stylesheet.dart';
import 'package:mirrorfly_plugin/logmessage.dart';
import 'package:mirrorfly_plugin/model/recent_chat.dart';

import '../../../common/app_localizations.dart';
import '../../../common/constants.dart';
import '../../../common/widgets.dart';
import '../../../data/helper.dart';
import '../../../data/utils.dart';
import '../../../routes/route_settings.dart';
import '../widgets.dart';

class RecentChatView extends StatelessWidget {
  const RecentChatView({super.key,required this.controller,required this.archivedTileStyle, this.recentChatItemStyle = const RecentChatItemStyle(), required this.noDataTextStyle, this.contactItemStyle = const ContactItemStyle()});
  final DashboardController controller;
  final ArchivedTileStyle archivedTileStyle;
  final RecentChatItemStyle recentChatItemStyle;
  final ContactItemStyle contactItemStyle;
  final TextStyle noDataTextStyle;

  @override
  Widget build(BuildContext context) {
    return Obx(() => controller.clearVisible.value
        ? recentSearchView(context)
        : Stack(
      children: [
        Obx(() {
          return Visibility(
              visible: !controller.recentChatLoading.value && controller.recentChats.isEmpty && controller.archivedChats.isEmpty,
              child: emptyChat(context));
        }),
        Column(
          children: [
            Visibility(
              visible: Constants.enableTopic,
              child: SizedBox(
                height: 40,
                child: Obx(() {
                  return ListView.builder(
                    key: const PageStorageKey("list"),
                    scrollDirection: Axis.horizontal,
                    itemCount: controller.topics.length,
                    itemBuilder: (BuildContext context, int index) {
                      return InkWell(
                        onTap: () {
                          controller.onTopicsTap(index);
                        },
                        child: Obx(() {
                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0), // Specify the border radius
                              side: (controller.topicId.value == controller.topics[index].topicId)
                                  ? const BorderSide(
                                color: Colors.blue, // Specify the border color
                                width: 2.0, // Specify the border width
                              )
                                  : BorderSide.none,
                            ),
                            color: Colors.grey[100],
                            margin: const EdgeInsets.all(4.0),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(controller.topics[index].topicName.checkNull()),
                            ),
                          );
                        }),
                      );
                    },
                  );
                }),
              ),
            ),
            /*Visibility(
              visible: Constants.enableTopic,
              child: SizedBox(
                child: Obx(() {
                  return controller.topics.isNotEmpty ? Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0), // Specify the border radius
                      ),
                      color: Colors.grey[100],
                      margin: const EdgeInsets.all(4.0),
                      child: ListTile(
                        title: Text(controller.topics[0].topicName.checkNull()),
                        subtitle: Text(controller.topics[0].metaData["description"]),
                      )
                  ) : const SizedBox.shrink();
                }),
              ),),*/
            Obx(() {
              return Visibility(
                visible:
                controller.archivedChats.isNotEmpty && controller.archiveSettingEnabled.value /*&& controller.archivedCount.isNotEmpty*/,
                child: ListItem(
                  leading: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: AppUtils.svgIcon(icon:archive),
                  ),
                  title: Text(
                    getTranslated("archived"),
                    style: archivedTileStyle.textStyle,
                  ),
                  trailing: controller.archivedCount != "0"
                      ? Text(
                    controller.archivedCount,
                    style: archivedTileStyle.countTextStyle,//const TextStyle(color: buttonBgColor),
                  )
                      : null,
                  dividerPadding: EdgeInsets.zero,
                  onTap: () {
                    NavUtils.toNamed(Routes.archivedChats);
                  },
                ),
              );
            }),
            Expanded(child: Obx(() {
              return controller.recentChatLoading.value
                  ? const Center(
                child: CircularProgressIndicator(),
              )
                  : ListView.builder(
                  padding: EdgeInsets.zero,
                  physics: const BouncingScrollPhysics(),
                  itemCount: controller.recentChats.length + 2,
                  shrinkWrap: true,
                  controller: controller.historyScrollController,
                  itemBuilder: (BuildContext context, int index) {
                    if (index < controller.recentChats.length) {
                      var item = controller.recentChats[index];
                      return Obx(() {
                        return RecentChatItem(
                          recentChatItemStyle: recentChatItemStyle,
                          item: item,
                          isSelected: controller.isSelected(index),
                          typingUserid: controller.typingUser(item.jid.checkNull()),
                          onTap: (RecentChatData chatItem) {
                            if (controller.selected.value) {
                              controller.selectOrRemoveChatfromList(index);
                            } else {
                              controller.toChatPage(item.jid.checkNull());
                            }
                          },
                          onLongPress: (RecentChatData chatItem) {
                            controller.selected(true);
                            controller.selectOrRemoveChatfromList(index);
                          },
                          onAvatarClick: (RecentChatData chatItem) {
                            controller.getProfileDetail(context, item, index);
                          },
                        );
                      });
                    } else if (index == controller.recentChats.length) {
                      // Display loading indicator
                      return Obx(() {
                        return controller.isRecentHistoryLoading.value
                            ? const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Center(
                            child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator()),
                          ),
                        )
                            : const SizedBox.shrink();
                      });
                    } else {
                      return Obx(() {
                        return Visibility(
                          visible: controller.archivedChats.isNotEmpty &&
                              !controller.archiveSettingEnabled.value /*&& controller.archivedCount.isNotEmpty*/,
                          child: ListItem(
                            leading: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: AppUtils.svgIcon(icon:archive),
                            ),
                            title: Text(
                              getTranslated("archived"),
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            trailing: controller.archivedChats.isNotEmpty
                                ? Text(
                              controller.archivedChats.length.toString(),
                              style: const TextStyle(color: buttonBgColor),
                            )
                                : null,
                            dividerPadding: EdgeInsets.zero,
                            onTap: () {
                              NavUtils.toNamed(Routes.archivedChats);
                            },
                          ),
                        );
                      });
                    }
                  });
            })
              // }),
            ),
          ],
        )
      ],
    ));
  }

  Widget recentSearchView(BuildContext context) {
    return ListView(
      controller: controller.userlistScrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        Obx(() {
          return Column(
            children: [
              Visibility(
                visible: controller.filteredRecentChatList.isNotEmpty,
                child: searchHeader(getTranslated("chats"), controller.filteredRecentChatList.length.toString(), context),
              ),
              recentChatSearchListView(),
              Visibility(
                visible: controller.chatMessages.isNotEmpty,
                child: searchHeader(getTranslated("message"), controller.chatMessages.length.toString(), context),
              ),
              filteredMessageListView(),
              Visibility(
                visible: controller.userList.isNotEmpty && !controller.searchLoading.value,
                child: searchHeader(getTranslated("contact"), controller.userList.length.toString(), context),
              ),
              Visibility(
                  visible: controller.searchLoading.value,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  )),
              Visibility(
                visible: controller.userList.isNotEmpty && !controller.searchLoading.value,
                child: filteredUsersListView(),
              ),
              Visibility(
                  visible: controller.search.text.isNotEmpty &&
                      controller.filteredRecentChatList.isEmpty &&
                      controller.chatMessages.isEmpty &&
                      controller.userList.isEmpty,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(getTranslated("noDataFound")),
                    ),
                  ))
            ],
          );
        })
      ],
    );
  }

  ListView filteredUsersListView() {
    return ListView.builder(
        itemCount: controller.scrollable.value ? controller.userList.length + 1 : controller.userList.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          if (index >= controller.userList.length && controller.scrollable.value) {
            return const Center(child: CircularProgressIndicator());
          } else {
            var item = controller.userList[index];
            return MemberItem(
              name: item.getName(),
              image: item.image.checkNull(),
              status: item.status.checkNull(),
              searchTxt: controller.search.text.toString(),
              onTap: () {
                controller.toChatPage(item.jid.checkNull());
              },
              isCheckBoxVisible: false,
              isGroup: item.isGroupProfile.checkNull(),
              blocked: item.isBlockedMe.checkNull() || item.isAdminBlocked.checkNull(),
              unknown: (!item.isItSavedContact.checkNull() || item.isDeletedContact()),
              itemStyle: contactItemStyle,
            );
          }
        });
  }

  ListView filteredMessageListView() {
    return ListView.builder(
        itemCount: controller.chatMessages.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          var items = controller.chatMessages[index];
          return FutureBuilder(
              future: controller.getProfileAndMessage(items.chatUserJid.checkNull(), items.messageId.checkNull()),
              builder: (context, snap) {
                if (snap.hasData) {
                  var profile = snap.data!.entries.first.key!;
                  var item = snap.data!.entries.first.value!;
                  // var unreadMessageCount = "0";
                  return RecentChatMessageItem(profile: profile, item: item, searchTxt: controller.search.text,
                    onTap: () { controller.toChatPage(items.chatUserJid.checkNull()); },);
                  /*return InkWell(
                    child: Row(
                      children: [
                        Container(
                            margin: const EdgeInsets.only(left: 19.0, top: 10, bottom: 10, right: 10),
                            child: Stack(
                              children: [
                                ImageNetwork(
                                  url: profile.image.checkNull(),
                                  width: recentChatItemStyle.profileImageSize.width,
                                  height: recentChatItemStyle.profileImageSize.height,
                                  clipOval: true,
                                  errorWidget: ProfileTextImage(
                                      text: profile.getName(),
                                    radius: recentChatItemStyle.profileImageSize.width/2,
                                  ),
                                  isGroup: profile.isGroupProfile.checkNull(),
                                  blocked: profile.isBlockedMe.checkNull() || profile.isAdminBlocked.checkNull(),
                                  unknown: (!profile.isItSavedContact.checkNull() || profile.isDeletedContact()),
                                ),
                                unreadMessageCount.toString() != "0"
                                    ? Positioned(
                                    right: 0,
                                    child: CircleAvatar(
                                      radius: 9,
                                      backgroundColor: recentChatItemStyle.unreadCountBgColor,
                                      child: Text(
                                        unreadMessageCount.toString(),
                                        style: recentChatItemStyle.unreadCountTextStyle,
                                        // style: const TextStyle(fontSize: 9, color: Colors.white, fontFamily: 'sf_ui'),
                                      ),
                                    ))
                                    : const Offstage(),
                              ],
                            )),
                        Flexible(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(profile.getName(), //profile.name.toString(),
                                      style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w700, fontFamily: 'sf_ui', color: textHintColor),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 16.0, left: 8),
                                    child: Text(
                                      DateTimeUtils.getRecentChatTime(context, item.messageSentTime.toInt()),
                                      textAlign: TextAlign.end,
                                      style: TextStyle(
                                          fontSize: 12.0,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'sf_ui',
                                          color: unreadMessageCount.toString() != "0" ? buttonBgColor : textColor),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  unreadMessageCount.toString() != "0"
                                      ? const Padding(
                                    padding: EdgeInsets.only(right: 8.0),
                                    child: CircleAvatar(
                                      radius: 4,
                                      backgroundColor: Colors.green,
                                    ),
                                  )
                                      : const SizedBox(),
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(right: 8.0),
                                          child: MessageUtils.getMessageIndicatorIcon(item.messageStatus.value.checkNull(), item.isMessageSentByMe.checkNull(),
                                              item.messageType.checkNull(), item.isMessageRecalled.value),
                                        ),
                                        item.isMessageRecalled.value
                                            ? const Offstage()
                                            : forMessageTypeIcon(item.messageType, item.mediaChatMessage),
                                        SizedBox(
                                          width:
                                          forMessageTypeString(item.messageType, content: item.mediaChatMessage?.mediaCaptionText.checkNull()) !=
                                              null
                                              ? 3.0
                                              : 0.0,
                                        ),
                                        Expanded(
                                          child:
                                          forMessageTypeString(item.messageType, content: item.mediaChatMessage?.mediaCaptionText.checkNull()) ==
                                              null
                                              ? spannableText(
                                            item.messageTextContent.toString(),
                                            controller.search.text,
                                            Theme.of(context).textTheme.titleSmall,Colors.blue,
                                          )
                                              : Text(
                                            forMessageTypeString(item.messageType,
                                                content: item.mediaChatMessage?.mediaCaptionText.checkNull()) ??
                                                item.messageTextContent.toString(),
                                            style: Theme.of(context).textTheme.titleSmall,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const AppDivider()
                            ],
                          ),
                        )
                      ],
                    ),
                    onTap: () {
                      controller.toChatPage(items.chatUserJid.checkNull());
                    },
                  );*/
                } else if (snap.hasError) {
                  LogMessage.d("snap error", snap.error.toString());
                }
                return const SizedBox();
              });
        });
  }

  ListView recentChatSearchListView() {
    return ListView.builder(
        itemCount: controller.filteredRecentChatList.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          var item = controller.filteredRecentChatList[index];
          return FutureBuilder(
              future: getRecentChatOfJid(item.jid.checkNull()),
              builder: (context, snapshot) {
                var item = snapshot.data;
                return item != null
                    ? RecentChatItem(
                  item: item,
                  spanTxt: controller.search.text,
                  onTap: (RecentChatData chatItem) {
                    controller.toChatPage(item.jid.checkNull(),);
                  },recentChatItemStyle: recentChatItemStyle,
                )
                    : const SizedBox();
              });
        });
  }

  Widget emptyChat(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AppUtils.assetIcon(assetName:
            noChatIcon,
            width: 200,
          ),
          Text(
            getTranslated("noNewMessages"),
            textAlign: TextAlign.center,
            style: noDataTextStyle,
            // style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            getTranslated("noMessagesContent"),
            textAlign: TextAlign.center,
            style: noDataTextStyle.copyWith(fontWeight: FontWeight.w300),
            // style: Theme.of(context).textTheme.titleSmall,
          ),
        ],
      ),
    );
  }
}
