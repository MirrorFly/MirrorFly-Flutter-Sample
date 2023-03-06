class ReplyHashMap{

  static late Map<String,String> hashmap;

  static init(){
    hashmap={};
  }

  static saveReplyId(String user, String replyId){
    hashmap[user]=replyId;
  }
  static String getReplyId(String user){
    return hashmap[user] ?? '';
  }
}