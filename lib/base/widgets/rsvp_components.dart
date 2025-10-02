

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/practice.dart';
import '../../core/providers/participation_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/time_utils.dart';

// Local top-of-screen toast helper for components used outside calendar/list screens
// Delegates to standardized ToastManager
import 'toast_manager.dart';

void showTopToast(BuildContext context, String message, Color color, IconData icon, {bool persistent = false}) {
  ToastManager.showTopToast(
    context,
    message: message,
    color: color,
    icon: icon,
    persistent: persistent,
    duration: const Duration(seconds: 3),
  );
}



/// Truncate tag to 4 characters (exact same as bulk RSVP)
String truncateTag(String tag) {
  if (tag.isEmpty) return '';

  // Special mappings for common levels to fit in 4 characters
  switch (tag.toLowerCase()) {
    case 'high-level':
    case 'high level':
      return 'HIGH';
    case 'intermediate':
      return 'INT';
    case 'beginner':
      return 'BEG';
    case 'advanced':
      return 'ADV';
    case 'open':
      return 'OPEN';
    default:
      // Truncate to 4 characters and uppercase
      return tag.toUpperCase().substring(0, tag.length > 4 ? 4 : tag.length);
  }
}

/// Centralized final-commit toast policy
void showFinalCommitToastForPractice(BuildContext context, ParticipationStatus finalStatus) {
  if (finalStatus == ParticipationStatus.no) {
    showTopToast(context, 'Not going', ParticipationStatus.no.color, Icons.close);
    return;
  }
  if (finalStatus == ParticipationStatus.yes || finalStatus == ParticipationStatus.maybe) {
    final base = finalStatus == ParticipationStatus.yes ? 'Going' : 'Might go';
    final color = finalStatus == ParticipationStatus.yes ? ParticipationStatus.yes.color : ParticipationStatus.maybe.color;
    final icon = finalStatus == ParticipationStatus.yes ? Icons.check : Icons.help_outline;
    showTopToast(context, base, color, icon);
  }
}

/// Show final toast explicitly for a known new status (avoids race)
void showFinalCommitToastForStatus(
  BuildContext context,
  ParticipationStatus status,
) {
  showFinalCommitToastForPractice(context, status);
}

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
  final bool showText;
  final Color? overrideColor;

  const RSVPStatusDisplay({
    super.key,
    required this.status,
    this.size = 24.0,
    this.showText = true,
    this.overrideColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = overrideColor ?? status.color;
    final iconWidget = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: effectiveColor,
          width: 2,
        ),
        color: status == ParticipationStatus.blank
          ? Colors.transparent
          : effectiveColor.withValues(alpha: 0.1),
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
              color: effectiveColor,
            ),
    );

    if (!showText) return iconWidget;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        iconWidget,
        const SizedBox(width: 8),
        Text(
          status.displayText,
          style: TextStyle(
            color: effectiveColor,
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


/// CLICKABLE mode: Interactive RSVP for future practices (replaces PracticeRSVPCard)
/// READ_ONLY mode: Status display for past practices and modals (replaces PracticeAttendanceCard)
enum PracticeStatusCardMode { clickable, readOnly }

class PracticeStatusCard extends ConsumerStatefulWidget {
  final Practice practice;
  final PracticeStatusCardMode mode;
  final String? clubId; // Add clubId for RSVP updates
  final ParticipationStatus? currentParticipationStatus; // Optional override of participation status
  final Function(ParticipationStatus)? onParticipationChanged; // Callback when participation changes
  final VoidCallback? onLocationTap;
  final VoidCallback? onInfoTap; // Add callback for info icon (only used in CLICKABLE mode)
  final VoidCallback? onTap; // For READ_ONLY mode card tap
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
    this.showAttendanceStatus = true,
  });

  @override
  ConsumerState<PracticeStatusCard> createState() => _PracticeStatusCardState();
}

class _PracticeStatusCardState extends ConsumerState<PracticeStatusCard> {
  // Guest update flag - REMOVED for clean slate

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
    final controller = ref.read(participationControllerProvider.notifier);
    final state = ref.watch(participationControllerProvider);
    final userStatus = state.participationStatusMap[widget.practice.id] ?? controller.getParticipationStatus(widget.practice.id);

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
                    truncateTag(widget.practice.tag!),
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
              if (widget.showAttendanceStatus)
                _buildReadOnlyStatusDisplay(userStatus),
            ],
          ),

          // Guest section - REMOVED for clean slate
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
    final controller = ref.read(participationControllerProvider.notifier);
    final state = ref.watch(participationControllerProvider);
    final userStatus = state.participationStatusMap[widget.practice.id] ?? controller.getParticipationStatus(widget.practice.id);

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
                    truncateTag(widget.practice.tag!),
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
              if (widget.showAttendanceStatus)
                _buildReadOnlyStatusDisplay(userStatus),
            ],
          ),

          // Guest section - REMOVED for clean slate
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
    final controller = ref.read(participationControllerProvider.notifier);
    final state = ref.watch(participationControllerProvider);

    // Get current participation status from Riverpod controller/state
    final currentParticipationStatus = state.participationStatusMap[widget.practice.id] ?? controller.getParticipationStatus(widget.practice.id);

    // Show final toast on commit via ToastManager

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
                        truncateTag(widget.practice.tag!),
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
                            // Only make the text itself clickable, not the entire expanded area
                            IntrinsicWidth(
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
                      _buildParticipationButton(ParticipationStatus.yes, currentParticipationStatus),
                      const SizedBox(width: 8),
                      _buildParticipationButton(ParticipationStatus.maybe, currentParticipationStatus),
                      const SizedBox(width: 8),
                      _buildParticipationButton(ParticipationStatus.no, currentParticipationStatus),
                    ],
                  ),
                ],
              ),

              // Bring a guest section: show only for Yes and Maybe
              if (currentParticipationStatus == ParticipationStatus.yes || currentParticipationStatus == ParticipationStatus.maybe) ...[
                const SizedBox(height: 12),
                _buildGuestSection(),
              ],


            ],
          ),
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

  // Read-only guest section - REMOVED for clean slate

  Widget _buildGuestSection() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Checkbox(
            value: false, // Always false for clean slate
            onChanged: null, // No functionality
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
        ],
      ),
    );
  }



  // Guest management modal - REMOVED for clean slate




  Widget _buildParticipationButton(ParticipationStatus status, ParticipationStatus currentParticipationStatus) {
    final bool isSelected = currentParticipationStatus == status;

    // Use status color
    Color color = status.color;
    final fadedBg = _getFadedBackground(status);


    return GestureDetector(
      onTap: () async {
        try {
          if (widget.clubId == null) return;
          if (!widget.practice.isRSVPWindowOpen) return;

          // Guest confirmation logic - REMOVED for clean slate

          // Guest confirmation logic removed in clean slate; kept as comment to avoid dead_code
          /*
          final bool _enableGuestConfirmation = const bool.fromEnvironment('ENABLE_GUEST_CONFIRMATION', defaultValue: false);
          if (_enableGuestConfirmation) {
            final res = await showSharedRSVPConfirmationDialog(
              context: context,
              provider: participationProvider,
              practiceId: widget.practice.id,
              target: status,
            );
            if (res == null) return; // cancelled

            if (!mounted) return;

            await applyRSVPChange(
              context: context,
              provider: participationProvider,
              clubId: widget.clubId!,
              practiceIds: [widget.practice.id],
              target: status,
              decision: res,
          }
          */


          // Default path: apply immediately through Riverpod controller
          await ref.read(participationControllerProvider.notifier).updateParticipationStatus(
            widget.clubId!,
            widget.practice.id,
            status,
          );
          if (mounted) {
            showFinalCommitToastForStatus(context, status);
          }
        } catch (error) {
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
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Center(
              child: Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: color,
                          width: isSelected ? 4 : 2,
                        ),
                        color: isSelected ? color.withValues(alpha: 0.1) : Colors.transparent,
                      ),
                      child: Icon(
                        _getOverlayIcon(status),
                        size: status == ParticipationStatus.maybe ? 20.8 : 25.7,
                        color: color,
                      ),
                    ),
            ),

          ],
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
        return 'Going';
      case ParticipationStatus.no:
        return 'Not going';
      case ParticipationStatus.maybe:
        return 'Maybe';
      case ParticipationStatus.attended:
        return 'Attended';
      case ParticipationStatus.missed:
        return 'Missed';
      case ParticipationStatus.blank:
      default:
        return 'Are you going?';
    }
  }

  Color _getParticipationHeaderColor(ParticipationStatus? currentParticipationStatus) {
    switch (currentParticipationStatus) {
      case ParticipationStatus.yes:
        return AppColors.success; // Green
      case ParticipationStatus.no:
        return AppColors.error; // Red
      case ParticipationStatus.maybe:
        // Default Maybe color
        return const Color(0xFFF59E0B);
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
              padding: const EdgeInsets.fromLTRB(20, 5, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Subtitle
                  const Text(
                    'All practices confirmed by the Club Admins',
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





/// Widget for displaying guest type tags - STUB for clean slate
class GuestTypeTag extends StatelessWidget {
  final dynamic guestType; // Using dynamic to avoid import issues

  const GuestTypeTag({
    super.key,
    required this.guestType,
  });

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink(); // Return empty widget
  }
}


/// Inline tap-triggered tooltip bubble with arrow, positioned above the icon
class _InlineTooltipBubble extends StatefulWidget {
  final String message;
  final Widget child;
  const _InlineTooltipBubble({required this.message, required this.child});

  @override
  State<_InlineTooltipBubble> createState() => _InlineTooltipBubbleState();
}

class _InlineTooltipBubbleState extends State<_InlineTooltipBubble> {
  bool _visible = false;

  void _toggle() => setState(() => _visible = !_visible);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          widget.child,
          if (_visible)
            Positioned(
              bottom: 25,
              left: -60,
              child: SizedBox(
                width: 180,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF374151),
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        widget.message,
                        style: const TextStyle(color: Colors.white, fontSize: 12, height: 1.3),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Transform.translate(
                      offset: const Offset(0, -1),
                      child: CustomPaint(size: const Size(8, 4), painter: _InlineTooltipArrowPainter()),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _InlineTooltipArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF374151)
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
