/// Dependent management modal for bulk RSVP
library;

import 'package:flutter/material.dart';
import 'phone_modal_utils.dart';

class DependentManagementModal extends StatefulWidget {
  final List<String> availableDependents;
  final List<String> selectedDependents;
  final Function(List<String>) onDependentsChanged;
  
  const DependentManagementModal({
    super.key,
    required this.availableDependents,
    required this.selectedDependents,
    required this.onDependentsChanged,
  });

  @override
  State<DependentManagementModal> createState() => _DependentManagementModalState();
}

class _DependentManagementModalState extends State<DependentManagementModal> {
  late List<String> _selectedDependents;
  
  @override
  void initState() {
    super.initState();
    _selectedDependents = List.from(widget.selectedDependents);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Include Dependents',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
              IconButton(
                onPressed: () => PhoneFrameModal.close(),
                icon: const Icon(Icons.close, color: Color(0xFF6B7280)),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Instructions
          const Text(
            'Select dependents to include in this RSVP:',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 16),
          
          // Dependent list
          Expanded(
            child: ListView.builder(
              itemCount: widget.availableDependents.length,
              itemBuilder: (context, index) {
                final dependent = widget.availableDependents[index];
                final isSelected = _selectedDependents.contains(dependent);
                
                return CheckboxListTile(
                  title: Text(
                    dependent,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF374151),
                    ),
                  ),
                  value: isSelected,
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        _selectedDependents.add(dependent);
                      } else {
                        _selectedDependents.remove(dependent);
                      }
                    });
                  },
                  activeColor: const Color(0xFF0284C7),
                  contentPadding: EdgeInsets.zero,
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => PhoneFrameModal.close(),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    widget.onDependentsChanged(_selectedDependents);
                    PhoneFrameModal.close();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0284C7),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
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