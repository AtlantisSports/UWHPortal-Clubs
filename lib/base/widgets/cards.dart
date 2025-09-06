/// Custom card widget following uwhportal design patterns
library;

import 'package:flutter/material.dart';
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
  final RSVPStatus? currentRSVP;
  final List<Practice> allPractices; // Add this to show typical weekly schedule
  final Function(RSVPStatus)? onRSVPChanged;
  final VoidCallback? onTap;
  final VoidCallback? onLocationTap;
  
  const ClubCard({
    super.key,
    required this.name,
    required this.location,
    this.logoUrl,
    this.nextPractice,
    this.currentRSVP,
    this.allPractices = const [],
    this.onRSVPChanged,
    this.onTap,
    this.onLocationTap,
  });

  @override
  State<ClubCard> createState() => _ClubCardState();
}

class _ClubCardState extends State<ClubCard> {
  bool _isExpanded = false;
  
  @override
  Widget build(BuildContext context) {
    return BaseCard(
      onTap: widget.onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Club logo or placeholder
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.small),
                ),
                child: widget.logoUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.small),
                        child: Image.network(
                          widget.logoUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.group, color: AppColors.primary),
                        ),
                      )
                    : const Icon(Icons.group, color: AppColors.primary),
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
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(
                            widget.location,
                            style: AppTextStyles.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // Next Practice Card
          if (widget.nextPractice != null) ...[
            const SizedBox(height: AppSpacing.medium),
            NextPracticeCard(
              practice: widget.nextPractice!,
              currentRSVP: widget.currentRSVP,
              onRSVPChanged: widget.onRSVPChanged ?? (_) {},
              onLocationTap: widget.onLocationTap,
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
                      Icons.schedule,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: AppSpacing.small),
                    const Expanded(
                      child: Text(
                        'Typical Weekly Schedule',
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
    final timeStr = '${practice.dateTime.hour.toString().padLeft(2, '0')}:${practice.dateTime.minute.toString().padLeft(2, '0')}';
    
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.small),
      padding: const EdgeInsets.all(AppSpacing.medium),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppRadius.small),
        border: Border.all(
          color: AppColors.textSecondary.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.small,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.small),
                ),
                child: Text(
                  dayName,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.small),
              Text(
                timeStr,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.location_on,
                size: 14,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                practice.location,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          if (practice.description.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              practice.description,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
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
}
