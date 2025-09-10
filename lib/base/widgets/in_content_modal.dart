import 'package:flutter/material.dart';

/// A modal overlay system that works within the phone frame content area
/// 
/// This creates modals that appear as overlays within the current widget tree
/// instead of using the root Navigator, ensuring they respect phone boundaries.
class InContentModal extends StatefulWidget {
  final Widget child;
  final Widget modal;
  final bool showModal;
  final VoidCallback? onDismiss;
  final Color barrierColor;

  const InContentModal({
    super.key,
    required this.child,
    required this.modal,
    required this.showModal,
    this.onDismiss,
    this.barrierColor = const Color(0x88000000),
  });

  @override
  State<InContentModal> createState() => _InContentModalState();
}

class _InContentModalState extends State<InContentModal> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(InContentModal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showModal != oldWidget.showModal) {
      if (widget.showModal) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main content
        widget.child,
        // Modal overlay
        if (widget.showModal) ...[
          // Animated backdrop
          AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Container(
                  color: widget.barrierColor,
                  child: GestureDetector(
                    onTap: widget.onDismiss,
                    child: Container(),
                  ),
                ),
              );
            },
          ),
          // Modal content
          AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(
                      maxWidth: 345, // Safe within phone frame
                      maxHeight: 500, // Safe height
                    ),
                    margin: const EdgeInsets.all(24),
                    child: Material(
                      borderRadius: BorderRadius.circular(12),
                      elevation: 8,
                      child: widget.modal,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ],
    );
  }
}

/// Utility to show modals within content area using InContentModal
class InContentModalUtils {
  /// Show a modal by updating state in a StatefulWidget
  /// 
  /// This approach requires the calling widget to be wrapped with InContentModal
  /// and manage the showModal state.
  static void showModal({
    required VoidCallback showCallback,
  }) {
    showCallback();
  }

  /// Helper to create a role selection modal content
  static Widget buildRoleSelectionModal({
    required List<dynamic> roles,
    required dynamic selectedRole,
    required Function(dynamic) onRoleSelected,
    required VoidCallback onCancel,
    required VoidCallback onApply,
  }) {
    return StatefulBuilder(
      builder: (context, setState) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Select Role',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: onCancel,
                    icon: const Icon(Icons.close),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Role options
              Column(
                children: roles.map((role) {
                  return RadioListTile(
                    title: Text(role.displayName ?? role.toString()),
                    value: role,
                    groupValue: selectedRole,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          onRoleSelected(value);
                        });
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: onCancel,
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: onApply,
                    child: const Text('Apply'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
