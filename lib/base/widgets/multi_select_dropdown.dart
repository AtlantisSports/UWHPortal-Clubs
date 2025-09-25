import 'package:flutter/material.dart';

class MultiSelectDropdown extends StatefulWidget {
  final String label;
  final List<String> items;
  final List<String> selectedItems;
  final Function(List<String>) onSelectionChanged;
  final String placeholder;
  final bool showAllOption;
  final bool showNoneOption;
  final String allOptionText;
  final String noneOptionText;
  
  const MultiSelectDropdown({
    super.key,
    required this.label,
    required this.items,
    required this.selectedItems,
    required this.onSelectionChanged,
    this.placeholder = 'Select items...',
    this.showAllOption = false,
    this.showNoneOption = false,
    this.allOptionText = 'All',
    this.noneOptionText = 'None',
  }) : assert(!(showAllOption && showNoneOption), 'Cannot show both All and None options simultaneously');

  @override
  State<MultiSelectDropdown> createState() => _MultiSelectDropdownState();
}

class _MultiSelectDropdownState extends State<MultiSelectDropdown> {
  bool _isExpanded = false;
  late List<String> _selectedItems;
  final GlobalKey _buttonKey = GlobalKey();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    if (widget.selectedItems.isNotEmpty) {
      _selectedItems = List.from(widget.selectedItems);
    } else if (widget.showAllOption) {
      // Default to "All" option if no items are pre-selected
      _selectedItems = [widget.allOptionText];
      // Notify parent of the default selection
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onSelectionChanged([widget.allOptionText]);
      });
    } else if (widget.showNoneOption) {
      // Default to "None" option if no items are pre-selected
      _selectedItems = [widget.noneOptionText];
      // Notify parent of the default selection
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onSelectionChanged([widget.noneOptionText]);
      });
    } else {
      _selectedItems = List.from(widget.selectedItems);
    }
  }

  @override
  void didUpdateWidget(MultiSelectDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Always sync with the parent's selected items to ensure consistency
    if (oldWidget.selectedItems != widget.selectedItems) {
      _selectedItems = List.from(widget.selectedItems);
      
      // If the external list is now empty and we have a "None" option, default to "None"
      if (_selectedItems.isEmpty && widget.showNoneOption) {
        _selectedItems = [widget.noneOptionText];
        // Notify parent of the default selection to keep them in sync
        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.onSelectionChanged([widget.noneOptionText]);
        });
      }
    }
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  String get _displayText {
    if (widget.showAllOption && _selectedItems.contains(widget.allOptionText)) {
      return widget.allOptionText;
    } else if (widget.showNoneOption && _selectedItems.contains(widget.noneOptionText)) {
      return widget.noneOptionText;
    } else if (_selectedItems.isEmpty) {
      return widget.placeholder;
    } else if (_selectedItems.length == 1) {
      return _selectedItems.first;
    } else {
      return '${_selectedItems.length} selected';
    }
  }

  void _toggleSelection(String item) {
    setState(() {
      if (widget.showAllOption && item == widget.allOptionText) {
        // If "All" is selected, clear everything else and add "All"
        _selectedItems.clear();
        _selectedItems.add(widget.allOptionText);
      } else if (widget.showNoneOption && item == widget.noneOptionText) {
        // If "None" is selected, clear everything and add "None"
        _selectedItems.clear();
        _selectedItems.add(widget.noneOptionText);
      } else {
        // If it's a regular item
        if (_selectedItems.contains(item)) {
          // Removing an individual item
          _selectedItems.remove(item);
          // If no items selected and we have None option, select None
          if (_selectedItems.isEmpty && widget.showNoneOption) {
            _selectedItems.add(widget.noneOptionText);
          }
        } else {
          // Adding an individual item - ALWAYS remove "All" or "None" first
          if (widget.showAllOption && _selectedItems.contains(widget.allOptionText)) {
            _selectedItems.remove(widget.allOptionText);
          }
          if (widget.showNoneOption && _selectedItems.contains(widget.noneOptionText)) {
            _selectedItems.remove(widget.noneOptionText);
          }
          _selectedItems.add(item);
        }
      }
    });
    
    // Notify parent of change
    widget.onSelectionChanged(_selectedItems);
    
    // Force rebuild of overlay if it exists
    if (_overlayEntry != null) {
      _overlayEntry!.markNeedsBuild();
    }
  }

  void _toggleDropdown() {
    if (_isExpanded) {
      _removeOverlay();
    } else {
      _showOverlay();
    }
  }

  void _showOverlay() {
    if (!mounted) return;
    
    final renderBox = _buttonKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return;

    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    
    // Get screen height to calculate available space
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Account for phone frame UI elements (specific to our phone frame implementation)
    final phoneFrameNavigationHeight = 48.0; // From phone_frame.dart _buildNavigationBar
    final phoneFrameStatusHeight = 28.0; // Typical status bar height
    final appBarHeight = 60.0; // App navigation bar
    
    // Calculate actual usable screen space within phone frame - be very conservative
    final usableTop = phoneFrameStatusHeight + appBarHeight;
    final usableBottom = screenHeight - phoneFrameNavigationHeight - 80; // Much larger buffer
    
    // Calculate approximate dropdown height (item height * items + padding)
    final hasSpecialOption = widget.showAllOption || widget.showNoneOption;
    final totalItems = hasSpecialOption ? widget.items.length + 1 : widget.items.length;
    final approximateItemHeight = 48.0; // checkbox + padding
    final approximateDropdownHeight = (totalItems * approximateItemHeight) + 16; // padding
    
    // Check if there's enough space below within usable area
    final spaceBelow = usableBottom - (offset.dy + size.height + 4);
    final spaceAbove = offset.dy - usableTop - 4;
    
    // Show above if dropdown would extend past usable bottom boundary
    final wouldExtendPastBottom = (offset.dy + size.height + 4 + approximateDropdownHeight) > usableBottom;
    final shouldShowAbove = wouldExtendPastBottom && (spaceAbove > 100); // Need at least 100px above

    setState(() {
      _isExpanded = true;
    });

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Invisible barrier to detect outside taps
          Positioned.fill(
            child: GestureDetector(
              onTap: _removeOverlay,
              child: Container(color: Colors.transparent),
            ),
          ),
          // Dropdown content
          Positioned(
            left: offset.dx,
            top: shouldShowAbove 
                ? offset.dy - approximateDropdownHeight - 4
                : offset.dy + size.height + 4,
            width: size.width,
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: shouldShowAbove ? spaceAbove : spaceBelow,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: StatefulBuilder(
                  builder: (context, setOverlayState) {
                    final totalItemsForBuild = hasSpecialOption ? widget.items.length + 1 : widget.items.length;
                    
                    // Build items in order
                    final List<Widget> orderedItems = [];
                    for (int index = 0; index < totalItemsForBuild; index++) {
                      String item;
                      bool isSelected;
                      
                      if (hasSpecialOption && index == 0) {
                        // First item is "All" or "None" option
                        if (widget.showAllOption) {
                          item = widget.allOptionText;
                          isSelected = _selectedItems.contains(widget.allOptionText);
                        } else {
                          item = widget.noneOptionText;
                          isSelected = _selectedItems.contains(widget.noneOptionText);
                        }
                      } else {
                        // Regular items (offset by 1 if hasSpecialOption is true)
                        final itemIndex = hasSpecialOption ? index - 1 : index;
                        item = widget.items[itemIndex];
                        isSelected = _selectedItems.contains(item);
                      }
                      
                      orderedItems.add(
                        Column(
                          children: [
                            InkWell(
                              onTap: () {
                                _toggleSelection(item);
                                setOverlayState(() {}); // Rebuild overlay
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                                child: Row(
                                  children: [
                                    Checkbox(
                                      value: isSelected,
                                      onChanged: (_) {
                                        _toggleSelection(item);
                                        setOverlayState(() {}); // Rebuild overlay
                                      },
                                      activeColor: const Color(0xFF0284C7),
                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      visualDensity: const VisualDensity(horizontal: -3, vertical: -3),
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        item,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: const Color(0xFF374151),
                                          fontWeight: hasSpecialOption && index == 0
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Add divider after special option (All/None)
                            if (hasSpecialOption && index == 0)
                              const Divider(height: 1, color: Color(0xFFE5E7EB)),
                          ],
                        ),
                      );
                    }
                    
                    // Reverse order if showing above so special option appears at bottom
                    final finalItems = shouldShowAbove ? orderedItems.reversed.toList() : orderedItems;
                    
                    return SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: finalItems,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );

    if (mounted) {
      Overlay.of(context).insert(_overlayEntry!);
    }
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) {
      setState(() {
        _isExpanded = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        
        // Dropdown trigger
        InkWell(
          key: _buttonKey,
          onTap: _toggleDropdown,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE5E7EB)),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _displayText,
                    style: TextStyle(
                      fontSize: 16,
                      color: _selectedItems.isEmpty 
                          ? const Color(0xFF9CA3AF) 
                          : const Color(0xFF374151),
                    ),
                  ),
                ),
                Icon(
                  _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: const Color(0xFF6B7280),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}