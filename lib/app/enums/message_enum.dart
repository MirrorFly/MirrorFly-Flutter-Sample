enum MessageEnum {
  text('TEXT'),
  image('IMAGE'),
  audio('AUDIO'),
  video('VIDEO'),
  location('LOCATION');

  const MessageEnum(this.type);
  final String type;
}

extension MessageType on String {
  MessageEnum toEnum() {
    switch(this){
      case 'TEXT':
        return MessageEnum.text;
      case 'IMAGE':
        return MessageEnum.image;
      case 'AUDIO':
        return MessageEnum.audio;
      case 'VIDEO':
        return MessageEnum.video;
      case 'LOCATION':
        return MessageEnum.location;
        default:
          return MessageEnum.text;
    }
  }
}

