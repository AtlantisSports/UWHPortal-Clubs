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

import 'dart:async';


enum PracticeStatus {
  attended,
  notAttended,
  rsvpYes,
  rsvpMaybe,
  rsvpNo,
  noRsvp,
}
enum BulkChoice { none, yes, no }


/// Extension to provide information about whether a practice passes level filters
class FilteredPracticeStatus {
  final String practiceId; // Link indicator to a specific practice
  final PracticeStatus status;
  final bool passesFilter;

  const FilteredPracticeStatus({
    required this.practiceId,
    required this.status,
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

  // Bulk controls state
  BulkChoice _bulkChoice = BulkChoice.none;
  bool _bulkBringGuests = false; // UI affordance; final bringGuest depends on merged guest list
  // Toast state (top-of-screen)
  bool _showToast = false;
  String _toastMessage = '';
  Color _toastColor = AppColors.info;
  IconData? _toastIcon;

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
                  child: _buildTopSelectionBar(),
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
    final overlay = Overlay.of(context, rootOverlay: true);
    overlay.insert(_selectionOverlay!);
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
        _buildCalendarGrid(context, year, month, participationProvider),
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
                              final guestCount = _getGuestCountForDate(date, participationProvider);
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
    // If this specific practice is selected, show solid purple with no icon
    if (_selectedPracticeIds.contains(filteredStatus.practiceId)) {
      return Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFF7C3AED), // Solid purple
        ),
      );
    }

    final status = filteredStatus.status;
    final passesFilter = filteredStatus.passesFilter;

    Color color;
    IconData? icon;
    bool filled = false;
    double borderWidth = size * 0.08; // Scale border thickness with circle size

    switch (status) {
      case PracticeStatus.attended:
        color = AppColors.primary; // System blue
        icon = Icons.check;
        filled = true; // Solid fill for past practices
        break;
      case PracticeStatus.notAttended:
        color = AppColors.primary; // System blue
        icon = Icons.close;
        filled = true; // Solid fill for past practices
        break;
      case PracticeStatus.rsvpYes:
        color = AppColors.success; // Green (matching RSVP button)
        icon = Icons.check;
        filled = false; // Outline only for future practices
        break;
      case PracticeStatus.rsvpMaybe:
        color = const Color(0xFFD97706); // Orange (matching RSVP button)
        icon = Icons.question_mark; // Match RSVP component exactly
        filled = false; // Outline only for future practices
        break;
      case PracticeStatus.rsvpNo:
        color = AppColors.error; // Red (matching RSVP button)
        icon = Icons.close;
        filled = false; // Outline only for future practices
        break;
      case PracticeStatus.noRsvp:
        color = Colors.grey[400]!;
        icon = null;
        filled = false; // Outline only, no icon
        break;
    }

    // Apply fading for practices that don't pass the filter
    final opacity = passesFilter ? 1.0 : 0.25; // 75% fading (25% opacity)

    return Opacity(
      opacity: opacity,
      child: Container(
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
      ),
    );
  }

  bool _isToday(DateTime date) {
    final today = DateTime.now();
    return date.year == today.year &&
           date.month == today.month &&
           date.day == today.day;
  }


  int _getGuestCountForDate(DateTime date, ParticipationProvider? participationProvider) {
    if (participationProvider == null) return 0;

    int maxGuestCount = 0;

    // Get all practices for this date
    final practicesForDate = _getPracticesForDate(date);

    // Find the highest guest count among all practices on this date
    for (final practice in practicesForDate) {
      final guestList = participationProvider.getPracticeGuests(practice.id);
      if (guestList.totalGuests > maxGuestCount) {
        maxGuestCount = guestList.totalGuests;
      }
    }

    return maxGuestCount;
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

              PracticeStatus status;
              if (hasTransitioned) {
                // Practice has been running for 30+ minutes, show attendance status
                switch (participationStatus) {
                  case ParticipationStatus.attended:
                    status = PracticeStatus.attended;
                    break;
                  case ParticipationStatus.missed:
                    status = PracticeStatus.notAttended;
                    break;
                  default:
                    // For practices that should show attendance but don't have status, show as no RSVP
                    status = PracticeStatus.noRsvp;
                    break;
                }
              } else {
                // Practice hasn't transitioned yet, show RSVP status
                switch (participationStatus) {
                  case ParticipationStatus.yes:
                    status = PracticeStatus.rsvpYes;
                    break;
                  case ParticipationStatus.maybe:
                    status = PracticeStatus.rsvpMaybe;
                    break;
                  case ParticipationStatus.no:
                    status = PracticeStatus.rsvpNo;
                    break;
                  default:
                    status = PracticeStatus.noRsvp;
                    break;
                }
              }

              practiceStatuses.add(FilteredPracticeStatus(
                practiceId: practice.id,
                status: status,
                passesFilter: passesLevelFilter,
              ));
            }
          }
        } else {
          // Future practices - use real practice data with participation status
          final filterProvider = Provider.of<PracticeFilterProvider>(context, listen: false);
          for (final practice in realPracticesForDay) {
            final passesLevelFilter = filterProvider.shouldShowPractice(practice);

            PracticeStatus status;
            if (participationProvider != null) {
              final participationStatus = participationProvider.getParticipationStatus(practice.id);

              switch (participationStatus) {
                case ParticipationStatus.yes:
                  status = PracticeStatus.rsvpYes;
                  break;
                case ParticipationStatus.maybe:
                  status = PracticeStatus.rsvpMaybe;
                  break;
                case ParticipationStatus.no:
                  status = PracticeStatus.rsvpNo;
                  break;
                case ParticipationStatus.blank:
                  status = PracticeStatus.noRsvp;
                  break;
                case ParticipationStatus.attended:
                  status = PracticeStatus.attended;
                  break;
                case ParticipationStatus.missed:
                  status = PracticeStatus.notAttended;
                  break;
              }
            } else {
              status = PracticeStatus.noRsvp;
            }

            practiceStatuses.add(FilteredPracticeStatus(
              practiceId: practice.id,
              status: status,
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
      _showPracticeSelectionModal(context, practicesForDate, widget.participationProvider);
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

    // Load with no option selected initially
    final tempSelected = <String>{};
    // Per-row description expansion state within the picker
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
                        'Select practices',
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
                          final String firstLine = fullDesc.split('\n').first;
                          final String preview = firstLine.length > 120 ? '${firstLine.substring(0, 120)}…' : firstLine;
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
                                          child: isSelected
                                              ? Container(
                                                  width: 24,
                                                  height: 24,
                                                  decoration: const BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Color(0xFF7C3AED),
                                                  ),
                                                )
                                              : RSVPStatusDisplay(status: ps, size: 24, showText: false),
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
                                            isExpanded ? fullDesc : preview,
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
                          final String firstLine = fullDesc.split('\n').first;
                          final String preview = firstLine.length > 120 ? '${firstLine.substring(0, 120)}…' : firstLine;
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
                                          child: RSVPStatusDisplay(status: ps, size: 24, showText: false),
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
                                              isExpanded ? fullDesc : preview,
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
                          // Commit selection to calendar selection mode
                          _enterSelectionMode(preselectIds: tempSelected);
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
    );
  }

  Widget _buildTopSelectionBar() {
    final selectedCount = _selectedPracticeIds.length;
    final applyEnabled = _bulkChoice != BulkChoice.none;

    final yesSelected = _bulkChoice == BulkChoice.yes;
    final noSelected = _bulkChoice == BulkChoice.no;

    return Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
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

            // Yes / No / CLEAR ALL row (equally spaced and centered)
            Row(
              children: [
                Expanded(
                  child: Center(
                    child: _buildOverlayRSVPButton(ParticipationStatus.yes, yesSelected),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: _buildOverlayRSVPButton(ParticipationStatus.no, noSelected),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _selectedPracticeIds.clear();
                          _bulkChoice = BulkChoice.none;
                          _bulkBringGuests = false;
                          _bulkGuestList = const PracticeGuestList();
                        });
                        _updateSelectionOverlay();
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFE5E7EB)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                      ),
                      child: const Text(
                        'CLEAR ALL',
                        style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Guests row: only when Yes is selected
            if (_bulkChoice == BulkChoice.yes)
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

            // Bottom actions: Cancel and Apply (match Bulk RSVP style)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _exitSelectionMode,
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
                              'Choose Yes or No to apply RSVP',
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
        if ((_bulkChoice == BulkChoice.yes && status == ParticipationStatus.yes) ||
            (_bulkChoice == BulkChoice.no && status == ParticipationStatus.no)) {
          return;
        }
        setState(() {
          _bulkChoice = status == ParticipationStatus.yes ? BulkChoice.yes : BulkChoice.no;
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
    PhoneAwareModalUtils.showPhoneAwareDialog(
      context: context,
      child: GuestManagementModal(
        initialGuests: _bulkGuestList,
        onGuestsChanged: (updated) {
          setState(() {
            _bulkGuestList = updated;
            // Keep checkbox state as-is; bringGuest on apply depends on merged list non-empty
          });
        },
        practiceId: 'bulk',
      ),
    );
  }
  Future<void> _applyBulk() async {
    if (_bulkChoice == BulkChoice.none) {
      _showCustomToast(
        'Choose Yes or No to apply RSVP',
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

    final status = _bulkChoice == BulkChoice.yes ? ParticipationStatus.yes : ParticipationStatus.no;

    // Guests handling per spec
    if (_bulkChoice == BulkChoice.yes) {
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
      // If bring OFF, leave existing guests/bringGuest unchanged
    } else {
      // For NO: clear guests and bring flag
      for (final id in practiceIds) {
        provider.updatePracticeGuests(id, const []);
        provider.updateBringGuestState(id, false);
      }
    }

    // Apply participation status in bulk
    try {
      await provider.bulkUpdateParticipation(
        BulkParticipationRequest(
          practiceIds: practiceIds,
          newStatus: status,
          clubId: widget.club.id,
          userId: provider.currentUserId,
        ),
      );

      if (!mounted) return;


      _showCustomToast(
        '${status == ParticipationStatus.yes ? 'Yes' : 'No'} applied to ${practiceIds.length} practice(s)',
        status == ParticipationStatus.yes ? AppColors.success : AppColors.error,
        status == ParticipationStatus.yes ? Icons.check_circle : Icons.cancel,
      );
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

  void _showPracticeSelectionModal(BuildContext context, List<Practice> practices, ParticipationProvider? participationProvider) {
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
