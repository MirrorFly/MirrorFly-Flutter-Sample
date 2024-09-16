part of 'utils.dart';

class MediaUtils {

  static const maxAudioFileSize = 2 * 1024;//30;
  static const maxVideoFileSize = 2 * 1024;//30;
  static const maxImageFileSize = 2 * 1024;//10;
  static const maxDocFileSize = 2 * 1024;//20;

  static bool isMediaFileNotAvailable(bool isMediaFileAvailable, ChatMessageModel message) {
    return !isMediaFileAvailable && message.isMediaMessage();
  }

  static bool isMediaExists(String? filePath) {
    if(filePath == null || filePath.isEmpty) {
      return false;
    }
    File file = File(filePath);
    return file.existsSync();
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

  static bool isMediaFileAvailable(MessageType msgType, ChatMessageModel message) {
    bool mediaExist = false;
    if (msgType == MessageType.audio ||
        msgType == MessageType.video ||
        msgType == MessageType.image ||
        msgType == MessageType.document) {
      final downloadedMediaValue = message.mediaChatMessage?.mediaDownloadStatus.value ?? "";
      final uploadedMediaValue = message.mediaChatMessage?.mediaUploadStatus.value ?? "";
      if (MediaDownloadStatus.mediaDownloaded.value.toString() == downloadedMediaValue ||
          MediaUploadStatus.mediaUploaded.value.toString() == uploadedMediaValue) {
        mediaExist = true;
      }
    }
    return mediaExist;
  }

  /// Get Width and Height from file
  ///
  /// @param filePath of the media
  static Future<Tuple2<int, int>> getImageDimensions(String filePath) async {
    try {
      // Open the file
      File file = File(filePath);
      if (!file.existsSync()) {
        return const Tuple2(Constants.mobileImageMaxWidth, Constants.mobileImageMaxHeight);
      }

      // Read metadata
      final bytes = await file.readAsBytes();
      final image = await decodeImageFromList(bytes);

      // Get dimensions
      final int width = image.width;
      final int height = image.height;
      debugPrint('Image dimensions: $width x $height');
      return Tuple2(width,height);
    } catch (e) {
      debugPrint('Error: $e');
      return const Tuple2(Constants.mobileImageMaxWidth, Constants.mobileImageMaxHeight);
    }
  }

  /// Get Width and Height for Mobile
  ///
  /// @param originalWidth original width of media
  /// @param originalHeight original height of media
  static Tuple2<int, int> getMobileWidthAndHeight(int? originalWidth, int? originalHeight) {
    if (originalWidth == null || originalHeight == null) {
      return const Tuple2(Constants.mobileImageMaxWidth, Constants.mobileImageMaxHeight);
    }

    var newWidth = originalWidth;
    var newHeight = originalHeight;

    // First check if we need to scale width
    if (originalWidth > Constants.mobileImageMaxWidth) {
      //scale width to fit
      newWidth = Constants.mobileImageMaxWidth;
      //scale height to maintain aspect ratio
      newHeight = (newWidth * originalHeight / originalWidth).round();
    }

    // then check if we need to scale even with the new height
    if (newHeight > Constants.mobileImageMaxHeight) {
      //scale height to fit instead
      newHeight = Constants.mobileImageMaxHeight;
      //scale width to maintain aspect ratio
      newWidth = (newHeight * originalWidth / originalHeight).round();
    }

    return Tuple2(
      newWidth > Constants.mobileImageMinWidth ? newWidth : Constants.mobileImageMinWidth,
      newHeight > Constants.mobileImageMinHeight ? newHeight : Constants.mobileImageMinHeight,
    );
  }

}