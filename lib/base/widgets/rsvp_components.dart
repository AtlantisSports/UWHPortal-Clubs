

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/practice.dart';
import '../../core/models/guest.dart';
import '../../core/providers/participation_provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/time_utils.dart';
import 'guest_management_modal.dart';
import 'phone_aware_modal_utils.dart';

/// Interactive circle-based RSVP component
/// Clean circle design with 70px size and overlay icons for status indication
class RSVPIconButton extends StatefulWidget {
  final ParticipationStatus status;
  final Function(ParticipationStatus) onStatusChanged;
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
    
    // Cycle through participation statuses: blank → yes → maybe → no → blank
    ParticipationStatus nextStatus;
    switch (widget.status) {
      case ParticipationStatus.blank:
        nextStatus = ParticipationStatus.yes;
        break;
      case ParticipationStatus.yes:
        nextStatus = ParticipationStatus.maybe;
        break;
      case ParticipationStatus.maybe:
        nextStatus = ParticipationStatus.no;
        break;
      case ParticipationStatus.no:
        nextStatus = ParticipationStatus.blank;
        break;
      case ParticipationStatus.attended:
      case ParticipationStatus.missed:
        // Admin-only states - don't allow cycling from user interface
        nextStatus = widget.status;
        break;
    }
    
    widget.onStatusChanged(nextStatus);
  }
  
  Widget _buildStatusContent() {
    if (widget.status == ParticipationStatus.blank) {
      return const SizedBox.shrink();
    }
    
    if (widget.status == ParticipationStatus.maybe) {
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
                        color: widget.status == ParticipationStatus.maybe 
                          ? widget.status.color  // Same as other options
                          : (widget.enabled 
                            ? widget.status.color 
                            : Colors.grey),
                        width: widget.status == ParticipationStatus.blank ? 2 : 4, // Thicker when selected
                      ),
                      color: widget.status == ParticipationStatus.blank 
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
  final ParticipationStatus status;
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
            color: status == ParticipationStatus.blank 
              ? Colors.transparent 
              : status.color.withValues(alpha: 0.1),
          ),
          child: status == ParticipationStatus.blank
              ? null
              : Icon(
                  status == ParticipationStatus.maybe
                      ? Icons.question_mark  // Plain question mark for maybe option
                      : status.overlayIcon,
                  size: status == ParticipationStatus.maybe 
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
  final Map<ParticipationStatus, int> counts;
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
          _buildStatusCount(ParticipationStatus.yes, counts[ParticipationStatus.yes] ?? 0),
          _buildStatusCount(ParticipationStatus.maybe, counts[ParticipationStatus.maybe] ?? 0),
          _buildStatusCount(ParticipationStatus.no, counts[ParticipationStatus.no] ?? 0),
          _buildStatusCount(ParticipationStatus.blank, counts[ParticipationStatus.blank] ?? 0),
        ],
      ),
    );
  }
  
  Widget _buildStatusCount(ParticipationStatus status, int count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          status == ParticipationStatus.blank ? Icons.star_border : Icons.star,
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
  
  String _getStatusLabel(ParticipationStatus status) {
    switch (status) {
      case ParticipationStatus.yes:
        return 'Yes';
      case ParticipationStatus.maybe:
        return 'Maybe';
      case ParticipationStatus.no:
        return 'No';
      case ParticipationStatus.blank:
        return 'Pending';
      case ParticipationStatus.attended:
        return 'Attended';
      case ParticipationStatus.missed:
        return 'Missed';
    }
  }
}

/// Practice Status Card component with two modes: CLICKABLE and READ_ONLY
/// CLICKABLE mode: Interactive RSVP for future practices (replaces PracticeRSVPCard)
/// READ_ONLY mode: Status display for past practices and modals (replaces PracticeAttendanceCard)
enum PracticeStatusCardMode { clickable, readOnly }

class PracticeStatusCard extends StatefulWidget {
  final Practice practice;
  final PracticeStatusCardMode mode;
  final String? clubId; // Add clubId for RSVP updates
  final ParticipationStatus? currentParticipationStatus; // Optional override of participation status
  final Function(ParticipationStatus)? onParticipationChanged; // Callback when participation changes
  final VoidCallback? onLocationTap;
  final VoidCallback? onInfoTap; // Add callback for info icon (only used in CLICKABLE mode)
  final VoidCallback? onTap; // For READ_ONLY mode card tap
  final ParticipationProvider? participationProvider; // For READ_ONLY mode
  final bool showAttendanceStatus; // For READ_ONLY mode
  
  const PracticeStatusCard({
    super.key,
    required this.practice,
    required this.mode,
    this.clubId,
    this.currentParticipationStatus,
    this.onParticipationChanged,
    this.onLocationTap,
    this.onInfoTap,
    this.onTap,
    this.participationProvider,
    this.showAttendanceStatus = true,
  });
  
  @override
  State<PracticeStatusCard> createState() => _PracticeStatusCardState();
}

class _PracticeStatusCardState extends State<PracticeStatusCard> {
  @override
  Widget build(BuildContext context) {
    if (widget.mode == PracticeStatusCardMode.readOnly) {
      // Check if practice is in the past
      final isPastEvent = widget.practice.dateTime.isBefore(DateTime.now());
      if (isPastEvent) {
        return _buildReadOnlyPastCard();
      } else {
        return _buildReadOnlyFutureCard();
      }
    } else {
      return _buildClickableCard();
    }
  }

  Widget _buildReadOnlyFutureCard() {
    final userStatus = widget.participationProvider?.getParticipationStatus(widget.practice.id);
    
    Widget cardContent = Container(
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 16), // Same padding as RSVP card
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB), // Same light gray background as RSVP card
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with status text and practice tag - same layout as RSVP card
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left: Status label (no info icon in read-only mode)
              const Text(
                'RSVP',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF374151),
                ),
              ),
              // Center: Status text
              Expanded(
                child: Center(
                  child: Text(
                    _getParticipationHeaderText(userStatus),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: (userStatus == ParticipationStatus.yes || userStatus == ParticipationStatus.no) ? FontWeight.w500 : FontWeight.normal,
                      color: _getParticipationHeaderColor(userStatus),
                    ),
                  ),
                ),
              ),
              // Right: Practice tag
              if (widget.practice.tag != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0284C7).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF0284C7).withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    widget.practice.tag!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF0284C7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              else
                const SizedBox(width: 24), // Placeholder to maintain alignment
            ],
          ),
          const SizedBox(height: 6),
          
          // Practice details - same layout as RSVP card
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
                        Flexible(
                          child: Text(
                            _formatTime(widget.practice.dateTime),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                            ),
                            overflow: TextOverflow.ellipsis,
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
                          child: MouseRegion(
                            cursor: widget.onLocationTap != null 
                                ? SystemMouseCursors.click 
                                : SystemMouseCursors.basic,
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
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Status display (single disabled button showing current status)
              if (widget.showAttendanceStatus && userStatus != null)
                _buildReadOnlyStatusDisplay(userStatus),
            ],
          ),
          
          // Guest section for read-only mode (if user is going and has guests)
          if (userStatus == ParticipationStatus.yes) ...[
            const SizedBox(height: 12),
            _buildReadOnlyGuestSection(),
          ],
        ],
      ),
    );

    // Make the entire card clickable if onTap is provided
    if (widget.onTap != null) {
      return InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(8),
        child: cardContent,
      );
    }
    
    return cardContent;
  }

  Widget _buildReadOnlyPastCard() {
    final userStatus = widget.participationProvider?.getParticipationStatus(widget.practice.id);
    
    Widget cardContent = Container(
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 16), // Same padding as RSVP card
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB), // Same light gray background as RSVP card
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with status text and practice tag - NO RSVP LABEL for past events
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Center: Status text (no left label for past events)
              Expanded(
                child: Center(
                  child: Text(
                    _getParticipationHeaderText(userStatus),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: (userStatus == ParticipationStatus.yes || userStatus == ParticipationStatus.no) ? FontWeight.w500 : FontWeight.normal,
                      color: _getParticipationHeaderColor(userStatus),
                    ),
                  ),
                ),
              ),
              // Right: Practice tag
              if (widget.practice.tag != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0284C7).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF0284C7).withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    widget.practice.tag!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF0284C7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              else
                const SizedBox(width: 24), // Placeholder to maintain alignment
            ],
          ),
          const SizedBox(height: 6),
          
          // Practice details - same layout as RSVP card
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
                        Flexible(
                          child: Text(
                            _formatTime(widget.practice.dateTime),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                            ),
                            overflow: TextOverflow.ellipsis,
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
                          child: MouseRegion(
                            cursor: widget.onLocationTap != null 
                                ? SystemMouseCursors.click 
                                : SystemMouseCursors.basic,
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
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Status display (single disabled button showing current status)
              if (widget.showAttendanceStatus && userStatus != null)
                _buildReadOnlyStatusDisplay(userStatus),
            ],
          ),
          
          // Guest section for read-only mode (show if attended or going and guests exist)
          if (userStatus == ParticipationStatus.yes || userStatus == ParticipationStatus.attended) ...[
            const SizedBox(height: 12),
            _buildReadOnlyGuestSection(),
          ],
        ],
      ),
    );

    // Make the entire card clickable if onTap is provided
    if (widget.onTap != null) {
      return InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(8),
        child: cardContent,
      );
    }
    
    return cardContent;
  }

  Widget _buildClickableCard() {
    return Consumer<ParticipationProvider>(
      builder: (context, participationProvider, child) {
        // Get current participation status from provider, fallback to widget parameter
        final currentParticipationStatus = participationProvider.getParticipationStatus(widget.practice.id);
        // Get guest data from provider
        final guestList = participationProvider.getPracticeGuests(widget.practice.id);
        final bringGuest = participationProvider.getBringGuestState(widget.practice.id);
        
        return Container(
          padding: const EdgeInsets.fromLTRB(8, 12, 8, 16), // Reduced left/right padding by 50% (16 -> 8)
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB), // Light gray background
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with RSVP label, centered text, and practice tag
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left: RSVP label with info icon
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'RSVP',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF374151),
                        ),
                      ),
                      if (widget.onInfoTap != null) ...[
                        const SizedBox(width: 6),
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: widget.onInfoTap,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              child: const Icon(
                                Icons.info_outline,
                                size: 20,
                                color: Color(0xFF0284C7),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  // Center: Participation status text
                  Expanded(
                    child: Center(
                      child: Text(
                        _getParticipationHeaderText(currentParticipationStatus),
                        style: TextStyle(
                          fontSize: 15, // Reduced from 17 to 15
                          fontWeight: (currentParticipationStatus == ParticipationStatus.yes || currentParticipationStatus == ParticipationStatus.no) ? FontWeight.w500 : FontWeight.normal,
                          color: _getParticipationHeaderColor(currentParticipationStatus),
                        ),
                      ),
                    ),
                  ),
                  // Right: Practice tag
                  if (widget.practice.tag != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0284C7).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF0284C7).withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        widget.practice.tag!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF0284C7),
                          fontWeight: FontWeight.w500,
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
                            Flexible(
                              child: Text(
                                _formatTime(widget.practice.dateTime),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF6B7280),
                                ),
                                overflow: TextOverflow.ellipsis,
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
                              child: MouseRegion(
                                cursor: widget.onLocationTap != null 
                                    ? SystemMouseCursors.click 
                                    : SystemMouseCursors.basic,
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
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // RSVP buttons
                  Row(
                    children: [
                      _buildParticipationButton(ParticipationStatus.yes, currentParticipationStatus, participationProvider),
                      const SizedBox(width: 8),
                      _buildParticipationButton(ParticipationStatus.maybe, currentParticipationStatus, participationProvider),
                      const SizedBox(width: 8),
                      _buildParticipationButton(ParticipationStatus.no, currentParticipationStatus, participationProvider),
                    ],
                  ),
                ],
              ),
              
              // Bring a guest section (only show if user selected "Yes")
              if (currentParticipationStatus == ParticipationStatus.yes) ...[
                const SizedBox(height: 12),
                _buildGuestSection(participationProvider, bringGuest, guestList),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildReadOnlyStatusDisplay(ParticipationStatus status) {
    // Use exact same layout as RSVP buttons but with system blue color scheme
    final isBlank = status == ParticipationStatus.blank;
    final isAttendanceStatus = status == ParticipationStatus.attended || status == ParticipationStatus.missed;
    
    return Container(
      width: 53, // Same as RSVP buttons
      height: 53, // Same as RSVP buttons
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isBlank ? Colors.grey.withValues(alpha: 0.3) : AppColors.primary.withValues(alpha: 0.3),
          width: 1,
        ),
        color: isBlank ? Colors.grey.withValues(alpha: 0.1) : AppColors.primary.withValues(alpha: 0.1),
      ),
      child: Center(
        child: isAttendanceStatus 
          ? Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary, // System blue background
              ),
              child: Icon(
                status == ParticipationStatus.attended ? Icons.check : Icons.close,
                size: 21, // 35 * 0.6
                color: Colors.white, // White icon
              ),
            )
          : Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isBlank ? Colors.transparent : AppColors.primary.withValues(alpha: 0.1),
                border: Border.all(
                  color: isBlank ? Colors.grey : AppColors.primary,
                  width: 2.8,
                ),
              ),
              child: isBlank 
                ? null
                : Icon(
                    _getOverlayIcon(status),
                    size: 21,
                    color: AppColors.primary,
                  ),
            ),
      ),
    );
  }

  Widget _buildReadOnlyGuestSection() {
    if (widget.participationProvider == null) return const SizedBox.shrink();
    
    final guestList = widget.participationProvider!.getPracticeGuests(widget.practice.id);

    // For read-only past practices, show guests if they exist regardless of bringGuest state
    // This displays historical data - what actually happened
    if (guestList.totalGuests == 0) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Read-only guest display (no checkbox, no edit button)
          Row(
            children: [
              Icon(
                Icons.group,
                size: 16,
                color: const Color(0xFF0284C7),
              ),
              const SizedBox(width: 8),
              const Text(
                'Guests',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF374151),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '+${guestList.totalGuests}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),

          // Guest list
          if (guestList.guests.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...guestList.guests.map((guest) => Container(
              margin: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  const SizedBox(width: 16), // Indent guest names
                  Expanded(
                    child: Text(
                      guest.name,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ),
                  GuestTypeTag(guestType: guest.type),
                ],
              ),
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildGuestSection(ParticipationProvider participationProvider, bool bringGuest, PracticeGuestList guestList) {
    return Container(
      padding: const EdgeInsets.all(6), // Reduced from 12 to 6 (50% reduction)
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Checkbox, label, and Edit guests pill button
          Row(
            children: [
              Checkbox(
                value: bringGuest,
                onChanged: (value) {
                  final newBringGuest = value ?? false;
                  participationProvider.updateBringGuestState(widget.practice.id, newBringGuest);
                  
                  if (!newBringGuest) {
                    // Clear guests if not bringing any
                    participationProvider.updatePracticeGuests(widget.practice.id, []);
                  } else {
                    // Automatically open guest modal when checkbox is checked
                    // Use a small delay to ensure the UI state is updated first
                    Future.delayed(const Duration(milliseconds: 100), () {
                      _showGuestManagementModal(participationProvider, guestList);
                    });
                  }
                },
                activeColor: const Color(0xFF0284C7),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              const SizedBox(width: 4),
              const Text(
                'Bring guest(s)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF374151),
                ),
              ),
              if (guestList.totalGuests > 0) ...[
                const SizedBox(width: 6),
                Text(
                  '+${guestList.totalGuests}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
              if (bringGuest) ...[
                const Spacer(), // Push the button to the right
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => _showGuestManagementModal(participationProvider, guestList),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0284C7),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        'Edit guests',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          
          // Guest list display (only show if guests exist)
          if (bringGuest && guestList.totalGuests > 0) ...[
            const SizedBox(height: 8),
            ...guestList.guests.map((guest) => Container(
              margin: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  const SizedBox(width: 16), // Indent guest names
                  Expanded(
                    child: Text(
                      guest.name,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ),
                  GuestTypeTag(guestType: guest.type),
                ],
              ),
            )),
          ],
        ],
      ),
    );
  }
  
  void _showGuestManagementModal(ParticipationProvider participationProvider, PracticeGuestList guestList) {
    PhoneAwareModalUtils.showPhoneAwareDialog(
      context: context,
      child: GuestManagementModal(
        initialGuests: guestList,
        onGuestsChanged: (newGuestList) {
          // Update provider with new guest data
          participationProvider.updatePracticeGuests(widget.practice.id, newGuestList.guests);
        },
        practiceId: widget.practice.id,
      ),
    );
  }
  
  Widget _buildParticipationButton(ParticipationStatus status, ParticipationStatus currentParticipationStatus, ParticipationProvider participationProvider) {
    final isSelected = currentParticipationStatus == status;
    final color = status.color;
    final fadedBg = _getFadedBackground(status);
    
    return GestureDetector(
      onTap: () async {
        // Only change if clicking a different option
        if (currentParticipationStatus != status) {
          try {
            // Use ParticipationProvider for centralized state management
            if (widget.clubId != null) {
              await participationProvider.updateParticipationStatus(widget.clubId!, widget.practice.id, status);
            }
            
            // Call legacy callback if provided for backward compatibility
            widget.onParticipationChanged?.call(status);
          } catch (error) {
            // Show error toast if RSVP update fails
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Failed to update RSVP. Please try again.'),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 3),
                ),
              );
            }
          }
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
              size: status == ParticipationStatus.maybe 
                  ? 20.8 // Increased by 10% (18.954 * 1.1 = 20.8)
                  : 25.7, // Increased by 10% (23.4 * 1.1 = 25.7)
              color: color,
            ),
          ),
        ),
      ),
    );
  }  Color _getFadedBackground(ParticipationStatus status) {
    switch (status) {
      case ParticipationStatus.yes:
        return const Color(0xFFECFDF5);
      case ParticipationStatus.maybe:
        return const Color(0xFFFFFBEB);
      case ParticipationStatus.no:
        return const Color(0xFFFEF2F2);
      case ParticipationStatus.blank:
        return const Color(0xFFF3F4F6);
      case ParticipationStatus.attended:
        return const Color(0xFFECFDF5);
      case ParticipationStatus.missed:
        return const Color(0xFFFEF2F2);
    }
  }

  String _getParticipationHeaderText(ParticipationStatus? currentParticipationStatus) {
    switch (currentParticipationStatus) {
      case ParticipationStatus.yes:
        return 'You are going';
      case ParticipationStatus.no:
        return 'Not going';
      case ParticipationStatus.maybe:
        return 'Might attend';
      case ParticipationStatus.blank:
        return 'Pending';
      case ParticipationStatus.attended:
        return 'You attended';
      case ParticipationStatus.missed:
        return 'You did not attend';
      case null:
        return 'Might attend';
    }
  }

  Color _getParticipationHeaderColor(ParticipationStatus? currentParticipationStatus) {
    switch (currentParticipationStatus) {
      case ParticipationStatus.yes:
        return AppColors.success; // Green
      case ParticipationStatus.no:
        return AppColors.error; // Red
      case ParticipationStatus.maybe:
        return const Color(0xFFF59E0B); // Yellow (same as status indicator)
      case ParticipationStatus.blank:
        return const Color(0xFF6B7280); // Gray
      case ParticipationStatus.attended:
        return AppColors.primary; // System blue
      case ParticipationStatus.missed:
        return AppColors.primary; // System blue
      case null:
        return const Color(0xFFF59E0B); // Yellow (for default case)
    }
  }
  
  IconData _getOverlayIcon(ParticipationStatus status) {
    switch (status) {
      case ParticipationStatus.yes:
        return Icons.check;
      case ParticipationStatus.maybe:
        return Icons.question_mark; // Plain question mark
      case ParticipationStatus.no:
        return Icons.close;
      case ParticipationStatus.blank:
        return Icons.star_border;
      case ParticipationStatus.attended:
        return Icons.check_circle;
      case ParticipationStatus.missed:
        return Icons.cancel;
    }
  }
  
  String _formatDate(DateTime dateTime) {
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    
    return '${weekdays[dateTime.weekday - 1]}, ${months[dateTime.month - 1]} ${dateTime.day}';
  }
  
  String _formatTime(DateTime dateTime) {
    final startHour = dateTime.hour;
    final startMinute = dateTime.minute;
    final startPeriod = startHour >= 12 ? 'PM' : 'AM';
    final startDisplayHour = startHour > 12 ? startHour - 12 : (startHour == 0 ? 12 : startHour);
    
    // Calculate end time using practice duration
    final endTime = dateTime.add(widget.practice.duration);
    final endHour = endTime.hour;
    final endMinute = endTime.minute;
    final endPeriod = endHour >= 12 ? 'PM' : 'AM';
    final endDisplayHour = endHour > 12 ? endHour - 12 : (endHour == 0 ? 12 : endHour);
    
    // Format time without trailing zeros
    String formatTimeComponent(int hour, int minute, bool includePeriod, String period) {
      final minuteStr = minute == 0 ? '' : ':${minute.toString().padLeft(2, '0')}';
      final periodStr = includePeriod ? ' $period' : '';
      return '$hour$minuteStr$periodStr';
    }
    
    // Check if we span from morning to afternoon/evening (AM to PM)
    final spansAmPm = startPeriod != endPeriod;
    
    final startTimeStr = formatTimeComponent(startDisplayHour, startMinute, spansAmPm, startPeriod);
    final endTimeStr = formatTimeComponent(endDisplayHour, endMinute, true, endPeriod);
    
    return '$startTimeStr - $endTimeStr';
  }
}

/// Participation Status Legend Modal
/// Shows a key/legend explaining different participation icons
class ParticipationStatusLegendModal extends StatelessWidget {
  const ParticipationStatusLegendModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with title and close button
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Announced Practices',
                    style: TextStyle(
                      color: Color(0xFF111827),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  color: Color(0xFF6B7280),
                ),
              ],
            ),
          ),

          // Content area
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Subtitle
                  const Text(
                    'All practices that have been announced as confirmed',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF6B7280),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Horizontal divider
                  Container(
                    height: 1,
                    color: Color(0xFFE5E7EB),
                  ),

                  const SizedBox(height: 16),

                  // Section title
                  const Text(
                    'Participation Status Key',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151),
                    ),
                  ),

                  const SizedBox(height: 16),
          
                  // Legend items (simple rows without containers)
                  _buildSimpleLegendItem(
                    Icons.check_circle_outline,
                    ParticipationStatus.yes.color,
                    'YES',
                    'You will attend this practice',
                  ),

                  const SizedBox(height: 12),

                  _buildSimpleLegendItem(
                    Icons.help_outline,
                    ParticipationStatus.maybe.color,
                    'MAYBE',
                    'You\'re unsure about attending this practice',
                  ),

                  const SizedBox(height: 12),

                  _buildSimpleLegendItem(
                    Icons.cancel_outlined,
                    ParticipationStatus.no.color,
                    'NO',
                    'You will not attend this practice',
                  ),

                  const SizedBox(height: 12),

                  _buildSimpleLegendItem(
                    Icons.check_circle,
                    ParticipationStatus.attended.color,
                    'ATTENDED',
                    'Confirmed to have attended practice',
                  ),

                  const SizedBox(height: 12),

                  _buildSimpleLegendItem(
                    Icons.cancel,
                    ParticipationStatus.missed.color,
                    'MISSED',
                    'Confirmed to have not attended practice',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleLegendItem(IconData icon, Color color, String title, String description) {
    return Row(
      children: [
        // Icon without background container
        Icon(
          icon,
          size: 24,
          color: color,
        ),

        const SizedBox(width: 12),

        // Text content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6B7280),
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
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
    final userRSVPStatus = practice.getParticipationStatus(currentUserId);
    final rsvpCounts = practice.getParticipationCounts();
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
                            TimeUtils.formatPracticeDateTime(practice.dateTime, practice.duration),
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
}

/// Floating bulk action panel for RSVP operations
class BulkRSVPActionPanel extends StatelessWidget {
  final int selectedCount;
  final Function(ParticipationStatus) onBulkRSVP;
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
                  ParticipationStatus.yes,
                  'Yes',
                  Icons.check,
                  isLoading,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildActionButton(
                  ParticipationStatus.no,
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
  
  Widget _buildActionButton(ParticipationStatus status, String label, IconData icon, bool isLoading) {
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
  final ParticipationStatus newStatus;
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
                                  TimeUtils.formatPracticeDateTime(practice.dateTime, practice.duration),
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
}





/// Widget for displaying guest type tags with practice tag styling
class GuestTypeTag extends StatelessWidget {
  final GuestType guestType;
  
  const GuestTypeTag({
    super.key,
    required this.guestType,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF0284C7).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF0284C7).withValues(alpha: 0.3)),
      ),
      child: Text(
        guestType.displayName,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF0284C7),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
