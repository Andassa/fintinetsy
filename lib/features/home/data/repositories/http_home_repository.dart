import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_assets.dart';
import '../../../../core/theme/media_resolver.dart';
import '../../domain/entities/home_dashboard.dart';
import '../../domain/repositories/home_repository.dart';

class HttpHomeRepository implements HomeRepository {
  HttpHomeRepository(this._api);

  final ApiClient _api;

  @override
  Future<HomeDashboard> getDashboard() async {
    try {
      final response =
          await _api.raw.get<Map<String, dynamic>>('/home/dashboard');
      final data = response.data!;
      final user = data['user'] as Map<String, dynamic>;
      final workout = data['workout'] as Map<String, dynamic>;
      final diet = data['diet'] as Map<String, dynamic>;
      final coach = data['ai_coach'] as Map<String, dynamic>;
      final date = DateTime.parse(user['date'] as String);

      return HomeDashboard(
        user: HomeUserGreeting(
          name: user['name'] as String,
          dateLabel: _formatDate(date),
          kcal: user['kcal'] as int,
          hungerStatus: user['hunger_status'] as String,
          notificationCount: user['notification_count'] as int,
          avatarAsset: MediaResolver.resolve(
            user['avatar_url'] as String?,
            fallback: AppAssets.womanRunning,
          ),
        ),
        categories: (data['categories'] as List<dynamic>).map((raw) {
          final c = raw as Map<String, dynamic>;
          return HomeCategory(
            id: c['id'] as String,
            label: c['label'] as String,
            iconKey: c['icon_key'] as String,
            isSelected: c['is_selected'] as bool? ?? false,
          );
        }).toList(),
        workout: HomeWorkoutCard(
          id: workout['id'] as String,
          title: workout['title'] as String,
          subtitle: workout['subtitle'] as String,
          durationMin: workout['duration_minutes'] as int,
          kcal: workout['calories'] as int,
          imageAsset: MediaResolver.resolve(
            workout['image_url'] as String?,
            fallback: AppAssets.workoutStrength,
          ),
        ),
        diet: HomeDietCard(
          id: diet['id'] as String,
          title: diet['title'] as String,
          kcal: diet['calories'] as int,
          durationMin: diet['duration_minutes'] as int,
          proteinG: diet['protein_g'] as int,
          fatsG: diet['fats_g'] as int,
          imageAsset: MediaResolver.resolve(
            diet['image_url'] as String?,
            fallback: AppAssets.saladPlate,
          ),
        ),
        activities: (data['activities'] as List<dynamic>).map((raw) {
          final a = raw as Map<String, dynamic>;
          final align = a['alignment'] as Map<String, dynamic>;
          return HomeActivityBlob(
            hoursLabel: a['hours_label'] as String,
            colorHex: a['color_hex'] as String,
            rotationDeg: (a['rotation_deg'] as num).toDouble(),
            widthFactor: (a['width_factor'] as num).toDouble(),
            heightFactor: (a['height_factor'] as num).toDouble(),
            alignment: AlignmentData(
              (align['x'] as num).toDouble(),
              (align['y'] as num).toDouble(),
            ),
          );
        }).toList(),
        aiCoach: HomeAiCoachCard(
          conversationsLabel: '${coach['conversations_count']} Conversations',
          subtitle: coach['subtitle'] as String,
          imageAsset: MediaResolver.resolve(
            coach['image_url'] as String?,
            fallback: AppAssets.aiCoachHero,
          ),
        ),
      );
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : ApiException.fromDio(e);
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
