import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';

import 'package:mirror_fly_demo/app/modules/dashboard/widgets.dart';
import '../data/session_management.dart';
import 'constants.dart';
import 'main_controller.dart';

class AppDivider extends StatelessWidget {
  const AppDivider({Key? key, this.padding}) : super(key: key);

  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: padding,
      height: 0.29,
      color: dividerColor,
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
                color: bgColor ?? Color(Helper.getColourCode(text))),
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
            backgroundColor: bgColor ?? Color(Helper.getColourCode(text)),
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
    // debugPrint("str.characters.length ${str}");
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

class ImageNetwork extends GetView<MainController> {
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
  Widget build(BuildContext context) {
    //var authToken = controller.authToken;
    // mirrorFlyLog("MirrorFly Auth", authToken.value);
    // mirrorFlyLog("Image URL", url);
    /*if (url.isEmpty) {
      return errorWidget != null
          ? errorWidget!
          : clipOval
              ? ClipOval(
                  child: Image.asset(
                    profileImg,
                    height: height,
                    width: width,
                  ),
                )
              : Image.asset(
                  profileImg,
                  height: height,
                  width: width,
                );
    } else {*/
    return Obx(
      () => CachedNetworkImage(
        imageUrl: controller.uploadEndpoint + url,
        fit: BoxFit.fill,
        width: width,
        height: height,
        cacheKey: controller.uploadEndpoint + url,
        httpHeaders: {"Authorization": controller.authToken.value},
        /*progressIndicatorBuilder: (context, link, progress) {
            return SizedBox(
              height: height,
              width: width,
              child: const Center(child: CircularProgressIndicator()),
            );
          },*/
        placeholder: (context, string) {
          if(!(blocked || (unknown && !SessionManagement.isTrailLicence()))){
            if(errorWidget !=null){
              return errorWidget!;
            }
          }
          return clipOval
                  ? ClipOval(
                      child: Image.asset(
                        getSingleOrGroup(isGroup),
                        height: height,
                        width: width,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Image.asset(
            getSingleOrGroup(isGroup),
                      height: height,
                      width: width,
            fit: BoxFit.cover,
                    );
        },
        errorWidget: (context, link, error) {
          if(url.isNotEmpty) {
            // mirrorFlyLog("image error", "$error link : $link token : ${controller.authToken.value}");
            if (error.toString().contains("401") && url.isNotEmpty) {
              // controller.getAuthToken();
              _deleteImageFromCache(url);
            }
          }
          // debugPrint("image blocked--> $blocked");
          // debugPrint("image unknown--> $unknown");

          if(!(blocked || (unknown && !SessionManagement.isTrailLicence()))){
            if(errorWidget !=null){
              return errorWidget!;
            }
          }
          return clipOval
              ? ClipOval(
            child: Image.asset(
              getSingleOrGroup(isGroup),
              height: height,
              width: width,
              fit: BoxFit.cover,
            ),
          )
              : Image.asset(
            getSingleOrGroup(isGroup),
            height: height,
            width: width,
            fit: BoxFit.cover,
          );
        },
        imageBuilder: (context, provider) {
          return clipOval
              ? ClipOval(
                  child: !(blocked || (unknown && !SessionManagement.isTrailLicence())) ? Image(
                  image: provider,
                  fit: BoxFit.fill,
                ) : Image.asset(
                    getSingleOrGroup(isGroup),
                    height: height,
                    width: width,
                    fit: BoxFit.cover,
                  ),)
              : InkWell(
                  onTap: onTap,
                  child: !(blocked || (unknown && !SessionManagement.isTrailLicence())) ? Image(
                    image: provider,
                    fit: BoxFit.fill,
                  ) : Image.asset(
                    getSingleOrGroup(isGroup),
                    height: height,
                    width: width,
                    fit: BoxFit.cover,
                  ),
                );
        },
      ),
    );
    // }
  }

  String getSingleOrGroup(bool isGroup){
    return isGroup ? groupImg : profileImg;
  }

  void _deleteImageFromCache(String url) {
    /*cache.DefaultCacheManager manager = cache.DefaultCacheManager();
    manager.emptyCache();*/
    CachedNetworkImage.evictFromCache(url, cacheKey: url)
        .then((value) => controller.getAuthToken());
    /*cache.DefaultCacheManager().removeFile(url).then((value) {
      mirrorFlyLog('File removed', "");
      controller.getAuthToken();
    }).onError((error, stackTrace) {
      mirrorFlyLog("", error.toString());
    });*/
    //await CachedNetworkImage.evictFromCache(url);
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

Widget memberItem(
    {required String name,
    required String image,
    required String status,
    bool? isAdmin,
    required Function() onTap,
    String spantext = "",
    bool isCheckBoxVisible = false,
    bool isChecked = false,
    Function(bool? value)? onchange,
      bool isGroup = false,
      required bool blocked,
      required bool unknown}) {
  var titlestyle = const TextStyle(
      color: Colors.black, fontSize: 14.0, fontWeight: FontWeight.w700);
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
                  width: 48,
                  height: 48,
                  clipOval: true,
                  errorWidget: name.checkNull().isNotEmpty
                      ? ProfileTextImage(
                          fontSize: 20,
                          text: name.checkNull(),
                        )
                      : null, blocked: blocked, unknown: unknown,
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
                        spantext.isEmpty
                            ? Text(
                                name.checkNull(),
                                style: titlestyle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis, //TextStyle
                              )
                            : spannableText(
                                name.checkNull(),
                                spantext,
                                titlestyle,
                              ),
                        Text(
                          status.checkNull(),
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 12.0,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis, //T
                        ),
                      ],
                    ),
                  ),
                ),
                (isAdmin != null && isAdmin)
                    ? const Text("Admin",
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 12.0,
                        ))
                    : const SizedBox(),
                Visibility(
                  visible: isCheckBoxVisible,
                  child: Checkbox(
                    value: isChecked,
                    onChanged: onchange,
                  ),
                ),
              ],
            ),
          ),
          const AppDivider(
              padding: EdgeInsets.only(right: 16, left: 16, top: 4))
        ],
      ),
    ),
  );
}

class EmojiLayout extends StatelessWidget {
  const EmojiLayout(
      {Key? key,
      required this.textController,
      this.onEmojiSelected,
      this.onBackspacePressed})
      : super(key: key);
  final TextEditingController textController;
  final Function(Category?, Emoji)? onEmojiSelected;
  final Function()? onBackspacePressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: EmojiPicker(
        onBackspacePressed: onBackspacePressed,
        onEmojiSelected: onEmojiSelected,
        textEditingController: textController,
        config: Config(
          columns: 7,
          emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
          verticalSpacing: 0,
          horizontalSpacing: 0,
          gridPadding: EdgeInsets.zero,
          initCategory: Category.RECENT,
          bgColor: const Color(0xFFF2F2F2),
          indicatorColor: Colors.blue,
          iconColor: Colors.grey,
          iconColorSelected: Colors.blue,
          backspaceColor: Colors.blue,
          skinToneDialogBgColor: Colors.white,
          skinToneIndicatorColor: Colors.grey,
          enableSkinTones: true,
          showRecentsTab: true,
          recentsLimit: 28,
          tabIndicatorAnimDuration: kTabScrollDuration,
          categoryIcons: const CategoryIcons(),
          buttonMode: ButtonMode.CUPERTINO,
        ),
      ),
    );
  }
}
