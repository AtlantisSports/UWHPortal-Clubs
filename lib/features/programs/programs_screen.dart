/// Programs screen placeholder matching UWH Portal design
library;

import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

class ProgramsScreen extends StatelessWidget {
  const ProgramsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Programs'),
        backgroundColor: Colors.grey[100],
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_outlined,
              size: 28.8, // 20% larger than default 24
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(
              Icons.menu,
              size: 28.8, // 20% larger than default 24
            ),
            onPressed: () {
              Scaffold.of(context).openEndDrawer();
            },
          ),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ThreePersonIcon(),
            SizedBox(height: AppSpacing.medium),
            Text(
              'Programs Feature',
              style: AppTextStyles.headline2,
            ),
            SizedBox(height: AppSpacing.small),
            Text(
              'Coming Soon',
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _ThreePersonIcon extends StatelessWidget {
  const _ThreePersonIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 64,
      child: Stack(
        children: [
          // Left person
          Positioned(
            left: 0,
            top: 16,
            child: Icon(
              Icons.person,
              size: 32,
              color: AppColors.textDisabled,
            ),
          ),
          // Center person (slightly larger and higher)
          Positioned(
            left: 24,
            top: 8,
            child: Icon(
              Icons.person,
              size: 40,
              color: AppColors.textDisabled,
            ),
          ),
          // Right person
          Positioned(
            left: 48,
            top: 16,
            child: Icon(
              Icons.person,
              size: 32,
              color: AppColors.textDisabled,
            ),
          ),
        ],
      ),
    );
  }
}
