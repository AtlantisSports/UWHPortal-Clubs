/// Guest management popup for practice RSVP
library;

import 'package:flutter/material.dart';
import '../../core/models/guest.dart';
import '../../core/constants/app_constants.dart';

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
    for (final controller in _nameControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 345,
      constraints: const BoxConstraints(maxHeight: 400),
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
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onGuestsChanged(_guestList);
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Done'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildGuestTypeSection(GuestType type) {
    final guests = _guestList.getGuestsByType(type);
    final isExpanded = _expandedSections[type] ?? false;
    
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
                Icons.close,
                size: 16,
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
        // Name field
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
              child: ElevatedButton(
                onPressed: nameController.text.trim().isEmpty 
                    ? null 
                    : () => _addGuest(type),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Add'),
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  void _toggleSection(GuestType type) {
    setState(() {
      _expandedSections[type] = !(_expandedSections[type] ?? false);
      
      // Close other sections
      for (final otherType in GuestType.values) {
        if (otherType != type) {
          _expandedSections[otherType] = false;
        }
      }
    });
  }
  
  void _addGuest(GuestType type) {
    final nameController = _nameControllers[type]!;
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
        guest = DependentGuest(
          id: guestId,
          name: name,
          waiverSigned: _waiverStates[type] ?? false,
        );
        break;
    }
    
    setState(() {
      _guestList = _guestList.addGuest(guest);
      nameController.clear();
      _waiverStates[type] = false;
      _expandedSections[type] = false;
    });
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
    });
  }
}