import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/search_entities.dart';
import '../../domain/usecases/search_usecase.dart';
import '../widgets/search_result_tile.dart';
import '../widgets/search_states.dart';

enum _SearchUiState { idle, suggesting, loading, results, notFound }

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, this.initialQuery = 'Fitness AI Assis'});

  final String initialQuery;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final TextEditingController _controller;
  final FocusNode _focus = FocusNode();
  SearchFilter _filter = SearchFilter.workout;
  _SearchUiState _state = _SearchUiState.idle;
  List<SearchSuggestion> _suggestions = const [];
  List<SearchResultItem> _results = const [];
  Timer? _debounce;
  int _requestId = 0;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
    _bootstrap();
    _focus.addListener(() {
      if (_focus.hasFocus && _state != _SearchUiState.loading) {
        _loadSuggestions(_controller.text);
      }
    });
  }

  Future<void> _bootstrap() async {
    final meta = await context.read<SearchUseCase>().meta();
    if (!mounted) return;
    setState(() {
      _suggestions = meta.suggestions;
      _results = meta.results;
      _state = _SearchUiState.suggesting;
    });
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 220), () {
      _loadSuggestions(value);
    });
  }

  Future<void> _loadSuggestions(String query) async {
    final list = await context.read<SearchUseCase>().suggestions(query);
    if (!mounted) return;
    setState(() {
      _suggestions = list;
      _state = _SearchUiState.suggesting;
    });
  }

  Future<void> _submit([String? override]) async {
    final query = (override ?? _controller.text).trim();
    if (override != null) {
      _controller.text = override;
      _controller.selection =
          TextSelection.collapsed(offset: _controller.text.length);
    }
    _focus.unfocus();
    final id = ++_requestId;
    setState(() => _state = _SearchUiState.loading);

    final results = await context.read<SearchUseCase>().search(query);
    if (!mounted || id != _requestId) return;

    setState(() {
      _results = results;
      _state = results.isEmpty
          ? _SearchUiState.notFound
          : _SearchUiState.results;
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final width = MediaQuery.sizeOf(context).width;
    final headerRadius = width >= 600 ? 48.0 : 40.0;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F8F8),
        body: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(16, top + 8, 16, 18),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(headerRadius),
                  bottomRight: Radius.circular(headerRadius),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Material(
                        color: AppColors.white.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          onTap: () => context.pop(),
                          borderRadius: BorderRadius.circular(12),
                          child: const SizedBox(
                            width: 40,
                            height: 40,
                            child: Icon(
                              Icons.arrow_back,
                              color: AppColors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                      const Expanded(
                        child: Text(
                          'Search',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 22,
                          ),
                        ),
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            focusNode: _focus,
                            onChanged: _onQueryChanged,
                            onSubmitted: (_) => _submit(),
                            cursorColor: AppColors.error,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: Color(0xFF333333),
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              filled: false,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                              hintText: 'Search...',
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => _submit(),
                          icon: const Icon(
                            Icons.search,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 36,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _FilterChip(
                          label: 'Workout',
                          icon: Icons.fitness_center,
                          selected: _filter == SearchFilter.workout,
                          onTap: () =>
                              setState(() => _filter = SearchFilter.workout),
                        ),
                        const SizedBox(width: 10),
                        _FilterChip(
                          label: 'Meals',
                          icon: Icons.restaurant,
                          selected: _filter == SearchFilter.meals,
                          onTap: () =>
                              setState(() => _filter = SearchFilter.meals),
                        ),
                        const SizedBox(width: 10),
                        _FilterChip(
                          label: 'Community',
                          icon: Icons.chat_bubble_outline,
                          selected: _filter == SearchFilter.community,
                          onTap: () => setState(
                            () => _filter = SearchFilter.community,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_state) {
      case _SearchUiState.loading:
        return const Center(child: SearchLoadingIndicator());
      case _SearchUiState.notFound:
        return SearchNotFoundView(
          onRetry: () => _submit(),
          onCheckConnection: () => context.pushNamed(RouteNames.noInternet),
        );
      case _SearchUiState.suggesting:
        return _SuggestionsPanel(
          suggestions: _suggestions,
          query: _controller.text,
          onSelect: (label) => _submit(label),
        );
      case _SearchUiState.results:
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
          itemCount: _results.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, i) => SearchResultTile(
            item: _results[i],
            onTap: () {
              switch (_filter) {
                case SearchFilter.workout:
                  context.pushNamed(RouteNames.workoutPreview);
                case SearchFilter.meals:
                  context.pushNamed(RouteNames.addMeal);
                case SearchFilter.community:
                  context.pushNamed(RouteNames.aiChatThread);
              }
            },
          ),
        );
      case _SearchUiState.idle:
        return const SizedBox.shrink();
    }
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? AppColors.white.withValues(alpha: 0.22)
          : Colors.transparent,
      shape: StadiumBorder(
        side: BorderSide(color: AppColors.white.withValues(alpha: 0.85)),
      ),
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: AppColors.white),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SuggestionsPanel extends StatelessWidget {
  const _SuggestionsPanel({
    required this.suggestions,
    required this.query,
    required this.onSelect,
  });

  final List<SearchSuggestion> suggestions;
  final String query;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        constraints: const BoxConstraints(maxWidth: 560),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ListView.builder(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: suggestions.length,
          itemBuilder: (context, i) {
            final s = suggestions[i];
            final highlighted =
                s.label.toLowerCase() == query.trim().toLowerCase() ||
                    (query.isNotEmpty &&
                        s.label.toLowerCase().contains(query.toLowerCase()) &&
                        i == 2);
            return InkWell(
              onTap: () => onSelect(s.label),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: highlighted
                      ? const Color(0xFFEFEFEF)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  s.label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Color(0xFF333333),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
