import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

import 'package:fintinetsy/core/network/api_client.dart';
import 'package:fintinetsy/core/offline/offline_cache.dart';
import 'package:fintinetsy/core/network/token_storage.dart';
import 'package:fintinetsy/features/coach/data/repositories/http_coach_repository.dart';
import 'package:fintinetsy/features/nutrition/data/repositories/http_nutrition_repository.dart';
import 'package:fintinetsy/features/stats/data/repositories/http_stats_repository.dart';

void main() {
  late Dio dio;
  late DioAdapter adapter;
  late ApiClient api;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'http://test/api/v1'));
    adapter = DioAdapter(dio: dio);
    api = ApiClient(
      tokenStorage: TokenStorage.memory(),
      offlineCache: OfflineCache.memory(),
      dio: dio,
    );
  });

  test('HttpNutritionRepository maps meal draft from API', () async {
    adapter.onGet(
      '/meals/draft',
      (server) => server.reply(200, {
        'name': '',
        'type': 'dinner',
        'protein_g': 20,
        'carbs_g': 25,
        'fat_g': 15,
        'entry_method': 'manual',
        'image_url': null,
      }),
    );

    final draft = await HttpNutritionRepository(api).getDefaultMealDraft();
    expect(draft.protein, 20);
    expect(draft.carbs, 25);
    expect(draft.type.name, 'dinner');
  });

  test('HttpStatsRepository maps hydration from API', () async {
    adapter.onGet(
      '/stats/hydration',
      (server) => server.reply(200, {
        'current_ml': 500,
        'goal_ml': 2000,
        'needed_ml': 1500,
      }),
    );

    final hydration = await HttpStatsRepository(api).getHydration();
    expect(hydration.currentMl, 500);
    expect(hydration.neededMl, 1500);
  });

  test('HttpCoachRepository maps hub conversations from API', () async {
    adapter.onGet(
      '/coach/hub',
      (server) => server.reply(200, {
        'total_conversations': '9,781',
        'total_label': '245total',
        'model_label': 'Gpt4.0',
        'conversations': [
          {
            'id': 'c1',
            'title': 'How to bulk faster?',
            'model': 'Gpt4.0',
            'total_label': '456 Total',
            'icon_key': 'restaurant',
            'color_hex': '#FF7D33',
          },
        ],
        'pro_title': 'Go Pro, Now!',
        'pro_benefits': ['Weekend Cheat'],
      }),
    );

    final hub = await HttpCoachRepository(api).getHub();
    expect(hub.conversations, hasLength(1));
    expect(hub.conversations.first.title, contains('bulk'));
  });
}
