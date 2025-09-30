/// Calendar widget for displaying practice schedules
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/models/club.dart';
import '../../core/models/practice.dart';
import '../../core/providers/participation_provider.dart';
import '../../core/providers/practice_filter_provider.dart';
import '../../base/widgets/phone_aware_modal_utils.dart';
import '../../base/widgets/rsvp_components.dart';
import '../../core/utils/time_utils.dart';

import '../../core/models/guest.dart';
import '../../base/widgets/guest_management_modal.dart';
import 'shared_rsvp_confirm.dart';
import '../../core/utils/rsvp_apply_helper.dart';


import 'dart:async';


enum BulkChoice { none, yes, maybe, no }


/// Extension to provide information about whether a practice passes level filters
class FilteredPracticeStatus {
  final String practiceId; // Link indicator to a specific practice
  final ParticipationStatus participationStatus;
  final bool isAttendanceMode; // true → render as attendance (filled); false → RSVP (outline)
  final bool passesFilter;

  const FilteredPracticeStatus({
    required this.practiceId,
    required this.participationStatus,
    required this.isAttendanceMode,
    required this.passesFilter,
  });
}

class PracticeDay {
  final DateTime date;
  final List<FilteredPracticeStatus> practices;

  PracticeDay({required this.date, required this.practices});
}

class PracticeCalendar extends StatefulWidget {
  final Club club;
  final Function(Practice)? onPracticeSelected;
  final ParticipationProvider? participationProvider;
  final VoidCallback? onShowLevelFilter;
  final VoidCallback? onAutoScrollTabBarToTop;

  const PracticeCalendar({
    super.key,
    required this.club,
    this.onPracticeSelected,
    this.participationProvider,
    this.onShowLevelFilter,
    this.onAutoScrollTabBarToTop,
  });

  @override
  State<PracticeCalendar> createState() => _PracticeCalendarState();
}

class _PracticeCalendarState extends State<PracticeCalendar> {
  Club get club => widget.club;

  @override
  void initState() {
    super.initState();
    // No longer need to clear overlays - using standard Flutter modals
  }

  // Selection mode state
  bool _selectionMode = false;
  final Set<String> _selectedPracticeIds = <String>{};

  // Tracks if the per-date practice picker dialog is currently open
  bool _isPracticePickerOpen = false;

  // Bulk controls state
  BulkChoice _bulkChoice = BulkChoice.none;
  bool _bulkBringGuests = false; // UI affordance; final bringGuest depends on merged guest list
  // Toast state (top-of-screen)
  bool _showToast = false;
  String _toastMessage = '';
  Color _toastColor = AppColors.info;
  IconData? _toastIcon;
  bool _bulkConditional = false; // Conditional Maybe for bulk
  int? _bulkConditionalThreshold; // Bulk threshold

  OverlayEntry? _toastOverlay;

  void _showTopScreenToast(String message, Color color, IconData icon, {bool persistent = false}) {
    // Remove any existing toast overlay
    _toastOverlay?.remove();
    _toastOverlay = null;

    final overlay = Overlay.of(context);

    _toastOverlay = OverlayEntry(
      builder: (context) {
        final top = MediaQuery.of(context).padding.top + 12;
        return Positioned(
          top: top,
          left: 16,
          right: 16,
          child: Material(
            elevation: 6,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(icon, color: Colors.white, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (persistent)
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 20),
                      onPressed: () {
                        _toastOverlay?.remove();
                        _toastOverlay = null;
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );

    overlay.insert(_toastOverlay!);

    if (!persistent) {
      // Auto-remove after 3 seconds
      Timer(const Duration(seconds: 3), () {
        _toastOverlay?.remove();
        _toastOverlay = null;
      });
    }
  }


  void _showCustomToast(String message, Color color, IconData icon) {
    setState(() {
      _toastMessage = message;
      _toastColor = color;
      _toastIcon = icon;
      _showToast = true;
    });
    // Auto-hide after 3 seconds
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showToast = false;
        });
        _updateSelectionOverlay();
      }
    });
    _updateSelectionOverlay();
  }

  // Overlay entry for top selection panel rendered above the tab bar
  OverlayEntry? _selectionOverlay;

  PracticeGuestList _bulkGuestList = const PracticeGuestList();

  void _enterSelectionMode({Iterable<String>? preselectIds}) {
    setState(() {
      _selectionMode = true;
      _selectedPracticeIds.clear();
      if (preselectIds != null) {
        _selectedPracticeIds.addAll(preselectIds);
      }
      // Neutral defaults per spec
      _bulkChoice = BulkChoice.none;
      _bulkBringGuests = false;
      _bulkGuestList = const PracticeGuestList();
      // Also reset Conditional Maybe state each new session
      _bulkConditional = false;
      _bulkConditionalThreshold = null;
    });
    _insertSelectionOverlay();
    // Smooth auto-scroll so the tab bar is at the top
    widget.onAutoScrollTabBarToTop?.call();
  }

  void _exitSelectionMode() {
    setState(() {
      _selectionMode = false;
      _selectedPracticeIds.clear();
      _bulkChoice = BulkChoice.none;
      _bulkBringGuests = false;
      _bulkGuestList = const PracticeGuestList();
    });
    _removeSelectionOverlay();
  }

  void _insertSelectionOverlay() {
    if (_selectionOverlay != null) return;
    _selectionOverlay = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: SafeArea(
                bottom: false,
                child: Container(
                  margin: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(maxWidth: 393),
                  width: double.infinity,
                  child: TweenAnimationBuilder<Offset>(
                    tween: Tween(begin: const Offset(0, 3), end: Offset.zero),
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) => FractionalTranslation(
                      translation: value,
                      child: child,
                    ),
                    child: _buildTopSelectionBar(),
                  ),
                ),
              ),
            ),
            if (_showToast)
              Positioned(
                top: MediaQuery.of(context).padding.top + 12,
                left: 16,
                right: 16,
                child: Material(
                  elevation: 6,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: _toastColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        if (_toastIcon != null)
                          Icon(_toastIcon, color: Colors.white, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _toastMessage,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
    final overlayState = Navigator.of(context).overlay;
    overlayState?.insert(_selectionOverlay!);
  }

  void _removeSelectionOverlay() {
    _selectionOverlay?.remove();
    _selectionOverlay = null;
  }

  void _updateSelectionOverlay() {
    _selectionOverlay?.markNeedsBuild();
  }

  void _toggleSelectionForPractice(String practiceId) {
    setState(() {
      if (_selectedPracticeIds.contains(practiceId)) {
        _selectedPracticeIds.remove(practiceId);
      } else {
        _selectedPracticeIds.add(practiceId);
      }
    });
    _updateSelectionOverlay();
  }

  bool _isPracticeSelectable(Practice practice) {
    // Eligible if not past/locked. Allow RSVP until 30 minutes after start.
    final cutoff = practice.dateTime.add(const Duration(minutes: 30));
    return DateTime.now().isBefore(cutoff);
  }

  List<Practice> _getEligiblePracticesForDate(DateTime date) {
    return _getPracticesForDate(date).where(_isPracticeSelectable).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            children: [
              // Calendar header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Announced Practices',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () => _showParticipationLegend(),
                      child: const Icon(
                        Icons.help_outline,
                        size: 16,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    const Spacer(),
                    _buildFilterButton(context, widget.participationProvider),
                  ],
                ),
              ),

              // Scrollable calendar content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildMonth(context, 'September 2025', 2025, 9, widget.participationProvider),
                      const SizedBox(height: 24),
                      _buildMonth(context, 'October 2025', 2025, 10, widget.participationProvider),
                      const SizedBox(height: 24),
                      _buildMonth(context, 'November 2025', 2025, 11, widget.participationProvider),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

      ],
    );
  }

  Widget _buildMonth(BuildContext context, String title, int year, int month, ParticipationProvider? participationProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Consumer<PracticeFilterProvider>(
          builder: (context, filterProvider, child) {
            // Rebuild the grid when filters change so fades and inclusion update immediately
            return _buildCalendarGrid(context, year, month, participationProvider);
          },
        ),
      ],
    );
  }

  Widget _buildCalendarGrid(BuildContext context, int year, int month, ParticipationProvider? participationProvider) {
    final practices = _generatePracticesForMonth(year, month, participationProvider);
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final firstDayOfMonth = DateTime(year, month, 1);
    final startingWeekday = firstDayOfMonth.weekday % 7; // Convert to 0-6 (Sunday = 0)

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Days of week header
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: ['Su', 'M', 'T', 'W', 'Th', 'F', 'Sa']
                  .map((day) => Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            day,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),
          // Calendar days
          ...List.generate((daysInMonth + startingWeekday + 6) ~/ 7, (weekIndex) {
            return Row(
              children: List.generate(7, (dayIndex) {
                final dayNumber = weekIndex * 7 + dayIndex - startingWeekday + 1;

                if (dayNumber < 1 || dayNumber > daysInMonth) {
                  return const Expanded(child: SizedBox(height: 40));
                }

                final date = DateTime(year, month, dayNumber);
                final practicesForDay = practices[date] ?? [];

                return Expanded(
                  child: MouseRegion(
                    cursor: practicesForDay.isNotEmpty ? SystemMouseCursors.click : SystemMouseCursors.basic,
                    child: GestureDetector(
                      onTap: () => _onDayTapped(context, date, practicesForDay),
                      onLongPress: () => _onDayLongPressed(context, date),
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Colors.grey[300]!),
                            left: BorderSide(color: Colors.grey[300]!),
                            right: dayIndex < 6 ? BorderSide(color: Colors.grey[300]!) : BorderSide.none,
                            bottom: weekIndex < ((daysInMonth + startingWeekday + 6) ~/ 7) - 1
                                ? BorderSide(color: Colors.grey[300]!)
                                : BorderSide.none,
                          ),
                        ),
                      child: Stack(
                        children: [
                          // Day number
                          Positioned(
                            top: 2,
                            left: 4,
                            child: Text(
                              dayNumber.toString(),
                              style: TextStyle(
                                fontSize: 12,
                                color: _isToday(date) ? AppColors.primary : AppColors.textPrimary,
                                fontWeight: _isToday(date) ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                          // Guest count indicator (lower-left corner)
                          Consumer<ParticipationProvider>(
                            builder: (context, participationProvider, child) {
                              // Sum unique guests across all practices on this day (unique by Guest.id)
                              final consideredIds = practicesForDay.map((s) => s.practiceId).toList();
                              final uniqueGuestIds = <String>{};
                              for (final pid in consideredIds) {
                                final guestList = participationProvider.getPracticeGuests(pid);
                                for (final g in guestList.guests) {
                                  uniqueGuestIds.add(g.id);
                                }
                              }
                              final guestCount = uniqueGuestIds.length;

                              if (guestCount > 0) {
                                return Positioned(
                                  bottom: 2,
                                  left: 2,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                                    child: Text(
                                      '+$guestCount',
                                      style: const TextStyle(
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                          // Practice indicators
                          if (practicesForDay.isNotEmpty)
                            Positioned(
                              bottom: 2,
                              right: 2,
                              child: _buildPracticeIndicators(practicesForDay),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                );
              }),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPracticeIndicators(List<FilteredPracticeStatus> practices) {
    if (practices.isEmpty) return const SizedBox.shrink();

    final count = practices.length;
    final size = count == 1 ? 20.0 : count == 2 ? 16.0 : 12.0; // Single practice circle size set to 20.0

    if (count == 1) {
      return _buildSingleIndicator(practices[0], size);
    } else if (count == 2) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSingleIndicator(practices[0], size),
          const SizedBox(height: 1),
          _buildSingleIndicator(practices[1], size),
        ],
      );
    } else if (count == 3) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSingleIndicator(practices[0], size),
          const SizedBox(height: 1),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSingleIndicator(practices[1], size),
              const SizedBox(width: 1),
              _buildSingleIndicator(practices[2], size),
            ],
          ),
        ],
      );
    } else {
      // 4+ practices in square pattern
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSingleIndicator(practices[0], size),
              const SizedBox(width: 1),
              _buildSingleIndicator(practices[1], size),
            ],
          ),
          const SizedBox(height: 1),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSingleIndicator(practices[2], size),
              const SizedBox(width: 1),
              _buildSingleIndicator(count > 3 ? practices[3] : practices[0], size),
            ],
          ),
        ],
      );
    }
  }

  Widget _buildSingleIndicator(FilteredPracticeStatus filteredStatus, double size) {
    final passesFilter = filteredStatus.passesFilter;
    final opacity = passesFilter ? 1.0 : 0.25; // 75% fading (25% opacity)

    // Selected overlay: solid purple circle (no icon), respects filter fading
    if (_selectedPracticeIds.contains(filteredStatus.practiceId)) {
      return Opacity(
        opacity: opacity,
        child: Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.selection,
          ),
        ),
      );
    }

    final ps = filteredStatus.participationStatus;
    final isAttendance = filteredStatus.isAttendanceMode;


    // Pending YES countdown: show full-size blue spinner replacing the circle
    if (!isAttendance) {
      final pending = context.select<ParticipationProvider, bool>((p) => p.isPendingChange(filteredStatus.practiceId));
      if (pending) {
        final stroke = (size * 0.15).clamp(1.5, 3.0);
        final progress = context.select<ParticipationProvider, double>((p) => p.pendingChangeProgress(filteredStatus.practiceId));
        return Opacity(
          opacity: opacity,
          child: SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: stroke,
              color: AppColors.primary,
              backgroundColor: AppColors.primary.withValues(alpha: 0.15),
              value: progress,
            ),
          ),
        );
      }
    }

    Color color;
    IconData? icon;
    bool filled = isAttendance;
    double borderWidth = size * 0.08; // Scale border thickness with circle size

    if (isAttendance) {
      // Attendance visuals (past practices): solid primary with check/close
      color = AppColors.primary;
      if (ps == ParticipationStatus.attended) {
        icon = Icons.check;
      } else if (ps == ParticipationStatus.missed) {
        icon = Icons.close;
      } else {
        icon = null;
      }
    } else {
      // RSVP visuals (future or non-attendance view): outline with RSVP color
      switch (ps) {
        case ParticipationStatus.yes:
          color = AppColors.success;
          icon = Icons.check;
          break;
        case ParticipationStatus.maybe:
          color = AppColors.maybe;
          icon = Icons.question_mark;
          break;
        case ParticipationStatus.no:
          color = AppColors.error;
          icon = Icons.close;
          break;
        case ParticipationStatus.blank:
          color = const Color(0xFF6B7280); // Gray border, no icon
          icon = null;
          break;
        case ParticipationStatus.attended:
        case ParticipationStatus.missed:
          // Shouldn't normally appear in RSVP mode; treat as blank
          color = const Color(0xFF6B7280);
          icon = null;
          break;
      }
    }

    final baseCircle = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: filled ? color : Colors.transparent,
        border: Border.all(color: color, width: borderWidth),
        shape: BoxShape.circle,
      ),
      child: icon != null
          ? Icon(
              icon,
              size: size * 0.6,
              color: filled ? Colors.white : color, // White for filled, color for outline
            )
          : null,
    );

    Widget child = baseCircle;

    // Add Conditional Maybe badge in RSVP mode for Maybe status
    if (!isAttendance && ps == ParticipationStatus.maybe) {
      child = Consumer<ParticipationProvider>(
        builder: (context, provider, _) {
          final pid = filteredStatus.practiceId;
          if (!provider.getConditionalMaybe(pid)) {
            return baseCircle;
          }
          final threshold = provider.getConditionalMaybeThreshold(pid);
          if (threshold == null) return baseCircle;

          // Find practice by ID (if not found, skip badge)
          Practice? practice;
          try {
            practice = widget.club.upcomingPractices.firstWhere((p) => p.id == pid);
          } catch (_) {
            practice = null;
          }
          if (practice == null) return baseCircle;
          final satisfied = provider.isCurrentUserConditionalSatisfied(practice);
          final badgeColor = satisfied ? AppColors.success : AppColors.maybe;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              // Base circle switches to green when Conditional Maybe is satisfied
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: filled ? (satisfied ? AppColors.success : color) : Colors.transparent,
                  border: Border.all(color: satisfied ? AppColors.success : color, width: borderWidth),
                  shape: BoxShape.circle,
                ),
                child: icon != null
                    ? Icon(
                        icon,
                        size: size * 0.6,
                        color: filled ? Colors.white : (satisfied ? AppColors.success : color),
                      )
                    : null,
              ),
              Positioned(
                right: -1,
                top: -1,
                child: Container(
                  width: size * 0.6,
                  height: size * 0.6,
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Center(
                    child: Text(
                      '${provider.getConditionalBadgeText(pid) ?? threshold}',
                      style: TextStyle(
                        fontSize: size * 0.35,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
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

    return Opacity(
      opacity: opacity,
      child: child,
    );
  }

  /// Small status icon with Conditional Maybe numeric badge when applicable (for lists/modals)
  Widget _rsvpIconWithCondBadge(Practice p, ParticipationStatus ps, double size) {
    return Consumer<ParticipationProvider>(
      builder: (context, provider, _) {
        // Pending countdown: show spinner regardless of current status
        if (provider.isPendingChange(p.id)) {
          final stroke = (size * 0.15).clamp(1.5, 3.0);
          final progress = provider.pendingChangeProgress(p.id);
          return SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: stroke,
              color: AppColors.primary,
              backgroundColor: AppColors.primary.withValues(alpha: 0.15),
              value: progress,
            ),
          );
        }

        // Conditional badge applies to Maybe now
        final isCondMaybe = ps == ParticipationStatus.maybe && provider.getConditionalMaybe(p.id);
        if (!isCondMaybe) {
          return RSVPStatusDisplay(status: ps, size: size, showText: false);
        }

        final threshold = provider.getConditionalMaybeThreshold(p.id);
        if (threshold == null) return RSVPStatusDisplay(status: ps, size: size, showText: false);

        final satisfied = provider.isCurrentUserConditionalSatisfied(p);
        final badgeColor = satisfied ? AppColors.success : AppColors.maybe;
        final overrideColor = satisfied ? AppColors.success : null; // Green icon when satisfied

        final base = RSVPStatusDisplay(status: ps, size: size, showText: false, overrideColor: overrideColor);

        return Stack(
          clipBehavior: Clip.none,
          children: [
            base,
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                width: size * 0.6,
                height: size * 0.6,
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Center(
                  child: Text(
                    '${provider.getConditionalBadgeText(p.id) ?? threshold}',
                    style: TextStyle(
                      fontSize: size * 0.35,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
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

  bool _isToday(DateTime date) {
    final today = DateTime.now();
    return date.year == today.year &&
           date.month == today.month &&
           date.day == today.day;
  }



  Map<DateTime, List<FilteredPracticeStatus>> _generatePracticesForMonth(int year, int month, ParticipationProvider? participationProvider) {
    final practices = <DateTime, List<FilteredPracticeStatus>>{};
    final today = DateTime.now();

    // Generate practices for each day in the month
    for (int day = 1; day <= DateTime(year, month + 1, 0).day; day++) {
      final date = DateTime(year, month, day);

      // Check for real practices on this specific date
      final realPracticesForDay = club.upcomingPractices.where((practice) {
        final dt = practice.dateTime;
        final practiceDate = DateTime(dt.year, dt.month, dt.day);
        final isSameDay = practiceDate.year == year && practiceDate.month == month && practiceDate.day == day;
        if (!isSameDay) return false;
        // Only show past/today practices and future practices up to the announced cutoff
        final todayDate = DateTime(today.year, today.month, today.day);
        final cutoff = AppConstants.mockAnnouncedCutoff;
        final cutoffDate = DateTime(cutoff.year, cutoff.month, cutoff.day);
        return practiceDate.isBefore(todayDate) ||
               practiceDate.isAtSameMomentAs(todayDate) ||
               (practiceDate.isAfter(todayDate) && (practiceDate.isBefore(cutoffDate) || practiceDate.isAtSameMomentAs(cutoffDate)));
      }).toList();

      if (realPracticesForDay.isNotEmpty) {
        final practiceStatuses = <FilteredPracticeStatus>[];

        // Check if this date has practices that need status evaluation
        final dateHasPractices = realPracticesForDay.isNotEmpty;
        final isDateInPastOrToday = !date.isAfter(today);

        if (isDateInPastOrToday && dateHasPractices) {
          // Past practices and today's practices - use real practice data with participation status
          if (participationProvider != null) {
            // Use real practice data with participation status
            final filterProvider = Provider.of<PracticeFilterProvider>(context, listen: false);
            for (final practice in realPracticesForDay) {
              final passesLevelFilter = filterProvider.shouldShowPractice(practice);
              final participationStatus = participationProvider.getParticipationStatus(practice.id);

              // Check if practice has transitioned to attendance tracking (30+ minutes after start)
              final now = DateTime.now();
              final transitionTime = practice.dateTime.add(const Duration(minutes: 30));
              final hasTransitioned = now.isAfter(transitionTime);

              bool isAttendanceMode;
              ParticipationStatus visualStatus;
              if (hasTransitioned) {
                // Practice has been running for 30+ minutes, show attendance status when available
                switch (participationStatus) {
                  case ParticipationStatus.attended:
                  case ParticipationStatus.missed:
                    isAttendanceMode = true;
                    visualStatus = participationStatus;
                    break;
                  default:
                    // For practices that should show attendance but don't have status, show as no RSVP
                    isAttendanceMode = false;
                    visualStatus = ParticipationStatus.blank;
                    break;
                }
              } else {
                // Practice hasn't transitioned yet, show RSVP status
                isAttendanceMode = false;
                switch (participationStatus) {
                  case ParticipationStatus.yes:
                  case ParticipationStatus.maybe:
                  case ParticipationStatus.no:
                    visualStatus = participationStatus;
                    break;
                  default:
                    visualStatus = ParticipationStatus.blank;
                    break;
                }
              }

              practiceStatuses.add(FilteredPracticeStatus(
                practiceId: practice.id,
                participationStatus: visualStatus,
                isAttendanceMode: isAttendanceMode,
                passesFilter: passesLevelFilter,
              ));
            }
          }
        } else {
          // Future practices - use real practice data with participation status
          final filterProvider = Provider.of<PracticeFilterProvider>(context, listen: false);
          for (final practice in realPracticesForDay) {
            final passesLevelFilter = filterProvider.shouldShowPractice(practice);

            bool isAttendanceMode = false;
            ParticipationStatus visualStatus;
            if (participationProvider != null) {
              final participationStatus = participationProvider.getParticipationStatus(practice.id);
              switch (participationStatus) {
                case ParticipationStatus.yes:
                case ParticipationStatus.maybe:
                case ParticipationStatus.no:
                case ParticipationStatus.blank:
                  visualStatus = participationStatus;
                  break;
                case ParticipationStatus.attended:
                case ParticipationStatus.missed:
                  // For future practices, attendance states shouldn't render; treat as blank RSVP
                  visualStatus = ParticipationStatus.blank;
                  break;
              }
            } else {
              visualStatus = ParticipationStatus.blank;
            }

            practiceStatuses.add(FilteredPracticeStatus(
              practiceId: practice.id,
              participationStatus: visualStatus,
              isAttendanceMode: isAttendanceMode,
              passesFilter: passesLevelFilter,
            ));
          }
        }

        if (practiceStatuses.isNotEmpty) {
          practices[date] = practiceStatuses;
        }
      }
    }

    return practices;
  }

  void _onDayTapped(BuildContext context, DateTime date, List<FilteredPracticeStatus> practicesForDay) {
    // Only act if there are practices on this day
    if (practicesForDay.isEmpty) return;

    final practicesForDate = _getPracticesForDate(date);

    if (_selectionMode) {
      // Selection mode behavior
      final eligible = practicesForDate.where(_isPracticeSelectable).toList();
      if (eligible.isEmpty) {
        // Ignore taps on days with no eligible practices
        return;
      }
      if (eligible.length == 1) {
        _toggleSelectionForPractice(eligible.first.id);
      } else {
        _openMultiPracticePickerForDate(context, date);
      }
      return;
    }

    // Normal mode behavior (unchanged)
    if (practicesForDate.length == 1) {
      widget.onPracticeSelected?.call(practicesForDate.first);
    } else if (practicesForDate.length > 1) {
      openPracticeDetailsModal(context, practicesForDate, widget.participationProvider);
    }
  }

  void _onDayLongPressed(BuildContext context, DateTime date) {
    final eligible = _getEligiblePracticesForDate(date);
    if (eligible.isEmpty) return; // Ignore past/locked-only days

    if (eligible.length == 1) {
      _enterSelectionMode(preselectIds: [eligible.first.id]);
    } else {
      // Multiple eligible practices: open multi-practice picker; no commit until Done
      _openMultiPracticePickerForDate(context, date);
    }
  }

  void _openMultiPracticePickerForDate(BuildContext context, DateTime date) {
    final practicesForDate = _getPracticesForDate(date);
    final eligible = practicesForDate.where(_isPracticeSelectable).toList();
    final ineligible = practicesForDate.where((p) => !_isPracticeSelectable(p)).toList();

    // Initialize selection for this date: pre-check items already selected for this date when in selection mode
    final tempSelected = <String>{}
      ..addAll(_selectionMode
          ? eligible.where((p) => _selectedPracticeIds.contains(p.id)).map((p) => p.id)
          : const <String>{});
    // Per-row description expansion state within the picker
    // Mark that the per-date practice picker is open so we can close it from the top overlay
    if (mounted) {
      setState(() {
        _isPracticePickerOpen = true;
      });
    }

    final Map<String, bool> expandedDescriptions = <String, bool>{};


    PhoneAwareModalUtils.showPhoneAwareDialog(
      context: context,
      child: StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 8, 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Select practice(s)',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      )
                    ],
                  ),
                ),
                const Divider(height: 1),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    children: [
                      if (eligible.isNotEmpty)
                        ...eligible.map((p) {
                          final provider = widget.participationProvider;
                          final ps = provider?.getParticipationStatus(p.id) ?? ParticipationStatus.blank;
                          final bool isSelected = tempSelected.contains(p.id);
                          final bool isExpanded = expandedDescriptions[p.id] ?? false;
                          final String fullDesc = p.description;
                          final filterProvider = Provider.of<PracticeFilterProvider>(context, listen: false);
                          final bool passesFilter = filterProvider.shouldShowPractice(p);

                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                            margin: const EdgeInsets.symmetric(vertical: 2),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Top row: left indicator, main content, level tag, chevron is on description row
                                GestureDetector(
                                  onTap: () {
                                    setModalState(() {
                                      if (isSelected) {
                                        tempSelected.remove(p.id);
                                      } else {
                                        tempSelected.add(p.id);
                                      }
                                    });
                                  },
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      // Left indicator (compact fixed width)
                                      SizedBox(
                                        width: 28,
                                        child: Center(
                                          child: Opacity(
                                            opacity: passesFilter ? 1.0 : 0.25,
                                            child: isSelected
                                                ? Container(
                                                    width: 24,
                                                    height: 24,
                                                    decoration: const BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: Color(0xFF7C3AED),
                                                    ),
                                                  )
                                                : _rsvpIconWithCondBadge(p, ps, 24),
                                          ),

                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      // Main content
                                      Expanded(
                                        child: Text(
                                          '${TimeUtils.formatShortDayName(p.dateTime.weekday)} • ${TimeUtils.formatTimeRangeWithDuration(p.dateTime, p.duration)} • ${p.location}',
                                          style: const TextStyle(fontSize: 15, color: Color(0xFF111827)),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      if (p.tag != null && p.tag!.isNotEmpty)
                                        Container(
                                          width: 32,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(4),
                                            color: const Color(0xFF0284C7).withValues(alpha: 0.1),
                                            border: Border.all(color: const Color(0xFF0284C7), width: 1.5),
                                          ),
                                          child: Center(
                                            child: Text(
                                              truncateTag(p.tag!),
                                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF0284C7)),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                if (fullDesc.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () {
                                      setModalState(() {
                                        expandedDescriptions[p.id] = !isExpanded;
                                      });
                                    },
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(width: 28), // align under indicator
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            fullDesc,
                                            maxLines: isExpanded ? null : 1,
                                            overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                                            style: const TextStyle(fontSize: 13, color: Color(0xFF374151)),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Icon(
                                          isExpanded ? Icons.expand_less : Icons.expand_more,
                                          size: 18,
                                          color: const Color(0xFF6B7280),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        }),
                      if (ineligible.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
                          child: Text('Ineligible (past/locked)', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ),
                        ...ineligible.map((p) {
                          final provider = widget.participationProvider;
                          final ps = provider?.getParticipationStatus(p.id) ?? ParticipationStatus.blank;
                          final bool isExpanded = expandedDescriptions[p.id] ?? false;
                          final String fullDesc = p.description;
                          return Opacity(
                            opacity: 0.6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                              margin: const EdgeInsets.symmetric(vertical: 2),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      // Left indicator (status only)
                                      SizedBox(
                                        width: 28,
                                        child: Center(
                                          child: _rsvpIconWithCondBadge(p, ps, 24),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          '${TimeUtils.formatShortDayName(p.dateTime.weekday)} • ${TimeUtils.formatTimeRangeWithDuration(p.dateTime, p.duration)} • ${p.location}',
                                          style: const TextStyle(fontSize: 15, color: Color(0xFF111827)),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      if (p.tag != null && p.tag!.isNotEmpty)
                                        Container(
                                          width: 32,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(4),
                                            color: const Color(0xFF0284C7).withValues(alpha: 0.1),
                                            border: Border.all(color: const Color(0xFF0284C7), width: 1.5),
                                          ),
                                          child: Center(
                                            child: Text(
                                              truncateTag(p.tag!),
                                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF0284C7)),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  if (fullDesc.isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () {
                                        setModalState(() {
                                          expandedDescriptions[p.id] = !isExpanded;
                                        });
                                      },
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(width: 28),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              fullDesc,
                                              maxLines: isExpanded ? null : 1,
                                              overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                                              style: const TextStyle(fontSize: 13, color: Color(0xFF374151)),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Icon(
                                            isExpanded ? Icons.expand_less : Icons.expand_more,
                                            size: 18,
                                            color: const Color(0xFF6B7280),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        }),
                      ]
                    ],
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () {
                          // Commit changes: merge into existing selection when already in selection mode; otherwise enter selection mode
                          if (_selectionMode) {
                            setState(() {
                              final idsForDate = eligible.map((p) => p.id).toSet();
                              // Remove deselected items from this date
                              _selectedPracticeIds.removeWhere((id) => idsForDate.contains(id) && !tempSelected.contains(id));
                              // Add newly selected items from this date
                              _selectedPracticeIds.addAll(tempSelected);
                            });
                            _updateSelectionOverlay();
                          } else {
                            if (tempSelected.isNotEmpty) {
                              _enterSelectionMode(preselectIds: tempSelected);
                            }
                          }
                          Navigator.of(context).pop();
                        },
                        child: const Text('Done'),
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ).whenComplete(() {
      if (mounted) {
        setState(() {
          _isPracticePickerOpen = false;
        });
      }
    });
  }

  Widget _buildTopSelectionBar() {
    final selectedCount = _selectedPracticeIds.length;
    final applyEnabled = _bulkChoice != BulkChoice.none;

    final yesSelected = _bulkChoice == BulkChoice.yes;
    final noSelected = _bulkChoice == BulkChoice.no;
    final maybeSelected = _bulkChoice == BulkChoice.maybe;


    return Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary, width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header label: N practices selected
            Center(
              child: Text(
                '$selectedCount practice${selectedCount == 1 ? '' : 's'} selected',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 8),

            // Center YES/NO in leftover space, with CLEAR ALL snug on the right
            Row(
              children: [
                // Left: expanded area where the two buttons are centered as a pair
                Expanded(
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildOverlayRSVPButton(ParticipationStatus.yes, yesSelected),
                        const SizedBox(width: 24),
                        _buildOverlayRSVPButton(ParticipationStatus.maybe, maybeSelected),
                        const SizedBox(width: 24),
                        _buildOverlayRSVPButton(ParticipationStatus.no, noSelected),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Right: CLEAR ALL button with intrinsic width
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedPracticeIds.clear();
                      _bulkChoice = BulkChoice.none;
                      _bulkBringGuests = false;
                      _bulkGuestList = const PracticeGuestList();
                      _bulkConditional = false;
                      _bulkConditionalThreshold = null;
                    });
                    _updateSelectionOverlay();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                    elevation: 0,
                  ),
                  child: const Text(
                    'CLEAR ALL',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Guests row: show for Yes and Maybe
            if (_bulkChoice == BulkChoice.yes || _bulkChoice == BulkChoice.maybe)
              Row(
                children: [
                  Checkbox(
                    value: _bulkBringGuests,
                    onChanged: (v) {
                      setState(() {
                        _bulkBringGuests = v ?? false;
                      });
                      _updateSelectionOverlay();
                      if (v == true) {
                        Future.delayed(const Duration(milliseconds: 50), _showBulkGuestModal);
                      }
                    },
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  const Text('Bring guest(s)'),
                  if (_bulkBringGuests) ...[
                    const SizedBox(width: 8),
                    if (_bulkGuestList.totalGuests > 0)
                      Text('+${_bulkGuestList.totalGuests}', style: const TextStyle(color: Colors.black54)),
                    const Spacer(),
                    TextButton(
                      onPressed: _showBulkGuestModal,
                      child: const Text('Edit guests'),
                    ),
                  ],
                ],
              ),

            const SizedBox(height: 8),

            // Conditional Maybe row: only when Maybe is selected
            if (_bulkChoice == BulkChoice.maybe)
              Row(
                children: [
                  Checkbox(
                    value: _bulkConditional,
                    onChanged: (v) {
                      final newVal = v ?? false;
                      setState(() {
                        _bulkConditional = newVal;
                        if (!newVal) _bulkConditionalThreshold = null;
                      });
                      _updateSelectionOverlay();
                    },
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  const Text('Conditional Maybe'),

                ],
              ),


              if (_bulkConditional) ...[
                const SizedBox(height: 6),
                const Text(
                  'I will commit so long as at least this many (including myself) will attend',
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 16,
                    runSpacing: 8,
                    children: [6, 8, 10, 12].map<Widget>((t) {
                      final selected = _bulkConditionalThreshold == t;
                      return GestureDetector(
                        onTap: () {
                          setState(() { _bulkConditionalThreshold = t; });
                          _updateSelectionOverlay();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: selected ? AppColors.primary.withValues(alpha: 0.08) : Colors.white,
                            border: Border.all(color: selected ? AppColors.primary : const Color(0xFFE5E7EB), width: 1),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '$t+',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: selected ? AppColors.primary : const Color(0xFF374151),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],

            // Guest list below checkbox (match RSVP cards display)
            if ((_bulkChoice == BulkChoice.yes || _bulkChoice == BulkChoice.maybe) && _bulkBringGuests && _bulkGuestList.totalGuests > 0) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ..._bulkGuestList.guests.map((guest) => Container(
                          margin: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              const SizedBox(width: 16), // Indent guest names
                              Expanded(
                                child: Text(
                                  guest.name,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF374151),
                                  ),
                                ),
                              ),
                              GuestTypeTag(guestType: guest.type),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 8),

            // Bottom actions: Cancel and Apply (match Bulk RSVP style)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // If the per-date practice picker is open, close it first
                      if (_isPracticePickerOpen) {
                        Navigator.of(context).maybePop();
                      }
                      _exitSelectionMode();
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: applyEnabled
                        ? null
                        : () {
                            _showCustomToast(
                              'Please choose an RSVP option to apply',
                              AppColors.primary,
                              Icons.info_outline,
                            );
                          },
                    child: ElevatedButton(
                      onPressed: applyEnabled
                          ? () {
                              _applyBulk();
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: applyEnabled ? AppColors.primary : const Color(0xFFE5E7EB),
                        foregroundColor: applyEnabled ? Colors.white : const Color(0xFF9CA3AF),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Apply',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),





                      ),
                    ),

                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Overlay Yes/No button styled like RSVP card buttons
  Widget _buildOverlayRSVPButton(ParticipationStatus status, bool isSelected) {
    final color = status.color;
    return GestureDetector(
      onTap: () {
        // No-op if already selected (use CLEAR ALL to reset)
        final alreadySelected =
            (_bulkChoice == BulkChoice.yes && status == ParticipationStatus.yes) ||
            (_bulkChoice == BulkChoice.maybe && status == ParticipationStatus.maybe) ||
            (_bulkChoice == BulkChoice.no && status == ParticipationStatus.no);
        if (alreadySelected) {
          return;
        }
        setState(() {
          switch (status) {
            case ParticipationStatus.yes:
              _bulkChoice = BulkChoice.yes;
              break;
            case ParticipationStatus.maybe:
              _bulkChoice = BulkChoice.maybe;
              break;
            case ParticipationStatus.no:
              _bulkChoice = BulkChoice.no;
              break;
            default:
              _bulkChoice = BulkChoice.none;
          }
        });
        _updateSelectionOverlay();
      },
      child: Container(
        width: 53,
        height: 53,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(

            color: isSelected ? color : const Color(0xFFE5E7EB),
            width: isSelected ? 3 : 1,
          ),
          color: isSelected ? color.withValues(alpha: 0.06) : Colors.white,
        ),
        child: Center(
          child: Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: color,
                width: isSelected ? 4 : 2,
              ),
              color: isSelected ? color.withValues(alpha: 0.1) : Colors.transparent,
            ),
            child: Icon(
              status.overlayIcon,
              size: 25.7,
              color: color,
            ),
          ),
        ),
      ),
    );
  }

  void _showBulkGuestModal() {
    final future = PhoneAwareModalUtils.showPhoneAwareBottomSheet(
      context: context,
      child: GuestManagementModal(
        initialGuests: _bulkGuestList,
        onGuestsChanged: (updated) {
          setState(() {
            _bulkGuestList = updated;
            _bulkBringGuests = updated.totalGuests > 0;
            _updateSelectionOverlay();
          });
        },
        practiceId: 'bulk',
        dependentsOnly: false,
      ),
    );
    future.whenComplete(() {
      if (mounted && _bulkGuestList.totalGuests == 0) {
        setState(() {
          _bulkBringGuests = false;
          _updateSelectionOverlay();
        });
      }
    });
  }
  Future<bool> _applyOverlayBulkWithGuestConfirmation(ParticipationProvider provider, List<String> practiceIds, ParticipationStatus target) async {
    final decision = await showSharedRSVPConfirmationDialog(
      context: context,
      provider: provider,
      practiceId: practiceIds.first,
      target: target,
      initialMakeConditional: target == ParticipationStatus.maybe ? (_bulkConditional && _bulkConditionalThreshold != null) : false,
      initialThreshold: _bulkConditionalThreshold,
      overrideHasClubMembers: true,
      overrideHasVisitors: true,
      overrideHasDependents: true,
      overrideHasNewPlayers: true,
    );
    if (decision == null) return false;

    if (!mounted) return false;

    await applyRSVPChange(
      context: context,
      provider: provider,
      clubId: widget.club.id,
      practiceIds: practiceIds,
      target: target,
      decision: decision,
    );

    // Success toast and close selection mode
    String label;
    IconData icon;
    Color color;
    switch (target) {
      case ParticipationStatus.yes:
        label = 'Yes'; icon = Icons.check; color = AppColors.success; break;
      case ParticipationStatus.maybe:
        label = 'Maybe'; icon = Icons.help_outline; color = AppColors.maybe; break;
      default:
        label = 'No'; icon = Icons.cancel; color = AppColors.error; break;
    }
    String message;
    if (target == ParticipationStatus.maybe && _bulkConditional && _bulkConditionalThreshold != null) {
      message = 'Maybe if ${_bulkConditionalThreshold!}+ applied for ${practiceIds.length} practices';
    } else {
      message = '$label applied to ${practiceIds.length == 1 ? '1 practice' : '${practiceIds.length} practices'}';
    }
    _showTopScreenToast(message, color, icon);
    _exitSelectionMode();

    return true;
  }

  Future<void> _applyBulk() async {
    if (_bulkChoice == BulkChoice.none) {
      _showCustomToast(
        'Please choose an RSVP option to apply',
        AppColors.primary,
        Icons.info_outline,
      );
      return;
    }
    final provider = widget.participationProvider;
    if (provider == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Internal error: participation provider unavailable'), duration: Duration(seconds: 2)),
      );
      return;
    }

    final practiceIds = _selectedPracticeIds.toList();
    if (practiceIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No practices selected'), duration: Duration(seconds: 2)),
      );

      return;
    }

    // Enforce global Maybe limit (max 10). Block entire apply if exceeding.
    if (_bulkChoice == BulkChoice.maybe) {
      final currentMaybe = provider.totalMaybeCount;
      int newMaybes = 0;
      for (final id in practiceIds) {
        if (provider.getParticipationStatus(id) != ParticipationStatus.maybe) {
          newMaybes++;
        }
      }
      final projected = currentMaybe + newMaybes;
      if (projected > 10) {
        final overBy = projected - 10;
        _showTopScreenToast(
          'Only 10 Maybe RSVPs are allowed at any given time; they are just not very useful to organizers. Remove $overBy ${overBy == 1 ? 'practice' : 'practices'} to apply Maybe RSVPs.',
          const Color(0xFFF59E0B),
          Icons.help_outline,
          persistent: true,
        );
        return;
      }
    }

    final status = _bulkChoice == BulkChoice.yes
        ? ParticipationStatus.yes
        : _bulkChoice == BulkChoice.maybe
            ? ParticipationStatus.maybe
            : ParticipationStatus.no;

    // If any selected practice has guest implications when moving from YES to Maybe/No, confirm once and apply
    if (status == ParticipationStatus.maybe || status == ParticipationStatus.no) {
      bool needsConfirm = false;
      for (final id in practiceIds) {
        if (provider.needsGuestConfirmation(id, status)) { needsConfirm = true; break; }
      }
      if (needsConfirm) {
        final applied = await _applyOverlayBulkWithGuestConfirmation(provider, practiceIds, status);
        if (applied) return;
      }
    }

    // Guests handling per spec
    if (_bulkChoice == BulkChoice.maybe && _bulkConditional) {
      // Dependents only for Conditional Maybe
      if (_bulkBringGuests) {
        for (final id in practiceIds) {
          final existing = provider.getPracticeGuests(id).guests.where((g) => g.type == GuestType.dependent).toList();
          final mergedMap = <String, Guest>{};
          for (final g in existing) {
            mergedMap[g.id] = g;
          }
          for (final g in _bulkGuestList.guests.where((g) => g.type == GuestType.dependent)) {
            mergedMap[g.id] = g;
          }
          final merged = mergedMap.values.toList();
          provider.updatePracticeGuests(id, merged);
          provider.updateBringGuestState(id, merged.isNotEmpty);
        }
      }
    } else if (_bulkChoice == BulkChoice.no) {
      // For NO: clear guests and bring flag
      for (final id in practiceIds) {
        provider.updatePracticeGuests(id, const []);
        provider.updateBringGuestState(id, false);
      }
    } else if (_bulkChoice == BulkChoice.yes) {
      // Bring guest UX remains available for YES
      if (_bulkBringGuests) {
        for (final id in practiceIds) {
          final existing = provider.getPracticeGuests(id).guests;
          final mergedMap = <String, Guest>{};
          for (final g in existing) {
            mergedMap[g.id] = g;
          }
          for (final g in _bulkGuestList.guests) {
            mergedMap[g.id] = g;
          }
          final merged = mergedMap.values.toList();
          provider.updatePracticeGuests(id, merged);
          provider.updateBringGuestState(id, merged.isNotEmpty);
        }
      }
    }

    // Apply participation status in bulk
    try {
      // Apply participation status in bulk first
      await provider.bulkUpdateParticipation(
        BulkParticipationRequest(
          practiceIds: practiceIds,
          newStatus: status,
          clubId: widget.club.id,
          userId: provider.currentUserId,
        ),
      );

      // Apply Conditional Maybe settings if MAYBE selected; clear otherwise
      if (status == ParticipationStatus.maybe) {
        if (!_bulkConditional || _bulkConditionalThreshold == null) {
          _showCustomToast(
            'You must pick a threshold to apply a bulk Maybe RSVP',
            const Color(0xFFF59E0B),
            Icons.help_outline,
          );
          return;
        }
        int removedNonDependentTotal = 0;
        for (final id in practiceIds) {
          provider.setConditionalMaybe(id, true, threshold: _bulkConditionalThreshold!);
          removedNonDependentTotal += provider.consumeRemovedNonDependentGuests(id);
        }
        if (removedNonDependentTotal > 0) {
          _showTopScreenToast(
            removedNonDependentTotal == 1 ? 'Removed non-dependent guest' : 'Removed non-dependent guests',
            AppColors.info,
            Icons.person_remove_alt_1,
          );
        }
      } else {
        // For YES/NO clear conditional flag and remove stored threshold
        for (final id in practiceIds) {
          provider.clearConditionalMaybe(id);
        }
      }

      if (!mounted) return;

      IconData icon;
      Color color;
      String label;
      switch (status) {
        case ParticipationStatus.yes:
          icon = Icons.check_circle;
          color = AppColors.success;
          label = 'Yes';
          break;
        case ParticipationStatus.maybe:
          icon = Icons.help;
          color = const Color(0xFFF59E0B);
          label = 'Maybe';
          break;
        default:
          icon = Icons.cancel;
          color = AppColors.error;
          label = 'No';
      }
      String message;
      if (status == ParticipationStatus.maybe && _bulkConditional && _bulkConditionalThreshold != null) {
        final n = _bulkConditionalThreshold!;
        final x = practiceIds.length;
        message = 'Maybe if $n+ applied for $x practices';
      } else {
        final count = practiceIds.length;
        message = '$label applied to ${count == 1 ? '1 practice' : '$count practices'}';
      }
      _showTopScreenToast(message, color, icon);
      _exitSelectionMode();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to apply: $e')),
      );
    }
  }



  List<Practice> _getPracticesForDate(DateTime date) {
    final practices = <Practice>[];

    // Get real practices from club data (sourced from MockDataService)
    for (final practice in club.upcomingPractices) {
      final dt = practice.dateTime;
      final practiceDate = DateTime(dt.year, dt.month, dt.day);
      final targetDate = DateTime(date.year, date.month, date.day);

      if (practiceDate.isAtSameMomentAs(targetDate)) {
        // Only include past/today practices and future practices up to the announced cutoff
        final now = DateTime.now();
        final todayDate = DateTime(now.year, now.month, now.day);
        final cutoff = AppConstants.mockAnnouncedCutoff;
        final cutoffDate = DateTime(cutoff.year, cutoff.month, cutoff.day);
        final allowed = practiceDate.isBefore(todayDate) ||
                        practiceDate.isAtSameMomentAs(todayDate) ||
                        (practiceDate.isAfter(todayDate) && (practiceDate.isBefore(cutoffDate) || practiceDate.isAtSameMomentAs(cutoffDate)));
        if (allowed) {
          practices.add(practice);
        }
      }
    }

    // Return only real practices - no fake generation
    // MockDataService already provides all practices for the date range
    return practices;
  }

  void openPracticeDetailsModal(BuildContext context, List<Practice> practices, ParticipationProvider? participationProvider) {
    PhoneAwareModalUtils.showPhoneAwareDialog(
      context: context,
      child: Container(
        decoration: const BoxDecoration(

          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(20)), // Round all corners
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Select Practice',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            // Practice list
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: practices.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final practice = practices[index];

                  return PracticeStatusCard(
                    practice: practice,
                    mode: PracticeStatusCardMode.readOnly,
                    participationProvider: participationProvider,
                    showAttendanceStatus: true,
                    onTap: () {
                      Navigator.of(context).pop();
                      Future.microtask(() {
                        widget.onPracticeSelected?.call(practice);
                      });
                    },
                  );
                },
              ),
            ),

            // Bottom padding and Cancel button
            Padding(
              padding: const EdgeInsets.all(20),
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build the filter button for the calendar header
  Widget _buildFilterButton(BuildContext context, ParticipationProvider? participationProvider) {
    return Consumer<PracticeFilterProvider>(
      builder: (context, filterProvider, child) {
        final hasFiltersApplied = filterProvider.hasLevelFiltersApplied || filterProvider.hasLocationFiltersApplied;
        final selectedCount = filterProvider.selectedLevels.length + filterProvider.selectedLocations.length;

        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Stack(
            children: [
              IconButton(
                onPressed: widget.onShowLevelFilter,
                icon: Icon(
                  Icons.filter_alt,
                  color: Colors.white,
                  size: 20,
                ),
                padding: EdgeInsets.zero,
              ),
              // Show badge when filters are applied
              if (hasFiltersApplied)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      selectedCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  /// Show participation status legend modal
  void _showParticipationLegend() {
    PhoneAwareModalUtils.showPhoneAwareDialog(
      context: context,
      child: const ParticipationStatusLegendModal(),
    );
  }

}
