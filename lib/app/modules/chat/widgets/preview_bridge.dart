import 'dart:io';
import 'package:flutter/services.dart';

class PreviewBridge {
  static const _ch = MethodChannel('app.preview');
  static Future<void> dismissPreview() async {
    if (!Platform.isIOS) return;
    try { await _ch.invokeMethod('dismissPreview'); } catch (_) {}
  }
}