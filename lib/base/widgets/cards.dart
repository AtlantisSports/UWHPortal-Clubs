/// Custom card widget following uwhportal design patterns
library;

import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/models/practice.dart';
import 'rsvp_components.dart';
import 'typical_practices_widget.dart';

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
            TypicalPracticesWidget(
              practices: widget.allPractices,
              isExpanded: _isExpanded,
              onToggle: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
            ),
          ],
        ],
      ),
    );
  }
}
