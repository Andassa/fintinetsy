import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/entities/stats_entities.dart';
import '../../domain/repositories/stats_repository.dart';

class HttpStatsRepository implements StatsRepository {
  HttpStatsRepository(this._api);

  final ApiClient _api;

  @override
  Future<HydrationStats> getHydration() async {
    try {
      final data = await _get('/stats/hydration');
      return HydrationStats(
        currentMl: data['current_ml'] as int,
        goalMl: data['goal_ml'] as int,
        neededMl: data['needed_ml'] as int,
      );
    } on DioException catch (e) {
      throw _map(e);
    }
  }

  @override
  Future<HeartRateStats> getHeartRate() async {
    try {
      final data = await _get('/stats/heart-rate');
      return HeartRateStats(
        bpm: data['bpm'] as int,
        activityLabel: data['activity_label'] as String,
        pressure: data['pressure'] as int,
        pressureUnit: data['pressure_unit'] as String,
        oxygen: data['oxygen'] as int,
        oxygenUnit: data['oxygen_unit'] as String,
        heroAsset: data['hero_image_url'] as String,
      );
    } on DioException catch (e) {
      throw _map(e);
    }
  }

  @override
  Future<CalorieStatsData> getCalorieStats() async {
    try {
      final data = await _get('/stats/calories');
      return CalorieStatsData(
        totalKcal: data['total_kcal'] as int,
        monthLabel: data['month_label'] as String,
        macros: (data['macros'] as List<dynamic>).map((raw) {
          final m = raw as Map<String, dynamic>;
          return MacroBar(
            label: m['label'] as String,
            percent: m['percent'] as int,
            grams: m['grams'] as int,
            colorHex: m['color_hex'] as String,
          );
        }).toList(),
      );
    } on DioException catch (e) {
      throw _map(e);
    }
  }

  @override
  Future<CalorieIntakeData> getCalorieIntake() async {
    try {
      final data = await _get('/stats/calories/intake');
      return CalorieIntakeData(
        totalKcal: data['total_kcal'] as int,
        remainingKcal: data['remaining_kcal'] as int,
        dateLabel: data['date_label'] as String,
        points: (data['points'] as List<dynamic>).map((raw) {
          final p = raw as Map<String, dynamic>;
          return CalorieIntakePoint(
            kcal: p['kcal'] as int,
            index: p['index'] as int,
          );
        }).toList(),
        activePointIndex: data['active_point_index'] as int,
        carbsG: data['carbs_g'] as int,
        proteinG: data['protein_g'] as int,
        fatsG: data['fats_g'] as int,
      );
    } on DioException catch (e) {
      throw _map(e);
    }
  }

  @override
  Future<UpliftScoreData> getUpliftScore() async {
    try {
      final data = await _get('/stats/uplift-score');
      return UpliftScoreData(
        score: data['score'] as int,
        message: data['message'] as String,
        segments: (data['segments'] as List<dynamic>).map((raw) {
          final s = raw as Map<String, dynamic>;
          return ScoreSegment(
            label: s['label'] as String,
            percent: s['percent'] as int,
            colorHex: s['color_hex'] as String,
          );
        }).toList(),
      );
    } on DioException catch (e) {
      throw _map(e);
    }
  }

  @override
  Future<JoggingCompletedData> getJoggingCompleted() async {
    try {
      final created = await _api.raw.post<Map<String, dynamic>>(
        '/activities',
        data: {'type': 'jogging', 'title': 'Morning jog'},
      );
      final id = created.data!['id'].toString();
      final done = await _api.raw.post<Map<String, dynamic>>(
        '/activities/$id/complete',
        data: <String, dynamic>{},
      );
      final data = done.data!;
      return JoggingCompletedData(
        title: data['title'] as String,
        segments: (data['segments'] as List<dynamic>).map((raw) {
          final s = raw as Map<String, dynamic>;
          return DonutSegment(
            label: s['label'] as String,
            percent: s['percent'] as int,
            colorHex: s['color_hex'] as String,
          );
        }).toList(),
        suggestionTitle: data['suggestion_title'] as String,
        suggestionSubtitle: data['suggestion_subtitle'] as String,
      );
    } on DioException catch (e) {
      throw _map(e);
    }
  }

  @override
  Future<ActivityStatusData> getActivityStatus() async {
    try {
      final data = await _get('/activities/status');
      return ActivityStatusData(
        items: (data['items'] as List<dynamic>).map((raw) {
          final i = raw as Map<String, dynamic>;
          return ActivityStatusItem(
            label: i['label'] as String,
            hoursLabel: i['hours_label'] as String,
            colorHex: i['color_hex'] as String,
            rotationDeg: (i['rotation_deg'] as num).toDouble(),
            width: (i['width'] as num).toDouble(),
            height: (i['height'] as num).toDouble(),
            dx: (i['dx'] as num).toDouble(),
            dy: (i['dy'] as num).toDouble(),
          );
        }).toList(),
      );
    } on DioException catch (e) {
      throw _map(e);
    }
  }

  @override
  Future<DirectionsData> getDirections() async {
    try {
      final data = await _get('/activities/directions');
      return DirectionsData(
        address: data['address'] as String,
        instruction: data['instruction'] as String,
        distanceLeft: data['distance_left'] as String,
        arrivalLabel: data['arrival_label'] as String,
        thumbnailAsset: data['thumbnail_url'] as String,
      );
    } on DioException catch (e) {
      throw _map(e);
    }
  }

  Future<Map<String, dynamic>> _get(String path) async {
    final response = await _api.raw.get<Map<String, dynamic>>(path);
    return response.data!;
  }

  Exception _map(DioException e) {
    return e.error is ApiException
        ? e.error as ApiException
        : ApiException.fromDio(e);
  }
}
