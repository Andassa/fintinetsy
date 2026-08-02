import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

import 'package:fintinetsy/core/network/api_client.dart';
import 'package:fintinetsy/core/network/etag_cache.dart';
import 'package:fintinetsy/core/network/token_storage.dart';
import 'package:fintinetsy/features/search/data/repositories/http_search_repository.dart';
import 'package:fintinetsy/features/workout/data/repositories/http_workout_repository.dart';

void main() {
  late Dio dio;
  late DioAdapter adapter;
  late ApiClient api;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'http://test/api/v1'));
    adapter = DioAdapter(dio: dio);
    api = ApiClient(
      tokenStorage: TokenStorage.memory(),
      etagCache: EtagCache.memory(),
      dio: dio,
    );
  });

  test('HttpSearchRepository.search maps cursor page items', () async {
    final repository = HttpSearchRepository(api);
    adapter.onGet(
      '/search',
      (server) => server.reply(200, {
        'items': {
          'items': [
            {
              'id': 's1',
              'title': 'Push-ups',
              'match_percent': 92,
              'icon_key': 'workout',
              'icon_color_hex': '#FF7101',
              'badge': null,
              'progress': null,
              'checked': false,
            },
          ],
          'next_cursor': null,
          'has_more': false,
        },
      }),
      queryParameters: {'q': 'push'},
    );

    final results = await repository.search('push');
    expect(results, hasLength(1));
    expect(results.first.title, 'Push-ups');
    expect(results.first.matchPercent, 92);
  });

  test('HttpWorkoutRepository.getBrowsePage maps browse payload', () async {
    final repository = HttpWorkoutRepository(api);
    adapter.onGet(
      '/workouts/browse',
      (server) => server.reply(200, {
        'title': 'Personalized Workouts',
        'subtitle': 'Pick a category',
        'hero_image_url': 'https://cdn.example/browse.png',
        'active_dot_index': 0,
        'dot_count': 3,
      }),
    );

    final page = await repository.getBrowsePage();
    expect(page.title, 'Personalized Workouts');
    expect(page.dotCount, 3);
    expect(page.heroAsset, contains('browse.png'));
  });
}
