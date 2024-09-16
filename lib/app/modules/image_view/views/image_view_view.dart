import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/app_localizations.dart';
import '../../../common/main_controller.dart';
import 'package:photo_view/photo_view.dart';

import '../../../extensions/extensions.dart';
import '../controllers/image_view_controller.dart';

class ImageViewView extends NavViewStateful<ImageViewController> {
  const ImageViewView({Key? key}) : super(key: key);

  @override
ImageViewController createController({String? tag}) => Get.put(ImageViewController());

  @override
  Widget build(BuildContext context) {
    var main = Get.find<MainController>();
    return Scaffold(
      appBar: AppBar(
        title: Text(controller.imageName.value),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Obx(() {
          return controller.imagePath.value.isNotEmpty
              ? PhotoView(
                  imageProvider: FileImage(File(controller.imagePath.value)),
                  // Contained = the smallest possible size to fit one dimension of the screen
                  minScale: PhotoViewComputedScale.contained * 0.8,
                  // Covered = the smallest possible size to fit the whole screen
                  maxScale: PhotoViewComputedScale.covered * 2,
                  enableRotation: false,
                  // Set the background color to the "classic white"
                  backgroundDecoration: const BoxDecoration(
                    color: Colors.black,
                  ),
                  loadingBuilder: (context, event) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : controller.imageUrl.value.isNotEmpty
                  ? PhotoView(
                      imageProvider: CachedNetworkImageProvider(
                          controller.imageUrl.value,
                          headers: {"Authorization": main.currentAuthToken.value}),
                      // Contained = the smallest possible size to fit one dimension of the screen
                      minScale: PhotoViewComputedScale.contained * 0.8,
                      // Covered = the smallest possible size to fit the whole screen
                      maxScale: PhotoViewComputedScale.covered * 2,
                      enableRotation: false,
                      // Set the background color to the "classic white"
                      backgroundDecoration: const BoxDecoration(
                        color: Colors.black,
                      ),
                      loadingBuilder: (context, event) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : Center(
                      child: Text(getTranslated("unableToLoadImage")),
                    );
        }),
      ),
    );
  }
}
