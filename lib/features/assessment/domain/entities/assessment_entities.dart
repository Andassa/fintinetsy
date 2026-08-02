enum WeightUnit { kg, lbs }

enum GenderOption { male, female, skipped }

class FitnessGoalOption {
  const FitnessGoalOption({
    required this.id,
    required this.label,
    required this.iconKey,
  });

  final String id;
  final String label;
  final String iconKey;
}

class VocalAssessmentContent {
  const VocalAssessmentContent({
    required this.prompt,
    required this.highlightedWords,
    required this.subtitle,
  });

  final String prompt;
  final String highlightedWords;
  final String subtitle;
}

class AssessmentConfig {
  const AssessmentConfig({
    required this.minAge,
    required this.maxAge,
    required this.defaultAge,
    required this.minWeightKg,
    required this.maxWeightKg,
    required this.defaultWeightKg,
    required this.fitnessLabels,
    required this.goals,
    required this.vocal,
  });

  final int minAge;
  final int maxAge;
  final int defaultAge;
  final double minWeightKg;
  final double maxWeightKg;
  final double defaultWeightKg;
  final List<String> fitnessLabels;
  final List<FitnessGoalOption> goals;
  final VocalAssessmentContent vocal;
}

class AssessmentProfile {
  AssessmentProfile({
    this.age,
    this.weightKg,
    this.weightUnit = WeightUnit.kg,
    this.fitnessLevel = 3,
    this.gender,
    this.goalId,
    this.vocalCompleted = false,
  });

  int? age;
  double? weightKg;
  WeightUnit weightUnit;
  int fitnessLevel;
  GenderOption? gender;
  String? goalId;
  bool vocalCompleted;
}
