import 'package:flutter/foundation.dart';

import '../domain/entities/assessment_entities.dart';
import '../domain/repositories/assessment_repository.dart';

class AssessmentSession extends ChangeNotifier {
  AssessmentSession(this._repository);

  final AssessmentRepository _repository;
  AssessmentConfig? config;
  AssessmentProfile profile = AssessmentProfile();
  bool loading = true;

  Future<void> init() async {
    loading = true;
    notifyListeners();
    config = await _repository.getConfig();
    profile = await _repository.getProfile();
    loading = false;
    notifyListeners();
  }

  Future<void> persist() => _repository.saveProfile(profile);

  void setAge(int age) {
    profile.age = age;
    notifyListeners();
  }

  void setWeight(double kg, WeightUnit unit) {
    profile.weightKg = kg;
    profile.weightUnit = unit;
    notifyListeners();
  }

  void setFitnessLevel(int level) {
    profile.fitnessLevel = level;
    notifyListeners();
  }

  void setGender(GenderOption? gender) {
    profile.gender = gender;
    notifyListeners();
  }

  void setGoal(String id) {
    profile.goalId = id;
    notifyListeners();
  }

  void completeVocal() {
    profile.vocalCompleted = true;
    notifyListeners();
  }
}
