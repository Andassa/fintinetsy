import '../../../../core/theme/app_assets.dart';
import '../../domain/entities/meal_entities.dart';
import '../../domain/repositories/nutrition_repository.dart';

class FakeNutritionRepository implements NutritionRepository {
  @override
  Future<MealDraft> getDefaultMealDraft() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return const MealDraft(
      name: '',
      type: MealType.dinner,
      protein: 20,
      carbs: 25,
      fat: 15,
      method: MealEntryMethod.manual,
    );
  }

  @override
  Future<ScanSession> getScanSession() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return const ScanSession(
      imageAsset: AppAssets.powerBowl,
      statusLabel: 'Scanning...',
      progress: 0.45,
    );
  }

  @override
  Future<void> saveMeal(MealDraft meal) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
  }
}
