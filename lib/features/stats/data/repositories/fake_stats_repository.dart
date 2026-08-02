import '../../../../core/theme/app_assets.dart';
import '../../domain/entities/stats_entities.dart';
import '../../domain/repositories/stats_repository.dart';

class FakeStatsRepository implements StatsRepository {
  @override
  Future<HydrationStats> getHydration() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return const HydrationStats(currentMl: 500, goalMl: 2000, neededMl: 1500);
  }

  @override
  Future<HeartRateStats> getHeartRate() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return const HeartRateStats(
      bpm: 112,
      activityLabel: 'Currently doing: Basketball',
      pressure: 112,
      pressureUnit: 'mmHg',
      oxygen: 112,
      oxygenUnit: 'SpO2',
      heroAsset: AppAssets.basketballPlayer,
    );
  }

  @override
  Future<CalorieStatsData> getCalorieStats() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return const CalorieStatsData(
      totalKcal: 318,
      monthLabel: 'Jan',
      macros: [
        MacroBar(label: 'Fat', percent: 20, grams: 201, colorHex: '#000000'),
        MacroBar(label: 'Protein', percent: 30, grams: 201, colorHex: '#2F69FF'),
        MacroBar(label: 'Carbs', percent: 10, grams: 201, colorHex: '#FF7A00'),
        MacroBar(label: 'Macro', percent: 25, grams: 201, colorHex: '#8CC622'),
      ],
    );
  }

  @override
  Future<CalorieIntakeData> getCalorieIntake() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return const CalorieIntakeData(
      totalKcal: 1745,
      remainingKcal: 158,
      dateLabel: 'January 2024',
      points: [
        CalorieIntakePoint(kcal: 1650, index: 0),
        CalorieIntakePoint(kcal: 1720, index: 1),
        CalorieIntakePoint(kcal: 1578, index: 2),
        CalorieIntakePoint(kcal: 1810, index: 3),
        CalorieIntakePoint(kcal: 1760, index: 4),
        CalorieIntakePoint(kcal: 1900, index: 5),
      ],
      activePointIndex: 2,
      carbsG: 125,
      proteinG: 15,
      fatsG: 5,
    );
  }

  @override
  Future<UpliftScoreData> getUpliftScore() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return const UpliftScoreData(
      score: 88,
      message: 'You are a healthy individual',
      segments: [
        ScoreSegment(label: 'Strength', percent: 26, colorHex: '#FF7A21'),
        ScoreSegment(label: 'Endurance', percent: 24, colorHex: '#A283F1'),
        ScoreSegment(label: 'Agility', percent: 54, colorHex: '#333333'),
      ],
    );
  }

  @override
  Future<JoggingCompletedData> getJoggingCompleted() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return const JoggingCompletedData(
      title: 'Jogging Completed',
      segments: [
        DonutSegment(label: 'Distance', percent: 26, colorHex: '#FF9547'),
        DonutSegment(label: 'Calorie', percent: 24, colorHex: '#A283F1'),
        DonutSegment(label: 'BPM', percent: 54, colorHex: '#3F3F3F'),
      ],
      suggestionTitle: 'Post Jogging Stretch',
      suggestionSubtitle: '+12 More AI Suggestions',
    );
  }

  @override
  Future<ActivityStatusData> getActivityStatus() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return const ActivityStatusData(
      items: [
        ActivityStatusItem(
          label: 'Running',
          hoursLabel: '68h',
          colorHex: '#000000',
          rotationDeg: 40,
          width: 140,
          height: 170,
          dx: 0.05,
          dy: 0.1,
        ),
        ActivityStatusItem(
          label: 'Yoga',
          hoursLabel: '87h',
          colorHex: '#EBEBEB',
          rotationDeg: -25,
          width: 130,
          height: 160,
          dx: -0.15,
          dy: -0.05,
        ),
        ActivityStatusItem(
          label: 'Weightlifting',
          hoursLabel: '15h',
          colorHex: '#2962FF',
          rotationDeg: 15,
          width: 100,
          height: 110,
          dx: 0.55,
          dy: 0.45,
        ),
        ActivityStatusItem(
          label: 'Jogging',
          hoursLabel: '1h',
          colorHex: '#FF7A21',
          rotationDeg: -40,
          width: 80,
          height: 90,
          dx: 0.5,
          dy: -0.55,
        ),
        ActivityStatusItem(
          label: 'Biking',
          hoursLabel: '7h',
          colorHex: '#FF4B4B',
          rotationDeg: -70,
          width: 75,
          height: 85,
          dx: -0.55,
          dy: -0.45,
        ),
      ],
    );
  }

  @override
  Future<DirectionsData> getDirections() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return const DirectionsData(
      address: '3 Birrel Avenue',
      instruction: 'Turn right',
      distanceLeft: '10 Mtr Left',
      arrivalLabel: 'Arrival ( 2 mins )',
      thumbnailAsset: AppAssets.workoutStrength,
    );
  }
}
