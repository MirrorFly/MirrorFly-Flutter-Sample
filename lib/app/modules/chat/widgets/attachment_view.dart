import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../stylesheet/stylesheet.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';

import '../../../app_style_config.dart';
import '../../../common/constants.dart';
import '../../../data/utils.dart';
import '../../../widgets/mirror_fly_icon.dart';

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
                var iconStyle = getIconStyle(attachments[index].attachmentId);
                return iconCreation(
                    attachments[index].iconPath, attachments[index].text,
                    (attachments[index].attachmentId == Constants.attachmentTypeDocument) ? onDocument :
                    (attachments[index].attachmentId == Constants.attachmentTypeCamera) ? onCamera :
                    (attachments[index].attachmentId == Constants.attachmentTypeGallery) ? onGallery :
                    (attachments[index].attachmentId == Constants.attachmentTypeAudio) ? onAudio :
                    (attachments[index].attachmentId == Constants.attachmentTypeContact) ? onContact :
                    (attachments[index].attachmentId == Constants.attachmentTypeLocation) ? onLocation : () {},
                    iconStyle,AppStyleConfig.chatPageStyle.attachmentViewStyle.textStyle, getCustomisedIcon(attachments[index].attachmentId));
              });
        }),
      ),
    );
  }

  IconStyle getIconStyle(String attachment){
    switch(attachment){
      case Constants.attachmentTypeDocument:
        return AppStyleConfig.chatPageStyle.attachmentViewStyle.documentStyle;
      case Constants.attachmentTypeCamera:
        return AppStyleConfig.chatPageStyle.attachmentViewStyle.cameraStyle;
      case Constants.attachmentTypeGallery:
        return AppStyleConfig.chatPageStyle.attachmentViewStyle.galleryStyle;
      case Constants.attachmentTypeAudio:
        return AppStyleConfig.chatPageStyle.attachmentViewStyle.audioStyle;
      case Constants.attachmentTypeContact:
        return AppStyleConfig.chatPageStyle.attachmentViewStyle.contactStyle;
      case Constants.attachmentTypeLocation:
        return AppStyleConfig.chatPageStyle.attachmentViewStyle.locationStyle;
      default :
        return AppStyleConfig.chatPageStyle.attachmentViewStyle.documentStyle;
    }
  }

  UIKitIcon? getCustomisedIcon(String attachmentId) {

    switch(attachmentId){
      case Constants.attachmentTypeDocument:
        return AppStyleConfig.chatPageStyle.attachmentViewStyle.iconDocument;
      case Constants.attachmentTypeCamera:
        return AppStyleConfig.chatPageStyle.attachmentViewStyle.iconCamera;
      case Constants.attachmentTypeGallery:
        return AppStyleConfig.chatPageStyle.attachmentViewStyle.iconGallery;
      case Constants.attachmentTypeAudio:
        return AppStyleConfig.chatPageStyle.attachmentViewStyle.iconAudio;
      case Constants.attachmentTypeContact:
        return AppStyleConfig.chatPageStyle.attachmentViewStyle.iconContact;
      case Constants.attachmentTypeLocation:
        return AppStyleConfig.chatPageStyle.attachmentViewStyle.iconLocation;
      default:
        return null;
    }
  }
}

class AttachmentIcon {
  String attachmentId;
  String iconPath;
  String text;
  AttachmentIcon(this.attachmentId, this.iconPath, this.text);
}


Widget iconCreation(String iconPath, String text, VoidCallback onTap,IconStyle iconStyle,TextStyle textStyle, UIKitIcon? uikitIcon) {
  return InkWell(
    onTap: onTap,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: (50/2),
          backgroundColor: iconStyle.bgColor,
            child: uikitIcon ?? AppUtils.svgIcon(icon:iconPath,colorFilter: ColorFilter.mode(iconStyle.iconColor, BlendMode.srcIn),)
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
