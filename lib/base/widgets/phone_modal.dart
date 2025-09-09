import 'dart:async';
import 'package:flutter/material.dart';

/// Show a modal dialog that stays within phone frame boundaries
Future<T?> showPhoneModal<T>({
  required BuildContext context,
  required Widget child,
  double? maxHeight,
  bool dismissible = true,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: dismissible,
    builder: (BuildContext context) {
      return Dialog(
        insetPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 120, // Top space for app bar, bottom space for nav
        ),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: maxHeight ?? 500,
          ),
          padding: const EdgeInsets.all(20),
          child: child,
        ),
      );
    },
  );
}
