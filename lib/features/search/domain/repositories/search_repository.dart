import '../entities/search_entities.dart';

abstract class SearchRepository {
  Future<SearchPageData> getSearchMeta();
  Future<List<SearchSuggestion>> getSuggestions(String query);
  Future<List<SearchResultItem>> search(String query);
}
