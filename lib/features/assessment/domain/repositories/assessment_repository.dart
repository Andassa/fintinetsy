import '../entities/assessment_entities.dart';

abstract class AssessmentRepository {
  Future<AssessmentConfig> getConfig();
  Future<AssessmentProfile> getProfile();
  Future<void> saveProfile(AssessmentProfile profile);
}
