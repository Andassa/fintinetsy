import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/entities/workout_entities.dart';
import '../../domain/repositories/workout_repository.dart';

class HttpWorkoutRepository implements WorkoutRepository {
  HttpWorkoutRepository(this._api);

  final ApiClient _api;
  String? _lastWorkoutId;

  @override
  Future<WorkoutBrowsePage> getBrowsePage() async {
    try {
      final response =
          await _api.raw.get<Map<String, dynamic>>('/workouts/browse');
      final data = response.data!;
      return WorkoutBrowsePage(
        heroAsset: data['hero_image_url'] as String,
        title: data['title'] as String,
        subtitle: data['subtitle'] as String,
        activeDotIndex: data['active_dot_index'] as int,
        dotCount: data['dot_count'] as int,
      );
    } on DioException catch (e) {
      throw _map(e);
    }
  }

  @override
  Future<WorkoutCategoryPage> getCategoryPage() async {
    try {
      final response = await _api.raw.get<Map<String, dynamic>>(
        '/workouts/categories/strength',
        queryParameters: {'limit': 20},
      );
      final data = response.data!;
      final items = (data['items'] as Map<String, dynamic>)['items']
          as List<dynamic>;
      if (items.isNotEmpty) {
        _lastWorkoutId = (items.first as Map<String, dynamic>)['id'].toString();
      }
      return WorkoutCategoryPage(
        title: data['title'] as String,
        totalLabel: '${data['total_workouts']} Workouts',
        description: data['description'] as String,
        headerAsset: data['header_image_url'] as String,
        items: items.map((raw) {
          final w = raw as Map<String, dynamic>;
          return WorkoutListItem(
            id: w['id'].toString(),
            title: w['title'] as String,
            totalLabel: '${w['total_exercises']} Exercises',
            repsLabel: '${w['reps']} Reps',
            thumbnailAsset: w['thumbnail_url'] as String,
          );
        }).toList(),
      );
    } on DioException catch (e) {
      throw _map(e);
    }
  }

  @override
  Future<WorkoutPreviewPage> getPreviewPage() async {
    try {
      final id = _lastWorkoutId ?? await _resolveFirstWorkoutId();
      final response =
          await _api.raw.get<Map<String, dynamic>>('/workouts/$id');
      final data = response.data!;
      _lastWorkoutId = data['id'].toString();
      return WorkoutPreviewPage(
        heroAsset: data['hero_image_url'] as String,
        totalLabel: '${data['total_exercises']} Exercises',
        title: data['title'] as String,
        coachLabel: data['coach_label'] as String,
        timeValue: '${data['duration_minutes']} min',
        calorieValue: '${data['calories']}kcal',
        setsValue: '${data['sets']} Sets',
      );
    } on DioException catch (e) {
      throw _map(e);
    }
  }

  @override
  Future<WorkoutCompletePage> getCompletePage() async {
    try {
      final id = _lastWorkoutId ?? await _resolveFirstWorkoutId();
      final response = await _api.raw.post<Map<String, dynamic>>(
        '/workouts/$id/complete',
        data: <String, dynamic>{},
      );
      final data = response.data!;
      return WorkoutCompletePage(
        heroAsset: data['hero_image_url'] as String,
        title: data['title'] as String,
        burnedLabel: 'Calories Burned',
        minutes: '${data['duration_minutes']}',
        kcal: '${data['calories_burned']}',
        bpm: '${data['avg_bpm']}',
      );
    } on DioException catch (e) {
      throw _map(e);
    }
  }

  Future<String> _resolveFirstWorkoutId() async {
    final page = await getCategoryPage();
    if (page.items.isEmpty) {
      throw ApiException('No workouts available');
    }
    _lastWorkoutId = page.items.first.id;
    return _lastWorkoutId!;
  }

  Exception _map(DioException e) {
    return e.error is ApiException
        ? e.error as ApiException
        : ApiException.fromDio(e);
  }
}
