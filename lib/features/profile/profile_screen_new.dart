import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/user_provider.dart';
import '../../core/models/user_role.dart';
import '../../core/constants/app_constants.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Modal state variables
  bool _isShowingRoleSelectionModal = false;
  
  void _showRoleSelectionModal() {
    setState(() => _isShowingRoleSelectionModal = true);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 393, // Galaxy S23 width - match phone frame
        ),
        child: Stack(
          children: [
            Scaffold(
              backgroundColor: Colors.grey[100],
              appBar: AppBar(
                title: const Text('Profile'),
                backgroundColor: Colors.grey[100],
                foregroundColor: Colors.black87,
                elevation: 0,
                automaticallyImplyLeading: false,
                actions: [
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_outlined,
                      size: 28.8,
                    ),
                    onPressed: () {
                      // TODO: Implement notifications functionality
                    },
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.menu,
                      size: 28.8,
                    ),
                    onPressed: () {
                      Scaffold.of(context).openEndDrawer();
                    },
                  ),
                ],
              ),
              body: Consumer<UserProvider>(
                builder: (context, userProvider, child) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.person,
                          size: 64,
                          color: AppColors.textDisabled,
                        ),
                        const SizedBox(height: AppSpacing.medium),
                        const Text(
                          'Profile Feature',
                          style: AppTextStyles.headline2,
                        ),
                        const SizedBox(height: AppSpacing.small),
                        Text(
                          'Current Role: ${userProvider.currentRole.displayName}',
                          style: AppTextStyles.bodyMedium,
                        ),
                        const SizedBox(height: AppSpacing.large),
                        ElevatedButton(
                          onPressed: _showRoleSelectionModal,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                          ),
                          child: const Text('Change Role (Testing)'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            
            // Modal overlays using the same pattern as level filter
            _buildModalOverlays(),
          ],
        ),
      ),
    );
  }

  Widget _buildModalOverlays() {
    return Stack(
      children: [
        // Role Selection Modal only
        if (_isShowingRoleSelectionModal) ...[
          _buildModalBackdrop(() => setState(() => _isShowingRoleSelectionModal = false)),
          _buildRoleSelectionModal(),
        ],
      ],
    );
  }

  Widget _buildModalBackdrop(VoidCallback onTap) {
    return Positioned(
      top: kToolbarHeight, // Start below AppBar
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        color: Colors.black54,
        child: GestureDetector(
          onTap: onTap,
          child: Container(),
        ),
      ),
    );
  }

  Widget _buildModalContainer({required Widget child}) {
    return Positioned(
      left: 0,
      right: 0,
      top: kToolbarHeight + 100, // Position below AppBar
      bottom: 0, // Extend to bottom
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: child,
      ),
    );
  }

  Widget _buildRoleSelectionModal() {
    return _buildModalContainer(
      child: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          UserRole tempSelectedRole = userProvider.currentRole;
          
          return StatefulBuilder(
            builder: (context, setModalState) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Select Role',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => setState(() => _isShowingRoleSelectionModal = false),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    // Role selection list
                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          children: UserRole.values.map((role) {
                            return InkWell(
                              onTap: () {
                                setModalState(() {
                                  tempSelectedRole = role;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                child: Row(
                                  children: [
                                    Icon(
                                      tempSelectedRole == role 
                                        ? Icons.radio_button_checked 
                                        : Icons.radio_button_unchecked,
                                      color: AppColors.primary,
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(role.displayName),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Action buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => setState(() => _isShowingRoleSelectionModal = false),
                          child: Text(
                            'Cancel',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: () {
                            userProvider.updateRole(tempSelectedRole);
                            setState(() => _isShowingRoleSelectionModal = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Role updated to ${tempSelectedRole.displayName}'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Apply'),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}