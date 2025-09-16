import 'dart:async';
import 'package:flutter/material.dart';
import 'dependent_management_modal.dart';
import 'phone_frame.dart';

/// Utility functions for showing modals that respect phone frame boundaries
class PhoneModalUtils {
  /// Show a modal using the phone frame's overlay system
  /// 
  /// This leverages the phone frame's built-in overlay that automatically
  /// appears above all navigation bars and status bars with proper z-index.
  /// Follows Flutter best practices for modal management.
  static Future<T?> showPhoneFrameModal<T>({
    required BuildContext context,
    required Widget child,
    bool barrierDismissible = true,
    Color? barrierColor,
  }) {
    final Completer<T?> completer = Completer<T?>();
    
    void closeModal([T? result]) {
      PhoneFrameState.hideOverlay();
      if (!completer.isCompleted) {
        completer.complete(result);
      }
    }
    
    // Create modal content with backdrop and positioning
    final modalOverlay = _PhoneFrameModalOverlay<T>(
      child: child,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor ?? Colors.black54,
      onResult: closeModal,
    );
    
    // Show using phone frame's overlay system
    PhoneFrameState.showOverlay(modalOverlay);
    
    return completer.future;
  }

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

  /// Show a bottom sheet modal positioned within the phone's content area
  /// 
  /// This positions the bottom sheet to slide up from the bottom of the phone
  /// content area. The modal will be behind navigation bars due to lower z-index.
  static Future<T?> showPhoneBottomSheet<T>({
    required BuildContext context,
    required Widget child,
    bool barrierDismissible = true,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: 'Bottom Sheet',
      barrierColor: Colors.transparent,
      // Lower z-index so navigation bars appear on top
      useRootNavigator: false,
      pageBuilder: (context, animation, secondaryAnimation) {
        return MediaQuery.removePadding(
          context: context,
          removeTop: true,
          removeBottom: true,
          removeLeft: true,
          removeRight: true,
          child: Builder(
            builder: (context) {
              // Phone dimensions and positioning
              const phoneWidth = 393.0;
              const phoneHeight = 851.0;
              const phoneRadius = 20.0; // Phone inner radius
              const modalTopOffset = 150.0; // Modal starts 150px from screen top
              
              final screenWidth = MediaQuery.of(context).size.width;
              final screenHeight = MediaQuery.of(context).size.height;
              
              // Calculate phone positioning (centered on screen)
              final phoneLeft = (screenWidth - phoneWidth) / 2;
              final phoneTop = (screenHeight - phoneHeight) / 2;
              
              // Modal positioning - starts 150px from screen top
              final modalTop = modalTopOffset;
              final modalHeight = screenHeight - modalTopOffset;
              
              return Material(
                type: MaterialType.transparency,
                child: Stack(
                  children: [
                    // Gray background constrained to phone frame with rounded corners
                    Positioned(
                      left: phoneLeft,
                      top: phoneTop,
                      width: phoneWidth,
                      height: phoneHeight,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(phoneRadius),
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
                    ),
                    // Modal positioned 150px from screen top, constrained to phone width
                    AnimatedBuilder(
                      animation: animation,
                      builder: (context, _) {
                        final slideValue = Curves.easeOutCubic.transform(animation.value);
                        return Positioned(
                          left: phoneLeft,
                          top: modalTop + (modalHeight * (1 - slideValue)),
                          width: phoneWidth,
                          height: modalHeight,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: child,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
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

  /// Show the dependent management modal
  static Future<void> showDependentManagementModal({
    required BuildContext context,
    required List<String> availableDependents,
    required List<String> selectedDependents,
    required Function(List<String>) onDependentsChanged,
  }) async {
    await showPhoneModal(
      context: context,
      child: DependentManagementModal(
        availableDependents: availableDependents,
        selectedDependents: selectedDependents,
        onDependentsChanged: onDependentsChanged,
      ),
    );
  }
}

/// Modal overlay widget that works with PhoneFrame's overlay system
class _PhoneFrameModalOverlay<T> extends StatefulWidget {
  final Widget child;
  final bool barrierDismissible;
  final Color barrierColor;
  final Function(T?) onResult;

  const _PhoneFrameModalOverlay({
    required this.child,
    required this.barrierDismissible,
    required this.barrierColor,
    required this.onResult,
  });

  @override
  State<_PhoneFrameModalOverlay<T>> createState() => _PhoneFrameModalOverlayState<T>();
}

class _PhoneFrameModalOverlayState<T> extends State<_PhoneFrameModalOverlay<T>>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _closeModal([T? result]) {
    _animationController.reverse().then((_) {
      widget.onResult(result);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Stack(
          children: [
            // Backdrop - only covers the main content area, excluding app bars
            Positioned(
              top: 44 + 56, // Below status bar + app bar (leave app bar visible)
              left: 0,
              right: 0,
              bottom: 48 + 56, // Above phone nav + app bottom nav (leave app nav visible)
              child: Container(
                color: widget.barrierColor.withValues(alpha: widget.barrierColor.opacity * _animation.value),
                child: widget.barrierDismissible
                    ? GestureDetector(
                        onTap: () => _closeModal(),
                        child: Container(),
                      )
                    : Container(),
              ),
            ),
            // Modal content - centered in the available content space
            Positioned(
              top: 44 + 56 + 40, // Status bar + app bar + padding
              left: 24,
              right: 24,
              child: Transform.scale(
                scale: 0.7 + (0.3 * _animation.value), // Scale in animation
                child: Opacity(
                  opacity: _animation.value,
                  child: Material(
                    borderRadius: BorderRadius.circular(12),
                    elevation: 8,
                    child: Container(
                      constraints: const BoxConstraints(
                        maxHeight: 400, // Reduced to fit in available space
                      ),
                      child: widget.child,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Custom modal widget that works with phone frame overlay system
class PhoneFrameModal extends StatelessWidget {
  final Widget child;
  final VoidCallback? onCancel;
  final VoidCallback? onDone;

  const PhoneFrameModal({
    super.key,
    required this.child,
    this.onCancel,
    this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    return child;
  }

  /// Close the current phone frame modal
  static void close() {
    PhoneFrameState.hideOverlay();
  }
}