/// Club detail tabs widget (RSVP, Typical Practices, Gallery, Forum)
library;

import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/responsive_helper.dart';

class ClubDetailTabs extends StatelessWidget {
  final TabController tabController;

  const ClubDetailTabs({
    super.key,
    required this.tabController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          labelStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.normal,
          ),
          tabs: [
            Tab(text: 'RSVP'),
            Tab(text: 'Typical Practices'),
            Tab(text: 'Gallery'),
            Tab(text: 'Forum'),
          ],
        ),
        SizedBox(
          height: 400, // Fixed height for tab content
          child: TabBarView(
            controller: tabController,
            children: [
              _buildRSVPTab(context),
              _buildTypicalPracticesTab(context),
              _buildGalleryTab(context),
              _buildForumTab(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRSVPTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'RSVP Management',
            style: AppTextStyles.headline3,
          ),
          const SizedBox(height: 8),
          Text(
            'Manage your RSVP status for upcoming practices and events.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypicalPracticesTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Schedule',
            style: AppTextStyles.headline3,
          ),
          const SizedBox(height: 8),
          Text(
            'Regular practice times and locations for this club.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGalleryTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Photo Gallery',
            style: AppTextStyles.headline3,
          ),
          const SizedBox(height: 8),
          Text(
            'Photos from recent practices and events.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForumTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Club Forum',
            style: AppTextStyles.headline3,
          ),
          const SizedBox(height: 8),
          Text(
            'Discussion and announcements for club members.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
