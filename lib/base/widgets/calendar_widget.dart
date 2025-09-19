/// Calendar widget for displaying practice schedules
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/models/club.dart';
import '../../core/models/practice.dart';
import '../../core/providers/participation_provider.dart';
import '../../base/widgets/phone_modal_utils.dart';
import '../../base/widgets/phone_frame.dart';
import '../../base/widgets/rsvp_components.dart';

enum PracticeStatus {
  attended,
  notAttended,
  rsvpYes,
  rsvpMaybe,
  rsvpNo,
  noRsvp,
}

class PracticeDay {
  final DateTime date;
  final List<PracticeStatus> practices;
  
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
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '+$guestCount',
                                      style: const TextStyle(
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
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

  Widget _buildPracticeIndicators(List<PracticeStatus> practices) {
    if (practices.isEmpty) return const SizedBox.shrink();

    final count = practices.length;
    final size = count == 1 ? 24.0 : count == 2 ? 16.0 : 12.0; // Doubled from 12.0, 8.0, 6.0

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

  Widget _buildSingleIndicator(PracticeStatus status, double size) {
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

    return Container(
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

  Map<DateTime, List<PracticeStatus>> _generatePracticesForMonth(int year, int month, ParticipationProvider? participationProvider) {
    final practices = <DateTime, List<PracticeStatus>>{};
    final today = DateTime.now();
    
    // Get typical practice schedule for this club
    List<Map<String, dynamic>> typicalSchedule = [];
    
    if (club.id == 'denver-uwh') {
      typicalSchedule = [
        {'day': DateTime.monday, 'time': '8:15 PM', 'location': 'VMAC'},
        {'day': DateTime.wednesday, 'time': '7:00 PM', 'location': 'Carmody'},
        {'day': DateTime.thursday, 'time': '8:15 PM', 'location': 'VMAC'},
        {'day': DateTime.sunday, 'time': '10:00 AM', 'location': 'VMAC'},
        {'day': DateTime.sunday, 'time': '3:00 PM', 'location': 'Carmody'},
      ];
    } else if (club.id == 'sydney-uwh') {
      typicalSchedule = [
        {'day': DateTime.friday, 'time': '7:00 PM', 'location': 'Ryde'},
      ];
    }

    // Generate practices for each day in the month
    for (int day = 1; day <= DateTime(year, month + 1, 0).day; day++) {
      final date = DateTime(year, month, day);
      final dayOfWeek = date.weekday;
      
      // Find typical practices for this day of week
      final typicalPracticesForDay = typicalSchedule.where((p) => p['day'] == dayOfWeek).toList();
      
      if (typicalPracticesForDay.isNotEmpty) {
        final practiceStatuses = <PracticeStatus>[];
        
        if (date.isBefore(today)) {
          // Past practices - use real practice data with participation status
          final realPracticesForDay = club.upcomingPractices.where((practice) {
            final practiceDate = DateTime(practice.dateTime.year, practice.dateTime.month, practice.dateTime.day);
            return practiceDate.year == year && practiceDate.month == month && practiceDate.day == day;
          }).toList();
          
          if (realPracticesForDay.isNotEmpty && participationProvider != null) {
            // Use real practice data with participation status
            for (final practice in realPracticesForDay) {
              final participationStatus = participationProvider.getParticipationStatus(practice.id);
              
              switch (participationStatus) {
                case ParticipationStatus.attended:
                  practiceStatuses.add(PracticeStatus.attended);
                  break;
                case ParticipationStatus.missed:
                  practiceStatuses.add(PracticeStatus.notAttended);
                  break;
                default:
                  // For past practices, fallback to mock data if no status recorded
                  final hash = practice.id.hashCode.abs();
                  practiceStatuses.add(hash % 2 == 0 
                      ? PracticeStatus.attended 
                      : PracticeStatus.notAttended);
                  break;
              }
            }
          } else {
            // Fallback to typical schedule with mock data
            for (int i = 0; i < typicalPracticesForDay.length; i++) {
              var practice = typicalPracticesForDay[i];
              final hash = date.hashCode + practice['location'].hashCode;
              practiceStatuses.add(hash % 2 == 0  // Changed from % 3 to % 2 to match repository logic
                  ? PracticeStatus.attended 
                  : PracticeStatus.notAttended);
            }
          }
        } else {
          // Future practices - check for real practices first, then fall back to typical schedule
          final realPracticesForDay = club.upcomingPractices.where((practice) {
            final practiceDate = DateTime(practice.dateTime.year, practice.dateTime.month, practice.dateTime.day);
            final isCorrectDate = practiceDate.year == year && practiceDate.month == month && practiceDate.day == day;
            
            // Apply level filtering if provider is available
            final passesLevelFilter = participationProvider?.shouldShowPractice(practice) ?? true;
            
            return isCorrectDate && passesLevelFilter;
          }).toList();
          
          if (realPracticesForDay.isNotEmpty) {
            // Use real practice data with participation status
            for (final practice in realPracticesForDay) {
              if (participationProvider != null) {
                final participationStatus = participationProvider.getParticipationStatus(practice.id);
                
                switch (participationStatus) {
                  case ParticipationStatus.yes:
                    practiceStatuses.add(PracticeStatus.rsvpYes);
                    break;
                  case ParticipationStatus.maybe:
                    practiceStatuses.add(PracticeStatus.rsvpMaybe);
                    break;
                  case ParticipationStatus.no:
                    practiceStatuses.add(PracticeStatus.rsvpNo);
                    break;
                  case ParticipationStatus.blank:
                    practiceStatuses.add(PracticeStatus.noRsvp);
                    break;
                  case ParticipationStatus.attended:
                    practiceStatuses.add(PracticeStatus.attended);
                    break;
                  case ParticipationStatus.missed:
                    practiceStatuses.add(PracticeStatus.notAttended);
                    break;
                }
              } else {
                practiceStatuses.add(PracticeStatus.noRsvp);
              }
            }
          } else {
            // No real practice data - use typical schedule with no RSVP status
            for (int i = 0; i < typicalPracticesForDay.length; i++) {
              practiceStatuses.add(PracticeStatus.noRsvp);
            }
          }
        }
        
        if (practiceStatuses.isNotEmpty) {
          practices[date] = practiceStatuses;
        }
      }
    }
    
    return practices;
  }

  void _onDayTapped(BuildContext context, DateTime date, List<PracticeStatus> practicesForDay) {
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
    
    // First, check for real practices from club data
    for (final practice in club.upcomingPractices) {
      final practiceDate = DateTime(practice.dateTime.year, practice.dateTime.month, practice.dateTime.day);
      final targetDate = DateTime(date.year, date.month, date.day);
      
      if (practiceDate.isAtSameMomentAs(targetDate)) {
        practices.add(practice);
      }
    }
    
    // If no real practices found, generate from typical schedule
    if (practices.isEmpty) {
      // Get typical practice schedule for this club
      List<Map<String, dynamic>> typicalSchedule = [];
      
      if (club.id == 'denver-uwh') {
        typicalSchedule = [
          {'day': DateTime.monday, 'time': '8:15 PM', 'location': 'VMAC'},
          {'day': DateTime.wednesday, 'time': '7:00 PM', 'location': 'Carmody'},
          {'day': DateTime.thursday, 'time': '8:15 PM', 'location': 'VMAC'},
          {'day': DateTime.sunday, 'time': '10:00 AM', 'location': 'VMAC'},
          {'day': DateTime.sunday, 'time': '3:00 PM', 'location': 'Carmody'},
        ];
      } else if (club.id == 'sydney-uwh') {
        typicalSchedule = [
          {'day': DateTime.friday, 'time': '7:00 PM', 'location': 'Ryde'},
        ];
      }
      
      // Find practices for this day of week
      final dayPractices = typicalSchedule.where((p) => p['day'] == date.weekday).toList();
      
      for (int i = 0; i < dayPractices.length; i++) {
        final practiceInfo = dayPractices[i];
        
        // Create a proper DateTime for the practice
        final practiceDateTime = _parseTimeToDateTime(date, practiceInfo['time']);
        
        practices.add(Practice(
          id: 'typical_${date.millisecondsSinceEpoch}_$i',
          clubId: club.id,
          title: _getPracticeTitle(practiceInfo['location'], practiceInfo['time']),
          description: _getPracticeDescription(practiceInfo['location'], practiceInfo['time']),
          dateTime: practiceDateTime,
          location: practiceInfo['location'],
          address: club.location, // Use club's address for now
          duration: Duration(hours: 2), // Default 2 hour duration
          maxParticipants: 20,
          participants: [],
          participationResponses: {},
          tag: _getPracticeTag(practiceInfo['location'], practiceInfo['time']), // Add tag
        ));
      }
    }
    
    return practices;
  }

  String _getPracticeTitle(String location, String time) {
    // For Sunday practices, use specific titles
    if (time.contains('AM') || time.contains('10:') || time.contains('11:') || time.contains('12:')) {
      return 'Sunday Morning';
    } else if (time.contains('3:') || time.contains('15:') || time.contains('PM')) {
      return 'Sunday Afternoon';
    } else {
      return 'Evening Practice';
    }
  }

  String _getPracticeTag(String location, String time) {
    // Assign tags based on time and location to match the repository data
    if (time.contains('AM') || time.contains('10:')) {
      return 'Intermediate'; // Sunday Morning at VMAC
    } else if (time.contains('3:') || time.contains('15:')) {
      return 'Open'; // Sunday Afternoon at Carmody
    } else if (time.contains('8:15')) {
      return 'High-Level'; // Monday/Thursday evening practices
    } else {
      return 'Open'; // Default for other practices
    }
  }

  String _getPracticeDescription(String location, String time) {
    final timeOfDay = time.contains('AM') ? 'morning' : 
                     (time.contains('10:') || time.contains('11:') || time.contains('12:') || time.contains('1:') || time.contains('2:') || time.contains('3:')) ? 'afternoon' : 'evening';
    return 'Regular $timeOfDay practice session at $location. Come ready to train and improve your underwater hockey skills!';
  }

  DateTime _parseTimeToDateTime(DateTime date, String timeString) {
    // Parse time string like "8:15 PM" or "10:00 AM"
    final parts = timeString.split(' ');
    final timePart = parts[0];
    final amPm = parts[1];
    
    final timeComponents = timePart.split(':');
    int hour = int.parse(timeComponents[0]);
    int minute = int.parse(timeComponents[1]);
    
    // Convert to 24-hour format
    if (amPm == 'PM' && hour != 12) {
      hour += 12;
    } else if (amPm == 'AM' && hour == 12) {
      hour = 0;
    }
    
    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final amPm = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final minuteStr = minute.toString().padLeft(2, '0');
    return '$displayHour:$minuteStr $amPm';
  }

  void _showPracticeSelectionModal(BuildContext context, List<Practice> practices, ParticipationProvider? participationProvider) {
    PhoneModalUtils.showPhoneFrameModal(
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
                    onPressed: () => PhoneFrameModal.close(),
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
                  
                  return PracticeAttendanceCard(
                    practice: practice,
                    participationProvider: participationProvider,
                    showAttendanceStatus: true,
                    onTap: () {
                      PhoneFrameModal.close();
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
                onPressed: () => PhoneFrameModal.close(),
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
    if (participationProvider == null) {
      return const SizedBox.shrink();
    }

    return Consumer<ParticipationProvider>(
      builder: (context, provider, child) {
        final hasFiltersApplied = provider.hasLevelFiltersApplied;
        final selectedCount = provider.selectedLevels.length;
        
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

  /// Get the participation status for a practice
  ParticipationStatus? _getParticipationStatus(Practice practice, ParticipationProvider? participationProvider) {
    if (participationProvider == null) return null;
    return participationProvider.getParticipationStatus(practice.id);
  }

  /// Build a participation status icon
  Widget? _buildParticipationStatusIcon(ParticipationStatus? status) {
    if (status == null || status == ParticipationStatus.blank) return null;
    
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: status.color,
        shape: BoxShape.circle,
      ),
      child: Icon(
        status.overlayIcon,
        color: Colors.white,
        size: 10,
      ),
    );
  }

  /// Build participation status display (matching RSVP card format)
  Widget _buildParticipationStatusDisplay(ParticipationStatus? status, Practice practice) {
    if (status == null || status == ParticipationStatus.blank) {
      return const SizedBox.shrink();
    }
    
    // For past practices, use blue attendance indicators
    if (practice.isInPastMode) {
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.primary, // System blue for both attended/missed
          shape: BoxShape.circle,
        ),
        child: Icon(
          status == ParticipationStatus.attended ? Icons.check : Icons.close,
          color: Colors.white,
          size: 18,
        ),
      );
    }
    
    // For future practices, use RSVP-style indicators
    bool isSelected = status != ParticipationStatus.blank;
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isSelected ? status.color : Colors.transparent,
        border: Border.all(
          color: status.color,
          width: 2,
        ),
        shape: BoxShape.circle,
      ),
      child: Icon(
        status.overlayIcon,
        color: isSelected ? Colors.white : status.color,
        size: 18,
      ),
    );
  }

  /// Format date for card display (matching RSVP card format)
  String _formatDateForCard(DateTime dateTime) {
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    
    return '${weekdays[dateTime.weekday - 1]}, ${months[dateTime.month - 1]} ${dateTime.day}';
  }

  /// Format time range for card display (matching RSVP card format)
  String _formatTimeRange(DateTime dateTime, Duration duration) {
    final startHour = dateTime.hour;
    final startMinute = dateTime.minute;
    final startPeriod = startHour >= 12 ? 'PM' : 'AM';
    final startDisplayHour = startHour > 12 ? startHour - 12 : (startHour == 0 ? 12 : startHour);
    
    // Calculate end time using practice duration
    final endTime = dateTime.add(duration);
    final endHour = endTime.hour;
    final endMinute = endTime.minute;
    final endPeriod = endHour >= 12 ? 'PM' : 'AM';
    final endDisplayHour = endHour > 12 ? endHour - 12 : (endHour == 0 ? 12 : endHour);
    
    // Format time without trailing zeros
    String formatTimeComponent(int hour, int minute, bool includePeriod, String period) {
      final minuteStr = minute == 0 ? '' : ':${minute.toString().padLeft(2, '0')}';
      final periodStr = includePeriod ? ' $period' : '';
      return '$hour$minuteStr$periodStr';
    }
    
    // Check if we span from morning to afternoon/evening (AM to PM)
    final spansAmPm = startPeriod != endPeriod;
    
    final startTimeStr = formatTimeComponent(startDisplayHour, startMinute, spansAmPm, startPeriod);
    final endTimeStr = formatTimeComponent(endDisplayHour, endMinute, true, endPeriod);
    
    return '$startTimeStr - $endTimeStr';
  }

  /// Build practice tag widget independently of status logic
  Widget _buildPracticeTag(Practice practice) {
    if (practice.tag == null) {
      return const SizedBox.shrink();
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Text(
        practice.tag!,
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// Show participation status legend modal
  void _showParticipationLegend() {
    PhoneModalUtils.showPhoneFrameModal(
      context: context,
      child: const ParticipationStatusLegendModal(),
    );
  }
}
