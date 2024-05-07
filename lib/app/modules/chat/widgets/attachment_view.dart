import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';

import '../../../common/constants.dart';

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
      color: bottomSheetColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        height: 250,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        child: Obx(() {
          return GridView.builder(gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3,
              childAspectRatio: 1
          ),
              itemCount: attachments.length,
              shrinkWrap: true,
              itemBuilder: (BuildContext ctx, index) {
                LogMessage.d("attachments", attachments[index].text);
                return iconCreation(
                    attachments[index].iconPath, attachments[index].text,
                    (attachments[index].text == "Document") ? onDocument :
                    (attachments[index].text == "Camera") ? onCamera :
                    (attachments[index].text == "Gallery") ? onGallery :
                    (attachments[index].text == "Audio") ? onAudio :
                    (attachments[index].text == "Contact") ? onContact :
                    (attachments[index].text == "Location") ? onLocation : () {});
              });
        }),
      ),
    );
  }
}

class AttachmentIcon {
  String iconPath;
  String text;

  AttachmentIcon(this.iconPath, this.text);
}


Widget iconCreation(String iconPath, String text, VoidCallback onTap) {
  return InkWell(
    onTap: onTap,
    child: Column(
      children: [
        SvgPicture.asset(iconPath),
        const SizedBox(
          height: 5,
        ),
        Text(
          text,
          style: const TextStyle(fontSize: 12, color: Colors.white),
        )
      ],
    ),
  );
}
