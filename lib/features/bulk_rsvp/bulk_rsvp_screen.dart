

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/practice.dart';
import '../../core/providers/rsvp_provider.dart';
import '../../core/constants/app_constants.dart';
import '../../features/clubs/clubs_provider.dart';
import '../../base/widgets/rsvp_components.dart';
import '../../base/widgets/phone_modal_utils.dart';

/// Screen demonstrating bulk RSVP functionality
class BulkRSVPScreen extends StatefulWidget {
  final String? clubId;
  
  const BulkRSVPScreen({super.key, this.clubId});
  
  @override
  State<BulkRSVPScreen> createState() => _BulkRSVPScreenState();
}

class _BulkRSVPScreenState extends State<BulkRSVPScreen> {
  final Set<String> _selectedPracticeIds = {};
  bool _isLoading = false;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Bulk RSVP',
          style: TextStyle(
            color: Color(0xFF111827),
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF111827)),
        actions: [
          if (_selectedPracticeIds.isNotEmpty)
            TextButton(
              onPressed: _clearSelection,
              child: const Text(
                'Clear All',
                style: TextStyle(color: Color(0xFF6B7280)),
              ),
            ),
        ],
      ),
      body: Consumer2<ClubsProvider, RSVPProvider>(
        builder: (context, clubsProvider, rsvpProvider, child) {
          final practices = _getAvailablePractices(clubsProvider);
          
          if (practices.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.event_busy,
                    size: 64,
                    color: Color(0xFF9CA3AF),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No upcoming practices',
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Check back later for new practice sessions',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            );
          }
          
          return Stack(
            children: [
              // Practice list
              CustomScrollView(
                slivers: [
                  // Instructions header
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: Color(0xFF0284C7),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Select multiple practices and update their RSVP status at once.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF0369A1),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Practice cards
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final practice = practices[index];
                        return SelectablePracticeCard(
                          practice: practice,
                          currentUserId: rsvpProvider.currentUserId,
                          isSelected: _selectedPracticeIds.contains(practice.id),
                          onSelectionChanged: _handleSelectionChanged,
                          showRSVPSummary: true,
                        );
                      },
                      childCount: practices.length,
                    ),
                  ),
                  
                  // Bottom padding for floating panel
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 120),
                  ),
                ],
              ),
              
              // Floating bulk action panel
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: SafeArea(
                  child: BulkRSVPActionPanel(
                    selectedCount: _selectedPracticeIds.length,
                    onBulkRSVP: _handleBulkRSVP,
                    onClearSelection: _clearSelection,
                    isLoading: _isLoading || rsvpProvider.isBulkOperationInProgress,
                  ),
                ),
              ),
              
              // Bulk operation progress overlay
              if (rsvpProvider.isBulkOperationInProgress)
                Container(
                  color: Colors.black.withValues(alpha: 0.5),
                  child: Center(
                    child: Container(
                      width: 280,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 16),
                          Text(
                            rsvpProvider.bulkOperationStatus ?? 'Processing...',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
  
  List<Practice> _getAvailablePractices(ClubsProvider clubsProvider) {
    if (widget.clubId != null) {
      // Show practices for specific club
      final club = clubsProvider.clubs.where((c) => c.id == widget.clubId).firstOrNull;
      return club?.upcomingPractices.where((p) => p.isUpcoming).toList() ?? [];
    } else {
      // Show all upcoming practices from all clubs
      final allPractices = <Practice>[];
      for (final club in clubsProvider.clubs) {
        allPractices.addAll(club.upcomingPractices.where((p) => p.isUpcoming));
      }
      // Sort by date
      allPractices.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      return allPractices;
    }
  }
  
  void _handleSelectionChanged(String practiceId, bool selected) {
    setState(() {
      if (selected) {
        _selectedPracticeIds.add(practiceId);
      } else {
        _selectedPracticeIds.remove(practiceId);
      }
    });
  }
  
  void _clearSelection() {
    setState(() {
      _selectedPracticeIds.clear();
    });
  }
  
  void _handleBulkRSVP(RSVPStatus newStatus) async {
    if (_selectedPracticeIds.isEmpty) return;
    
    final clubsProvider = context.read<ClubsProvider>();
    final rsvpProvider = context.read<RSVPProvider>();
    
    // Get the practices to be updated
    final allPractices = _getAvailablePractices(clubsProvider);
    final selectedPractices = allPractices.where(
      (p) => _selectedPracticeIds.contains(p.id),
    ).toList();
    
    // Find the club ID (assuming all selected practices are from the same club)
    final clubId = widget.clubId ?? selectedPractices.first.clubId;
    
    // Show confirmation modal with proper phone content area positioning
    final confirmed = await PhoneModalUtils.showPhoneModal<bool>(
      context: context,
      child: BulkRSVPConfirmationModal(
        practices: selectedPractices,
        newStatus: newStatus,
        onConfirm: () => Navigator.of(context).pop(true),
        onCancel: () => Navigator.of(context).pop(false),
        isLoading: false,
      ),
    ) ?? false;
    
    if (!confirmed) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Create bulk RSVP request
      final request = BulkRSVPRequest(
        practiceIds: _selectedPracticeIds.toList(),
        newStatus: newStatus,
        clubId: clubId,
        userId: rsvpProvider.currentUserId,
      );
      
      // Execute bulk update
      final result = await rsvpProvider.bulkUpdateRSVP(request);
      
      // Show result
      if (mounted) {
        _showResultDialog(result);
      }
      
      // Clear selection on success
      if (result.isFullSuccess || result.isPartialSuccess) {
        setState(() {
          _selectedPracticeIds.clear();
        });
      }
      
    } catch (error) {
      if (mounted) {
        _showErrorDialog('Failed to update RSVP statuses: $error');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  void _showResultDialog(BulkRSVPResult result) {
    PhoneModalUtils.showPhoneModal(
      context: context,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              result.isFullSuccess
                ? 'Success!'
                : result.isPartialSuccess
                  ? 'Partially Complete'
                  : 'Failed',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: result.isFullSuccess
                  ? AppColors.success
                  : result.isPartialSuccess
                    ? const Color(0xFFF59E0B)
                    : AppColors.error,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              result.summaryText,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  void _showErrorDialog(String message) {
    PhoneModalUtils.showPhoneModal(
      context: context,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Error',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('OK'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
