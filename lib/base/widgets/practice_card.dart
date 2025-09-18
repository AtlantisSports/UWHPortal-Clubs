/// Practice card component with RSVP functionality
library;

import 'package:flutter/material.dart';
import '../../core/models/practice.dart';
import '../../core/constants/app_constants.dart';
import 'rsvp_components.dart';

/// Card displaying practice information with RSVP functionality
class PracticeCard extends StatelessWidget {
  final Practice practice;
  final String currentUserId;
  final Function(String practiceId, ParticipationStatus status)? onRSVPChanged;
  final VoidCallback? onTap;
  final bool showRSVPSummary;
  
  const PracticeCard({
    super.key,
    required this.practice,
    required this.currentUserId,
    this.onRSVPChanged,
    this.onTap,
    this.showRSVPSummary = true,
  });
  
  @override
  Widget build(BuildContext context) {
    final userRSVPStatus = practice.getParticipationStatus(currentUserId);
    final rsvpCounts = practice.getParticipationCounts();
    final isUpcoming = practice.isUpcoming;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with title and date
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          practice.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${practice.formattedDate} at ${practice.formattedTime}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Status indicator
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isUpcoming 
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.small),
                    ),
                    child: Text(
                      isUpcoming ? 'Upcoming' : 'Past',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isUpcoming ? AppColors.primary : Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Location
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${practice.location}${practice.address.isNotEmpty ? ' - ${practice.address}' : ''}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
              
              // Description if available
              if (practice.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  practice.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              
              const SizedBox(height: 16),
              
              // RSVP Section - only show for upcoming practices
              if (isUpcoming) ...[
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your RSVP:',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                          RSVPStatusDisplay(status: userRSVPStatus),
                        ],
                      ),
                    ),
                    
                    // RSVP Button
                    RSVPIconButton(
                      status: userRSVPStatus,
                      onStatusChanged: (newStatus) {
                        onRSVPChanged?.call(practice.id, newStatus);
                      },
                      size: 60, // Slightly smaller than portal-rsvp-demo for card layout
                    ),
                  ],
                ),
                
                // RSVP Summary
                if (showRSVPSummary) ...[
                  const SizedBox(height: 16),
                  RSVPSummary(
                    counts: rsvpCounts,
                    totalInvited: practice.maxParticipants,
                  ),
                ],
              ] else ...[
                // For past practices, just show the RSVP summary
                if (showRSVPSummary)
                  RSVPSummary(
                    counts: rsvpCounts,
                    totalInvited: practice.maxParticipants,
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact practice list item for dense layouts
class PracticeListItem extends StatelessWidget {
  final Practice practice;
  final String currentUserId;
  final Function(String practiceId, ParticipationStatus status)? onRSVPChanged;
  final VoidCallback? onTap;
  
  const PracticeListItem({
    super.key,
    required this.practice,
    required this.currentUserId,
    this.onRSVPChanged,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    final userRSVPStatus = practice.getParticipationStatus(currentUserId);
    final isUpcoming = practice.isUpcoming;
    
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: isUpcoming 
          ? AppColors.primary.withValues(alpha: 0.1)
          : Colors.grey.withValues(alpha: 0.1),
        child: Icon(
          Icons.sports_hockey,
          color: isUpcoming ? AppColors.primary : Colors.grey[600],
        ),
      ),
      title: Text(
        practice.title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${practice.formattedDate} at ${practice.formattedTime}'),
          Text(practice.location),
          if (isUpcoming)
            RSVPStatusDisplay(
              status: userRSVPStatus,
              size: 16,
            ),
        ],
      ),
      trailing: isUpcoming
        ? RSVPIconButton(
            status: userRSVPStatus,
            onStatusChanged: (newStatus) {
              onRSVPChanged?.call(practice.id, newStatus);
            },
            size: 40, // Small size for list item
          )
        : Icon(
            Icons.history,
            color: Colors.grey[400],
          ),
      isThreeLine: true,
    );
  }
}
