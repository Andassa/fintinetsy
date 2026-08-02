enum MealType { breakfast, dinner, snack, lunch }
enum MealEntryMethod { manual, aiScan }

class MealDraft {
  const MealDraft({
    required this.name,
    required this.type,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.method,
    this.imageAsset,
  });

  final String name;
  final MealType type;
  final double protein;
  final double carbs;
  final double fat;
  final MealEntryMethod method;
  final String? imageAsset;
}

class ScanSession {
  const ScanSession({
    required this.imageAsset,
    required this.statusLabel,
    required this.progress,
  });

  final String imageAsset;
  final String statusLabel;
  final double progress;
}
