import 'dart:io';
import 'dart:math';

import 'package:custom_image_crop/custom_image_crop.dart';
import 'package:flutter/material.dart';
import '../common/app_localizations.dart';

import '../app_style_config.dart';
import '../data/utils.dart';
class CropImage extends StatefulWidget {
  const CropImage({Key? key, required this.imageFile}) : super(key: key);
  final File imageFile;

  // File? _file;
  // File? _sample;
  // File? _lastCropped;
  @override
  State<CropImage> createState() => _CropImageState();
}

class _CropImageState extends State<CropImage> {
  late CustomImageCropController controller;

  @override
  void initState() {
    super.initState();
    controller = CustomImageCropController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: Container(
              color: const Color(0X55000000),
              padding: const EdgeInsets.all(20.0),
              child: CustomImageCrop(
                cropController: controller,
                canMove: true,
                forceInsideCropArea: true,
                shape: CustomCropShape.Square,
                image: FileImage(widget.imageFile),
              ),
              /*child: Crop.file(
                imageFile,
                key: cropKey,
                aspectRatio: 5.0 / 5.0,
              ),*/
            ),
          ),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: ()=>NavUtils.back(),
                    style: ElevatedButton.styleFrom(backgroundColor: WidgetStateColor.resolveWith((states) => Colors.white),shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),padding: EdgeInsets.zero),
                    child: Text(getTranslated("cancel").toUpperCase(),style: const TextStyle(color: Colors.black,fontSize:16.0),),
                  ),
                ),
                /*SizedBox(width: 1.0,),
                Material(child: IconButton(icon: const Icon(Icons.zoom_in), onPressed: () => controller.addTransition(CropImageData(scale: 1.33))),),
                SizedBox(width: 1.0,),
                Material(child: IconButton(icon: const Icon(Icons.zoom_out), onPressed: () => controller.addTransition(CropImageData(scale: 0.75))),),*/
                const SizedBox(width: 1.0,),
                Material(child: IconButton(onPressed: ()=>controller.addTransition(CropImageData(angle: -pi / 4)), icon: const Icon(Icons.rotate_left))),
                const SizedBox(width: 1.0,),
                Material(child: IconButton(onPressed: ()=>controller.addTransition(CropImageData(angle: pi / 4)), icon: const Icon(Icons.rotate_right))),
                const SizedBox(width: 1.0,),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      DialogUtils.showLoading(message: getTranslated("imageCropping"),dialogStyle: AppStyleConfig.dialogStyle);
                      await controller.onCropImage().then((image){
                        DialogUtils.hideLoading();
                        NavUtils.back(result: image);
                      });

                    },
                    style: ElevatedButton.styleFrom(backgroundColor: WidgetStateColor.resolveWith((states) => Colors.white),shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),padding: EdgeInsets.zero),
                    child: Text(getTranslated("save").toUpperCase(),style: const TextStyle(color: Colors.black,fontSize:16.0),),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
  // Future<void> _cropImage() async {
    /*final scale = cropKey.currentState!.scale;
    final area = cropKey.currentState!.area;
    if (area == null) {
      // cannot crop, widget is not setup
      return;
    }

    // scale up to use maximum possible number of pixels
    // this will sample image in higher resolution to make cropped image larger
    final sample = await ImageCrop.sampleImage(
      file: _file!,
      preferredSize: (2000 / scale).round(),
    );

    final file = await ImageCrop.cropImage(
      file: sample,
      area: area,
    );

    sample.delete();

    _lastCropped?.delete();
    _lastCropped = file;

    debugPrint('$file');*/
  // }
}
