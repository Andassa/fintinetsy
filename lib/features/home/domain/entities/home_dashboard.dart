class HomeUserGreeting {
  const HomeUserGreeting({
    required this.name,
    required this.dateLabel,
    required this.kcal,
    required this.hungerStatus,
    required this.notificationCount,
    required this.avatarAsset,
  });

  final String name;
  final String dateLabel;
  final int kcal;
  final String hungerStatus;
  final int notificationCount;
  final String avatarAsset;
}

class HomeCategory {
  const HomeCategory({
    required this.id,
    required this.label,
    required this.iconKey,
    required this.isSelected,
  });

  final String id;
  final String label;
  final String iconKey;
  final bool isSelected;
}

class HomeWorkoutCard {
  const HomeWorkoutCard({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.durationMin,
    required this.kcal,
    required this.imageAsset,
  });

  final String id;
  final String title;
  final String subtitle;
  final int durationMin;
  final int kcal;
  final String imageAsset;
}

class HomeDietCard {
  const HomeDietCard({
    required this.id,
    required this.title,
    required this.kcal,
    required this.durationMin,
    required this.proteinG,
    required this.fatsG,
    required this.imageAsset,
  });

  final String id;
  final String title;
  final int kcal;
  final int durationMin;
  final int proteinG;
  final int fatsG;
  final String imageAsset;
}

class HomeActivityBlob {
  const HomeActivityBlob({
    required this.hoursLabel,
    required this.colorHex,
    required this.rotationDeg,
    required this.widthFactor,
    required this.heightFactor,
    required this.alignment,
  });

  final String hoursLabel;
  final String colorHex;
  final double rotationDeg;
  final double widthFactor;
  final double heightFactor;
  final AlignmentData alignment;
}

class AlignmentData {
  const AlignmentData(this.x, this.y);
  final double x;
  final double y;
}

class HomeAiCoachCard {
  const HomeAiCoachCard({
    required this.conversationsLabel,
    required this.subtitle,
    required this.imageAsset,
  });

  final String conversationsLabel;
  final String subtitle;
  final String imageAsset;
}

class HomeDashboard {
  const HomeDashboard({
    required this.user,
    required this.categories,
    required this.workout,
    required this.diet,
    required this.activities,
    required this.aiCoach,
  });

  final HomeUserGreeting user;
  final List<HomeCategory> categories;
  final HomeWorkoutCard workout;
  final HomeDietCard diet;
  final List<HomeActivityBlob> activities;
  final HomeAiCoachCard aiCoach;
}
