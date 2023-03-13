import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../../core/decode_image.dart';
import '../../../core/functions.dart';
import '../../pages/gallery_media_picker_controller.dart';

class CoverThumbnail extends StatefulWidget {
  final int thumbnailQuality;
  final double thumbnailScale;
  final BoxFit thumbnailFit;
  const CoverThumbnail(
      {Key? key,
      this.thumbnailQuality = 120,
      this.thumbnailScale = 1.0,
      this.thumbnailFit = BoxFit.cover})
      : super(key: key);

  @override
  State<CoverThumbnail> createState() => _CoverThumbnailState();
}

class _CoverThumbnailState extends State<CoverThumbnail> {
  /// create object of PickerDataProvider
  final provider = GalleryMediaPickerController();

  @override
  void initState() {
    GalleryFunctions.getPermission(setState, provider);
    super.initState();
  }

  @override
  void dispose() {
    if (mounted) {
      provider.pickedFile.clear();
      provider.picked.clear();
      provider.pathList.clear();
      PhotoManager.stopChangeNotify();
      super.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return provider.pathList.isNotEmpty
        ? Image(
            image: DecodeImage(provider.pathList[0],
                thumbSize: widget.thumbnailQuality,
                index: 0,
                scale: widget.thumbnailScale),
            fit: widget.thumbnailFit,
            filterQuality: FilterQuality.high,
          )
        : Container();
  }
}
