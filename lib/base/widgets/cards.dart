/// Custom card widget following uwhportal design patterns
library;

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_constants.dart';
import '../../core/models/practice.dart';
import 'rsvp_components.dart';

/// Base card component for consistent styling
class BaseCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final double elevation;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  
  const BaseCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.elevation = 2,
    this.borderRadius,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    final card = Card(
      elevation: elevation,
      color: backgroundColor ?? AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(AppRadius.medium),
      ),
      margin: margin ?? const EdgeInsets.all(AppSpacing.small),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(AppSpacing.medium),
        child: child,
      ),
    );
    
    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: borderRadius ?? BorderRadius.circular(AppRadius.medium),
        child: card,
      );
    }
    
    return card;
  }
}

/// Club card component for displaying club information with next practice RSVP
class ClubCard extends StatefulWidget {
  final String name;
  final String location;
  final String? logoUrl;
  final Practice? nextPractice;
  final ParticipationStatus? currentParticipationStatus;
  final List<Practice> allPractices; // Add this to show typical weekly schedule
  final Function(ParticipationStatus)? onParticipationChanged;
  final VoidCallback? onTap;
  final VoidCallback? onLocationTap;
  final VoidCallback? onPracticeInfoTap; // Add callback for practice info
  final String? clubId; // Add clubId for RSVP synchronization
  
  const ClubCard({
    super.key,
    required this.name,
    required this.location,
    this.logoUrl,
    this.nextPractice,
    this.currentParticipationStatus,
    this.allPractices = const [],
    this.onParticipationChanged,
    this.onTap,
    this.onLocationTap,
    this.onPracticeInfoTap,
    this.clubId,
  });

  @override
  State<ClubCard> createState() => _ClubCardState();
}

class _ClubCardState extends State<ClubCard> {
  bool _isExpanded = false;
  final Map<String, bool> _expandedDescriptions = {}; // Track which descriptions are expanded
  
  @override
  Widget build(BuildContext context) {
    return BaseCard(
      onTap: widget.onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Banner image with 1.91:1 ratio (30% of previous size: ~36px height)
              Container(
                width: 69, // 36px height * 1.91 ratio = ~69px width
                height: 36, // 30% of 120px = 36px
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.small),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.primary,
                      AppColors.primaryDark,
                    ],
                  ),
                ),
                clipBehavior: Clip.hardEdge,
                child: widget.logoUrl != null
                    ? Image.network(
                        widget.logoUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.group, color: Colors.white54, size: 20),
                      )
                    : const Icon(Icons.group, color: Colors.white54, size: 20),
              ),
              const SizedBox(width: AppSpacing.medium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.name,
                      style: AppTextStyles.headline3,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // Next Practice Section
          if (widget.nextPractice != null) ...[
            const SizedBox(height: AppSpacing.medium),
            // Next Practice Label
            Text(
              'Next Practice',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            // Practice RSVP Card
            PracticeStatusCard(
              practice: widget.nextPractice!,
              mode: PracticeStatusCardMode.clickable,
              clubId: widget.clubId,
              currentParticipationStatus: widget.currentParticipationStatus,
              onParticipationChanged: widget.onParticipationChanged ?? (_) {},
              onLocationTap: widget.onLocationTap,
              onInfoTap: widget.onPracticeInfoTap,
            ),
          ],
          
          // Typical Weekly Schedule Dropdown
          if (widget.allPractices.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.medium),
            InkWell(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
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
                    const Expanded(
                      child: Text(
                        'Typical weekly practices',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    Icon(
                      _isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),
          ],
          
          // Expanded Schedule Details
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: _isExpanded ? null : 0,
            child: _isExpanded
                ? Column(
                    children: [
                      const SizedBox(height: AppSpacing.small),
                      ...widget.allPractices.map((practice) => _buildPracticeScheduleItem(practice)),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildPracticeScheduleItem(Practice practice) {
    final dayName = _getDayName(practice.dateTime.weekday);
    final startTime = practice.dateTime;
    final endTime = practice.dateTime.add(practice.duration);
    final timeStr = '${_formatPracticeTime(startTime)}-${_formatPracticeTime(endTime)}';
    
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
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              // Practice tag
              if (practice.tag != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: Colors.blue.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    practice.tag!,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ],
          ),
          // Practice description
          if (practice.description.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    shouldTruncateDescription && !isDescriptionExpanded
                        ? _getTruncatedDescription(practice.description)
                        : practice.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary.withValues(alpha: 0.8),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                if (shouldTruncateDescription)
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
          ],
        ],
      ),
    );
  }

  /// Launch location URL in maps app or browser
  Future<void> _launchLocationUrl(String url) async {
    try {
      // For web, this will open in a new tab
      // For mobile, this will try to open in maps app
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(
          Uri.parse(url),
          mode: LaunchMode.externalApplication,
        );
      } else {
        // Fallback: show a snackbar with the address
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not open location: $url'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      // Error handling
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error opening location'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
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

  /// Determines if a description should be truncated based on visual length
  bool _shouldTruncateDescription(String description) {
    // Estimate if description would wrap to second line
    // Rough estimate: more than 40 characters likely to wrap
    return description.length > 40;
  }

  /// Returns truncated description with ellipsis
  String _getTruncatedDescription(String description) {
    if (description.length <= 40) return description;
    
    // Find a good break point (prefer word boundaries)
    String truncated = description.substring(0, 37);
    int lastSpace = truncated.lastIndexOf(' ');
    
    // If we can break at a word boundary and it's not too short, do so
    if (lastSpace > 25) {
      truncated = truncated.substring(0, lastSpace);
    }
    
    return '$truncated...';
  }

  /// Format time in 12-hour format with AM/PM (matches club detail screen format)
  String _formatPracticeTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final amPm = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final minuteStr = minute.toString().padLeft(2, '0');
    return '$displayHour:$minuteStr $amPm';
  }
}
