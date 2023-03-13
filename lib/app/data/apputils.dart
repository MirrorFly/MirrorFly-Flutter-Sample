import 'package:internet_connection_checker/internet_connection_checker.dart';

class AppUtils{
  AppUtils._();
  static Future<bool> isNetConnected() async {
    final bool isConnected = await InternetConnectionChecker().hasConnection;
    return isConnected;
  }
}