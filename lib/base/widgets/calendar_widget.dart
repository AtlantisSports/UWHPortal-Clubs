/// Calendar widget for displaying practice schedules
library;

import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/models/club.dart';

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

class PracticeCalendar extends StatelessWidget {
  final Club club;
  
  const PracticeCalendar({super.key, required this.club});

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
            child: const Row(
              children: [
                Icon(Icons.calendar_today, color: AppColors.primary, size: 20),
                SizedBox(width: 8),
                Text(
                  'Announced Practices',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          
          // Scrollable calendar content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildMonth(context, 'September 2025', 2025, 9),
                  const SizedBox(height: 24),
                  _buildMonth(context, 'October 2025', 2025, 10),
                  const SizedBox(height: 24),
                  _buildMonth(context, 'November 2025', 2025, 11),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonth(BuildContext context, String title, int year, int month) {
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
        _buildCalendarGrid(context, year, month),
      ],
    );
  }

  Widget _buildCalendarGrid(BuildContext context, int year, int month) {
    final practices = _generatePracticesForMonth(year, month);
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
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      border: Border(
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
        color = const Color(0xFF059669); // Green
        icon = Icons.check;
        filled = true; // Solid fill for past practices
        break;
      case PracticeStatus.notAttended:
        color = const Color(0xFFDC2626); // Red
        icon = Icons.close;
        filled = true; // Solid fill for past practices
        break;
      case PracticeStatus.rsvpYes:
        color = const Color(0xFF059669); // Green (matching RSVP button)
        icon = Icons.check;
        filled = false; // Outline only for future practices
        break;
      case PracticeStatus.rsvpMaybe:
        color = const Color(0xFFD97706); // Orange (matching RSVP button)
        icon = Icons.question_mark; // Match RSVP component exactly
        filled = false; // Outline only for future practices
        break;
      case PracticeStatus.rsvpNo:
        color = const Color(0xFFDC2626); // Red (matching RSVP button)
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

  Map<DateTime, List<PracticeStatus>> _generatePracticesForMonth(int year, int month) {
    final practices = <DateTime, List<PracticeStatus>>{};
    final today = DateTime.now();
    
    // Get practice schedule based on club
    List<Map<String, dynamic>> practiceSchedule = [];
    
    if (club.id == 'denver-uwh') {
      practiceSchedule = [
        {'day': DateTime.monday, 'time': '8:15 PM', 'location': 'VMAC'},
        {'day': DateTime.wednesday, 'time': '7:00 PM', 'location': 'Carmody'},
        {'day': DateTime.thursday, 'time': '8:15 PM', 'location': 'VMAC'},
        {'day': DateTime.sunday, 'time': '10:00 AM', 'location': 'VMAC'},
        {'day': DateTime.sunday, 'time': '3:00 PM', 'location': 'Carmody'},
      ];
    } else if (club.id == 'sydney-uwh') {
      practiceSchedule = [
        {'day': DateTime.friday, 'time': '7:00 PM', 'location': 'Ryde'},
      ];
    }

    // Generate practices for each day in the month
    for (int day = 1; day <= DateTime(year, month + 1, 0).day; day++) {
      final date = DateTime(year, month, day);
      final dayOfWeek = date.weekday;
      
      // Find practices for this day of week
      final dayPractices = practiceSchedule.where((p) => p['day'] == dayOfWeek).toList();
      
      if (dayPractices.isNotEmpty) {
        final practiceStatuses = <PracticeStatus>[];
        
        for (var practice in dayPractices) {
          if (date.isBefore(today)) {
            // Past practice - randomly assign attended/not attended
            final hash = date.hashCode + practice['location'].hashCode;
            practiceStatuses.add(hash % 3 == 0 
                ? PracticeStatus.notAttended 
                : PracticeStatus.attended);
          } else {
            // Future practice - randomly assign RSVP status
            final hash = date.hashCode + practice['location'].hashCode;
            final rsvpChoice = hash % 4;
            switch (rsvpChoice) {
              case 0:
                practiceStatuses.add(PracticeStatus.rsvpYes);
                break;
              case 1:
                practiceStatuses.add(PracticeStatus.rsvpMaybe);
                break;
              case 2:
                practiceStatuses.add(PracticeStatus.rsvpNo);
                break;
              default:
                practiceStatuses.add(PracticeStatus.noRsvp);
                break;
            }
          }
        }
        
        practices[date] = practiceStatuses;
      }
    }
    
    return practices;
  }
}
