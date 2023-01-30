
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Widget imageFromBase64String(String base64String, BuildContext context,
    double? width, double? height) {
  var decodedBase64 = base64String.replaceAll("\n", "");
  Uint8List image = const Base64Decoder().convert(decodedBase64);
  return Image.memory(
    image,
    width: width ?? MediaQuery.of(context).size.width * 0.60,
    height: height ?? MediaQuery.of(context).size.height * 0.4,
    fit: BoxFit.cover,
  );
}