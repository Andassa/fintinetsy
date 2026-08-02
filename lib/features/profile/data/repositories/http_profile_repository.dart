import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_assets.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';

class HttpProfileRepository implements ProfileRepository {
  HttpProfileRepository(this._api);

  final ApiClient _api;

  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Future<UserProfile> getProfile() async {
    try {
      final me = await _get('/users/me');
      Map<String, dynamic>? assessment;
      Map<String, dynamic>? intake;
      try {
        assessment = await _get('/users/me/assessment');
      } catch (_) {}
      try {
        intake = await _get('/stats/calories/intake');
      } catch (_) {}

      final age = assessment?['age'] as int?;
      final weight = (assessment?['weight_kg'] as num?)?.toDouble();
      final totalKcal = intake?['total_kcal'] as int? ?? 0;

      final points = (intake?['points'] as List<dynamic>?) ?? [];
      final weekly = <WeeklyScorePoint>[];
      for (var i = 0; i < _days.length; i++) {
        final score = i < points.length
            ? (((points[i] as Map<String, dynamic>)['kcal'] as int) / 20)
                .round()
                .clamp(0, 100)
            : 70 + (i * 3) % 20;
        weekly.add(WeeklyScorePoint(day: _days[i], score: score));
      }
      final highlight = weekly.reduce((a, b) => a.score >= b.score ? a : b);

      return UserProfile(
        name: me['name'] as String? ?? me['email'] as String? ?? 'Athlete',
        location: 'Uplift.ai',
        membership: me['membership'] as String? ?? 'Basic Member',
        coverAsset: AppAssets.profileCover,
        avatarAsset: me['avatar_url'] as String? ?? AppAssets.womanRunning,
        weeklyScores: weekly,
        highlightDay: highlight.day,
        stats: [
          ProfileStat(
            value: age != null ? '${age}yr' : '--',
            label: 'Current Age',
            colorHex: '#FF6D1F',
            iconKey: 'age',
          ),
          ProfileStat(
            value: weight != null ? '${weight.round()}kg' : '--',
            label: 'Weight',
            colorHex: '#2F69FF',
            iconKey: 'weight',
          ),
          ProfileStat(
            value: totalKcal > 0 ? '${totalKcal}kcal' : '--',
            label: 'Daily Intake',
            colorHex: '#FF4B4B',
            iconKey: 'intake',
          ),
        ],
      );
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : ApiException.fromDio(e);
    }
  }

  Future<Map<String, dynamic>> _get(String path) async {
    final response = await _api.raw.get<Map<String, dynamic>>(path);
    return response.data!;
  }
}
