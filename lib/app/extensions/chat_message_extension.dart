part of "extensions.dart";

extension ChatmessageParsing on ChatMessageModel {
  bool isMediaDownloaded() {
    return isMediaMessage() && (mediaChatMessage?.mediaDownloadStatus.value == Constants.mediaDownloaded);
  }

  bool isMediaUploaded() {
    return isMediaMessage() && (mediaChatMessage?.mediaUploadStatus.value == Constants.mediaUploaded);
  }

  bool isMediaDownloading() {
    return isMediaMessage() && (mediaChatMessage?.mediaDownloadStatus.value == Constants.mediaDownloading);
  }

  bool isMediaUploading() {
    return isMediaMessage() && (mediaChatMessage?.mediaUploadStatus.value == Constants.mediaUploading);
  }
  bool isUploadFailed() {
    return isMediaMessage() && (mediaChatMessage?.mediaUploadStatus.value == Constants.mediaNotUploaded);
  }

  bool isMediaMessage() => (isAudioMessage() || isVideoMessage() || isImageMessage() || isFileMessage());

  bool isTextMessage() => messageType == Constants.mText;

  bool isAudioMessage() => messageType == Constants.mAudio;

  bool isImageMessage() => messageType == Constants.mImage;

  bool isVideoMessage() => messageType == Constants.mVideo;

  bool isFileMessage() => messageType == Constants.mDocument;

  bool isNotificationMessage() => messageType.toUpperCase() == Constants.mNotification;
}