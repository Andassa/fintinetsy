import '../../domain/entities/assessment_entities.dart';
import '../../domain/repositories/assessment_repository.dart';

class FakeAssessmentRepository implements AssessmentRepository {
  AssessmentProfile _profile = AssessmentProfile(
    age: 19,
    weightKg: 62,
    fitnessLevel: 3,
  );

  @override
  Future<AssessmentConfig> getConfig() async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    return const AssessmentConfig(
      minAge: 12,
      maxAge: 80,
      defaultAge: 19,
      minWeightKg: 30,
      maxWeightKg: 180,
      defaultWeightKg: 62,
      fitnessLabels: [
        'Beginner',
        'Novice',
        'Somewhat Athletic',
        'Athletic',
        'Very Athletic',
        'Elite',
      ],
      goals: [
        FitnessGoalOption(
          id: 'lose_weight',
          label: 'I wanna lose weight',
          iconKey: 'scale',
        ),
        FitnessGoalOption(
          id: 'ai_coach',
          label: 'I wanna try AI Coach',
          iconKey: 'smart_toy',
        ),
        FitnessGoalOption(
          id: 'bulk',
          label: 'I wanna get bulks',
          iconKey: 'fitness_center',
        ),
        FitnessGoalOption(
          id: 'endurance',
          label: 'I wanna gain endurance',
          iconKey: 'favorite',
        ),
        FitnessGoalOption(
          id: 'trying',
          label: 'Just trying out the app! 👍',
          iconKey: 'phone_iphone',
        ),
      ],
      vocal: VocalAssessmentContent(
        prompt: "If there's no pain, then there's always no gain.",
        highlightedWords: "If there's",
        subtitle:
            'Your voice is connected to your health. Say the following for better assessment. 🙌',
      ),
    );
  }

  @override
  Future<AssessmentProfile> getProfile() async => _profile;

  @override
  Future<void> saveProfile(AssessmentProfile profile) async {
    _profile = profile;
  }
}
