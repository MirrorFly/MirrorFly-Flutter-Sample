import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app_style_config.dart';
import '../../../common/app_localizations.dart';

import '../../../data/utils.dart';
import '../../../extensions/extensions.dart';
import '../../../routes/route_settings.dart';
import '../controllers/gallery_picker_controller.dart';
import '../src/presentation/pages/gallery_media_picker.dart';

class GalleryPickerView extends NavViewStateful<GalleryPickerController> {
  const GalleryPickerView({Key? key}) : super(key: key);

  @override
GalleryPickerController createController({String? tag}) => Get.put(GalleryPickerController());

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(appBarTheme: AppStyleConfig.galleryPageStyle.appBarTheme),
      child: Scaffold(
        appBar: AppBar(
          title: Text(getTranslated("sendToUser").replaceAll("%d", "${controller.userName}")),
        ),
        body: Column(
          children: [
            Expanded(
              child: FutureBuilder(
                  future: null,
                builder: (context, snapshot) {
                  return GalleryMediaPicker(
                    provider: controller.provider,
                    childAspectRatio: 1,
                    crossAxisCount: 3,
                    thumbnailQuality: 200,
                    thumbnailBoxFix: BoxFit.cover,
                    singlePick: false,
                    gridViewBackgroundColor: Colors.grey,
                    imageBackgroundColor: Colors.black,
                    maxPickImages: controller.maxPickImages,
                    appBarHeight: 60,
                    selectedBackgroundColor: Colors.black,
                    selectedCheckColor: Colors.black87,
                    selectedCheckBackgroundColor: Colors.white10,
                    pathList: (paths) {
                      debugPrint("file selected");
                      controller.addFile(paths);
                    },
                    appBarLeadingWidget: Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 15, bottom: 12),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [

                            Obx(() {
                              return Text("${controller.pickedFile.length} / ${controller.maxPickImages}");
                            }),

                            const SizedBox(width: 20,),
                            GestureDetector(
                              onTap: () async {
                                // List<String> mediaPath = [];
                                // media.pickedFile.map((p) {
                                //   setState(() {
                                //     mediaPath.add(p.path);
                                //   });
                                // }).toString();
                                if (controller.pickedFile.isNotEmpty) {
                                  // await Share.shareFiles(mediaPath);
                                  //
                                  NavUtils.toNamed(Routes.mediaPreview, arguments: {
                                    "filePath": controller.pickedFile,
                                    "userName": controller.userName,
                                    'profile': controller.profile,
                                    'caption': controller.textMessage,
                                    'from': 'gallery_pick',
                                    'userJid': controller.userJid
                                  })?.then((value) {
                                    value != null ? NavUtils.back() : null;

                                  });
                                } else {
                                  NavUtils.back();
                                }
                                // mediaPath.clear();
                              },
                              child: Container(
                                  height: 30,
                                  padding: const EdgeInsets.only(left: 8, right: 8),
                                  decoration: AppStyleConfig.galleryPageStyle.buttonDecoration,
                                  child: Center(child: Text(getTranslated("done")))
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                }
              ),
            ),
          ],
        ),
      ),
    );
  }
}
