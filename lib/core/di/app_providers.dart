import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../../features/assessment/data/repositories/http_assessment_repository.dart';
import '../../features/assessment/domain/repositories/assessment_repository.dart';
import '../../features/assessment/presentation/assessment_session.dart';
import '../../features/auth/data/repositories/http_auth_repository.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/get_reset_methods_usecase.dart';
import '../../features/auth/domain/usecases/request_password_reset_usecase.dart';
import '../../features/auth/domain/usecases/sign_in_usecase.dart';
import '../../features/auth/domain/usecases/sign_in_with_google_oauth_usecase.dart';
import '../../features/auth/domain/usecases/sign_up_usecase.dart';
import '../../features/coach/data/repositories/http_coach_repository.dart';
import '../../features/coach/domain/repositories/coach_repository.dart';
import '../../features/home/data/repositories/http_home_repository.dart';
import '../../features/home/domain/repositories/home_repository.dart';
import '../../features/home/domain/usecases/get_home_dashboard_usecase.dart';
import '../../features/nutrition/data/repositories/http_nutrition_repository.dart';
import '../../features/nutrition/domain/repositories/nutrition_repository.dart';
import '../../features/profile/data/repositories/http_profile_repository.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/search/data/repositories/http_search_repository.dart';
import '../../features/search/domain/repositories/search_repository.dart';
import '../../features/search/domain/usecases/search_usecase.dart';
import '../../features/settings/data/repositories/http_settings_repository.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';
import '../../features/stats/data/repositories/http_stats_repository.dart';
import '../../features/stats/domain/repositories/stats_repository.dart';
import '../../features/workout/data/repositories/http_workout_repository.dart';
import '../../features/workout/domain/repositories/workout_repository.dart';
import '../auth/auth_session.dart';
import '../network/api_client.dart';
import '../network/api_config.dart';
import '../network/token_refresh_service.dart';
import '../network/token_storage.dart';
import '../offline/offline_cache.dart';
import '../offline/offline_status.dart';
import '../theme/theme_controller.dart';

class AppBinding {
  AppBinding({
    required this.providers,
    required this.authSession,
  });

  final List<SingleChildWidget> providers;
  final AuthSession authSession;
}

/// Wires every feature repository to the FastAPI backend.
///
/// Bootstrap order:
/// 1. Open Hive [OfflineCache]
/// 2. Restore JWT session via [AuthSession.bootstrap]
/// 3. Build [ApiClient] with refresh + offline interceptors
/// 4. Register HTTP repositories for each feature
Future<AppBinding> buildAppBinding() async {
  final tokens = TokenStorage();
  final offlineCache = await OfflineCache.open();
  final offlineStatus = OfflineStatus();
  final authSession = AuthSession(tokens);
  await authSession.bootstrap();

  final api = ApiClient(
    tokenStorage: tokens,
    offlineCache: offlineCache,
    offlineStatus: offlineStatus,
    onUnauthorized: authSession.clear,
  );

  debugPrint(
    'API ${ApiConfig.baseUrl} | Hive offline=${offlineCache.isHiveBacked}',
  );

  final authRepository = HttpAuthRepository(
    api: api,
    tokens: tokens,
    session: authSession,
  );
  final homeRepository = HttpHomeRepository(api);
  final searchRepository = HttpSearchRepository(api);
  final assessmentRepository = HttpAssessmentRepository(api);
  final workoutRepository = HttpWorkoutRepository(api);
  final settingsRepository = HttpSettingsRepository(api);
  final nutritionRepository = HttpNutritionRepository(api);
  final statsRepository = HttpStatsRepository(api);
  final profileRepository = HttpProfileRepository(api);
  final coachRepository = HttpCoachRepository(api);

  final assessmentSession = AssessmentSession(assessmentRepository)..init();
  final themeController = ThemeController();

  final providers = <SingleChildWidget>[
    ChangeNotifierProvider<ThemeController>.value(value: themeController),
    ChangeNotifierProvider<AuthSession>.value(value: authSession),
    ChangeNotifierProvider<OfflineStatus>.value(value: offlineStatus),
    Provider<TokenStorage>.value(value: tokens),
    Provider<OfflineCache>.value(value: offlineCache),
    Provider<TokenRefreshService>.value(value: api.tokenRefreshService),
    Provider<ApiClient>.value(value: api),
    Provider<AuthRepository>.value(value: authRepository),
    Provider(create: (_) => SignInUseCase(authRepository)),
    Provider(create: (_) => SignInWithGoogleOAuthUseCase(authRepository)),
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
