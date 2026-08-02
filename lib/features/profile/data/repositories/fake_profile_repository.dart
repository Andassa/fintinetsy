import '../../../../core/theme/app_assets.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';

class FakeProfileRepository implements ProfileRepository {
  @override
  Future<UserProfile> getProfile() async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    return const UserProfile(
      name: 'Makise Kurisu',
      location: 'Tokyo, Japan',
      membership: 'Basic Member',
      coverAsset: AppAssets.profileCover,
      avatarAsset: AppAssets.womanRunning,
      weeklyScores: [
        WeeklyScorePoint(day: 'Mon', score: 72),
        WeeklyScorePoint(day: 'Tue', score: 95),
        WeeklyScorePoint(day: 'Wed', score: 78),
        WeeklyScorePoint(day: 'Thu', score: 70),
        WeeklyScorePoint(day: 'Fri', score: 82),
        WeeklyScorePoint(day: 'Sat', score: 76),
        WeeklyScorePoint(day: 'Sun', score: 68),
      ],
      highlightDay: 'Tue',
      stats: [
        ProfileStat(
          value: '17yr',
          label: 'Current Age',
          colorHex: '#FF6D1F',
          iconKey: 'age',
        ),
        ProfileStat(
          value: '68kg',
          label: 'Weight',
          colorHex: '#2F69FF',
          iconKey: 'weight',
        ),
        ProfileStat(
          value: '978kalc',
          label: 'Daily Intake',
          colorHex: '#FF4B4B',
          iconKey: 'intake',
        ),
      ],
    );
  }
}
