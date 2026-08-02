import '../entities/search_entities.dart';
import '../repositories/search_repository.dart';

class SearchUseCase {
  const SearchUseCase(this._repository);
  final SearchRepository _repository;

  Future<SearchPageData> meta() => _repository.getSearchMeta();
  Future<List<SearchSuggestion>> suggestions(String query) =>
      _repository.getSuggestions(query);
  Future<List<SearchResultItem>> search(String query) =>
      _repository.search(query);
}
