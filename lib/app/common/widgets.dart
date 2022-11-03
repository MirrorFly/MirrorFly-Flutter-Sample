import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/parser.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:mirror_fly_demo/app/data/SessionManagement.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';

import 'package:flutter_cache_manager/flutter_cache_manager.dart' as cache;
import '../nativecall/platformRepo.dart';
import 'constants.dart';
import 'main_controller.dart';

class AppDivider extends StatelessWidget {
  final double padding;

  const AppDivider({Key? key, this.padding = 18.0}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: const Divider(
        thickness: 0.29,
        color: dividercolor,
      ),
    );
  }
}

class ProfileTextImage extends StatelessWidget {
  final String text;
  final Color bgcolor;
  final double fontsize;
  final double radius;
  final Color fontcolor;

  ProfileTextImage(
      {Key? key,
      required this.text,
      this.fontsize = 15,
      this.bgcolor = buttonbgcolor,
      this.radius = 22,
      this.fontcolor = Colors.white})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Color(Helper.getColourCode(text)), //bgcolor,
      child: Center(
          child: Text(
        getString(text),
        style: TextStyle(fontSize: fontsize, color: fontcolor),
      )),
    );
  }

  String getString(String str) {
    String string = "";
    if (str.characters.length >= 2) {
      if (str.trim().contains(" ")) {
        var st = str.trim().split(" ");
        string = st[0].characters.first.toUpperCase() +
            st[1].characters.first.toUpperCase();
      } else {
        string = str.substring(0, 2).toUpperCase().toString();
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
  final bool clipoval;

  const ImageNetwork(
      {Key? key,
      required this.url,
      required this.width,
      required this.height,
      this.errorWidget,
      required this.clipoval})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var AUTHTOKEN = controller.AUTHTOKEN;
    Log("Mirrorfly Auth", AUTHTOKEN.value);
    Log("Image URL", url);
    return Obx(
      () => CachedNetworkImage(
        imageUrl: imagedomin + url,
        fit: BoxFit.fill,
        width: width,
        height: height,
        httpHeaders: {"Authorization": controller.AUTHTOKEN.value},
        /*placeholder: (context, url) {
          //Log("placeholder", url);
          return errorWidget ??
              Image.asset(
                'assets/logos/profile_img.png',
                height: width,
                width: height,
              );
        },*/

        progressIndicatorBuilder: (context, link, progress) {
          return SizedBox(
            height: height,
            width: width,
            child: const Center(child: CircularProgressIndicator()),
          );
        },
        errorWidget: (context, link, error) {
          Log("imageerror", error.toString());
          if(error.toString().contains("401")&&url.isNotEmpty){
            // controller.getAuthToken();
            _deleteImageFromCache(url);
          }
          return errorWidget ??
              Image.asset(
                'assets/logos/profile_img.png',
                height: width,
                width: height,
              );
        },
        imageBuilder: (context,provider){
          return clipoval ? ClipOval(child: Image(image: provider,fit: BoxFit.fill,)) : Image(image: provider,fit: BoxFit.fill,);
        },
      ),
      /*Image.network(
        imagedomin + url,
        fit: BoxFit.fill,
        width: width,
        height: height,
        headers: {"Authorization": controller.AUTHTOKEN.value},
        loadingBuilder: (context, widget, chunkevent) {
          if(chunkevent==null) return clipoval ? ClipOval(child: widget) : widget;
          return errorWidget ?? SizedBox(child: Center(child: const CircularProgressIndicator()),height: height,width: width,);
        },
        errorBuilder: (context,Object object, trace) {
          Log("image", imagedomin + url);
          Log("imageError", object.toString());
          if(object.toString().contains("401")){
            Get.find<MainController>().getAuthToken();
          }
          return errorWidget ??
              Image.asset(
                'assets/logos/profile_img.png',
                height: width,
                width: height,
              );
        },
      ),*/
    );
  }
  void _deleteImageFromCache(String url) {
    cache.DefaultCacheManager manager = cache.DefaultCacheManager();
    manager.emptyCache();
    // cache.DefaultCacheManager().removeFile(url).then((value) {
      //ignore: avoid_print
      print('File removed');
      controller.getAuthToken();
    // }).onError((error, stackTrace) {
    //   ignore: avoid_print
      // print(error);
    // });
    //await CachedNetworkImage.evictFromCache(url);
  }
}

class EmojiLayout extends StatelessWidget {
  const EmojiLayout(
      {Key? key, required this.textcontroller, this.onEmojiSelected})
      : super(key: key);
  final TextEditingController textcontroller;
  final Function(Category?, Emoji)? onEmojiSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: EmojiPicker(
        onBackspacePressed: () {
          // Do something when the user taps the backspace button (optional)
        },
        onEmojiSelected: onEmojiSelected,
        textEditingController: textcontroller,
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

/*
Image NetImage (String url,double width,double height){
  return Image.network(imagedomin+url,
      width: width,
      height: height,
      headers: {"Authorization":SessionManagement().getauthToken().toString()},
  errorBuilder:(context,object,trace){
    return Image.asset(
      'assets/logos/profile_img.png',
      height: width,
      width: height,
    );
  },);
}*/
