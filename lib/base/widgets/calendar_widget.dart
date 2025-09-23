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

enum PracticeStatus {
  attended,
  notAttended,
  rsvpYes,
  rsvpMaybe,
  rsvpNo,
  noRsvp,
}

/// Extension to provide information about whether a practice passes level filters
class FilteredPracticeStatus {
  final PracticeStatus status;
  final bool passesFilter;

  const FilteredPracticeStatus({
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
  
  const PracticeCalendar({
    super.key, 
    required this.club,
    this.onPracticeSelected,
    this.participationProvider,
    this.onShowLevelFilter,
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

  @override
  Widget build(BuildContext context) {
    return Container(
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
    // Only navigate if there are practices on this day
    if (practicesForDay.isNotEmpty) {
      // Get practice schedule to generate actual Practice objects
      final practicesForDate = _getPracticesForDate(date);
      
      if (practicesForDate.length == 1) {
        // Single practice - call callback directly
        widget.onPracticeSelected?.call(practicesForDate.first);
      } else if (practicesForDate.length > 1) {
        // Multiple practices - show selection modal
        _showPracticeSelectionModal(context, practicesForDate, widget.participationProvider);
      }
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
