import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../bulk_rsvp/bulk_rsvp_screen.dart';

/// Home screen placeholder matching UWH Portal design with bulk RSVP access
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
            
            const SizedBox(height: AppSpacing.xxl),
            
            // Bulk RSVP Demo Button
            Container(
              width: 280,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.checklist,
                    size: 40,
                    color: Color(0xFF0284C7),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Bulk RSVP Demo',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0369A1),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Update multiple practice RSVPs at once',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF0369A1),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BulkRSVPScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0284C7),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Try Bulk RSVP',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
