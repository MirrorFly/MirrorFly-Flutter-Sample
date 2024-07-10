part of 'utils.dart';

class MessageUtils{

  /// Constructs a URI for a static Google Maps image based on the provided latitude and longitude coordinates.
  /// The image will display a map centered at the specified coordinates with a red marker indicating the location.
  ///
  /// @param latitude The latitude coordinate of the location.
  /// @param longitude The longitude coordinate of the location.
  /// @return A [Uri] representing the URI for the static Google Maps image.
  static Uri getMapImageUri(double latitude, double longitude) {
    var googleMapKey = Get.find<MainController>()
        .googleMapKey; // Obtain Google Maps API key from the main controller
    return Uri.parse("https://maps.googleapis.com/maps/api/staticmap?center=$latitude,$longitude&zoom=13&size=300x200&markers=color:red|$latitude,$longitude&key=$googleMapKey");
  }

  /// Generates a Google Maps launch URI based on the provided latitude and longitude coordinates.
  ///
  /// @param latitude The latitude coordinate.
  /// @param longitude The longitude coordinate.
  /// @return A [Uri] representing the Google Maps URI for launching the map at the specified location.
  static Uri getMapLaunchUri(double latitude, double longitude){
    return Uri.parse('https://www.google.com/maps/search/?api=1&query=$latitude, $longitude');
  }


  /// Returns the color code corresponding to the given name.
  /// If the name matches the translated version of "you",
  /// returns the color code for black (0Xff000000).
  ///
  /// @param name The name for which the color code is to be determined.
  /// @return The color code as an integer value.
  static int getColourCode(String name) {
    if (name == getTranslated("you")) return 0Xff000000;
    var colorsArray = Constants.defaultColorList;
    var hashcode = name.hashCode;
    var rand = hashcode % colorsArray.length;
    return colorsArray[(rand).abs()];
  }


  /// Returns an appropriate icon widget based on the provided media type.
  ///
  /// [mediaType]: The type of media for which the icon is needed.
  /// [isAudioRecorded]: Optional parameter to indicate if the audio is recorded.
  /// If `true` and [mediaType] is audio, it displays a different icon for recorded audio.
  ///
  /// Returns a widget displaying the appropriate icon for the given [mediaType].
  static Widget getMediaTypeIcon(String mediaType, [bool isAudioRecorded = false]) {
    // Logs the media type for debugging purposes.
    LogMessage.d("iconfor", mediaType.toString());

    // Determines the appropriate icon based on the media type.
    switch (mediaType.toUpperCase()) {
      case Constants.mImage:
        return SvgPicture.asset(
          mImageIcon,
          fit: BoxFit.contain,
          colorFilter: const ColorFilter.mode(playIconColor, BlendMode.srcIn),
        );
      case Constants.mAudio:
      // Displays different icons based on whether the audio is recorded or not.
        return SvgPicture.asset(
          isAudioRecorded ? mAudioRecordIcon : mAudioIcon,
          fit: BoxFit.contain,
          colorFilter: const ColorFilter.mode(playIconColor, BlendMode.srcIn),
        );
      case Constants.mVideo:
        return SvgPicture.asset(
          mVideoIcon,
          fit: BoxFit.contain,
          colorFilter: const ColorFilter.mode(playIconColor, BlendMode.srcIn),
        );
      case Constants.mDocument:
      case Constants.mFile:
      // Displays the same icon for both document and file types.
        return SvgPicture.asset(
          mDocumentIcon,
          fit: BoxFit.contain,
          colorFilter: const ColorFilter.mode(playIconColor, BlendMode.srcIn),
        );
      case Constants.mContact:
        return SvgPicture.asset(
          mContactIcon,
          fit: BoxFit.contain,
          colorFilter: const ColorFilter.mode(playIconColor, BlendMode.srcIn),
        );
      case Constants.mLocation:
        return SvgPicture.asset(
          mLocationIcon,
          fit: BoxFit.contain,
          colorFilter: const ColorFilter.mode(playIconColor, BlendMode.srcIn),
        );
      default:
      // Returns an empty Offstage if the media type is not recognized.
        return const Offstage();
    }
  }

  /// Returns a widget representing the appropriate message indicator icon based on the provided parameters.
  ///
  /// Parameters:
  /// - messageStatus: The status of the message (A - Acknowledged, D - Delivered, S - Seen, N - Unsent).
  /// - isSender: Indicates if the message sender is the sender user.
  /// - messageType: The type of message.
  /// - isRecalled: Indicates if the message has been recalled.
  ///
  /// Returns:
  /// - Widget: A widget representing the message indicator icon.
  ///
  /// If the message type is not a notification, and the sender is not the current user and the message is not recalled,
  /// the appropriate icon is returned based on the message status. If the message type is a notification, or if the sender
  /// is the current user or the message is recalled, an Offstage widget is returned to indicate no icon should be displayed.

  static Widget getMessageIndicatorIcon(String messageStatus, bool isSender, String messageType, bool isRecalled) {
    // debugPrint("Message Status ==>");
    // debugPrint("Message Status ==> $messageStatus");
    if (messageType.toUpperCase() != MessageType.isNotification) {
      if (isSender && !isRecalled) {
        if (messageStatus == 'A') {
          return SvgPicture.asset(acknowledgedIcon);
        } else if (messageStatus == 'D') {
          return SvgPicture.asset(deliveredIcon);
        } else if (messageStatus == 'S') {
          return SvgPicture.asset(seenIcon);
        } else if (messageStatus == 'N') {
          return SvgPicture.asset(unSendIcon);
        } else {
          return const Offstage();
        }
      } else {
        return const Offstage();
      }
    } else {
      return const Offstage();
    }
  }

  /// Retrieves and displays the appropriate icon for a document type based on the provided media file name.
  ///
  /// Parameters:
  ///   - mediaFileName: The name of the media file representing the document.
  ///   - size: The size (both width and height) of the icon to be displayed.
  /// Returns:
  ///   A Widget displaying the icon for the specified document type.
  static Widget getDocumentTypeIcon(String mediaFileName, double size) {
    debugPrint("mediaFileName--> $mediaFileName");
    return SvgPicture.asset(getDocAsset(mediaFileName),
        width: size, height: size);
  }


  /// Retrieves the corresponding image asset for a given document file type.
  ///
  /// @param filename The name of the document file.
  /// @return The image asset corresponding to the document file type, or an empty string if the filename is empty or does not contain an extension.
  static String getDocAsset(String filename) {
    if (filename.isEmpty || !filename.contains(".")) {
      return "";
    }
    debugPrint("helper document--> ${filename.toLowerCase().substring(filename.lastIndexOf(".") + 1)}");
    switch (filename.toLowerCase().substring(filename.lastIndexOf(".") + 1)) {
      case "csv":
        return csvImage;
      case "pdf":
        return pdfImage;
      case "doc":
        return docImage;
      case "docx":
        return docxImage;
      case "txt":
        return txtImage;
      case "xls":
        return xlsImage;
      case "xlsx":
        return xlsxImage;
      case "ppt":
        return pptImage;
      case "pptx":
        return pptxImage;
      case "zip":
        return zipImage;
      case "rar":
        return rarImage;
      case "apk":
        return apkImage;
      default:
        return "";
    }
  }


  /// split the call link from the message
  static String getCallLinkFromMessage(String message) {
    var link = "";
    var messageArray = message.split(" ");
    for (var i = 0; i < messageArray.length; i++) {
      if (messageArray[i].isURL && messageArray[i].startsWith(Constants.webChatLogin)) {
        link = messageArray[i];
        break;
      }
    }
    LogMessage.d("getCallLinkFromMessage", link);
    return link.trim();
  }
}