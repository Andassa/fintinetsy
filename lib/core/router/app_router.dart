import 'package:go_router/go_router.dart';

import '../../features/activity/presentation/screens/activity_status_screen.dart';
import '../../features/activity/presentation/screens/add_activity_screen.dart';
import '../../features/activity/presentation/screens/directions_map_screen.dart';
import '../../features/activity/presentation/screens/no_activities_screen.dart';
import '../../features/assessment/presentation/screens/age_assessment_screen.dart';
import '../../features/assessment/presentation/screens/fitness_level_assessment_screen.dart';
import '../../features/assessment/presentation/screens/gender_assessment_screen.dart';
import '../../features/assessment/presentation/screens/goals_assessment_screen.dart';
import '../../features/assessment/presentation/screens/vocal_assessment_screen.dart';
import '../../features/assessment/presentation/screens/weight_assessment_screen.dart';
import '../../features/auth/presentation/screens/password_sent_screen.dart';
import '../../features/auth/presentation/screens/reset_password_screen.dart';
import '../../features/auth/presentation/screens/sign_in_screen.dart';
import '../../features/auth/presentation/screens/sign_up_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/nutrition/presentation/screens/add_meal_screen.dart';
import '../../features/nutrition/presentation/screens/food_scan_screen.dart';
import '../../features/search/presentation/screens/search_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/stats/presentation/screens/calorie_intake_screen.dart';
import '../../features/stats/presentation/screens/calorie_stats_screen.dart';
import '../../features/stats/presentation/screens/heart_rate_screen.dart';
import '../../features/stats/presentation/screens/hydration_screen.dart';
import '../../features/stats/presentation/screens/jogging_completed_screen.dart';
import '../../features/stats/presentation/screens/uplift_score_screen.dart';
import '../../features/welcome/presentation/welcome_screen.dart';
import 'route_names.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      name: RouteNames.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.welcome,
      name: RouteNames.welcome,
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.signIn,
      name: RouteNames.signIn,
      builder: (context, state) => const SignInScreen(),
    ),
    GoRoute(
      path: AppRoutes.signUp,
      name: RouteNames.signUp,
      builder: (context, state) => const SignUpScreen(),
    ),
    GoRoute(
      path: AppRoutes.resetPassword,
      name: RouteNames.resetPassword,
      builder: (context, state) => const ResetPasswordScreen(),
    ),
    GoRoute(
      path: AppRoutes.passwordSent,
      name: RouteNames.passwordSent,
      builder: (context, state) {
        final email = state.uri.queryParameters['email'] ?? '221b@gmail.com';
        return PasswordSentScreen(email: email);
      },
    ),
    GoRoute(
      path: AppRoutes.assessmentAge,
      name: RouteNames.assessmentAge,
      builder: (context, state) => const AgeAssessmentScreen(),
    ),
    GoRoute(
      path: AppRoutes.assessmentWeight,
      name: RouteNames.assessmentWeight,
      builder: (context, state) => const WeightAssessmentScreen(),
    ),
    GoRoute(
      path: AppRoutes.assessmentFitnessLevel,
      name: RouteNames.assessmentFitnessLevel,
      builder: (context, state) => const FitnessLevelAssessmentScreen(),
    ),
    GoRoute(
      path: AppRoutes.assessmentGender,
      name: RouteNames.assessmentGender,
      builder: (context, state) => const GenderAssessmentScreen(),
    ),
    GoRoute(
      path: AppRoutes.assessmentVocal,
      name: RouteNames.assessmentVocal,
      builder: (context, state) => const VocalAssessmentScreen(),
    ),
    GoRoute(
      path: AppRoutes.assessmentGoals,
      name: RouteNames.assessmentGoals,
      builder: (context, state) => const GoalsAssessmentScreen(),
    ),
    GoRoute(
      path: AppRoutes.home,
      name: RouteNames.home,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.search,
      name: RouteNames.search,
      builder: (context, state) {
        final q = state.uri.queryParameters['q'];
        return SearchScreen(initialQuery: q ?? 'Fitness AI Assis');
      },
    ),
    GoRoute(
      path: AppRoutes.noActivities,
      name: RouteNames.noActivities,
      builder: (context, state) => const NoActivitiesScreen(),
    ),
    GoRoute(
      path: AppRoutes.addActivity,
      name: RouteNames.addActivity,
      builder: (context, state) => const AddActivityScreen(),
    ),
    GoRoute(
      path: AppRoutes.activityStatus,
      name: RouteNames.activityStatus,
      builder: (context, state) => const ActivityStatusScreen(),
    ),
    GoRoute(
      path: AppRoutes.directions,
      name: RouteNames.directions,
      builder: (context, state) => const DirectionsMapScreen(),
    ),
    GoRoute(
      path: AppRoutes.joggingCompleted,
      name: RouteNames.joggingCompleted,
      builder: (context, state) => const JoggingCompletedScreen(),
    ),
    GoRoute(
      path: AppRoutes.addMeal,
      name: RouteNames.addMeal,
      builder: (context, state) => const AddMealScreen(),
    ),
    GoRoute(
      path: AppRoutes.mealScan,
      name: RouteNames.mealScan,
      builder: (context, state) => const FoodScanScreen(),
    ),
    GoRoute(
      path: AppRoutes.activity,
      name: RouteNames.activity,
      builder: (context, state) => const ActivityStatusScreen(),
    ),
    GoRoute(
      path: AppRoutes.hydration,
      name: RouteNames.hydration,
      builder: (context, state) => const HydrationScreen(),
    ),
    GoRoute(
      path: AppRoutes.heartRate,
      name: RouteNames.heartRate,
      builder: (context, state) => const HeartRateScreen(),
    ),
    GoRoute(
      path: AppRoutes.calorieStats,
      name: RouteNames.calorieStats,
      builder: (context, state) => const CalorieStatsScreen(),
    ),
    GoRoute(
      path: AppRoutes.calorieIntake,
      name: RouteNames.calorieIntake,
      builder: (context, state) => const CalorieIntakeScreen(),
    ),
    GoRoute(
      path: AppRoutes.upliftScore,
      name: RouteNames.upliftScore,
      builder: (context, state) => const UpliftScoreScreen(),
    ),
  ],
);
