/// RSVP icon button component with circle-based design
library;

import 'package:flutter/material.dart';
import '../../core/models/practice.dart';

/// Interactive circle-based RSVP component
/// Clean circle design with 70px size and overlay icons for status indication
class RSVPIconButton extends StatefulWidget {
  final RSVPStatus status;
  final Function(RSVPStatus) onStatusChanged;
  final double size;
  final bool enabled;
  
  const RSVPIconButton({
    super.key,
    required this.status,
    required this.onStatusChanged,
    this.size = 70.0, // Default 70px circle for optimal touch targets
    this.enabled = true,
  });
  
  @override
  State<RSVPIconButton> createState() => _RSVPIconButtonState();
}

class _RSVPIconButtonState extends State<RSVPIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  void _onTap() {
    if (!widget.enabled) return;
    
    // Play animation
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
    
    // Cycle through RSVP statuses: pending → yes → maybe → no → pending
    RSVPStatus nextStatus;
    switch (widget.status) {
      case RSVPStatus.pending:
        nextStatus = RSVPStatus.yes;
        break;
      case RSVPStatus.yes:
        nextStatus = RSVPStatus.maybe;
        break;
      case RSVPStatus.maybe:
        nextStatus = RSVPStatus.no;
        break;
      case RSVPStatus.no:
        nextStatus = RSVPStatus.pending;
        break;
    }
    
    widget.onStatusChanged(nextStatus);
  }
  
  Widget _buildStatusContent() {
    if (widget.status == RSVPStatus.pending) {
      return const SizedBox.shrink();
    }
    
    if (widget.status == RSVPStatus.maybe) {
      // Return empty container for maybe option (no icon)
      return Container();
    }
    
    // Use icons for yes/no only
    return Icon(
      widget.status.overlayIcon,
      size: widget.size * 0.52, // Increased by 30% (0.4 * 1.3 = 0.52)
      color: widget.enabled 
        ? widget.status.color 
        : Colors.grey,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTap: _onTap,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.enabled 
                  ? Colors.transparent 
                  : Colors.grey.withValues(alpha: 0.3),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Main circle container
                  Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: widget.status == RSVPStatus.maybe 
                          ? widget.status.color  // Same as other options
                          : (widget.enabled 
                            ? widget.status.color 
                            : Colors.grey),
                        width: widget.status == RSVPStatus.pending ? 2 : 4, // Thicker when selected
                      ),
                      color: widget.status == RSVPStatus.pending 
                        ? Colors.transparent 
                        : widget.status.color.withValues(alpha: 0.1), // Light background when selected
                    ),
                    child: Center(
                      child: _buildStatusContent(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Compact RSVP display showing status with smaller icon
class RSVPStatusDisplay extends StatelessWidget {
  final RSVPStatus status;
  final double size;
  
  const RSVPStatusDisplay({
    super.key,
    required this.status,
    this.size = 24.0,
  });
  
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: status.color,
              width: 2,
            ),
            color: status == RSVPStatus.pending 
              ? Colors.transparent 
              : status.color.withValues(alpha: 0.1),
          ),
          child: status == RSVPStatus.pending
              ? null
              : status == RSVPStatus.maybe
                  ? null  // No icon for maybe option
                  : Icon(
                      status.overlayIcon,
                      size: (size * 0.6) * 1.3, // Increased by 30% (0.6 * 1.3 = 0.78)
                      color: status.color,
                    ),
        ),
        const SizedBox(width: 8),
        Text(
          status.displayText,
          style: TextStyle(
            color: status.color,
            fontWeight: FontWeight.w500,
            fontSize: size * 0.6,
          ),
        ),
      ],
    );
  }
}

/// RSVP summary showing counts for each status
class RSVPSummary extends StatelessWidget {
  final Map<RSVPStatus, int> counts;
  final int totalInvited;
  
  const RSVPSummary({
    super.key,
    required this.counts,
    required this.totalInvited,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatusCount(RSVPStatus.yes, counts[RSVPStatus.yes] ?? 0),
          _buildStatusCount(RSVPStatus.maybe, counts[RSVPStatus.maybe] ?? 0),
          _buildStatusCount(RSVPStatus.no, counts[RSVPStatus.no] ?? 0),
          _buildStatusCount(RSVPStatus.pending, counts[RSVPStatus.pending] ?? 0),
        ],
      ),
    );
  }
  
  Widget _buildStatusCount(RSVPStatus status, int count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          status == RSVPStatus.pending ? Icons.star_border : Icons.star,
          color: status.color,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          count.toString(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: status.color,
          ),
        ),
        Text(
          _getStatusLabel(status),
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
  
  String _getStatusLabel(RSVPStatus status) {
    switch (status) {
      case RSVPStatus.yes:
        return 'Yes';
      case RSVPStatus.maybe:
        return 'Maybe';
      case RSVPStatus.no:
        return 'No';
      case RSVPStatus.pending:
        return 'Pending';
    }
  }
}

/// Next Practice Card component with circle-based RSVP design
/// Shows upcoming practice details with circle RSVP buttons
class NextPracticeCard extends StatelessWidget {
  final Practice practice;
  final RSVPStatus? currentRSVP;
  final Function(RSVPStatus) onRSVPChanged;
  final VoidCallback? onLocationTap;
  
  const NextPracticeCard({
    super.key,
    required this.practice,
    this.currentRSVP,
    required this.onRSVPChanged,
    this.onLocationTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB), // Light gray background
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Next Practice',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 6),
          
          // Practice details
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: Color(0xFF6B7280),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _formatDate(practice.dateTime),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF374151),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    
                    // Time
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 16,
                          color: Color(0xFF6B7280),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _formatTime(practice.dateTime),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    
                    // Location
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 16,
                          color: Color(0xFF6B7280),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: GestureDetector(
                            onTap: onLocationTap,
                            child: Text(
                              practice.location,
                              style: TextStyle(
                                fontSize: 14,
                                color: onLocationTap != null 
                                    ? const Color(0xFF0284C7) 
                                    : const Color(0xFF6B7280),
                                decoration: onLocationTap != null 
                                    ? TextDecoration.underline 
                                    : null,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // RSVP buttons
              Column(
                children: [
                  const Text(
                    'Will you attend?',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildRSVPButton(RSVPStatus.yes),
                      const SizedBox(width: 8),
                      _buildRSVPButton(RSVPStatus.maybe),
                      const SizedBox(width: 8),
                      _buildRSVPButton(RSVPStatus.no),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildRSVPButton(RSVPStatus status) {
    final isSelected = currentRSVP == status;
    final color = status.color;
    final fadedBg = _getFadedBackground(status);
    
    return GestureDetector(
      onTap: () {
        // Only change if clicking a different option
        if (currentRSVP != status) {
          onRSVPChanged(status);
        }
        // If already selected, do nothing (no toast, no change)
      },
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : const Color(0xFFE5E7EB),
            width: isSelected ? 3 : 1,
          ),
          color: isSelected ? fadedBg : Colors.white,
        ),
        child: Stack(
          children: [
            // Circle background
            Center(
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: color,
                    width: isSelected ? 4 : 2, // Thicker border when selected
                  ),
                  color: isSelected ? color.withValues(alpha: 0.1) : Colors.transparent, // Light background when selected
                ),
                child: status == RSVPStatus.maybe 
                  ? null  // No icon for maybe option
                  : Icon(
                      _getOverlayIcon(status),
                      size: 23.4, // Increased by 30% (18 * 1.3 = 23.4)
                      color: color,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Color _getFadedBackground(RSVPStatus status) {
    switch (status) {
      case RSVPStatus.yes:
        return const Color(0xFFECFDF5);
      case RSVPStatus.maybe:
        return const Color(0xFFFFFBEB);
      case RSVPStatus.no:
        return const Color(0xFFFEF2F2);
      case RSVPStatus.pending:
        return const Color(0xFFF3F4F6);
    }
  }
  
  IconData _getOverlayIcon(RSVPStatus status) {
    switch (status) {
      case RSVPStatus.yes:
        return Icons.check;
      case RSVPStatus.maybe:
        return Icons.help_outline; // Not used anymore, but kept for consistency
      case RSVPStatus.no:
        return Icons.close;
      case RSVPStatus.pending:
        return Icons.star_border;
    }
  }
  
  String _formatDate(DateTime dateTime) {
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    
    return '${weekdays[dateTime.weekday - 1]}, ${months[dateTime.month - 1]} ${dateTime.day}';
  }
  
  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    
    return '$displayHour:$minute $period';
  }
}
