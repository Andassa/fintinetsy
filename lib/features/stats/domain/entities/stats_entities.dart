class HydrationStats {
  const HydrationStats({
    required this.currentMl,
    required this.goalMl,
    required this.neededMl,
  });
  final int currentMl;
  final int goalMl;
  final int neededMl;
}

class HeartRateStats {
  const HeartRateStats({
    required this.bpm,
    required this.activityLabel,
    required this.pressure,
    required this.pressureUnit,
    required this.oxygen,
    required this.oxygenUnit,
    required this.heroAsset,
  });
  final int bpm;
  final String activityLabel;
  final int pressure;
  final String pressureUnit;
  final int oxygen;
  final String oxygenUnit;
  final String heroAsset;
}

class MacroBar {
  const MacroBar({
    required this.label,
    required this.percent,
    required this.grams,
    required this.colorHex,
  });
  final String label;
  final int percent;
  final int grams;
  final String colorHex;
}

class CalorieStatsData {
  const CalorieStatsData({
    required this.totalKcal,
    required this.monthLabel,
    required this.macros,
  });
  final int totalKcal;
  final String monthLabel;
  final List<MacroBar> macros;
}

class CalorieIntakePoint {
  const CalorieIntakePoint({required this.kcal, required this.index});
  final int kcal;
  final int index;
}

class CalorieIntakeData {
  const CalorieIntakeData({
    required this.totalKcal,
    required this.remainingKcal,
    required this.dateLabel,
    required this.points,
    required this.activePointIndex,
    required this.carbsG,
    required this.proteinG,
    required this.fatsG,
  });
  final int totalKcal;
  final int remainingKcal;
  final String dateLabel;
  final List<CalorieIntakePoint> points;
  final int activePointIndex;
  final int carbsG;
  final int proteinG;
  final int fatsG;
}

class ScoreSegment {
  const ScoreSegment({
    required this.label,
    required this.percent,
    required this.colorHex,
  });
  final String label;
  final int percent;
  final String colorHex;
}

class UpliftScoreData {
  const UpliftScoreData({
    required this.score,
    required this.message,
    required this.segments,
  });
  final int score;
  final String message;
  final List<ScoreSegment> segments;
}

class DonutSegment {
  const DonutSegment({
    required this.label,
    required this.percent,
    required this.colorHex,
  });
  final String label;
  final int percent;
  final String colorHex;
}

class JoggingCompletedData {
  const JoggingCompletedData({
    required this.title,
    required this.segments,
    required this.suggestionTitle,
    required this.suggestionSubtitle,
  });
  final String title;
  final List<DonutSegment> segments;
  final String suggestionTitle;
  final String suggestionSubtitle;
}

class ActivityStatusItem {
  const ActivityStatusItem({
    required this.label,
    required this.hoursLabel,
    required this.colorHex,
    required this.rotationDeg,
    required this.width,
    required this.height,
    required this.dx,
    required this.dy,
  });
  final String label;
  final String hoursLabel;
  final String colorHex;
  final double rotationDeg;
  final double width;
  final double height;
  final double dx;
  final double dy;
}

class ActivityStatusData {
  const ActivityStatusData({required this.items});
  final List<ActivityStatusItem> items;
}

class DirectionsData {
  const DirectionsData({
    required this.address,
    required this.instruction,
    required this.distanceLeft,
    required this.arrivalLabel,
    required this.thumbnailAsset,
  });
  final String address;
  final String instruction;
  final String distanceLeft;
  final String arrivalLabel;
  final String thumbnailAsset;
}
