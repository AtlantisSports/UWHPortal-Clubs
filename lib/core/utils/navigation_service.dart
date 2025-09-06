import 'package:flutter/material.dart';

/// Global navigation service for handling navigation from anywhere in the app
class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  
  static NavigatorState? get navigator => navigatorKey.currentState;
  
  static BuildContext? get context => navigatorKey.currentContext;
  
  /// Navigate to a new route
  static Future<T?> navigateTo<T extends Object?>(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushNamed<T>(routeName, arguments: arguments);
  }
  
  /// Replace the current route
  static Future<T?> navigateAndReplace<T extends Object?, TO extends Object?>(
    String routeName, {
    Object? arguments,
  }) {
    return navigatorKey.currentState!.pushReplacementNamed<T, TO>(routeName, arguments: arguments);
  }
  
  /// Go back to previous route
  static void goBack<T extends Object?>([T? result]) {
    return navigatorKey.currentState!.pop<T>(result);
  }
  
  /// Check if we can go back
  static bool canGoBack() {
    return navigatorKey.currentState!.canPop();
  }
  
  /// Pop until a specific route
  static void popUntil(String routeName) {
    return navigatorKey.currentState!.popUntil(ModalRoute.withName(routeName));
  }
}
