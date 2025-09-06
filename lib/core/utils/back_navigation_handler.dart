import 'package:flutter/material.dart';

/// Singleton to handle back navigation throughout the app
class BackNavigationHandler {
  static final BackNavigationHandler _instance = BackNavigationHandler._internal();
  
  factory BackNavigationHandler() => _instance;
  static BackNavigationHandler get instance => _instance;
  
  BackNavigationHandler._internal();
  
  VoidCallback? _backHandler;
  
  void setHandler(VoidCallback handler) {
    _backHandler = handler;
  }
  
  void clearHandler() {
    _backHandler = null;
  }
  
  void handleBack() {
    if (_backHandler != null) {
      _backHandler!();
    }
  }
  
  bool get hasHandler => _backHandler != null;
}
