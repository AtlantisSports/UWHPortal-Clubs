/// Profile feature - Simple profile screen with role selection for testing
library;

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
  void _showRoleSelectionModal(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    UserRole tempSelectedRole = userProvider.currentRole;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Role Selection",
      barrierColor: Colors.transparent, // No default barrier
      pageBuilder: (context, animation, secondaryAnimation) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Material(
              type: MaterialType.transparency,
              child: Center(
                child: Container(
                  width: 393, // Match phone width exactly
                  height: double.infinity,
                  child: Stack(
                    children: [
                      // Custom backdrop only within phone bounds
                      Positioned.fill(
                        top: 100, // Space for app bar
                        bottom: 100, // Space for bottom nav
                        child: Container(
                          color: Colors.black54,
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Container(),
                          ),
                        ),
                      ),
                      // Modal content
                      Positioned(
                        top: 120,
                        bottom: 120,
                        left: 20,
                        right: 20,
                        child: Center(
                          child: Material(
                            borderRadius: BorderRadius.circular(12),
                            elevation: 8,
                            child: Container(
                              constraints: const BoxConstraints(
                                maxHeight: 450,
                              ),
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
                                          fontSize: 18, // Mobile-friendly size
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.close),
                                        iconSize: 20, // Smaller close button
                                        onPressed: () => Navigator.of(context).pop(),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  
                                  // Role selection list
                                  Expanded(
                                    child: SingleChildScrollView(
                                      child: Column(
                                        children: UserRole.values.map((role) {
                                          return RadioListTile<UserRole>(
                                            value: role,
                                            groupValue: tempSelectedRole,
                                            onChanged: (UserRole? value) {
                                              if (value != null) {
                                                setState(() {
                                                  tempSelectedRole = value;
                                                });
                                              }
                                            },
                                            title: Text(role.displayName),
                                            activeColor: AppColors.primary,
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
                                        onPressed: () => Navigator.of(context).pop(),
                                        child: Text(
                                          'Cancel',
                                          style: TextStyle(color: Colors.grey[600]),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      ElevatedButton(
                                        onPressed: () {
                                          userProvider.updateRole(tempSelectedRole);
                                          Navigator.of(context).pop();
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
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 393, // Galaxy S23 width - match phone frame
        ),
        child: Scaffold(
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
                      onPressed: () => _showRoleSelectionModal(context),
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
      ),
    );
  }
}
