/// Phone-aware modal utilities that preserve phone frame boundaries
/// Uses standard Flutter modals but constrains them to the phone content area
library;

import 'package:flutter/material.dart';
import '../../core/constants/phone_frame_constants.dart';

/// Utility functions for showing modals that preserve phone frame boundaries
/// while using standard Flutter modal APIs
class PhoneAwareModalUtils {
  /// Show a modal dialog that preserves phone status bar and navigation bar
  /// 
  /// This uses showGeneralDialog with proper positioning to:
  /// - Keep phone status bar visible (top 44px)
  /// - Keep phone navigation bar visible (bottom 48px) 
  /// - Only cover the app content area with backdrop
  /// - Use standard Navigator.pop() for closing
  static Future<T?> showPhoneAwareDialog<T>({
    required BuildContext context,
    required Widget child,
    bool barrierDismissible = true,
    Color barrierColor = Colors.black54,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: 'Modal',
      barrierColor: Colors.transparent, // We handle backdrop ourselves
      pageBuilder: (context, animation, secondaryAnimation) {
        return MediaQuery.removePadding(
          context: context,
          removeTop: true,
          removeBottom: true,
          removeLeft: true,
          removeRight: true,
          child: Stack(
            children: [
              // Backdrop - only covers app content area, preserving phone frame
              Positioned(
                left: PhoneFrameConstants.getPhoneCenterX(MediaQuery.of(context).size.width),
                top: PhoneFrameConstants.getModalBackdropTop(MediaQuery.of(context).size.height),
                width: PhoneFrameConstants.phoneWidth,
                height: PhoneFrameConstants.getModalBackdropHeight(),
                child: Container(
                  color: barrierColor,
                  child: barrierDismissible
                      ? GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(),
                        )
                      : Container(),
                ),
              ),
              // Modal content - centered in app content area
              Center(
                child: FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.7, end: 1.0).animate(
                      CurvedAnimation(parent: animation, curve: Curves.easeInOut),
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: PhoneFrameConstants.maxModalWidth,
                        maxHeight: PhoneFrameConstants.maxModalHeight,
                      ),
                      child: Material(
                        borderRadius: BorderRadius.circular(12),
                        elevation: 8,
                        child: child,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Show a bottom sheet modal that preserves phone frame boundaries
  /// 
  /// This slides up from the bottom but stays within the phone content area
  static Future<T?> showPhoneAwareBottomSheet<T>({
    required BuildContext context,
    required Widget child,
    bool barrierDismissible = true,
    Color barrierColor = Colors.black54,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: 'Bottom Sheet',
      barrierColor: Colors.transparent,
      pageBuilder: (context, animation, secondaryAnimation) {
        return MediaQuery.removePadding(
          context: context,
          removeTop: true,
          removeBottom: true,
          removeLeft: true,
          removeRight: true,
          child: Stack(
            children: [
              // Backdrop - only covers app content area
              Positioned(
                left: (MediaQuery.of(context).size.width - 393) / 2,
                top: (MediaQuery.of(context).size.height - 851) / 2 + 44,
                width: 393,
                height: 851 - 44 - 48,
                child: Container(
                  color: barrierColor,
                  child: barrierDismissible
                      ? GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(),
                        )
                      : Container(),
                ),
              ),
              // Bottom sheet content - slides up from bottom of app area
              Positioned(
                left: PhoneFrameConstants.getPhoneCenterX(MediaQuery.of(context).size.width),
                bottom: PhoneFrameConstants.getBottomSheetBottom(MediaQuery.of(context).size.height),
                width: PhoneFrameConstants.phoneWidth,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
                  child: Material(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    elevation: 8,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: PhoneFrameConstants.maxBottomSheetHeight,
                      ),
                      child: child,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
