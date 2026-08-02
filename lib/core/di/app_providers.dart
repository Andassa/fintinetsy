import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../../features/assessment/data/repositories/fake_assessment_repository.dart';
import '../../features/assessment/domain/repositories/assessment_repository.dart';
import '../../features/assessment/presentation/assessment_session.dart';
import '../../features/auth/data/repositories/fake_auth_repository.dart';
import '../../features/auth/data/repositories/http_auth_repository.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/get_reset_methods_usecase.dart';
import '../../features/auth/domain/usecases/request_password_reset_usecase.dart';
import '../../features/auth/domain/usecases/sign_in_usecase.dart';
import '../../features/auth/domain/usecases/sign_up_usecase.dart';
import '../../features/coach/data/repositories/fake_coach_repository.dart';
import '../../features/coach/domain/repositories/coach_repository.dart';
import '../../features/home/data/repositories/fake_home_repository.dart';
import '../../features/home/data/repositories/http_home_repository.dart';
import '../../features/home/domain/repositories/home_repository.dart';
import '../../features/home/domain/usecases/get_home_dashboard_usecase.dart';
import '../../features/nutrition/data/repositories/fake_nutrition_repository.dart';
import '../../features/nutrition/domain/repositories/nutrition_repository.dart';
import '../../features/profile/data/repositories/fake_profile_repository.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/search/data/repositories/fake_search_repository.dart';
import '../../features/search/data/repositories/http_search_repository.dart';
import '../../features/search/domain/repositories/search_repository.dart';
import '../../features/search/domain/usecases/search_usecase.dart';
import '../../features/settings/data/repositories/fake_settings_repository.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';
import '../../features/stats/data/repositories/fake_stats_repository.dart';
import '../../features/stats/domain/repositories/stats_repository.dart';
import '../../features/workout/data/repositories/fake_workout_repository.dart';
import '../../features/workout/domain/repositories/workout_repository.dart';
import '../auth/auth_session.dart';
import '../network/api_client.dart';
import '../network/api_config.dart';
import '../network/etag_cache.dart';
import '../network/token_storage.dart';
import '../theme/theme_controller.dart';

class AppBinding {
  AppBinding({
    required this.providers,
    required this.authSession,
  });

  final List<SingleChildWidget> providers;
  final AuthSession authSession;
}

Future<AppBinding> buildAppBinding() async {
  final tokens = TokenStorage();
  final etagCache = await EtagCache.open();
  final authSession = AuthSession(tokens);
  await authSession.bootstrap();

  late final ApiClient api;
  api = ApiClient(
    tokenStorage: tokens,
    etagCache: etagCache,
    onUnauthorized: () {
      authSession.clear();
    },
  );

  final AuthRepository authRepository;
  final HomeRepository homeRepository;
  final SearchRepository searchRepository;

  if (ApiConfig.useRemoteApi) {
    debugPrint('Using remote API at ${ApiConfig.baseUrl}');
    authRepository = HttpAuthRepository(
      api: api,
      tokens: tokens,
      session: authSession,
    );
    homeRepository = HttpHomeRepository(api);
    searchRepository = HttpSearchRepository(api);
  } else {
    authRepository = FakeAuthRepository();
    homeRepository = FakeHomeRepository();
    searchRepository = FakeSearchRepository();
  }

  final assessmentRepository = FakeAssessmentRepository();
  final nutritionRepository = FakeNutritionRepository();
  final statsRepository = FakeStatsRepository();
  final settingsRepository = FakeSettingsRepository();
  final profileRepository = FakeProfileRepository();
  final coachRepository = FakeCoachRepository();
  final workoutRepository = FakeWorkoutRepository();
  final assessmentSession = AssessmentSession(assessmentRepository)..init();
  final themeController = ThemeController();

  final providers = <SingleChildWidget>[
    ChangeNotifierProvider<ThemeController>.value(value: themeController),
    ChangeNotifierProvider<AuthSession>.value(value: authSession),
    Provider<TokenStorage>.value(value: tokens),
    Provider<ApiClient>.value(value: api),
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
    Provider<SettingsRepository>.value(value: settingsRepository),
    Provider<ProfileRepository>.value(value: profileRepository),
    Provider<CoachRepository>.value(value: coachRepository),
    Provider<WorkoutRepository>.value(value: workoutRepository),
  ];

  return AppBinding(providers: providers, authSession: authSession);
}
