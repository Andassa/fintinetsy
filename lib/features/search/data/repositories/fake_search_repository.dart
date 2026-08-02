import '../../domain/entities/search_entities.dart';
import '../../domain/repositories/search_repository.dart';

class FakeSearchRepository implements SearchRepository {
  static const _allSuggestions = [
    SearchSuggestion(id: 's1', label: 'Fitness'),
    SearchSuggestion(id: 's2', label: 'My Fitness Schedule'),
    SearchSuggestion(id: 's3', label: 'Fitness Ai Assistant'),
    SearchSuggestion(id: 's4', label: 'Visual AI Coach'),
    SearchSuggestion(id: 's5', label: 'AR/VR Fitness Videos'),
    SearchSuggestion(id: 's6', label: 'Fitness App'),
  ];

  static const _allResults = [
    SearchResultItem(
      id: 'r1',
      title: 'Virtual AI Coach',
      matchPercent: 98,
      iconKey: 'notifications',
      iconColorHex: '#FFFFFF',
      badge: '4+',
    ),
    SearchResultItem(
      id: 'r2',
      title: 'Activity Tracker',
      matchPercent: 78,
      iconKey: 'directions_run',
      iconColorHex: '#FF7A21',
      badge: '8+',
    ),
    SearchResultItem(
      id: 'r3',
      title: 'Coach Farness',
      matchPercent: 67,
      iconKey: 'chat_bubble',
      iconColorHex: '#2F69FF',
      progress: 0.6,
    ),
    SearchResultItem(
      id: 'r4',
      title: 'AI Fitness Assisstant',
      matchPercent: 82,
      iconKey: 'fitness_center',
      iconColorHex: '#8CC622',
      checked: true,
    ),
    SearchResultItem(
      id: 'r5',
      title: 'Workout Course',
      matchPercent: 55,
      iconKey: 'play_arrow',
      iconColorHex: '#8A2BE2',
    ),
    SearchResultItem(
      id: 'r6',
      title: 'AI Workout',
      matchPercent: 48,
      iconKey: 'cloud',
      iconColorHex: '#FF4B4B',
    ),
  ];

  @override
  Future<SearchPageData> getSearchMeta() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return const SearchPageData(
      suggestions: _allSuggestions,
      results: _allResults,
      filters: [
        SearchFilter.workout,
        SearchFilter.meals,
        SearchFilter.community,
      ],
    );
  }

  @override
  Future<List<SearchSuggestion>> getSuggestions(String query) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return _allSuggestions;
    return _allSuggestions
        .where((s) => s.label.toLowerCase().contains(q))
        .toList();
  }

  @override
  Future<List<SearchResultItem>> search(String query) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return _allResults;

    // Explicit not-found demos + unmatched queries
    if (q.contains('zzzz') || q == 'xyz' || q.contains('not found')) {
      return const [];
    }

    final filtered = _allResults
        .where(
          (r) =>
              r.title.toLowerCase().contains(q) ||
              q.contains('fitness') ||
              q.contains('ai') ||
              q.contains('coach') ||
              q.contains('workout') ||
              q.contains('activity'),
        )
        .toList();
    return filtered;
  }
}
