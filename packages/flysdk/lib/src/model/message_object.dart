
class MessageObject{
  MessageObject({
    required this.toJid,
    required this.messageType,
    this.textMessage,
    this.replyMessageId,
    this.latitude,
    this.longitude,
    this.contactName,
    this.contactNumbers,
    this.file,
    this.fileName,
    this.caption,
    this.base64Thumbnail,
    this.audioDuration,
    this.isAudioRecorded
});

  String toJid;
  String messageType;
  String? textMessage;
  String? replyMessageId;
  double? latitude;
  double? longitude;
  String? contactName;
  List<String>? contactNumbers;
  String? file;
  String? fileName;
  String? caption;
  String? base64Thumbnail;
  String? audioDuration;
  bool? isAudioRecorded;
}