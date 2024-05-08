part of 'utils.dart';

class MediaUtils {

  static const maxAudioFileSize = 2 * 1024;//30;
  static const maxVideoFileSize = 2 * 1024;//30;
  static const maxImageFileSize = 2 * 1024;//10;
  static const maxDocFileSize = 2 * 1024;//20;

  static bool isFileExist(String mediaLocalStoragePath) {
    return mediaLocalStoragePath.isNotEmpty && File(mediaLocalStoragePath).existsSync();
  }

  /// Converts a file size in bytes to a human-readable format with appropriate units.
  ///
  /// [bytes]: The size of the file in bytes.
  /// [decimals]: The number of decimal places to include in the result. Default is 0.
  /// Returns a string representing the file size with appropriate units (bytes, kilobytes, megabytes, etc.).
  static String fileSize(int bytes, [int decimals = 0]) {
    // If the file size is 0 or negative, return "0 B"
    if (bytes <= 0) return "0 B";

    // List of suffixes for different units (bytes, kilobytes, megabytes, etc.)
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];

    // Calculate the index of the appropriate unit based on the logarithm of the file size
    var i = (log(bytes) / log(1024)).floor();

    // Calculate the size in the appropriate unit and convert it to a string with the specified number of decimals
    return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  }

  /// Checks if the size of a file at the specified [path] is within the acceptable
  /// upload limits for the given [mediaType].
  /// Returns true if the file size is within the limits, otherwise false.
  static bool checkFileUploadSize(String path, String mediaType) {
    // Retrieve file information from the provided path
    var file = File(path);

    // Get the size of the file in bytes
    int sizeInBytes = file.lengthSync();
    debugPrint("file size --> $sizeInBytes");

    // Convert the file size from bytes to megabytes
    double sizeInMb = sizeInBytes / (1024 * 1024);
    debugPrint("sizeInBytes $sizeInMb");

    // Determine the maximum acceptable file size based on the media type
    debugPrint("MediaUtils.maxImageFileSize $maxImageFileSize");
    if (mediaType == Constants.mImage && sizeInMb <= maxImageFileSize) {
      return true;
    } else if (mediaType == Constants.mAudio && sizeInMb <= maxAudioFileSize) {
      return true;
    } else if (mediaType == Constants.mVideo && sizeInMb <= maxVideoFileSize) {
      return true;
    } else if (mediaType == Constants.mDocument && sizeInMb <= maxDocFileSize) {
      return true;
    } else {
      // File size exceeds the acceptable limit for the specified media type
      return false;
    }
  }

}