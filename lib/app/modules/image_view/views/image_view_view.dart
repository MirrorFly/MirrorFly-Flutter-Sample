import 'dart:io';

import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';

import '../controllers/image_view_controller.dart';

class ImageViewView extends GetView<ImageViewController> {
  const ImageViewView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(controller.image_name.value),
      ),
      body: Obx(() {
        return controller.imagepath.value.isNotEmpty ?
        PhotoView(
          imageProvider: FileImage(File(controller.imagepath.value)),
          // Contained = the smallest possible size to fit one dimension of the screen
          minScale: PhotoViewComputedScale.contained * 0.8,
          // Covered = the smallest possible size to fit the whole screen
          maxScale: PhotoViewComputedScale.covered * 2,
          enableRotation: true,
          // Set the background color to the "classic white"
          backgroundDecoration: BoxDecoration(
            color: Theme
                .of(context)
                .canvasColor,
          ),
          loadingBuilder: (context, event) =>
              Center(
                child: CircularProgressIndicator(),
              ),
        ) : Center(child: Text('Unable to Load Image'),);
      }),
    );
  }
}
