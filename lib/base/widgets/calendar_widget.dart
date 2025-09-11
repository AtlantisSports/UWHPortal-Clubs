/// Calendar widget for displaying practice schedules
library;

import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

class PracticeCalendar extends StatelessWidget {
  const PracticeCalendar({super.key});

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
                  'Announced Practice Calendar',
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
                  _buildMonth('September 2025', DateTime(2025, 9, 1)),
                  const SizedBox(height: 24),
                  _buildMonth('October 2025', DateTime(2025, 10, 1)),
                  const SizedBox(height: 24),
                  _buildMonth('November 2025', DateTime(2025, 11, 1)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonth(String monthName, DateTime firstDay) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Month name
        Text(
          monthName,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        
        // Days of week header
        Row(
          children: ['Su', 'M', 'T', 'W', 'Th', 'F', 'Sa']
              .map((day) => Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 8),
        
        // Calendar grid
        _buildCalendarGrid(firstDay),
      ],
    );
  }

  Widget _buildCalendarGrid(DateTime firstDay) {
    final daysInMonth = DateTime(firstDay.year, firstDay.month + 1, 0).day;
    final firstWeekday = firstDay.weekday % 7; // Convert to 0-6 where 0 is Sunday
    
    final weeks = <Widget>[];
    var currentWeek = <Widget>[];
    
    // Add empty cells for days before the first day of the month
    for (int i = 0; i < firstWeekday; i++) {
      currentWeek.add(const Expanded(child: SizedBox(height: 40)));
    }
    
    // Add days of the month
    for (int day = 1; day <= daysInMonth; day++) {
      currentWeek.add(
        Expanded(
          child: Container(
            height: 40,
            margin: const EdgeInsets.all(1),
            child: Center(
              child: Text(
                day.toString(),
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ),
      );
      
      // If we've filled a week (7 days), start a new week
      if (currentWeek.length == 7) {
        weeks.add(Row(children: currentWeek));
        currentWeek = <Widget>[];
      }
    }
    
    // Fill the last week with empty cells if needed
    while (currentWeek.length < 7) {
      currentWeek.add(const Expanded(child: SizedBox(height: 40)));
    }
    if (currentWeek.isNotEmpty) {
      weeks.add(Row(children: currentWeek));
    }
    
    return Column(children: weeks);
  }
}
