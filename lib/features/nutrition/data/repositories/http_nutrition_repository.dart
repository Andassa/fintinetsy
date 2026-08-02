import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/entities/meal_entities.dart';
import '../../domain/repositories/nutrition_repository.dart';

class HttpNutritionRepository implements NutritionRepository {
  HttpNutritionRepository(this._api);

  final ApiClient _api;

  @override
  Future<MealDraft> getDefaultMealDraft() async {
    try {
      final response =
          await _api.raw.get<Map<String, dynamic>>('/meals/draft');
      final data = response.data!;
      return MealDraft(
        name: data['name'] as String? ?? '',
        type: _mapType(data['type'] as String?),
        protein: (data['protein_g'] as num).toDouble(),
        carbs: (data['carbs_g'] as num).toDouble(),
        fat: (data['fat_g'] as num).toDouble(),
        method: data['entry_method'] == 'ai_scan'
            ? MealEntryMethod.aiScan
            : MealEntryMethod.manual,
        imageAsset: data['image_url'] as String?,
      );
    } on DioException catch (e) {
      throw _map(e);
    }
  }

  @override
  Future<ScanSession> getScanSession() async {
    try {
      final response = await _api.raw.post<Map<String, dynamic>>(
        '/meals/scan',
        data: <String, dynamic>{},
      );
      final data = response.data!;
      return ScanSession(
        imageAsset: data['image_url'] as String,
        statusLabel: data['status_label'] as String,
        progress: (data['progress'] as num).toDouble(),
      );
    } on DioException catch (e) {
      throw _map(e);
    }
  }

  @override
  Future<void> saveMeal(MealDraft meal) async {
    try {
      await _api.raw.post<Map<String, dynamic>>(
        '/meals',
        data: {
          'name': meal.name.isEmpty ? 'Meal' : meal.name,
          'type': meal.type.name,
          'protein_g': meal.protein,
          'carbs_g': meal.carbs,
          'fat_g': meal.fat,
          'entry_method':
              meal.method == MealEntryMethod.aiScan ? 'ai_scan' : 'manual',
          if (meal.imageAsset != null) 'image_url': meal.imageAsset,
        },
      );
    } on DioException catch (e) {
      throw _map(e);
    }
  }

  MealType _mapType(String? raw) {
    switch (raw) {
      case 'breakfast':
        return MealType.breakfast;
      case 'lunch':
        return MealType.lunch;
      case 'snack':
        return MealType.snack;
      default:
        return MealType.dinner;
    }
  }

  Exception _map(DioException e) {
    return e.error is ApiException
        ? e.error as ApiException
        : ApiException.fromDio(e);
  }
}
