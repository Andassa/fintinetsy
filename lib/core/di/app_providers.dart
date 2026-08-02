import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../../features/assessment/data/repositories/fake_assessment_repository.dart';
import '../../features/assessment/domain/repositories/assessment_repository.dart';
import '../../features/assessment/presentation/assessment_session.dart';
import '../../features/auth/data/repositories/fake_auth_repository.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/get_reset_methods_usecase.dart';
import '../../features/auth/domain/usecases/request_password_reset_usecase.dart';
import '../../features/auth/domain/usecases/sign_in_usecase.dart';
import '../../features/auth/domain/usecases/sign_up_usecase.dart';
import '../../features/home/data/repositories/fake_home_repository.dart';
import '../../features/home/domain/repositories/home_repository.dart';
import '../../features/home/domain/usecases/get_home_dashboard_usecase.dart';
import '../../features/nutrition/data/repositories/fake_nutrition_repository.dart';
import '../../features/nutrition/domain/repositories/nutrition_repository.dart';
import '../../features/search/data/repositories/fake_search_repository.dart';
import '../../features/search/domain/repositories/search_repository.dart';
import '../../features/search/domain/usecases/search_usecase.dart';
import '../../features/stats/data/repositories/fake_stats_repository.dart';
import '../../features/stats/domain/repositories/stats_repository.dart';

List<SingleChildWidget> buildAppProviders() {
  final authRepository = FakeAuthRepository();
  final homeRepository = FakeHomeRepository();
  final searchRepository = FakeSearchRepository();
  final assessmentRepository = FakeAssessmentRepository();
  final nutritionRepository = FakeNutritionRepository();
  final statsRepository = FakeStatsRepository();
  final assessmentSession = AssessmentSession(assessmentRepository)..init();

  return [
    Provider<AuthRepository>.value(value: authRepository),
    Provider(create: (_) => SignInUseCase(authRepository)),
    Provider(create: (_) => SignUpUseCase(authRepository)),
    Provider(create: (_) => GetResetMethodsUseCase(authRepository)),
    Provider(create: (_) => RequestPasswordResetUseCase(authRepository)),
    Provider<HomeRepository>.value(value: homeRepository),
    Provider(create: (_) => GetHomeDashboardUseCase(homeRepository)),
    Provider<SearchRepository>.value(value: searchRepository),
    Provider(create: (_) => SearchUseCase(searchRepository)),
    Provider<AssessmentRepository>.value(value: assessmentRepository),
    ChangeNotifierProvider<AssessmentSession>.value(value: assessmentSession),
    Provider<NutritionRepository>.value(value: nutritionRepository),
    Provider<StatsRepository>.value(value: statsRepository),
  ];
}
