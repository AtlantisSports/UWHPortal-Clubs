import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

/// Home screen placeholder matching UWH Portal design
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Underwater Hockey'),
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.home,
              size: 64,
              color: AppColors.textDisabled,
            ),
            const SizedBox(height: AppSpacing.medium),
            const Text(
              'Home Feature',
              style: AppTextStyles.headline2,
            ),
            const SizedBox(height: AppSpacing.small),
            const Text(
              'Coming Soon',
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
