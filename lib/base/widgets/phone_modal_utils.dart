import 'package:flutter/material.dart';

/// Utility functions for showing modals that respect phone frame boundaries
class PhoneModalUtils {
  /// Show a modal dialog positioned within the phone's content area
  /// 
  /// This uses showGeneralDialog with proper positioning to constrain
  /// the modal and backdrop to the phone's content area only.
  static Future<T?> showPhoneModal<T>({
    required BuildContext context,
    required Widget child,
    bool barrierDismissible = true,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: 'Modal',
      barrierColor: Colors.transparent, // We'll handle the backdrop ourselves
      pageBuilder: (context, animation, secondaryAnimation) {
        return MediaQuery.removePadding(
          context: context,
          removeTop: true,
          removeBottom: true,
          removeLeft: true,
          removeRight: true,
          child: Builder(
            builder: (context) {
              return Stack(
                children: [
                  // Backdrop constrained to content area only
                  Positioned(
                    left: (MediaQuery.of(context).size.width - 393) / 2, // Center horizontally on screen
                    top: (MediaQuery.of(context).size.height - 851) / 2 + 86, // Phone center + status bar + app bar offset
                    width: 393, // Phone width
                    height: 661, // Content area height (851 - 30 - 56 - 56 - 48)
                    child: Container(
                      color: Colors.black54,
                      child: barrierDismissible
                          ? GestureDetector(
                              onTap: () => Navigator.of(context).pop(),
                              child: Container(),
                            )
                          : Container(),
                    ),
                  ),
                  // Modal content centered within the backdrop
                  Positioned(
                    left: (MediaQuery.of(context).size.width - 345) / 2, // Center modal on screen
                    top: (MediaQuery.of(context).size.height - 400) / 2, // Center modal vertically
                    child: Material(
                      borderRadius: BorderRadius.circular(12),
                      elevation: 8,
                      child: Container(
                        width: 345, // Modal width
                        constraints: const BoxConstraints(
                          maxHeight: 500, // Safe height within content area
                        ),
                        child: child,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  /// Show a confirmation dialog with proper phone positioning
  static Future<bool> showPhoneConfirmationDialog({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDestructive = false,
  }) async {
    final result = await showPhoneModal<bool>(
      context: context,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    cancelText,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDestructive 
                        ? Colors.red 
                        : Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(confirmText),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    return result ?? false;
  }
}