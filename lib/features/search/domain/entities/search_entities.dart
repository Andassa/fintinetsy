enum SearchFilter { workout, meals, community }

class SearchSuggestion {
  const SearchSuggestion({required this.id, required this.label});
  final String id;
  final String label;
}

class SearchResultItem {
  const SearchResultItem({
    required this.id,
    required this.title,
    required this.matchPercent,
    required this.iconKey,
    required this.iconColorHex,
    this.badge,
    this.progress,
    this.checked = false,
  });

  final String id;
  final String title;
  final int matchPercent;
  final String iconKey;
  final String iconColorHex;
  final String? badge;
  final double? progress;
  final bool checked;
}

class SearchPageData {
  const SearchPageData({
    required this.suggestions,
    required this.results,
    required this.filters,
  });

  final List<SearchSuggestion> suggestions;
  final List<SearchResultItem> results;
  final List<SearchFilter> filters;
}
