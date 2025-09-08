import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/models/practice.dart';
import '../../core/utils/responsive_helper.dart';

class NextPracticeCard extends StatelessWidget {
  final Practice? practice;
  final VoidCallback? onRSVPPressed;
  final bool isRSVPed;
  final bool isLoading;

  const NextPracticeCard({
    super.key,
    this.practice,
    this.onRSVPPressed,
    this.isRSVPed = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMobile = ResponsiveHelper.isMobile(context);
    
    if (practice == null) {
      return Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(
                Icons.calendar_today,
                size: isMobile ? 32 : 40,
                color: AppColors.textDisabled,
              ),
              SizedBox(height: ResponsiveHelper.getSpacing(context, mobileSpacing: 8.0)),
              Text(
                'No upcoming practices',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: isMobile ? 14 : 16,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: isMobile ? 18 : 20,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Next Practice',
                  style: AppTextStyles.headline3.copyWith(
                    fontSize: isMobile ? 16 : 18,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            SizedBox(height: ResponsiveHelper.getSpacing(context, mobileSpacing: 12.0)),
            
            // Practice details
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: isMobile ? 16 : 18,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  _formatDate(practice!.dateTime),
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: isMobile ? 14 : 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: isMobile ? 16 : 18,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  _formatTime(practice!.dateTime),
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: isMobile ? 14 : 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: isMobile ? 16 : 18,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    practice!.location,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: isMobile ? 14 : 16,
                    ),
                  ),
                ),
              ],
            ),
            
            if (practice!.description != null && practice!.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                practice!.description!,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: isMobile ? 13 : 15,
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            
            SizedBox(height: ResponsiveHelper.getSpacing(context, mobileSpacing: 16.0)),
            
            // RSVP button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : onRSVPPressed,
                icon: isLoading
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isRSVPed ? Colors.white : AppColors.primary,
                          ),
                        ),
                      )
                    : Icon(
                        isRSVPed ? Icons.check_circle : Icons.add_circle_outline,
                        size: isMobile ? 18 : 20,
                      ),
                label: Text(
                  isRSVPed ? 'RSVP\'d - Tap to cancel' : 'RSVP for this practice',
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isRSVPed ? AppColors.success : AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    vertical: isMobile ? 12 : 16,
                    horizontal: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    
    return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }

  String _formatTime(DateTime startTime) {
    final endTime = startTime.add(const Duration(hours: 2)); // Default 2-hour duration
    return '${_formatTimeOnly(startTime)} - ${_formatTimeOnly(endTime)}';
  }

  String _formatTimeOnly(DateTime time) {
    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    
    return '$displayHour:$minute $period';
  }
}
