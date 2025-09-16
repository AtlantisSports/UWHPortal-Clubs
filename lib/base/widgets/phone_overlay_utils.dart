import 'package:flutter/material.dart';

/// Utility functions for showing overlays within the phone frame
class PhoneOverlayUtils {
  /// Show a bottom sheet modal within the phone frame
  /// 
  /// This will appear above all phone elements including status bar and navigation
  static void showPhoneBottomSheet({
    required BuildContext context,
    required Widget child,
    bool barrierDismissible = true,
  }) {
    // Use the standard showModalBottomSheet but with proper constraints
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useRootNavigator: false, // Important: use the current navigator context
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
            maxWidth: 393, // Phone width constraint
          ),
          child: child,
        );
      },
    );
  }
  
  /// Show a centered modal within the phone frame
  static void showPhoneModal({
    required BuildContext context,
    required Widget child,
    bool barrierDismissible = true,
  }) {
    showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      useRootNavigator: false, // Important: use the current navigator context
      builder: (context) => Dialog(
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 345,
            maxHeight: 500,
          ),
          child: child,
        ),
      ),
    );
  }
}