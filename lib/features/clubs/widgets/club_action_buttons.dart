/// Club action buttons (Join/Contact) widget
library;

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/models/club.dart';
import '../../../core/constants/app_constants.dart';
import '../../../base/widgets/buttons.dart';
import '../../../core/utils/responsive_helper.dart';

class ClubActionButtons extends StatelessWidget {
  final Club club;

  const ClubActionButtons({
    super.key,
    required this.club,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Join button
        Expanded(
          child: PrimaryButton(
            text: 'Join',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Join club feature coming soon!')),
              );
            },
            icon: Icons.group_add,
          ),
        ),
        const SizedBox(width: 12),
        
        // Contact button
        Expanded(
          child: SecondaryButton(
            text: 'Contact',
            onPressed: () async {
              final Uri emailUri = Uri(
                scheme: 'mailto',
                path: club.contactEmail,
                query: 'subject=Inquiry about ${club.name}',
              );
              try {
                if (await canLaunchUrl(emailUri)) {
                  await launchUrl(emailUri);
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Could not open email: ${club.contactEmail}')),
                    );
                  }
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error opening email: ${club.contactEmail}')),
                  );
                }
              }
            },
            icon: Icons.email,
          ),
        ),
      ],
    );
  }
}
