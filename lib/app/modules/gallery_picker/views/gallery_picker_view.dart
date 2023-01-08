import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../routes/app_pages.dart';
import '../controllers/gallery_picker_controller.dart';
import '../src/presentation/pages/gallery_media_picker.dart';

class GalleryPickerView extends GetView<GalleryPickerController> {
  const GalleryPickerView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Send to ${controller.userName}'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: GalleryMediaPicker(
              childAspectRatio: 1,
              crossAxisCount: 3,
              thumbnailQuality: 200,
              thumbnailBoxFix: BoxFit.cover,
              singlePick: false,
              gridViewBackgroundColor: Colors.grey,
              imageBackgroundColor: Colors.black,
              maxPickImages: 10,
              appBarHeight: 60,
              selectedBackgroundColor: Colors.black,
              selectedCheckColor: Colors.black87,
              selectedCheckBackgroundColor: Colors.white10,
              pathList: (paths) {
                controller.pickedFile = paths;
              },
              appBarLeadingWidget: Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 15, bottom: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      const Spacer(),

                      GestureDetector(
                        onTap: () async {
                          List<String> mediaPath = [];
                          // media.pickedFile.map((p) {
                          //   setState(() {
                          //     mediaPath.add(p.path);
                          //   });
                          // }).toString();
                          if (controller.pickedFile.isNotEmpty) {
                            // await Share.shareFiles(mediaPath);
                            Get.toNamed(Routes.mediaPreview, arguments: {
                              "filePath": controller.pickedFile,
                              "userName": controller.userName
                            });
                          }else{
                            Get.back();
                          }
                          mediaPath.clear();
                        },
                        child: Container(
                          height: 30,
                          width: 50,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: Colors.blue, width: 1.5),
                          ),
                          child: const Center(child: Text("Done"))
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
