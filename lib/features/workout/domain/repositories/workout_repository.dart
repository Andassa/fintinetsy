import '../entities/workout_entities.dart';

abstract class WorkoutRepository {
  Future<WorkoutBrowsePage> getBrowsePage();
  Future<WorkoutCategoryPage> getCategoryPage();
  Future<WorkoutPreviewPage> getPreviewPage();
  Future<WorkoutCompletePage> getCompletePage();
}
