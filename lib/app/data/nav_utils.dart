

part of 'utils.dart';

class NavUtils{

  static BuildContext get currentContext => navigatorKey.currentContext!;

  static void back({dynamic result}){
    Navigator.pop(currentContext,result);
  }

}