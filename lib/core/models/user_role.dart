

enum UserRole {
  clubAdmin('Club Admin'),
  practiceAdmin('Practice Admin'),
  regularClubMember('Regular Club Member'),
  knownNonClubMember('Known Non-Club Member'),
  unknownUser('Unknown User');

  const UserRole(this.displayName);

  final String displayName;

  /// Get role description for UI display
  String get description {
    switch (this) {
      case UserRole.clubAdmin:
        return 'Can manage club settings, practices, and member access';
      case UserRole.practiceAdmin:
        return 'Can manage practice details and member RSVPs';
      case UserRole.regularClubMember:
        return 'Full access to club practices and features';
      case UserRole.knownNonClubMember:
        return 'Can view club information but limited practice access';
      case UserRole.unknownUser:
        return 'Basic view access only';
    }
  }

  /// Check if role has admin privileges
  bool get isAdmin => this == UserRole.clubAdmin || this == UserRole.practiceAdmin;

  /// Check if role is a club member
  bool get isMember => this == UserRole.clubAdmin || 
                       this == UserRole.practiceAdmin || 
                       this == UserRole.regularClubMember;
}
