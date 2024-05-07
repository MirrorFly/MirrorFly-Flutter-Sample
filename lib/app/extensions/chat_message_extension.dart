part of "extensions.dart";

extension ChatmessageParsing on ChatMessageModel {
  bool isMediaDownloaded() {
    return isMediaMessage() && (mediaChatMessage?.mediaDownloadStatus.value == MediaDownloadStatus.mediaDownloaded.value);
  }

  bool isMediaUploaded() {
    return isMediaMessage() && (mediaChatMessage?.mediaUploadStatus.value == MediaUploadStatus.mediaUploaded.value);
  }

  bool isMediaDownloading() {
    return isMediaMessage() && (mediaChatMessage?.mediaDownloadStatus.value == MediaDownloadStatus.mediaDownloading.value);
  }

  bool isMediaUploading() {
    return isMediaMessage() && (mediaChatMessage?.mediaUploadStatus.value == MediaUploadStatus.mediaUploading.value);
  }
  bool isUploadFailed() {
    return isMediaMessage() && (mediaChatMessage?.mediaUploadStatus.value == MediaUploadStatus.mediaNotUploaded.value);
  }

  bool isMediaMessage() => (isAudioMessage() || isVideoMessage() || isImageMessage() || isFileMessage());

  bool isTextMessage() => messageType == Constants.mText;

  bool isAudioMessage() => messageType == Constants.mAudio;

  bool isImageMessage() => messageType == Constants.mImage;

  bool isVideoMessage() => messageType == Constants.mVideo;

  bool isFileMessage() => messageType == Constants.mDocument;

  bool isNotificationMessage() => messageType.toUpperCase() == Constants.mNotification;
}