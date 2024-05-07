
import 'package:flutter/material.dart';
import 'package:mirrorfly_plugin/logmessage.dart';

class MirrorFlyNavigationObserver extends NavigatorObserver {
  List<Route<dynamic>> routeStack = [];

  Route<dynamic>? get currentRoute => routeStack.isNotEmpty ? routeStack.last : null;
  Route<dynamic>? get previousRoute => routeStack.length > 1 ? routeStack[routeStack.length - 2] : null;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    routeStack.add(route);
    logCurrentStack("push");
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    routeStack.removeLast();
    logCurrentStack("pop");
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    routeStack.remove(route);
    logCurrentStack("remove");
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (oldRoute != null && newRoute != null) {
      int index = routeStack.indexOf(oldRoute);
      if (index != -1) {
        routeStack[index] = newRoute;
      }
    }
    logCurrentStack("replace");
  }

  void logCurrentStack(String action) {
    LogMessage.d("MirrorFly Navigator Observer: ","After $action: Current Stack: ${routeStack.map((r) => r.settings.name).toList()}");
  }
}
