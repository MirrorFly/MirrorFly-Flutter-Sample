

part of 'utils.dart';

class NavUtils{

  // Returns the size of the current media query.
  static Size get size => MediaQuery.of(navigatorKey.currentContext!).size;

  // Returns the width of the current media query.
  static double get width => size.width;

  // Returns the height of the current media query.
  static double get height => size.height;

  // Returns the current BuildContext using the navigator key.
  static BuildContext get currentContext => navigatorKey.currentContext!;

  // Returns the name of the current route using the MirrorFlyNavigationObserver.
  static String get currentRoute =>
      MirrorFlyNavigationObserver.current?.settings.name ?? '';

  // Returns the name of the previous route using the MirrorFlyNavigationObserver.
  static String get previousRoute =>
      MirrorFlyNavigationObserver.previous?.settings.name ?? '';

  // Parsing the query parameters
  static dynamic get parameters => MirrorFlyNavigationObserver.current?.settings.name != null ? Uri.parse(MirrorFlyNavigationObserver.current!.settings.name!).queryParameters : null;
  static dynamic get arguments => MirrorFlyNavigationObserver.current?.settings.arguments != null ? MirrorFlyNavigationObserver.current!.settings.arguments : null;

  static back({dynamic result}){
    return Navigator.pop(currentContext,result);
  }

  static bool get canPop => Navigator.canPop(currentContext);
  static String get defaultRouteName => Navigator.defaultRouteName;

  static offNamed(String page, {
    dynamic arguments,
    int? id,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
  }){
    if (preventDuplicates && page == MirrorFlyNavigationObserver.current?.settings.name) {
      debugPrint("offNamed: $page return null");
      return null;
    }

    if (parameters != null) {
      final uri = Uri(path: page, queryParameters: parameters);
      page = uri.toString();
    }
    return Navigator.pushReplacementNamed(currentContext, page,
      arguments: arguments);
  }

  static offAllNamed(String newRouteName, {RoutePredicate? predicate, dynamic arguments, int? id, Map<String, String>? parameters}){
    if (parameters != null) {
      final uri = Uri(path: newRouteName, queryParameters: parameters);
      newRouteName = uri.toString();
    }
    return Navigator.pushNamedAndRemoveUntil(currentContext,newRouteName,predicate ?? (_) => false, arguments: arguments);
  }

  static popUntil(RoutePredicate predicate){
    return Navigator.popUntil(currentContext,predicate);
  }

  static toNamed(String page, {
    dynamic arguments,
    int? id,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
  }){
    if (preventDuplicates && page == MirrorFlyNavigationObserver.current?.settings.name) {
      return null;
    }

    if (parameters != null) {
      final uri = Uri(path: page, queryParameters: parameters);
      page = uri.toString();
    }
    return Navigator.pushNamed(currentContext,page, arguments: arguments);
  }

  static to(dynamic page, {
    dynamic arguments,
    int? id,
  }){
    return Navigator.push(currentContext, MaterialPageRoute<void>(
      builder: (BuildContext context) => page,
    ),);
  }

  static bool get isOverlayOpen => DialogUtils.isDialogOpen() || isModalBottomSheetOpen();

  static bool isModalBottomSheetOpen() {
    var currentRoute = ModalRoute.of(currentContext);
    return currentRoute is ModalBottomSheetRoute;
  }

}