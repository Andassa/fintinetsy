import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/entities/assessment_entities.dart';
import '../../domain/repositories/assessment_repository.dart';

class HttpAssessmentRepository implements AssessmentRepository {
  HttpAssessmentRepository(this._api);

  final ApiClient _api;

  @override
  Future<AssessmentConfig> getConfig() async {
    try {
      final response =
          await _api.raw.get<Map<String, dynamic>>('/assessment/config');
      final data = response.data!;
      final vocal = data['vocal'] as Map<String, dynamic>;
      return AssessmentConfig(
        minAge: data['min_age'] as int,
        maxAge: data['max_age'] as int,
        defaultAge: data['default_age'] as int,
        minWeightKg: (data['min_weight_kg'] as num).toDouble(),
        maxWeightKg: (data['max_weight_kg'] as num).toDouble(),
        defaultWeightKg: (data['default_weight_kg'] as num).toDouble(),
        fitnessLabels: (data['fitness_labels'] as List<dynamic>)
            .map((e) => e.toString())
            .toList(),
        goals: (data['goals'] as List<dynamic>).map((raw) {
          final g = raw as Map<String, dynamic>;
          return FitnessGoalOption(
            id: g['id'] as String,
            label: g['label'] as String,
            iconKey: g['icon_key'] as String,
          );
        }).toList(),
        vocal: VocalAssessmentContent(
          prompt: vocal['prompt'] as String,
          highlightedWords: vocal['highlighted_words'] as String,
          subtitle: vocal['subtitle'] as String,
        ),
      );
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : ApiException.fromDio(e);
    }
  }

  @override
  Future<AssessmentProfile> getProfile() async {
    try {
      final response = await _api.raw
          .get<Map<String, dynamic>>('/users/me/assessment');
      final data = response.data!;
      return AssessmentProfile(
        age: data['age'] as int?,
        weightKg: (data['weight_kg'] as num?)?.toDouble(),
        weightUnit: data['weight_unit'] == 'lbs' ? WeightUnit.lbs : WeightUnit.kg,
        fitnessLevel: data['fitness_level'] as int? ?? 3,
        gender: _mapGender(data['gender'] as String?),
        goalId: data['goal_id'] as String?,
        vocalCompleted: data['vocal_completed'] as bool? ?? false,
      );
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : ApiException.fromDio(e);
    }
  }

  @override
  Future<void> saveProfile(AssessmentProfile profile) async {
    try {
      await _api.raw.put<Map<String, dynamic>>(
        '/users/me/assessment',
        data: {
          'age': profile.age,
          'weight_kg': profile.weightKg,
          'weight_unit': profile.weightUnit == WeightUnit.lbs ? 'lbs' : 'kg',
          'fitness_level': profile.fitnessLevel,
          'gender': profile.gender?.name,
          'goal_id': profile.goalId,
          'vocal_completed': profile.vocalCompleted,
        },
      );
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : ApiException.fromDio(e);
    }
  }

  GenderOption? _mapGender(String? raw) {
    switch (raw) {
      case 'male':
        return GenderOption.male;
      case 'female':
        return GenderOption.female;
      case 'skipped':
        return GenderOption.skipped;
      default:
        return null;
    }
  }
}
