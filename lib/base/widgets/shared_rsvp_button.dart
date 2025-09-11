import 'package:flutter/material.dart';
import '../../core/models/practice.dart';

/// Shared RSVP button widget that matches the design of RSVP cards
/// This function creates consistent RSVP buttons for use in modals and other places
Widget buildRSVPButton({
  required RSVPStatus status,
  required RSVPStatus selectedStatus,
  required VoidCallback onTap,
  double size = 60.0,
}) {
  final isSelected = selectedStatus == status;
  
  // Define colors and icons based on status
  late Color statusColor;
  late IconData statusIcon;
  
  switch (status) {
    case RSVPStatus.yes:
      statusColor = const Color(0xFF10B981);
      statusIcon = Icons.check;
      break;
    case RSVPStatus.maybe:
      statusColor = const Color(0xFFF59E0B);
      statusIcon = Icons.question_mark;
      break;
    case RSVPStatus.no:
      statusColor = const Color(0xFFEF4444);
      statusIcon = Icons.close;
      break;
    case RSVPStatus.pending:
      statusColor = const Color(0xFF9CA3AF);
      statusIcon = Icons.help_outline;
      break;
  }
  
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: statusColor,
          width: isSelected ? 4 : 2,
        ),
        color: isSelected 
            ? statusColor.withValues(alpha: 0.1)
            : Colors.transparent,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Inner circle (matching RSVP card design)
          Container(
            width: size * 0.6, // Inner circle is 60% of button size
            height: size * 0.6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: statusColor,
                width: isSelected ? 4 : 2,
              ),
              color: isSelected 
                  ? statusColor.withValues(alpha: 0.1)
                  : Colors.transparent,
            ),
            child: Center(
              child: Icon(
                statusIcon,
                color: statusColor,
                size: size * 0.35, // Icon size is 35% of button size
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
