

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/practice.dart';
import '../../core/providers/rsvp_provider.dart';

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
      // Try plain question mark icon first (option 3)
      return Icon(
        Icons.question_mark,
        size: widget.size * 0.52, // Same size as other icons
        color: widget.status.color,
      );
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
              : Icon(
                  status == RSVPStatus.maybe
                      ? Icons.question_mark  // Plain question mark for maybe option
                      : status.overlayIcon,
                  size: status == RSVPStatus.maybe 
                      ? size * 0.7  // Smaller question mark
                      : (size * 0.6) * 1.3, // Increased by 30% (0.6 * 1.3 = 0.78)
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

/// Practice RSVP Card component with circle-based RSVP design
/// Shows practice details with circle RSVP buttons
class PracticeRSVPCard extends StatefulWidget {
  final Practice practice;
  final String? clubId; // Add clubId for RSVP updates
  final RSVPStatus? currentRSVP; // Keep for backward compatibility
  final Function(RSVPStatus)? onRSVPChanged; // Keep for backward compatibility
  final VoidCallback? onLocationTap;
  final VoidCallback? onInfoTap; // Add callback for info icon
  
  const PracticeRSVPCard({
    super.key,
    required this.practice,
    this.clubId,
    this.currentRSVP,
    this.onRSVPChanged,
    this.onLocationTap,
    this.onInfoTap,
  });
  
  @override
  State<PracticeRSVPCard> createState() => _PracticeRSVPCardState();
}

class _PracticeRSVPCardState extends State<PracticeRSVPCard> {
  
  @override
  Widget build(BuildContext context) {
    return Consumer<RSVPProvider>(
      builder: (context, rsvpProvider, child) {
        // Get current RSVP status from provider, fallback to widget parameter
        final currentRSVP = rsvpProvider.getRSVPStatus(widget.practice.id);
        
        return Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16), // Reduced top padding by 25% (16 * 0.75 = 12)
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB), // Light gray background
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with RSVP label, centered text, and info icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left: RSVP label
                  const Text(
                    'RSVP',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF374151),
                    ),
                  ),
                  // Center: Will you attend text
                  Expanded(
                    child: Center(
                      child: Text(
                        _getRSVPHeaderText(currentRSVP),
                        style: TextStyle(
                          fontSize: 17, // Increased from 12 to 17 (12 + 5)
                          fontWeight: (currentRSVP == RSVPStatus.yes || currentRSVP == RSVPStatus.no) ? FontWeight.w500 : FontWeight.normal,
                          color: _getRSVPHeaderColor(currentRSVP),
                        ),
                      ),
                    ),
                  ),
                  // Right: Info icon
                  if (widget.onInfoTap != null)
                    GestureDetector(
                      onTap: widget.onInfoTap,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        child: const Icon(
                          Icons.info_outline,
                          size: 20,
                          color: Color(0xFF0284C7),
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 24), // Placeholder to maintain alignment
                ],
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
                              _formatDate(widget.practice.dateTime),
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
                              _formatTime(widget.practice.dateTime),
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
                                onTap: widget.onLocationTap,
                                child: Text(
                                  widget.practice.location,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: widget.onLocationTap != null 
                                        ? const Color(0xFF0284C7) 
                                        : const Color(0xFF6B7280),
                                    decoration: widget.onLocationTap != null 
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
                  Row(
                    children: [
                      _buildRSVPButton(RSVPStatus.yes, currentRSVP, rsvpProvider),
                      const SizedBox(width: 8),
                      _buildRSVPButton(RSVPStatus.maybe, currentRSVP, rsvpProvider),
                      const SizedBox(width: 8),
                      _buildRSVPButton(RSVPStatus.no, currentRSVP, rsvpProvider),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildRSVPButton(RSVPStatus status, RSVPStatus currentRSVP, RSVPProvider rsvpProvider) {
    final isSelected = currentRSVP == status;
    final color = status.color;
    final fadedBg = _getFadedBackground(status);
    
    return GestureDetector(
      onTap: () async {
        // Only change if clicking a different option
        if (currentRSVP != status) {
          // Use RSVPProvider for centralized state management
          if (widget.clubId != null) {
            await rsvpProvider.updateRSVP(widget.clubId!, widget.practice.id, status);
          }
          
          // Call legacy callback if provided for backward compatibility
          widget.onRSVPChanged?.call(status);
        }
        // If already selected, do nothing (no toast, no change)
      },
      child: Container(
        width: 53, // Increased from 48 to 53 (48 * 1.1 = 52.8, rounded to 53)
        height: 53, // Increased from 48 to 53 (48 * 1.1 = 52.8, rounded to 53)
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : const Color(0xFFE5E7EB),
            width: isSelected ? 3 : 1,
          ),
          color: isSelected ? fadedBg : Colors.white,
        ),
        child: Center(
          child: Container(
            width: 35, // Increased from 32 to 35 (32 * 1.1 = 35.2, rounded to 35)
            height: 35, // Increased from 32 to 35 (32 * 1.1 = 35.2, rounded to 35)
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: color,
                width: isSelected ? 4 : 2, // Thicker border when selected
              ),
              color: isSelected ? color.withValues(alpha: 0.1) : Colors.transparent, // Light background when selected
            ),
            child: Icon(
              _getOverlayIcon(status),
              size: status == RSVPStatus.maybe 
                  ? 20.8 // Increased by 10% (18.954 * 1.1 = 20.8)
                  : 25.7, // Increased by 10% (23.4 * 1.1 = 25.7)
              color: color,
            ),
          ),
        ),
      ),
    );
  }  Color _getFadedBackground(RSVPStatus status) {
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

  String _getRSVPHeaderText(RSVPStatus? currentRSVP) {
    switch (currentRSVP) {
      case RSVPStatus.yes:
        return 'You are going';
      case RSVPStatus.no:
        return 'Not going';
      case RSVPStatus.maybe:
        return 'Will you attend?';
      case RSVPStatus.pending:
        return 'Will you attend?';
      case null:
        return 'Will you attend?';
    }
  }

  Color _getRSVPHeaderColor(RSVPStatus? currentRSVP) {
    switch (currentRSVP) {
      case RSVPStatus.yes:
        return const Color(0xFF10B981); // Green
      case RSVPStatus.no:
        return const Color(0xFFEF4444); // Red
      case RSVPStatus.maybe:
        return const Color(0xFF6B7280); // Gray (same as default)
      case RSVPStatus.pending:
        return const Color(0xFF6B7280); // Gray
      case null:
        return const Color(0xFF6B7280); // Gray
    }
  }
  
  IconData _getOverlayIcon(RSVPStatus status) {
    switch (status) {
      case RSVPStatus.yes:
        return Icons.check;
      case RSVPStatus.maybe:
        return Icons.question_mark; // Plain question mark
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

/// Selectable practice card for bulk RSVP operations
class SelectablePracticeCard extends StatelessWidget {
  final Practice practice;
  final String currentUserId;
  final bool isSelected;
  final Function(String practiceId, bool selected) onSelectionChanged;
  final VoidCallback? onTap;
  final bool showRSVPSummary;
  
  const SelectablePracticeCard({
    super.key,
    required this.practice,
    required this.currentUserId,
    required this.isSelected,
    required this.onSelectionChanged,
    this.onTap,
    this.showRSVPSummary = true,
  });
  
  @override
  Widget build(BuildContext context) {
    final userRSVPStatus = practice.getRSVPStatus(currentUserId);
    final rsvpCounts = practice.getRSVPCounts();
    final isUpcoming = practice.isUpcoming;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: isSelected ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected 
          ? const BorderSide(color: Color(0xFF0284C7), width: 2)
          : BorderSide.none,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? const Color(0xFFEFF6FF) : null,
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with checkbox, title, and date
                Row(
                  children: [
                    // Selection checkbox
                    Transform.scale(
                      scale: 1.2,
                      child: Checkbox(
                        value: isSelected,
                        onChanged: (value) {
                          onSelectionChanged(practice.id, value ?? false);
                        },
                        activeColor: const Color(0xFF0284C7),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    
                    // Practice title and date
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            practice.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatDateTime(practice.dateTime),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Current RSVP status display (small)
                    if (isUpcoming)
                      RSVPStatusDisplay(
                        status: userRSVPStatus,
                        size: 20,
                      ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Location and description
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 16,
                      color: Color(0xFF6B7280),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        practice.location,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF374151),
                        ),
                      ),
                    ),
                  ],
                ),
                
                if (practice.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    practice.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                
                // RSVP Summary
                if (showRSVPSummary) ...[
                  const SizedBox(height: 12),
                  RSVPSummary(
                    counts: rsvpCounts,
                    totalInvited: practice.maxParticipants,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  String _formatDateTime(DateTime dateTime) {
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    
    final weekday = weekdays[dateTime.weekday - 1];
    final month = months[dateTime.month - 1];
    final day = dateTime.day;
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    
    return '$weekday, $month $day • $displayHour:$minute $period';
  }
}

/// Floating bulk action panel for RSVP operations
class BulkRSVPActionPanel extends StatelessWidget {
  final int selectedCount;
  final Function(RSVPStatus) onBulkRSVP;
  final VoidCallback onClearSelection;
  final bool isLoading;
  
  const BulkRSVPActionPanel({
    super.key,
    required this.selectedCount,
    required this.onBulkRSVP,
    required this.onClearSelection,
    this.isLoading = false,
  });
  
  @override
  Widget build(BuildContext context) {
    if (selectedCount == 0) return const SizedBox.shrink();
    
    return Container(
      width: 393, // Phone boundary constraint
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Selection count and clear button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$selectedCount practice${selectedCount == 1 ? '' : 's'} selected',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
              TextButton(
                onPressed: isLoading ? null : onClearSelection,
                child: const Text(
                  'Clear',
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Bulk RSVP action buttons
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  RSVPStatus.yes,
                  'Yes',
                  Icons.check,
                  isLoading,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildActionButton(
                  RSVPStatus.maybe,
                  'Maybe',
                  Icons.question_mark,
                  isLoading,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildActionButton(
                  RSVPStatus.no,
                  'No',
                  Icons.close,
                  isLoading,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildActionButton(RSVPStatus status, String label, IconData icon, bool isLoading) {
    return ElevatedButton(
      onPressed: isLoading ? null : () => onBulkRSVP(status),
      style: ElevatedButton.styleFrom(
        backgroundColor: status.color.withValues(alpha: 0.1),
        foregroundColor: status.color,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: status.color, width: 1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: status.color.withValues(alpha: 0.1),
              border: Border.all(color: status.color, width: 2),
            ),
            child: Icon(icon, size: 18, color: status.color),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: status.color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Bulk RSVP confirmation modal
class BulkRSVPConfirmationModal extends StatelessWidget {
  final List<Practice> practices;
  final RSVPStatus newStatus;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final bool isLoading;
  
  const BulkRSVPConfirmationModal({
    super.key,
    required this.practices,
    required this.newStatus,
    required this.onConfirm,
    required this.onCancel,
    this.isLoading = false,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        maxWidth: 393, // Phone boundary constraint
        maxHeight: 450, // Reduced height to fit better
      ),
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: newStatus.color.withValues(alpha: 0.1),
                  border: Border.all(color: newStatus.color, width: 2),
                ),
                child: Icon(
                  newStatus.overlayIcon,
                  size: 20,
                  color: newStatus.color,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bulk RSVP Update',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),
                    Text(
                      'Change to "${newStatus.displayText}"',
                      style: TextStyle(
                        fontSize: 14,
                        color: newStatus.color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Practice list preview
          Text(
            'Practices to update (${practices.length}):',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF374151),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Compact scrollable practice list
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 160), // Reduced height
              child: SingleChildScrollView(
                child: Column(
                  children: practices.map((practice) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 6), // Reduced margin
                      padding: const EdgeInsets.all(10), // Reduced padding
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  practice.title,
                                  style: const TextStyle(
                                    fontSize: 13, // Reduced font size
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF111827),
                                  ),
                                ),
                                const SizedBox(height: 1), // Reduced spacing
                                Text(
                                  _formatDateTime(practice.dateTime),
                                  style: const TextStyle(
                                    fontSize: 11, // Reduced font size
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward,
                            size: 14, // Reduced icon size
                            color: newStatus.color,
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16), // Reduced spacing
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: isLoading ? null : onCancel,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10), // Reduced padding
                    side: const BorderSide(color: Color(0xFFE5E7EB)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: isLoading ? null : onConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: newStatus.color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10), // Reduced padding
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: isLoading
                    ? const SizedBox(
                        width: 18, // Reduced size
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Confirm',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  String _formatDateTime(DateTime dateTime) {
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    
    final weekday = weekdays[dateTime.weekday - 1];
    final month = months[dateTime.month - 1];
    final day = dateTime.day;
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    
    return '$weekday, $month $day • $displayHour:$minute $period';
  }
}
