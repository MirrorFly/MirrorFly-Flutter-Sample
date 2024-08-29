import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart' as emoji;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../common/app_localizations.dart';
import '../data/session_management.dart';
import '../extensions/extensions.dart';
import '../modules/dashboard/widgets.dart';
import 'package:mirrorfly_plugin/mirrorflychat.dart';

import '../data/utils.dart';
import '../stylesheet/stylesheet.dart';
import 'constants.dart';
import 'main_controller.dart';

class AppDivider extends StatelessWidget {
  const AppDivider({Key? key, this.padding, this.color}) : super(key: key);

  final EdgeInsetsGeometry? padding;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: padding,
      height: 0.29,
      color: color ?? dividerColor,
    );
  }
}

class ProfileTextImage extends StatelessWidget {
  final String text;
  final Color? bgColor;
  final double fontSize;
  final double radius;
  final Color fontColor;

  const ProfileTextImage(
      {Key? key,
      required this.text,
      this.fontSize = 15,
      this.bgColor,
      this.radius = 25,
      this.fontColor = Colors.white})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return radius == 0
        ? Container(
            decoration: BoxDecoration(
                color: bgColor ?? Color(MessageUtils.getColourCode(text))),
            child: Center(
              child: Text(
                getString(text),
                style: TextStyle(
                    fontSize: fontSize,
                    color: fontColor,
                    fontWeight: FontWeight.w800),
              ),
            ),
          )
        : CircleAvatar(
            radius: radius,
            backgroundColor: bgColor ?? Color(MessageUtils.getColourCode(text)),
            child: Center(
                child: Text(
              getString(text),
              style: TextStyle(
                  fontSize: radius != 0 ? radius / 1.5 : fontSize,
                  color: fontColor),
            )),
          );
  }

  String getString(String str) {
    String string = "";
    if (str.characters.length >= 2) {
      if (str.trim().contains(" ")) {
        var st = str.trim().split(" ");
        string = st[0].characters.take(1).toUpperCase().toString() +
            st[1].characters.take(1).toUpperCase().toString();
      } else {
        string = str.characters.take(2).toUpperCase().toString();
      }
    } else {
      string = str;
    }
    return string;
  }
}

class ImageNetwork extends NavView<MainController> {
  final double? width;
  final double? height;
  final String url;
  final Widget? errorWidget;
  final bool clipOval;
  final Function()? onTap;
  final bool isGroup;
  final bool blocked;
  final bool unknown;

  const ImageNetwork({
    Key? key,
    required this.url,
    required this.width,
    required this.height,
    this.errorWidget,
    required this.clipOval,
    this.onTap,
    required this.isGroup,
    required this.blocked,
    required this.unknown,
  }) : super(key: key);

  @override
  MainController createController({String? tag}) => MainController();

  @override
  Widget build(BuildContext context) {
    // LogMessage.d("MirrorFly Auth", authToken.value);
    // LogMessage.d("Image URL", url);
    var imageUrl = getImageUrl();
    return imageUrl
            .isNotEmpty //Added this condition to avoid the error log print while loading the image if the url is empty
        ? Obx(() {
            return CachedNetworkImage(
              key: UniqueKey(),
              imageUrl: getImageUrl(),
              fit: BoxFit.fill,
              width: width,
              height: height,
              cacheKey: getImageUrl(),
              httpHeaders: {"Authorization": controller.currentAuthToken.value},
              placeholder: (context, string) {
                if (!(blocked || (unknown && Constants.enableContactSync))) {
                  if (errorWidget != null) {
                    return errorWidget!;
                  }
                }
                return clipOval
                    ? ClipOval(
                        child: AppUtils.assetIcon(assetName:
                          getSingleOrGroup(isGroup),
                          height: height,
                          width: width,
                          fit: BoxFit.cover,
                        ),
                      )
                    : AppUtils.assetIcon(assetName:
                        getSingleOrGroup(isGroup),
                        height: height,
                        width: width,
                        fit: BoxFit.cover,
                      );
              },
              errorWidget: (context, link, error) {
                if (getImageUrl().isNotEmpty) {
                  LogMessage.d("ImageNetwork Error",
                      "$error link : $link token : ${controller.currentAuthToken.value} ${url.isURL}");
                  if (error.toString().contains("401")) {
                    CachedNetworkImage.evictFromCache(url, cacheKey: url)
                        .then((value) {
                      refreshHeaders();
                    });
                  }
                }
                return imageErrorWidget();
              },
              imageBuilder: (context, provider) {
                return clipOval
                    ? ClipOval(
                        child: !(blocked ||
                                (unknown && Constants.enableContactSync))
                            ? Image(
                                image: provider,
                                fit: BoxFit.fill,
                              )
                            : AppUtils.assetIcon(assetName:
                                getSingleOrGroup(isGroup),
                                height: height,
                                width: width,
                                fit: BoxFit.cover,
                              ),
                      )
                    : InkWell(
                        onTap: onTap,
                        child: !(blocked ||
                                (unknown && Constants.enableContactSync))
                            ? Image(
                                image: provider,
                                fit: BoxFit.fill,
                              )
                            : AppUtils.assetIcon(assetName:
                                getSingleOrGroup(isGroup),
                                height: height,
                                width: width,
                                fit: BoxFit.cover,
                              ),
                      );
              },
            );
          })
        : imageErrorWidget();
  }

  String getImageUrl() {
    if (url.isEmpty) {
      return "";
    }
    if (url.startsWith("http")) {
      return url;
    } else {
      if (url.contains("/")) return "";
      return controller.mediaEndpoint + url;
    }
  }

  Widget imageErrorWidget() {
    if (!(blocked || (unknown && Constants.enableContactSync))) {
      if (errorWidget != null) {
        return errorWidget!;
      }
    }
    return clipOval
        ? ClipOval(
            child: AppUtils.assetIcon(assetName:
              getSingleOrGroup(isGroup),
              height: height,
              width: width,
              fit: BoxFit.cover,
            ),
          )
        : AppUtils.assetIcon(assetName:
            getSingleOrGroup(isGroup),
            height: height,
            width: width,
            fit: BoxFit.cover,
          );
  }

  Future<bool> isTokenExpired(String token) async {
    // logic to check if the token is expired
    // Return true if the token is expired, otherwise return false
    final http.Response response = await http
        .get(Uri.parse(getImageUrl()), headers: {"Authorization": token});
    var code = response.statusCode;
    LogMessage.d("ImageNetwork",
        "isTokenExpired url ${getImageUrl()} token: $token statusCode : ${response.statusCode}");
    return code == 401;
  }

  Future<Map<String, String>> refreshHeaders() async {
    if (getImageUrl().isEmpty) {
      return {};
    }
    var count = 0;
    // logic to get refreshed headers
    // get the available current Token
    var token = await Mirrorfly.getCurrentAuthToken();
    // This might involve checking the token expiration, refreshing the token if needed, and returning the headers
    while ((await isTokenExpired(token))) {
      if (count <= 1) {
        count++;
        if (SessionManagement.getUsername().checkNull().isNotEmpty &&
            SessionManagement.getPassword().checkNull().isNotEmpty) {
          await Mirrorfly.refreshAndGetAuthToken(flyCallBack: (response) {
            token = response.data;
          });
        }
        LogMessage.d(
            "ImageNetwork", "refreshAndGetAuthToken retryCount $count");
      } else {
        LogMessage.d("ImageNetwork",
            "refreshHeaders $count retryCount exceed retrying stopped...");
        break;
      }
    }
    LogMessage.d("ImageNetwork",
        "refreshHeaders url ${getImageUrl()} token: $token statusCode : ${200} retryCount : $count");
    // Adding the token in headers
    controller.currentAuthToken(token);
    return {
      'Authorization': token,
    };
  }

  String getSingleOrGroup(bool isGroup) {
    return isGroup ? groupImg : profileImg;
  }
}

class ListItem extends StatelessWidget {
  final Widget? leading;
  final Widget title;
  final Widget? trailing;
  final Function()? onTap;
  final EdgeInsetsGeometry? dividerPadding;

  const ListItem(
      {Key? key,
      this.leading,
      required this.title,
      this.trailing,
      this.onTap,
      this.dividerPadding})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                leading != null
                    ? Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                        child: leading)
                    : const SizedBox(),
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

class MemberItem extends StatelessWidget {
  const MemberItem(
      {super.key,
      required this.name,
      required this.image,
      required this.status,
      this.isAdmin,
      required this.onTap,
      this.onChange,
      required this.blocked,
      required this.unknown,
      this.itemStyle = const ContactItemStyle(),
      this.searchTxt = "",
      this.isCheckBoxVisible = false,
      this.isChecked = false,
      this.isGroup = false});
  final String name;
  final String image;
  final String status;
  final bool? isAdmin;
  final Function() onTap;
  final String searchTxt;
  final bool isCheckBoxVisible;
  final bool isChecked;
  final Function(bool? value)? onChange;
  final bool isGroup;
  final bool blocked;
  final bool unknown;
  final ContactItemStyle itemStyle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  right: 16.0, left: 16.0, top: 4, bottom: 4),
              child: Row(
                children: [
                  ImageNetwork(
                    url: image.checkNull(),
                    width: itemStyle.profileImageSize.width,
                    height: itemStyle.profileImageSize.height,
                    clipOval: true,
                    errorWidget: name.checkNull().isNotEmpty
                        ? ProfileTextImage(
                            radius: itemStyle.profileImageSize.width / 2,
                            text: name.checkNull(),
                          )
                        : null,
                    blocked: blocked,
                    unknown: unknown,
                    isGroup: isGroup,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          searchTxt.isEmpty
                              ? Text(
                                  name.checkNull(),
                                  style: itemStyle.titleStyle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis, //TextStyle
                                )
                              : spannableText(
                                  name.checkNull(),
                                  searchTxt,
                                  itemStyle.titleStyle,
                                  itemStyle.spanTextColor),
                          Text(
                            status.checkNull(),
                            style: itemStyle.descriptionStyle,
                            /* style: const TextStyle(
                              color: Colors.black,
                              fontSize: 12.0,
                            ),*/
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis, //T
                          ),
                        ],
                      ),
                    ),
                  ),
                  (isAdmin != null && isAdmin!)
                      ? Text(
                          getTranslated("groupAdmin"),
                          style: itemStyle.actionTextStyle,
                        )
                      : const SizedBox(),
                  Visibility(
                    visible: isCheckBoxVisible,
                    child: Checkbox(
                      value: isChecked,
                      onChanged: onChange,
                    ),
                  ),
                ],
              ),
            ),
            AppDivider(
              padding: const EdgeInsets.only(right: 16, left: 16, top: 4),
              color: itemStyle.dividerColor,
            )
          ],
        ),
      ),
    );
  }
}

class EmojiLayout extends StatelessWidget {
  const EmojiLayout(
      {Key? key,
      required this.textController,
      this.onEmojiSelected,
      this.onBackspacePressed})
      : super(key: key);
  final TextEditingController textController;
  final Function(emoji.Category?, emoji.Emoji)? onEmojiSelected;
  final Function()? onBackspacePressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: emoji.EmojiPicker(
        onBackspacePressed: onBackspacePressed,
        onEmojiSelected: onEmojiSelected,
        textEditingController: textController,
        config: emoji.Config(
          bottomActionBarConfig: const emoji.BottomActionBarConfig(enabled: false),
          skinToneConfig: const emoji.SkinToneConfig(
            enabled: true,
            indicatorColor: Colors.grey,
            dialogBackgroundColor: Colors.white,
          ),
          emojiViewConfig: emoji.EmojiViewConfig(
            columns: 7,
            emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
            verticalSpacing: 0,
            horizontalSpacing: 0,
            gridPadding: EdgeInsets.zero,
            recentsLimit: 28,
            buttonMode: emoji.ButtonMode.CUPERTINO,
          ),
          categoryViewConfig: const emoji.CategoryViewConfig(
            initCategory: emoji.Category.RECENT,
            backgroundColor: Color(0xFFF2F2F2),
            indicatorColor: Colors.blue,
            iconColor: Colors.grey,
            iconColorSelected: Colors.blue,
            backspaceColor: Colors.blue,
            tabIndicatorAnimDuration: kTabScrollDuration,
            categoryIcons: emoji.CategoryIcons(),
          ),
        ),
      ),
    );
  }
}
