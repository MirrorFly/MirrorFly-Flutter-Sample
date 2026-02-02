part of 'utils.dart';

class NavUtils {
  // Returns the size of the current media query.
  static Size get size => MediaQuery.of(navigatorKey.currentContext!).size;

  // Returns the width of the current media query.
  static double get width => size.width;

  // Returns the height of the current media query.
  static double get height => size.height;

  // Returns the safe area padding of the current media query.
  static double get safeAreaPadding =>
      (MediaQuery.of(navigatorKey.currentContext!).viewPadding.top +
          MediaQuery.of(navigatorKey.currentContext!).viewPadding.bottom);

  // Returns the current BuildContext using the navigator key.
  static BuildContext get currentContext => navigatorKey.currentContext!;

  static NavigatorState? get _navigator => navigatorKey.currentState;

  // Returns the name of the current route using the MirrorFlyNavigationObserver.
  static String get currentRoute =>
      MirrorFlyNavigationObserver.current?.settings.name ?? '';

  // Returns the name of the previous route using the MirrorFlyNavigationObserver.
  static String get previousRoute =>
      MirrorFlyNavigationObserver.previous?.settings.name ?? '';

  static List<dynamic> get navigationRouteStack =>
      MirrorFlyNavigationObserver.navigationRouteStack;

  // Parsing the query parameters
  static dynamic get parameters =>
      MirrorFlyNavigationObserver.current?.settings.name != null
          ? Uri.parse(MirrorFlyNavigationObserver.current!.settings.name!)
              .queryParameters
          : null;

  static dynamic get arguments =>
      MirrorFlyNavigationObserver.current?.settings.arguments != null
          ? MirrorFlyNavigationObserver.current!.settings.arguments
          : null;

  static Future<void> back({dynamic result}) async {
    final nav = await _waitForNavigator();
    if (nav.canPop()) nav.pop(result);
  }

  static bool get canPop => _navigator?.canPop() ?? false;

  static String _defaultRouteName = Navigator.defaultRouteName;

  static String get defaultRouteName => _defaultRouteName;

  static void setDefaultRouteName(String defaultRouteName) {
    _defaultRouteName = defaultRouteName;
  }

  static Future<dynamic> offNamed(
    String page, {
    dynamic arguments,
    int? id,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
  }) async {
    if (preventDuplicates &&
        page == MirrorFlyNavigationObserver.current?.settings.name) {
      debugPrint("offNamed: $page return null");
      return null;
    }

    if (parameters != null) {
      final uri = Uri(path: page, queryParameters: parameters);
      page = uri.toString();
    }
    // return Navigator.pushReplacementNamed(currentContext, page,
    //     arguments: arguments);
    final nav = await _waitForNavigator();
    return nav.pushReplacementNamed(page, arguments: arguments);
  }

  static Future<dynamic> offAllNamed(String newRouteName,
      {RoutePredicate? predicate,
      dynamic arguments,
      int? id,
      Map<String, String>? parameters}) async {
    if (parameters != null) {
      final uri = Uri(path: newRouteName, queryParameters: parameters);
      newRouteName = uri.toString();
    }
    // return Navigator.pushNamedAndRemoveUntil(
    //     currentContext, newRouteName, predicate ?? (_) => false,
    //     arguments: arguments);
    final nav = await _waitForNavigator();
    return nav.pushNamedAndRemoveUntil(
      newRouteName,
      predicate ?? (_) => false,
      arguments: arguments,
    );
  }

  static Future<void> popUntil(RoutePredicate predicate) async {
    // return Navigator.popUntil(currentContext, predicate);
    final nav = await _waitForNavigator();
    nav.popUntil(predicate);
  }

  static Future<dynamic> toNamed(
    String page, {
    dynamic arguments,
    int? id,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
  }) async {
    if (preventDuplicates &&
        page == MirrorFlyNavigationObserver.current?.settings.name) {
      debugPrint("toNamed: $page return null. ${MirrorFlyNavigationObserver.current?.settings.name}");
      return null;
    }

    if (parameters != null) {
      final uri = Uri(path: page, queryParameters: parameters);
      page = uri.toString();
    }
    // return Navigator.pushNamed(currentContext, page, arguments: arguments);
    final nav = await _waitForNavigator();
    return nav.pushNamed(page, arguments: arguments);
  }

  static Future<dynamic> to(
    dynamic page, {
    dynamic arguments,
    int? id,
  }) async {
    // return Navigator.push(
    //   currentContext,
    //   MaterialPageRoute<void>(
    //     builder: (BuildContext context) => page,
    //   ),
    // );
    final nav = await _waitForNavigator();
    return nav.push(
      MaterialPageRoute<void>(
        builder: (_) => page,
        settings: RouteSettings(arguments: arguments),
      ),
    );
  }

  static bool get isOverlayOpen =>
      DialogUtils.isDialogOpen() || isModalBottomSheetOpen();

  static bool isModalBottomSheetOpen() {
    final context = currentContext;
    var currentRoute = ModalRoute.of(context);
    return currentRoute is ModalBottomSheetRoute;
  }

  static Future<NavigatorState> _waitForNavigator() async {
    while (_navigator == null) {
      debugPrint(
          "NavUtils: Waiting for navigator to be available...");
      await WidgetsBinding.instance.endOfFrame;
    }
    return _navigator!;
  }
}
