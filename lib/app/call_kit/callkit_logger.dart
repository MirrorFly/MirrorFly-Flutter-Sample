import 'dart:developer';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class CallkitLogger {
  bool _enabled = true;
  final bool _enableFileLogging = true;
  String _tag = 'MIRROR_FLY_SAMPLE_APP';
  final String _dirName = 'mf_qa_logs';

  // Buffer for queuing logs
  final List<String> _loggingQueue = [];
  bool _isWriting = false;

  void configure({required bool enabled, required String tag}) {
    _enabled = enabled;
    _tag = tag;

    if (_enableFileLogging) {
      getLogFilePath().then((path) {
        print('[$_tag][LOG FILE] $path');
      });
    }
  }

  void _log(String level, String message) {
    if (!_enabled) return;
    final String now = DateTime.now().toIso8601String();
    final emoji = _emojiForLevel(level);
    final formattedMessage = '$emoji [MirrorFly] [$level][$now] $message';

    log(formattedMessage, name: _tag);
    print(formattedMessage);

    if (_enableFileLogging) {
      _addToLogQueue(level, formattedMessage);
    }
  }

  String _emojiForLevel(String level) {
    switch (level) {
      case 'INFO':
        return '✅';
      case 'SUCCESS':
        return '🟢';
      case 'WARN':
        return '⚠️';
      case 'ERROR':
        return '❌';
      default:
        return 'ℹ️';
    }
  }

  void _addToLogQueue(String level, String message) {
    _loggingQueue.add(message);

    // Trigger write if not already writing
    if (!_isWriting) {
      _writeLog();
    }
  }

  Future<void> _writeLog() async {
    if (_loggingQueue.isEmpty) return;

    _isWriting = true;

    try {
      Directory dir;
      if (Platform.isAndroid) {
        dir = (await getExternalStorageDirectory())!;
      } else {
        dir = await getApplicationDocumentsDirectory();
      }

      final logDir = Directory(dir.path);
      if (!await logDir.exists()) await logDir.create(recursive: true);

      final date = DateTime.now();
      final file = File(
          '${logDir.path}/$_dirName-${date.year}_${date.month}_${date.day}.txt');

      // Join all buffered messages into one batch
      final batch = _loggingQueue.join('\n');
      _loggingQueue.clear();

      await file.writeAsString('$batch\n', mode: FileMode.append, flush: true);
    } catch (e) {
      print('[MFLogger][ERROR] $e');
    } finally {
      _isWriting = false;

      // If new logs were added during write, write again
      if (_loggingQueue.isNotEmpty) {
        _writeLog();
      }
    }
  }

  void info(String message) => _log('INFO_SAMPLE_APP', message);

  void error(String message) {
    _log('ERROR_SAMPLE_APP', '============================');
    _log('ERROR_SAMPLE_APP', message);
    _log('ERROR_SAMPLE_APP', '============================');
  }

  Future<String?> getLogFilePath() async {
    try {
      Directory dir;
      if (Platform.isAndroid) {
        dir = (await getExternalStorageDirectory())!;
      } else {
        dir = await getApplicationDocumentsDirectory();
      }

      final date = DateTime.now();
      final file = File(
          '${dir.path}/$_dirName-${date.year}_${date.month}_${date.day}.txt');
      return file.path;
    } catch (_) {
      return null;
    }
  }
}

final CallkitLogger callkitLogger = CallkitLogger();

void initializeLogger({required bool enabled, required String tag}) {
  callkitLogger.configure(enabled: enabled, tag: tag);
}