import 'dart:async';
import 'package:flutter/material.dart';

/// Standardized top-of-screen toast manager with stacking (max 3).
/// - Persistent shadow via Material elevation
/// - SafeArea-aware top offset
/// - Optional icon and action
/// - Stacking: up to 3 visible; soonest-to-dismiss at the top
class ToastManager {
  ToastManager._();

  static final Map<OverlayState, _ToastStack> _stacks = {};

  static void showTopToast(
    BuildContext context, {
    required String message,
    required Color color,
    IconData? icon,
    bool persistent = false,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final overlay = Overlay.of(context);
    final stack = _stacks.putIfAbsent(overlay, () => _ToastStack(overlay));
    stack.show(_ToastModel(
      message: message,
      color: color,
      icon: icon,
      persistent: persistent,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
    ));
  }

  static void hideAll(BuildContext context) {
    final overlay = Overlay.of(context);
    final stack = _stacks[overlay];
    stack?.clear();
  }
}

class _ToastStack {
  _ToastStack(this.overlay) {
    _entry = OverlayEntry(builder: _build);
    overlay.insert(_entry);
  }

  final OverlayState overlay;
  late OverlayEntry _entry;
  final List<_ToastEntry> _toasts = [];

  void show(_ToastModel model) {
    // Replace any existing toast (no stacking)
    for (final t in _toasts) {
      t.timer?.cancel();
    }
    _toasts.clear();

    // Create entry and timer (if not persistent)
    final entry = _ToastEntry(model: model, onClose: _remove);
    _toasts.add(entry);
    _rebuild();

    if (!model.persistent) {
      entry.timer = Timer(model.duration, () {
        _remove(entry);
      });
    }
  }

  void _remove(_ToastEntry entry) {
    entry.timer?.cancel();
    _toasts.remove(entry);
    _rebuild();
    if (_toasts.isEmpty) {
      // Tear down when empty to avoid lingering overlay
      _entry.remove();
      ToastManager._stacks.remove(overlay);
    }
  }

  void clear() {
    for (final t in _toasts) {
      t.timer?.cancel();
    }
    _toasts.clear();
    _rebuild();
    _entry.remove();
    ToastManager._stacks.remove(overlay);
  }

  Widget _build(BuildContext context) {
    final paddingTop = MediaQuery.of(context).padding.top;
    const horizontal = 16.0;

    if (_toasts.isEmpty) {
      return const SizedBox.shrink();
    }

    final t = _toasts.first;

    return Stack(children: [
      Positioned(
        top: paddingTop + 12.0,
        left: horizontal,
        right: horizontal,
        child: _ToastWidget(
          model: t.model,
          onClose: () => _remove(t),
        ),
      ),
    ]);
  }

  void _rebuild() {
    try {
      _entry.markNeedsBuild();
    } catch (_) {
      // If entry was removed unexpectedly, recreate
      _entry = OverlayEntry(builder: _build);
      overlay.insert(_entry);
    }
  }
}

class _ToastEntry {
  _ToastEntry({required this.model, required this.onClose})
      : createdAt = DateTime.now();

  final _ToastModel model;
  final DateTime createdAt;
  final void Function(_ToastEntry) onClose;
  Timer? timer;

  Duration remaining(DateTime now) {
    if (model.persistent) return const Duration(days: 365);
    final elapsed = now.difference(createdAt);
    final rem = model.duration - elapsed;
    return rem.isNegative ? Duration.zero : rem;
  }
}

class _ToastModel {
  _ToastModel({
    required this.message,
    required this.color,
    this.icon,
    this.persistent = false,
    this.duration = const Duration(seconds: 3),
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final Color color;
  final IconData? icon;
  final bool persistent;
  final Duration duration;
  final String? actionLabel;
  final VoidCallback? onAction;
}

class _ToastWidget extends StatelessWidget {
  const _ToastWidget({required this.model, required this.onClose});

  final _ToastModel model;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: model.color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            if (model.icon != null) ...[
              Icon(model.icon, color: Colors.white, size: 20),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                model.message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (model.actionLabel != null && model.onAction != null) ...[
              TextButton(
                onPressed: model.onAction,
                style: TextButton.styleFrom(foregroundColor: Colors.white),
                child: Text(model.actionLabel!),
              ),
            ],
            if (model.persistent)
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 20),
                onPressed: onClose,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
          ],
        ),
      ),
    );
  }
}

