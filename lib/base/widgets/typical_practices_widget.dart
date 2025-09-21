/// Shared typical practices dropdown widget
library;

import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/models/practice.dart';
import '../../core/utils/time_utils.dart';
import 'package:url_launcher/url_launcher.dart';

class TypicalPracticesWidget extends StatefulWidget {
  final List<Practice> practices;
  final bool isExpanded;
  final VoidCallback onToggle;
  final String title;
  
  const TypicalPracticesWidget({
    super.key,
    required this.practices,
    required this.isExpanded,
    required this.onToggle,
    this.title = 'Typical weekly practices',
  });

  @override
  State<TypicalPracticesWidget> createState() => _TypicalPracticesWidgetState();
}

class _TypicalPracticesWidgetState extends State<TypicalPracticesWidget> {
  final Map<String, bool> _expandedDescriptions = {};

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
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: widget.isExpanded ? null : 0,
            child: widget.isExpanded
                ? Column(
                    children: [
                      const SizedBox(height: 8),
                      ...widget.practices.map((practice) => _buildPracticeItem(practice)),
                      const SizedBox(height: 8),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildPracticeItem(Practice practice) {
    // For typical practices, extract day name from practice ID instead of dateTime
    final dayName = _getDayNameForPractice(practice);
    final startTime = practice.dateTime;
    final endTime = practice.dateTime.add(practice.duration);
    final timeStr = TimeUtils.formatTimeRange(startTime, endTime);
    
    final isDescriptionExpanded = _expandedDescriptions[practice.id] ?? false;
    final shouldTruncateDescription = _shouldTruncateDescription(practice.description);
    
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
                  onTap: () => _launchLocationUrl(practice.mapsUrl),
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
                    practice.tag!,
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
          
          // Description (collapsible)
          if (practice.description.isNotEmpty) ...[
            const SizedBox(height: 4),
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

  String _getDayNameForPractice(Practice practice) {
    // For typical practices, extract day from practice ID
    if (practice.id.startsWith('typical-')) {
      final dayPrefix = practice.id.substring(8); // Remove 'typical-'
      switch (dayPrefix) {
        case 'monday':
          return 'Mon';
        case 'tuesday':
          return 'Tue';
        case 'wednesday':
          return 'Wed';
        case 'thursday':
          return 'Thu';
        case 'friday':
          return 'Fri';
        case 'saturday':
          return 'Sat';
        case 'sunday-morning':
        case 'sunday-afternoon':
          return 'Sun';
        default:
          return _getDayName(practice.dateTime.weekday);
      }
    }
    
    // For regular practices, use the actual date
    return _getDayName(practice.dateTime.weekday);
  }

  String _getDayName(int weekday) {
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

  bool _shouldTruncateDescription(String description) {
    return description.length > 45;
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