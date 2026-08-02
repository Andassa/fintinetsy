import '../entities/stats_entities.dart';

abstract class StatsRepository {
  Future<HydrationStats> getHydration();
  Future<HeartRateStats> getHeartRate();
  Future<CalorieStatsData> getCalorieStats();
  Future<CalorieIntakeData> getCalorieIntake();
  Future<UpliftScoreData> getUpliftScore();
  Future<JoggingCompletedData> getJoggingCompleted();
  Future<ActivityStatusData> getActivityStatus();
  Future<DirectionsData> getDirections();
}
