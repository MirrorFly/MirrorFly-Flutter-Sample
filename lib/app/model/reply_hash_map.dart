import 'package:mirrorfly_plugin/mirrorflychat.dart';
import 'package:tuple/tuple.dart';

class ReplyHashMap{

  static late Map<String,String> hashmap;
  static late Map<String,Tuple2<String,int>> refreshToken;

  static init(){
    hashmap={};
    refreshToken={};
  }

  static saveReplyId(String user, String replyId){
    hashmap[user]=replyId;
  }
  static String getReplyId(String user){
    return hashmap[user] ?? '';
  }
  static addRefreshToken(String url,String error){
    var count = refreshToken[url]?.item2 ?? 0;
    refreshToken[url]=Tuple2(error,count+1);
    LogMessage.d("refreshToken","addRefreshToken $url: ${refreshToken[url]}");
  }
  static getRefreshCount(String url){
    LogMessage.d("refreshToken","getRefreshCount $url: ${refreshToken[url]}");
    return refreshToken[url]?.item2 ?? 0;
  }
  static clearRefreshToken(){
    refreshToken={};
  }
}