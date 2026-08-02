import '../../../../core/network/api_client.dart';
import '../../domain/entities/search_entities.dart';
import '../../domain/repositories/search_repository.dart';

class HttpSearchRepository implements SearchRepository {
  HttpSearchRepository(this._api);

  final ApiClient _api;

  @override
  Future<SearchPageData> getSearchMeta() async {
    final suggestions = await getSuggestions('');
    final results = await search('');
    return SearchPageData(
      suggestions: suggestions,
      results: results,
      filters: const [
        SearchFilter.workout,
        SearchFilter.meals,
        SearchFilter.community,
      ],
    );
  }

  @override
  Future<List<SearchSuggestion>> getSuggestions(String query) async {
    final response = await _api.raw.get<List<dynamic>>(
      '/search/suggestions',
      queryParameters: {'q': query},
    );
    return (response.data ?? []).map((raw) {
      final m = raw as Map<String, dynamic>;
      return SearchSuggestion(
        id: m['id'].toString(),
        label: m['label'] as String,
      );
    }).toList();
  }

  @override
  Future<List<SearchResultItem>> search(String query) async {
    final response = await _api.raw.get<Map<String, dynamic>>(
      '/search',
      queryParameters: {'q': query},
    );
    final items =
        (response.data?['items'] as Map<String, dynamic>?)?['items']
            as List<dynamic>? ??
        [];
    return items.map((raw) {
      final m = raw as Map<String, dynamic>;
      return SearchResultItem(
        id: m['id'].toString(),
        title: m['title'] as String,
        matchPercent: m['match_percent'] as int,
        iconKey: m['icon_key'] as String,
        iconColorHex: m['icon_color_hex'] as String,
        badge: m['badge'] as String?,
        progress: (m['progress'] as num?)?.toDouble(),
        checked: m['checked'] as bool? ?? false,
      );
    }).toList();
  }
}
