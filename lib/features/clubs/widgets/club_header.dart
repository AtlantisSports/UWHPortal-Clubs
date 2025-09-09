/// Club header widget with banner and club name
library;

import 'package:flutter/material.dart';
import '../../../core/models/club.dart';
import '../../../core/constants/app_constants.dart';

class ClubHeader extends StatelessWidget {
  final Club club;

  const ClubHeader({
    super.key,
    required this.club,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Club header section with image/icon - minimal padding for tight layout
        Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 2.0, bottom: 0.0),
          child: Container(
            width: double.infinity,
            height: 200.0, // Mobile height
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primary,
                  AppColors.primaryDark,
                ],
              ),
            ),
            clipBehavior: Clip.hardEdge,
            child: club.logoUrl != null
                ? Image.network(
                    club.logoUrl!,
                    fit: BoxFit.cover,
                  )
                : Icon(
                    Icons.group,
                    size: 80,
                    color: Colors.white54,
                  ),
          ),
        ),
        
        // Club info content
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 0), // No padding above club name
              
              // Full club name - centered
              Center(
                child: Text(
                  club.longName,
                  style: AppTextStyles.headline2.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
