import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:mirrorfly_plugin/mirrorflychat.dart';

import '../../../data/utils.dart';

class ImageCacheManager {
  static final Map<String, Image> _cache = {};

  static Image getImage(String base64String, String messageId,
      [double? width, double? height]) {
    if (_cache.containsKey(messageId)) {
      return _cache[messageId]!;
    } else {
      Uint8List bytes = base64Decode(base64String);
      Image image = Image.memory(
        bytes,
        gaplessPlayback: true,
        width: width ?? NavUtils.width * 0.60,
        height: height ?? NavUtils.height * 0.4,
        fit: BoxFit.cover,
        errorBuilder: (ctx, obj, strace) {
          return Container(
            color: Colors.black12,
            width: width ?? NavUtils.width * 0.60,
            height: height ?? NavUtils.height * 0.4,
          );
        },
      );
      _cache[messageId] = image;
      return image;
    }
  }

  Widget imageFromBase64String(String base64String, BuildContext context,
      double? width, double? height) {
    LogMessage.d("imageFromBase64String", "final");
    final decodedBase64 = base64String.replaceAll("\n", "");
    final Uint8List image = const Base64Decoder().convert(decodedBase64);
    return Image.memory(
      image,
      key: ValueKey<String>(base64String),
      width: width ?? NavUtils.width * 0.60,
      height: height ?? NavUtils.height * 0.4,
      fit: BoxFit.cover,
      gaplessPlayback: true,
      cacheHeight: (height ?? NavUtils.height * 0.4).toInt(),
      cacheWidth: (width ?? NavUtils.width * 0.60).toInt(),
    );
  }

  static disposeCache() {
    debugPrint("Disposing the image message view cache list");
    if (_cache.isNotEmpty) {
      _cache.clear();
    }
  }
}
