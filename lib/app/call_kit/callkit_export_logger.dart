import 'dart:io';
import 'package:share_plus/share_plus.dart';
import '../common/constants.dart';
import 'callkit_logger.dart';

Future<void> exportLiveKitLogFile() async {
  try {
    final CallkitLogger callkitLogger = CallkitLogger();
    final logPath = await callkitLogger.getLogFilePath();

    if (logPath == null) {
      toToast("Log file not found");
      return;
    }

    final file = File(logPath);

    if (!await file.exists()) {
      toToast("Log file does not exist");
      return;
    }

    await Share.shareXFiles(
      [XFile(file.path)],
      text: "MirrorFly Flutter liveKit Log File",
    );

  } catch (e, stack) {
    print("Log share failed: $e");
    print(stack);
    toToast("Log share failed");
  }
}