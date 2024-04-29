import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ImageCacheManager {
  static final Map<String, Image> _cache = {};

  static Image getImage(String base64String, String messageId) {
    if (_cache.containsKey(messageId)) {
      return _cache[messageId]!;
    } else {
      Uint8List bytes = base64Decode(base64String);
      Image image = Image.memory(bytes, gaplessPlayback: true,  width: Get.width * 0.60,
        height: Get.height * 0.4, fit: BoxFit.cover,);
      _cache[messageId] = image;
      return image;
    }
  }

  static disposeCache(){
    debugPrint("Disposing the image message view cache list");
    if(_cache.isNotEmpty) {
      _cache.clear();
    }
  }
}