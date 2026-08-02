import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/assessment/presentation/screens/assessment_placeholder_screen.dart';
import '../../features/auth/presentation/screens/password_sent_screen.dart';
import '../../features/auth/presentation/screens/reset_password_screen.dart';
import '../../features/auth/presentation/screens/sign_in_screen.dart';
import '../../features/auth/presentation/screens/sign_up_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';
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
      builder: (context, state) => const AssessmentPlaceholderScreen(
        title: "What's your Age?",
        step: 1,
        totalSteps: 6,
        nextRouteName: RouteNames.assessmentWeight,
      ),
    ),
    GoRoute(
      path: AppRoutes.assessmentWeight,
      name: RouteNames.assessmentWeight,
      builder: (context, state) => const AssessmentPlaceholderScreen(
        title: "What's your current weight right now?",
        step: 2,
        totalSteps: 6,
        nextRouteName: RouteNames.assessmentFitnessLevel,
      ),
    ),
    GoRoute(
      path: AppRoutes.assessmentFitnessLevel,
      name: RouteNames.assessmentFitnessLevel,
      builder: (context, state) => const AssessmentPlaceholderScreen(
        title: 'How would you rate your fitness level?',
        step: 3,
        totalSteps: 6,
        nextRouteName: RouteNames.assessmentGender,
      ),
    ),
    GoRoute(
      path: AppRoutes.assessmentGender,
      name: RouteNames.assessmentGender,
      builder: (context, state) => const AssessmentPlaceholderScreen(
        title: 'What is your gender?',
        step: 4,
        totalSteps: 6,
        nextRouteName: RouteNames.assessmentVocal,
      ),
    ),
    GoRoute(
      path: AppRoutes.assessmentVocal,
      name: RouteNames.assessmentVocal,
      builder: (context, state) => const AssessmentPlaceholderScreen(
        title: 'AI Vocal Analysis',
        step: 5,
        totalSteps: 6,
        nextRouteName: RouteNames.assessmentGoals,
      ),
    ),
    GoRoute(
      path: AppRoutes.assessmentGoals,
      name: RouteNames.assessmentGoals,
      builder: (context, state) => const AssessmentPlaceholderScreen(
        title: "What's your fitness goal/target?",
        step: 6,
        totalSteps: 6,
        nextRouteName: RouteNames.home,
      ),
    ),
    GoRoute(
      path: AppRoutes.home,
      name: RouteNames.home,
      builder: (context, state) => const HomePlaceholderScreen(),
    ),
    GoRoute(
      path: AppRoutes.addMeal,
      name: RouteNames.addMeal,
      builder: (context, state) => const Scaffold(
        body: Center(child: Text('Add Meal — coming next')),
      ),
    ),
    GoRoute(
      path: AppRoutes.mealScan,
      name: RouteNames.mealScan,
      builder: (context, state) => const Scaffold(
        body: Center(child: Text('Meal Scan — coming next')),
      ),
    ),
    GoRoute(
      path: AppRoutes.activity,
      name: RouteNames.activity,
      builder: (context, state) => const Scaffold(
        body: Center(child: Text('Activity Status — coming next')),
      ),
    ),
  ],
);
