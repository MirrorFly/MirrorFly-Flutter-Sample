

part of 'utils.dart';

class NavUtils{

  static BuildContext get currentContext => navigatorKey.currentContext!;

  static void back({dynamic result}){
    Navigator.pop(currentContext,result);
  }

  static offAllNamed(String newRouteName, {RoutePredicate? predicate, dynamic arguments, int? id, Map<String, String>? parameters}){
    if (parameters != null) {
      final uri = Uri(path: newRouteName, queryParameters: parameters);
      newRouteName = uri.toString();
    }
    return Navigator.pushNamedAndRemoveUntil(currentContext,newRouteName,predicate ?? (_) => false, arguments: arguments);
  }

}