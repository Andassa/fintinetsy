import '../../../../core/theme/app_assets.dart';
import '../../domain/entities/home_dashboard.dart';
import '../../domain/repositories/home_repository.dart';

class FakeHomeRepository implements HomeRepository {
  @override
  Future<HomeDashboard> getDashboard() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return const HomeDashboard(
      user: HomeUserGreeting(
        name: 'Eren',
        dateLabel: 'Jun 25, 2024',
        kcal: 251,
        hungerStatus: 'Hungry',
        notificationCount: 8,
        avatarAsset: AppAssets.manRunning,
      ),
      categories: [
        HomeCategory(
          id: 'hydration',
          label: 'Hydration',
          iconKey: 'flame',
          isSelected: true,
        ),
        HomeCategory(
          id: 'score',
          label: 'Score',
          iconKey: 'favorite',
          isSelected: false,
        ),
        HomeCategory(
          id: 'calorie',
          label: 'Calorie',
          iconKey: 'local_fire',
          isSelected: false,
        ),
      ],
      workout: HomeWorkoutCard(
        id: 'wk_upper',
        title: 'Upper Strength 2',
        subtitle: '8 Series Workout',
        durationMin: 25,
        kcal: 412,
        imageAsset: AppAssets.workoutStrength,
      ),
      diet: HomeDietCard(
        id: 'diet_salad',
        title: 'Salad & Egg',
        kcal: 548,
        durationMin: 20,
        proteinG: 25,
        fatsG: 16,
        imageAsset: AppAssets.saladPlate,
      ),
      activities: [
        HomeActivityBlob(
          hoursLabel: '1h',
          colorHex: '#FF7A21',
          rotationDeg: -28,
          widthFactor: 0.22,
          heightFactor: 0.38,
          alignment: AlignmentData(-0.85, -0.55),
        ),
        HomeActivityBlob(
          hoursLabel: '15h',
          colorHex: '#2962FF',
          rotationDeg: 18,
          widthFactor: 0.26,
          heightFactor: 0.42,
          alignment: AlignmentData(0.75, -0.35),
        ),
        HomeActivityBlob(
          hoursLabel: '68h',
          colorHex: '#000000',
          rotationDeg: -12,
          widthFactor: 0.42,
          heightFactor: 0.55,
          alignment: AlignmentData(-0.05, 0.05),
        ),
        HomeActivityBlob(
          hoursLabel: '7h',
          colorHex: '#FF4B4B',
          rotationDeg: 32,
          widthFactor: 0.2,
          heightFactor: 0.36,
          alignment: AlignmentData(-0.7, 0.65),
        ),
        HomeActivityBlob(
          hoursLabel: '87h',
          colorHex: '#EBEBEB',
          rotationDeg: 8,
          widthFactor: 0.24,
          heightFactor: 0.5,
          alignment: AlignmentData(0.7, 0.55),
        ),
      ],
      aiCoach: HomeAiCoachCard(
        conversationsLabel: '1,879+',
        subtitle: 'AI Conversation',
        imageAsset: AppAssets.aiCoachHero,
      ),
    );
  }
}
