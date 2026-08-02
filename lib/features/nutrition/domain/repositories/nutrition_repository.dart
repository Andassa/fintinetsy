import '../entities/meal_entities.dart';

abstract class NutritionRepository {
  Future<MealDraft> getDefaultMealDraft();
  Future<ScanSession> getScanSession();
  Future<void> saveMeal(MealDraft meal);
}
