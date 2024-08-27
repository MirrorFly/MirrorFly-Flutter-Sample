import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/stylesheet/stylesheet.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';

import '../../../app_style_config.dart';
import '../../../data/utils.dart';

class AttachmentsSheetView extends StatelessWidget {
  const AttachmentsSheetView({Key? key,
    required this.availableFeatures,
    required this.attachments,
    required this.onDocument,
    required this.onCamera,
    required this.onGallery,
    required this.onAudio,
    required this.onContact,
    required this.onLocation})
      : super(key: key);
  final Rx<AvailableFeatures> availableFeatures;
  final RxList<AttachmentIcon> attachments;
  final Function() onDocument;
  final Function() onCamera;
  final Function() onGallery;
  final Function() onAudio;
  final Function() onContact;
  final Function() onLocation;


  @override
  Widget build(BuildContext context) {
    LogMessage.d("attachments", attachments.length);
    // final attachments = [AttachmentIcon(documentImg, "Document", onDocument),AttachmentIcon(cameraImg, "Camera", onCamera),AttachmentIcon(galleryImg, "Gallery", onGallery),AttachmentIcon(audioImg, "Audio", onAudio),AttachmentIcon(contactImg, "Contact", onContact),AttachmentIcon(locationImg, "Location", onLocation)];
    return Card(
      color: AppStyleConfig.chatPageStyle.attachmentViewStyle.bgColor,
      shape: AppStyleConfig.chatPageStyle.attachmentViewStyle.shapeBorder,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        child: Obx(() {
          return GridView.builder(gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3,
              childAspectRatio: (1.1)
          ),
              itemCount: attachments.length,
              shrinkWrap: true,
              itemBuilder: (BuildContext ctx, index) {
                LogMessage.d("attachments", attachments[index].text);
                var iconStyle = getIconStyle(attachments[index].text);
                return iconCreation(
                    attachments[index].iconPath, attachments[index].text,
                    (attachments[index].text == "Document") ? onDocument :
                    (attachments[index].text == "Camera") ? onCamera :
                    (attachments[index].text == "Gallery") ? onGallery :
                    (attachments[index].text == "Audio") ? onAudio :
                    (attachments[index].text == "Contact") ? onContact :
                    (attachments[index].text == "Location") ? onLocation : () {},iconStyle,AppStyleConfig.chatPageStyle.attachmentViewStyle.textStyle);
              });
        }),
      ),
    );
  }

  IconStyle getIconStyle(String attachment){
    switch(attachment){
      case "Document":
        return AppStyleConfig.chatPageStyle.attachmentViewStyle.documentStyle;
      case "Camera":
        return AppStyleConfig.chatPageStyle.attachmentViewStyle.cameraStyle;
      case "Gallery":
        return AppStyleConfig.chatPageStyle.attachmentViewStyle.galleryStyle;
      case "Audio":
        return AppStyleConfig.chatPageStyle.attachmentViewStyle.audioStyle;
      case "Contact":
        return AppStyleConfig.chatPageStyle.attachmentViewStyle.contactStyle;
      case "Location":
        return AppStyleConfig.chatPageStyle.attachmentViewStyle.locationStyle;
      default :
        return AppStyleConfig.chatPageStyle.attachmentViewStyle.documentStyle;
    }
  }
}

class AttachmentIcon {
  String iconPath;
  String text;
  AttachmentIcon(this.iconPath, this.text);
}


Widget iconCreation(String iconPath, String text, VoidCallback onTap,IconStyle iconStyle,TextStyle textStyle) {
  return InkWell(
    onTap: onTap,
    child: Column(
      children: [
        CircleAvatar(
          radius: (50/2),
          backgroundColor: iconStyle.bgColor,
            child: AppUtils.svgIcon(icon:iconPath,colorFilter: ColorFilter.mode(iconStyle.iconColor, BlendMode.srcIn),)
        ),
        const SizedBox(
          height: 7,
        ),
        Text(
          text,
          style: textStyle,
          // style: const TextStyle(fontSize: 12, color: Colors.white),
        )
      ],
    ),
  );
}
