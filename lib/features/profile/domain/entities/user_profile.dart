class ProfileStat {
  const ProfileStat({
    required this.value,
    required this.label,
    required this.colorHex,
    required this.iconKey,
  });
  final String value;
  final String label;
  final String colorHex;
  final String iconKey;
}

class WeeklyScorePoint {
  const WeeklyScorePoint({required this.day, required this.score});
  final String day;
  final int score;
}

class UserProfile {
  const UserProfile({
    required this.name,
    required this.location,
    required this.membership,
    required this.coverAsset,
    required this.avatarAsset,
    required this.weeklyScores,
    required this.highlightDay,
    required this.stats,
  });

  final String name;
  final String location;
  final String membership;
  final String coverAsset;
  final String avatarAsset;
  final List<WeeklyScorePoint> weeklyScores;
  final String highlightDay;
  final List<ProfileStat> stats;
}
