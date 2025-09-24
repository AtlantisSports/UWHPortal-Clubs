/// Shared recurring practices dropdown widget
library;

import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/models/practice_pattern.dart';
import '../../core/models/practice_recurrence.dart';
import 'package:url_launcher/url_launcher.dart';
import 'rsvp_components.dart';

class RecurringPracticesWidget extends StatefulWidget {
  final List<PracticePattern> practices;
  final bool isExpanded;
  final VoidCallback onToggle;
  final String title;
  final Function(String patternId)? onPatternSelected; // Optional callback for pattern selection
  
  const RecurringPracticesWidget({
    super.key,
    required this.practices,
    required this.isExpanded,
    required this.onToggle,
    this.title = 'Recurring practices',
    this.onPatternSelected,
  });

  @override
  State<RecurringPracticesWidget> createState() => _RecurringPracticesWidgetState();
}

class _RecurringPracticesWidgetState extends State<RecurringPracticesWidget> {
  final Map<String, bool> _expandedDescriptions = {};

  @override
  void initState() {
    super.initState();
    _verifyPatternIds();
  }

  /// Verify that all practices have valid patternIds for data consistency
  void _verifyPatternIds() {
    if (widget.practices.isEmpty) return;
    
    for (final practice in widget.practices) {
      if (practice.id.isEmpty) {
        debugPrint('WARNING: Practice pattern missing ID: ${practice.title}');
      }
      // The practice.id should be the patternId (e.g., "denver-sun-1100-vmac-1")
      if (!practice.id.contains('-')) {
        debugPrint('WARNING: Practice pattern ID does not look like a patternId: ${practice.id}');
      }
    }
    
    // Log pattern IDs for debugging bulk RSVP consistency
    debugPrint('Practice pattern IDs: ${widget.practices.map((p) => p.id).toList()}');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.textSecondary.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: widget.onToggle,
            borderRadius: BorderRadius.circular(AppRadius.small),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.medium,
                vertical: AppSpacing.small,
              ),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.textSecondary.withValues(alpha: 0.3),
                ),
                borderRadius: BorderRadius.circular(AppRadius.small),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: AppSpacing.small),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  Icon(
                    widget.isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
          
          // Expanded Schedule Details
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: widget.isExpanded
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 8),
                      ..._buildGroupedPractices(),
                      const SizedBox(height: 8),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildPracticeItem(PracticePattern practice) {
    final dayName = practice.day.shortName;
    final timeStr = practice.timeRangeString;
    
    final isDescriptionExpanded = _expandedDescriptions[practice.id] ?? false;
    final shouldTruncateDescription = _shouldTruncateDescription(practice.description);
    
    // Group weekly and biweekly practices differently
    final isWeekly = practice.recurrence.type == RecurrenceType.weekly && practice.recurrence.interval == 1;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Day text (no background)
              Text(
                dayName,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 8),
              // Time range
              Text(
                timeStr,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              // Separator
              Text(
                '•',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(width: 8),
              // Location (clickable)
              Expanded(
                child: GestureDetector(
                  onTap: () => _launchLocationUrl(_generateMapsUrl(practice.address)),
                  child: Text(
                    practice.location,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF0284C7), // Blue color to indicate it's clickable
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
              // Level tag
              if (practice.tag != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0284C7).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0xFF0284C7).withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    truncateTag(practice.tag!),
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF0284C7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),

          // Recurrence information between day/time and description (if not weekly)
          if (!isWeekly) ...[
            const SizedBox(height: 4),
            Text(
              _formatNextOccurrence(practice),
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],

          // Description after the day/time/location
          if (practice.description.isNotEmpty) ...[
            const SizedBox(height: 6),
            if (shouldTruncateDescription) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      isDescriptionExpanded 
                          ? practice.description 
                          : '${practice.description.substring(0, practice.description.length.clamp(0, 45))}...',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary.withValues(alpha: 0.8),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _expandedDescriptions[practice.id] = !isDescriptionExpanded;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Icon(
                        isDescriptionExpanded ? Icons.expand_less : Icons.expand_more,
                        size: 16,
                        color: AppColors.textSecondary.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              Text(
                practice.description,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary.withValues(alpha: 0.8),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  /// Build practices grouped by recurrence type with dividers
  List<Widget> _buildGroupedPractices() {
    final widgets = <Widget>[];
    
    // Group practices by recurrence type
    final weeklyPractices = widget.practices.where((p) => 
      p.recurrence.type == RecurrenceType.weekly && p.recurrence.interval == 1
    ).toList();
    
    final nonWeeklyPractices = widget.practices.where((p) => 
      !(p.recurrence.type == RecurrenceType.weekly && p.recurrence.interval == 1)
    ).toList();
    
    // Add weekly practices with header if any exist
    if (weeklyPractices.isNotEmpty) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(left: 12, bottom: 6),
          child: Text(
            'Weekly practices',
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
      
      for (final practice in weeklyPractices) {
        widgets.add(_buildPracticeItem(practice));
      }
    }
    
    // Add divider and non-weekly practices if any exist
    if (nonWeeklyPractices.isNotEmpty) {
      // Only add divider if there are also weekly practices
      if (weeklyPractices.isNotEmpty) {
        widgets.add(const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Divider(
            height: 1,
            color: Colors.grey,
            thickness: 0.5,
          ),
        ));
      }
      
      for (final practice in nonWeeklyPractices) {
        widgets.add(_buildPracticeItem(practice));
      }
    }
    
    return widgets;
  }

  bool _shouldTruncateDescription(String description) {
    return description.length > 45;
  }

  /// Format next occurrence for display
  String _formatNextOccurrence(PracticePattern practice) {
    final nextDate = practice.getNextOccurrence();
    if (nextDate == null) {
      return practice.recurrence.description; // No next occurrence
    }
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final nextDateOnly = DateTime(nextDate.year, nextDate.month, nextDate.day);
    
    if (nextDateOnly.isAtSameMomentAs(today)) {
      return '${practice.recurrence.description} (Next is today)';
    }
    
    // Format: "Mon - Sep 29"
    final dayName = _getDayAbbreviation(nextDate.weekday);
    final monthName = _getMonthAbbreviation(nextDate.month);
    
    return '${practice.recurrence.description} (Next on $dayName - $monthName ${nextDate.day})';
  }
  
  /// Get day abbreviation
  String _getDayAbbreviation(int weekday) {
    switch (weekday) {
      case DateTime.monday: return 'Mon';
      case DateTime.tuesday: return 'Tue';
      case DateTime.wednesday: return 'Wed';
      case DateTime.thursday: return 'Thu';
      case DateTime.friday: return 'Fri';
      case DateTime.saturday: return 'Sat';
      case DateTime.sunday: return 'Sun';
      default: return '';
    }
  }
  
  /// Get month abbreviation
  String _getMonthAbbreviation(int month) {
    switch (month) {
      case 1: return 'Jan';
      case 2: return 'Feb';
      case 3: return 'Mar';
      case 4: return 'Apr';
      case 5: return 'May';
      case 6: return 'Jun';
      case 7: return 'Jul';
      case 8: return 'Aug';
      case 9: return 'Sep';
      case 10: return 'Oct';
      case 11: return 'Nov';
      case 12: return 'Dec';
      default: return '';
    }
  }

  /// Generate Google Maps URL from address
  String _generateMapsUrl(String address) {
    final encodedAddress = Uri.encodeComponent(address);
    return 'https://www.google.com/maps/search/?api=1&query=$encodedAddress';
  }

  void _launchLocationUrl(String? url) async {
    if (url != null && url.isNotEmpty) {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    }
  }
}