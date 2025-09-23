/// Guest management popup for practice RSVP
library;

import 'package:flutter/material.dart';
import '../../core/models/guest.dart';
import '../../core/constants/app_constants.dart';
import 'dropdown_utils.dart';

class GuestManagementModal extends StatefulWidget {
  final PracticeGuestList initialGuests;
  final Function(PracticeGuestList) onGuestsChanged;
  final String practiceId;
  
  const GuestManagementModal({
    super.key,
    required this.initialGuests,
    required this.onGuestsChanged,
    required this.practiceId,
  });

  @override
  State<GuestManagementModal> createState() => _GuestManagementModalState();
}

class _GuestManagementModalState extends State<GuestManagementModal> {
  late PracticeGuestList _guestList;
  final Map<GuestType, bool> _expandedSections = {};
  final Map<GuestType, TextEditingController> _nameControllers = {};
  final Map<GuestType, bool> _waiverStates = {};
  List<String> _selectedDependents = []; // For multiple dependent selections
  final ScrollController _scrollController = ScrollController(); // Add scroll controller
  
  // Toast state for validation feedback
  bool _showToast = false;
  String _toastMessage = '';
  
  @override
  void initState() {
    super.initState();
    _guestList = widget.initialGuests;
    
    // Initialize controllers for each guest type
    for (final type in GuestType.values) {
      _nameControllers[type] = TextEditingController();
      _waiverStates[type] = false;
      _expandedSections[type] = false;
    }
  }
  
  @override
  void dispose() {
    _scrollController.dispose(); // Dispose scroll controller
    for (final controller in _nameControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 345,
          constraints: const BoxConstraints(maxHeight: 500),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Manage Guests',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          
          // Content
          Flexible(
            child: SingleChildScrollView(
              controller: _scrollController, // Add scroll controller
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Guest summary
                  if (_guestList.totalGuests > 0) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.group, color: AppColors.primary, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            'Bringing ${_guestList.totalGuests} guest${_guestList.totalGuests == 1 ? '' : 's'}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Guest type sections - show dependents at bottom
                  for (final type in GuestType.values.where((t) => t != GuestType.dependent))
                    _buildGuestTypeSection(type),
                  // Dependents section at the bottom
                  _buildGuestTypeSection(GuestType.dependent),
                  
                  // Bottom padding to ensure buttons are always accessible
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
          
          // Action buttons
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: !_canComplete() ? () {
                      // Show validation toast when button is disabled but user taps
                      _validateAndShowDoneToast();
                    } : null,
                    child: ElevatedButton(
                      onPressed: _canComplete() ? () {
                        widget.onGuestsChanged(_guestList);
                        Navigator.of(context).pop();
                      } : null, // null = disabled styling
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.4), // Disabled blue
                        disabledForegroundColor: Colors.white.withValues(alpha: 0.7),
                      ),
                      child: const Text('Done'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
        ),
        
        // Toast overlay (mobile-only) - positioned at top
        if (_showToast && MediaQuery.of(context).size.width <= 768)
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.red[700],
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                _toastMessage,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
  
  Widget _buildGuestTypeSection(GuestType type) {
    final guests = _guestList.getGuestsByType(type);
    final isExpanded = _expandedSections[type] ?? false;
    
    // Debug logging
    if (type == GuestType.dependent) {
      // TODO: Replace with proper logging
      // print('Building ${type.displayName} section with ${guests.length} guests: ${guests.map((g) => g.name).toList()}');
    }
    
    return Column(
      children: [
        // Header with + button
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          type.displayName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (guests.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${guests.length}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      type.description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Add button
              GestureDetector(
                onTap: () => _toggleSection(type),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Existing guests list
        if (guests.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: Column(
              children: guests.map((guest) => _buildGuestItem(guest)).toList(),
            ),
          ),
        
        // Expanded form
        if (isExpanded)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: _buildGuestForm(type),
          ),
      ],
    );
  }
  
  Widget _buildGuestItem(Guest guest) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  guest.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (guest.type == GuestType.visitor && guest is VisitorGuest && guest.homeClub != null)
                  Text(
                    'From: ${guest.homeClub}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          // Waiver status
          if (guest.type != GuestType.clubMember)
            Row(
              children: [
                Icon(
                  guest.waiverSigned ? Icons.check_circle : Icons.radio_button_unchecked,
                  size: 16,
                  color: guest.waiverSigned ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  guest.waiverSigned ? 'Waiver' : 'No waiver',
                  style: TextStyle(
                    fontSize: 12,
                    color: guest.waiverSigned ? Colors.green : Colors.grey,
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          // Remove button
          GestureDetector(
            onTap: () => _removeGuest(guest.id),
            child: Container(
              padding: const EdgeInsets.all(4),
              child: const Icon(
                Icons.remove_circle,
                size: 18,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildGuestForm(GuestType type) {
    final nameController = _nameControllers[type]!;
    final waiverSigned = _waiverStates[type] ?? false;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Name field - use dependent selector for dependents, text field for others
        if (type == GuestType.dependent)
          DropdownUtils.createDependentSelector(
            selectedDependents: _selectedDependents,
            onDependentsChanged: (selected) {
              setState(() {
                _selectedDependents = selected;
              });
            },
          )
        else
          TextField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: type == GuestType.clubMember ? 'Select member' : 'Guest name',
              border: OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            textCapitalization: TextCapitalization.words,
          ),
        
        const SizedBox(height: 12),
        
        // Waiver checkbox (not for club members)
        if (type != GuestType.clubMember)
          Row(
            children: [
              Checkbox(
                value: waiverSigned,
                onChanged: (value) {
                  setState(() {
                    _waiverStates[type] = value ?? false;
                  });
                },
                activeColor: AppColors.primary,
              ),
              const Text(
                'Waiver signed (placeholder)',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        
        const SizedBox(height: 12),
        
        // Add button
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () => _cancelForm(type),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: GestureDetector(
                onTap: !_canAddGuest(type) ? () {
                  // Show validation toast when button is disabled but user taps
                  _validateAndShowToast(type);
                } : null,
                child: ElevatedButton(
                  onPressed: _canAddGuest(type) ? () {
                    // TODO: Replace with proper logging
                    // print('Add button pressed for ${type.displayName} with ${_selectedDependents.length} dependents');
                    _addGuest(type);
                  } : null, // null = disabled styling
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.4), // Disabled blue
                    disabledForegroundColor: Colors.white.withValues(alpha: 0.7),
                  ),
                  child: const Text('Add'),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  void _toggleSection(GuestType type) {
    setState(() {
      final wasExpanded = _expandedSections[type] ?? false;
      _expandedSections[type] = !wasExpanded;
      
      // Close other sections
      for (final otherType in GuestType.values) {
        if (otherType != type) {
          _expandedSections[otherType] = false;
        }
      }
      
      // Auto-scroll to bottom when expanding (not when collapsing)
      if (!wasExpanded && _expandedSections[type]!) {
        _autoScrollToBottom();
      }
    });
  }
  
  void _addGuest(GuestType type) {
    final nameController = _nameControllers[type]!;
    
    if (type == GuestType.dependent) {
      // Handle multiple dependent selections
      if (_selectedDependents.isEmpty) return;
      
      final waiverSigned = _waiverStates[type] ?? false;
      
      // Add each selected dependent as a separate guest
      for (final dependentName in _selectedDependents) {
        final guestId = '${widget.practiceId}_${type.name}_${dependentName}_${DateTime.now().millisecondsSinceEpoch}';
        final guest = DependentGuest(
          id: guestId,
          name: dependentName,
          waiverSigned: waiverSigned,
        );
        _guestList = _guestList.addGuest(guest);
        // TODO: Replace with proper logging
        // print('Added dependent guest: ${guest.name}, ID: ${guest.id}, Type: ${guest.type}');
      }
      
      setState(() {
        _waiverStates[type] = false;
        _expandedSections[type] = false;
        _selectedDependents.clear();
        // TODO: Replace with proper logging
        // print('Current guest list has ${_guestList.totalGuests} guests');
        // print('Dependents in list: ${_guestList.getGuestsByType(GuestType.dependent).map((g) => g.name).toList()}');
      });
    } else {
      // Handle single guest addition for other types
      final name = nameController.text.trim();
      if (name.isEmpty) return;
      
      final guestId = '${widget.practiceId}_${type.name}_${DateTime.now().millisecondsSinceEpoch}';
      
      Guest guest;
      switch (type) {
        case GuestType.newPlayer:
          guest = NewPlayerGuest(
            id: guestId,
            name: name,
            waiverSigned: _waiverStates[type] ?? false,
          );
          break;
        case GuestType.visitor:
          guest = VisitorGuest(
            id: guestId,
            name: name,
            waiverSigned: _waiverStates[type] ?? false,
          );
          break;
        case GuestType.clubMember:
          guest = ClubMemberGuest(
            id: guestId,
            name: name,
            memberId: guestId, // Placeholder - would be actual member ID
          );
          break;
        case GuestType.dependent:
          // This case is handled above
          return;
      }
      
      setState(() {
        _guestList = _guestList.addGuest(guest);
        nameController.clear();
        _waiverStates[type] = false;
        _expandedSections[type] = false;
      });
    }
  }
  
  void _removeGuest(String guestId) {
    setState(() {
      _guestList = _guestList.removeGuest(guestId);
    });
  }
  
  void _cancelForm(GuestType type) {
    setState(() {
      _nameControllers[type]!.clear();
      _waiverStates[type] = false;
      _expandedSections[type] = false;
      if (type == GuestType.dependent) {
        _selectedDependents.clear();
      }
    });
  }

  // Check if all guests have waivers signed (for enabling DONE button)
  bool _allGuestsHaveWaivers() {
    if (_guestList.totalGuests == 0) return true; // No guests = valid state
    
    // Check all existing guests
    for (final guest in _guestList.guests) {
      if (!guest.waiverSigned) return false;
    }
    
    return true;
  }

  // Auto-scroll to bottom when form expands
  void _autoScrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  // Check if ADD button should be enabled for a specific guest type
  bool _canAddGuest(GuestType type) {
    final nameController = _nameControllers[type]!;
    final waiverSigned = _waiverStates[type] ?? false;
    
    if (type == GuestType.dependent) {
      return _selectedDependents.isNotEmpty && waiverSigned;
    } else {
      return nameController.text.trim().isNotEmpty && waiverSigned;
    }
  }

  // Show validation toast (mobile-only)
  void _showValidationToast(String message) {
    // Only show toasts on mobile screen layout
    if (MediaQuery.of(context).size.width <= 768) {
      setState(() {
        _toastMessage = message;
        _showToast = true;
      });
      
      // Hide toast after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _showToast = false;
          });
        }
      });
    }
  }

  // Validate guest addition attempt
  void _validateAndShowToast(GuestType type) {
    final nameController = _nameControllers[type]!;
    final waiverSigned = _waiverStates[type] ?? false;
    
    if (type == GuestType.dependent) {
      if (_selectedDependents.isEmpty && !waiverSigned) {
        _showValidationToast('Please select dependents and sign waiver');
      } else if (_selectedDependents.isEmpty) {
        _showValidationToast('Please select at least one dependent');
      } else if (!waiverSigned) {
        _showValidationToast('Please sign the waiver to add dependents');
      }
    } else {
      if (nameController.text.trim().isEmpty && !waiverSigned) {
        _showValidationToast('Please enter name and sign waiver');
      } else if (nameController.text.trim().isEmpty) {
        _showValidationToast('Please enter a name for the ${type.displayName.toLowerCase()}');
      } else if (!waiverSigned) {
        _showValidationToast('Please sign the waiver to add ${type.displayName.toLowerCase()}');
      }
    }
  }

  // Validate Done button attempt and show appropriate toast
  void _validateAndShowDoneToast() {
    // Check if any section is expanded (user is in process of adding)
    for (final type in GuestType.values) {
      final isExpanded = _expandedSections[type] ?? false;
      if (isExpanded) {
        _showValidationToast('Please add the ${type.displayName.toLowerCase()} or cancel the form before finishing');
        return;
      }
    }
    
    // Check if any existing guests lack waivers
    if (!_allGuestsHaveWaivers()) {
      _showValidationToast('All guests must have signed waivers');
      return;
    }
  }

  // Enhanced DONE button validation
  bool _canComplete() {
    // Check if any guest type section is expanded (regardless of completion status)
    for (final type in GuestType.values) {
      final isExpanded = _expandedSections[type] ?? false;
      if (isExpanded) {
        // If any section is expanded, user is in process of adding - DONE should be disabled
        return false;
      }
    }
    
    // All existing guests must have waivers signed
    return _allGuestsHaveWaivers();
  }
}