import '../../auth/models/user.dart';

class ProfileSummary {
  final AppUser user;
  final ProfileActivities activities;

  const ProfileSummary({
    required this.user,
    required this.activities,
  });

  factory ProfileSummary.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'] is Map
        ? Map<String, dynamic>.from(json['user'] as Map)
        : <String, dynamic>{};
    final activitiesJson = json['activities'] is Map
        ? Map<String, dynamic>.from(json['activities'] as Map)
        : <String, dynamic>{};

    return ProfileSummary(
      user: AppUser.fromJson(userJson),
      activities: ProfileActivities.fromJson(activitiesJson),
    );
  }
}

class ProfileActivities {
  final int reports;
  final int suggestions;
  final int likesGiven;

  const ProfileActivities({
    required this.reports,
    required this.suggestions,
    required this.likesGiven,
  });

  factory ProfileActivities.fromJson(Map<String, dynamic> json) {
    return ProfileActivities(
      reports: _readInt(json, 'reports'),
      suggestions: _readInt(json, 'suggestions'),
      likesGiven: _readInt(json, 'likesGiven'),
    );
  }

  static int _readInt(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value == null) return 0;
    return int.tryParse(value.toString()) ?? 0;
  }
}
