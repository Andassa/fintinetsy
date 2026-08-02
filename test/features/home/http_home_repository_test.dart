import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

import 'package:fintinetsy/core/network/api_client.dart';
import 'package:fintinetsy/core/offline/offline_cache.dart';
import 'package:fintinetsy/core/network/token_storage.dart';
import 'package:fintinetsy/features/home/data/repositories/http_home_repository.dart';

void main() {
  late Dio dio;
  late DioAdapter adapter;
  late HttpHomeRepository repository;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'http://test/api/v1'));
    adapter = DioAdapter(dio: dio);
    final api = ApiClient(
      tokenStorage: TokenStorage.memory(),
      offlineCache: OfflineCache.memory(),
      dio: dio,
    );
    repository = HttpHomeRepository(api);
  });

  test('getDashboard maps REST payload to HomeDashboard', () async {
    adapter.onGet(
      '/home/dashboard',
      (server) => server.reply(200, {
        'user': {
          'name': 'Alex',
          'date': '2026-08-02T10:00:00Z',
          'kcal': 420,
          'hunger_status': 'Normal',
          'notification_count': 2,
          'avatar_url': 'https://cdn.example/a.png',
        },
        'categories': [
          {
            'id': 'workout',
            'label': 'Workout',
            'icon_key': 'dumbbell',
            'is_selected': true,
          },
        ],
        'workout': {
          'id': 'w1',
          'title': 'Morning HIIT',
          'subtitle': 'Full body',
          'duration_minutes': 30,
          'calories': 280,
          'image_url': 'https://cdn.example/w.png',
        },
        'diet': {
          'id': 'd1',
          'title': 'Protein bowl',
          'calories': 520,
          'duration_minutes': 15,
          'protein_g': 40,
          'fats_g': 12,
          'image_url': 'https://cdn.example/d.png',
        },
        'activities': [
          {
            'hours_label': '2h',
            'color_hex': '#FF7101',
            'rotation_deg': 12.0,
            'width_factor': 0.4,
            'height_factor': 0.3,
            'alignment': {'x': 0.1, 'y': -0.2},
          },
        ],
        'ai_coach': {
          'conversations_count': 3,
          'subtitle': 'Ask me anything',
          'image_url': 'https://cdn.example/c.png',
        },
      }),
    );

    final dashboard = await repository.getDashboard();

    expect(dashboard.user.name, 'Alex');
    expect(dashboard.user.kcal, 420);
    expect(dashboard.categories, hasLength(1));
    expect(dashboard.workout.title, 'Morning HIIT');
    expect(dashboard.diet.proteinG, 40);
    expect(dashboard.activities.first.hoursLabel, '2h');
    expect(dashboard.aiCoach.conversationsLabel, '3 Conversations');
  });
}
