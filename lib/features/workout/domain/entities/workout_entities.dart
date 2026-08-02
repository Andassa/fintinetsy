class WorkoutBrowsePage {
  const WorkoutBrowsePage({
    required this.heroAsset,
    required this.title,
    required this.subtitle,
    required this.activeDotIndex,
    required this.dotCount,
  });

  final String heroAsset;
  final String title;
  final String subtitle;
  final int activeDotIndex;
  final int dotCount;
}

class WorkoutListItem {
  const WorkoutListItem({
    required this.id,
    required this.title,
    required this.totalLabel,
    required this.repsLabel,
    required this.thumbnailAsset,
  });

  final String id;
  final String title;
  final String totalLabel;
  final String repsLabel;
  final String thumbnailAsset;
}

class WorkoutCategoryPage {
  const WorkoutCategoryPage({
    required this.title,
    required this.totalLabel,
    required this.description,
    required this.headerAsset,
    required this.items,
  });

  final String title;
  final String totalLabel;
  final String description;
  final String headerAsset;
  final List<WorkoutListItem> items;
}

class WorkoutPreviewPage {
  const WorkoutPreviewPage({
    required this.heroAsset,
    required this.totalLabel,
    required this.title,
    required this.coachLabel,
    required this.timeValue,
    required this.calorieValue,
    required this.setsValue,
  });

  final String heroAsset;
  final String totalLabel;
  final String title;
  final String coachLabel;
  final String timeValue;
  final String calorieValue;
  final String setsValue;
}

class WorkoutCompletePage {
  const WorkoutCompletePage({
    required this.heroAsset,
    required this.title,
    required this.burnedLabel,
    required this.minutes,
    required this.kcal,
    required this.bpm,
  });

  final String heroAsset;
  final String title;
  final String burnedLabel;
  final String minutes;
  final String kcal;
  final String bpm;
}
