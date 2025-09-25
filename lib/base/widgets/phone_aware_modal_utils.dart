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
      useRootNavigator: false,
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

  /// Show a dialog that slides up from the bottom to its final position (pop-up style)
  static Future<T?> showPhoneAwareDialogSlideUpFromBottom<T>({
    required BuildContext context,
    required Widget child,
    bool barrierDismissible = true,
    Color barrierColor = Colors.black54,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: 'Modal',
      barrierColor: Colors.transparent,
      useRootNavigator: false,
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
              // Modal content - slides up into place (same final placement as standard dialog)
              Center(
                child: FadeTransition(
                  opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 1),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
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

  /// Show a dialog aligned to the top of the app content area that animates
  /// up from the bottom of the phone frame (strong, unmistakable motion)
  static Future<T?> showPhoneAwareDialogSlideUpToTop<T>({
    required BuildContext context,
    required Widget child,
    bool barrierDismissible = true,
    Color barrierColor = Colors.black54,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: 'Modal',
      barrierColor: Colors.transparent,
      useRootNavigator: false,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, animation, secondaryAnimation) {
        // We build in transitionBuilder instead; this returns an inert child.
        return const SizedBox.shrink();
      },
      transitionBuilder: (context, animation, secondaryAnimation, _) {
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;
        final left = PhoneFrameConstants.getPhoneCenterX(screenWidth) +
            (PhoneFrameConstants.phoneWidth - PhoneFrameConstants.maxModalWidth) / 2;
        final top = PhoneFrameConstants.getModalBackdropTop(screenHeight) + 12;
        final travelPx = PhoneFrameConstants.getModalBackdropHeight() - 100;

        final fade = CurvedAnimation(parent: animation, curve: Curves.easeOut);
        final slideCurve = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);

        return MediaQuery.removePadding(
          context: context,
          removeTop: true,
          removeBottom: true,
          removeLeft: true,
          removeRight: true,
          child: Stack(
            children: [
              // Backdrop
              Positioned(
                left: PhoneFrameConstants.getPhoneCenterX(screenWidth),
                top: PhoneFrameConstants.getModalBackdropTop(screenHeight),
                width: PhoneFrameConstants.phoneWidth,
                height: PhoneFrameConstants.getModalBackdropHeight(),
                child: Container(
                  color: barrierColor,
                  child: barrierDismissible
                      ? GestureDetector(
                          onTap: () { FocusScope.of(context).unfocus(); Navigator.of(context).pop(); },
                          child: Container(),
                        )
                      : Container(),
                ),
              ),

              // Top-aligned dialog that translates from bottom to top
              Positioned(
                left: left,
                top: top,
                width: PhoneFrameConstants.maxModalWidth,
                child: Opacity(
                  opacity: fade.value,
                  child: Transform.translate(
                    offset: Offset(0, (1.0 - slideCurve.value) * travelPx),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
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
      useRootNavigator: false,
      pageBuilder: (context, animation, secondaryAnimation) {
        final size = MediaQuery.of(context).size;
        final screenWidth = size.width;
        final screenHeight = size.height;
        final isNarrow = screenWidth <= PhoneFrameConstants.phoneWidth;
        final sheetWidth = isNarrow ? screenWidth : PhoneFrameConstants.phoneWidth;
        final left = isNarrow ? 0.0 : PhoneFrameConstants.getPhoneCenterX(screenWidth);
        final bottom = isNarrow ? 0.0 : PhoneFrameConstants.getBottomSheetBottom(screenHeight);
        final maxHeight = isNarrow ? screenHeight * 0.92 : PhoneFrameConstants.maxBottomSheetHeight;

        return MediaQuery.removePadding(
          context: context,
          removeTop: true,
          removeBottom: true,
          removeLeft: true,
          removeRight: true,
          child: Stack(
            children: [
              // Backdrop - full screen on mobile, phone content area on desktop
              if (isNarrow)
                Positioned.fill(
                  child: Container(
                    color: barrierColor,
                    child: barrierDismissible
                        ? GestureDetector(
                            onTap: () { FocusScope.of(context).unfocus(); Navigator.of(context).pop(); },
                            child: Container(),
                          )
                        : Container(),
                  ),
                )
              else
                Positioned(
                  left: PhoneFrameConstants.getPhoneCenterX(screenWidth),
                  top: PhoneFrameConstants.getModalBackdropTop(screenHeight),
                  width: PhoneFrameConstants.phoneWidth,
                  height: PhoneFrameConstants.getModalBackdropHeight(),
                  child: Container(
                    color: barrierColor,
                    child: barrierDismissible
                        ? GestureDetector(
                            onTap: () { FocusScope.of(context).unfocus(); Navigator.of(context).pop(); },
                            child: Container(),
                          )
                        : Container(),
                  ),
                ),

              // Bottom sheet content - slides up from bottom
              Positioned(
                left: left,
                bottom: bottom,
                width: sheetWidth,
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
                    child: SafeArea(
                      top: false,
                      left: false,
                      right: false,
                      child: AnimatedPadding(
                        duration: const Duration(milliseconds: 150),
                        curve: Curves.easeOut,
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom,
                        ),
                        child: FocusTraversalGroup(
                          child: PopScope(
                            canPop: barrierDismissible,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxHeight: maxHeight,
                              ),
                              child: child,
                            ),
                          ),
                        ),
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
}
