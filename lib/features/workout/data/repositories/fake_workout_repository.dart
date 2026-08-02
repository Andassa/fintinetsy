import '../../../../core/theme/app_assets.dart';
import '../../domain/entities/workout_entities.dart';
import '../../domain/repositories/workout_repository.dart';

class FakeWorkoutRepository implements WorkoutRepository {
  @override
  Future<WorkoutBrowsePage> getBrowsePage() async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    return const WorkoutBrowsePage(
      heroAsset: AppAssets.workoutBrowseHero,
      title: 'Personalized Workout & Training',
      subtitle:
          'Workout categories will help you gain strength, get in better shape and embrace a healthy lifestyle',
      activeDotIndex: 1,
      dotCount: 3,
    );
  }

  @override
  Future<WorkoutCategoryPage> getCategoryPage() async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    const item = WorkoutListItem(
      id: 'back',
      title: 'Back Workout',
      totalLabel: '10 Total',
      repsLabel: '30x reps Each',
      thumbnailAsset: AppAssets.womanRunning,
    );
    return const WorkoutCategoryPage(
      title: 'Strength',
      totalLabel: '25 Total',
      description:
          'Build bigger and stronger muscles with this exercise. Train every day to get bulk',
      headerAsset: AppAssets.aiHeaderCurves,
      items: [item, item, item, item],
    );
  }

  @override
  Future<WorkoutPreviewPage> getPreviewPage() async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    return const WorkoutPreviewPage(
      heroAsset: AppAssets.workoutPreviewHero,
      totalLabel: '25 Total',
      title: 'Back Workout',
      coachLabel: 'With Azunyan U. WU',
      timeValue: '58min',
      calorieValue: '254kcal',
      setsValue: '3*4',
    );
  }

  @override
  Future<WorkoutCompletePage> getCompletePage() async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    return const WorkoutCompletePage(
      heroAsset: AppAssets.workoutCompleteHero,
      title: 'Back Workout Complete',
      burnedLabel: 'You burned 218kcal',
      minutes: '128',
      kcal: '158',
      bpm: '130',
    );
  }
}
