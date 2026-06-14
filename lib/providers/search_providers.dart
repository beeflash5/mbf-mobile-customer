import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fuodz/models/search.dart';
import 'package:fuodz/services/search.request.dart';

final _searchRequestProvider = Provider<SearchRequest>((_) => SearchRequest());

class SearchState {
  const SearchState({
    this.search,
    this.keyword = '',
    this.selectedTagId = 2,
    this.results = const [],
    this.page = 1,
    this.isLoadingMore = false,
    this.showGrid = false,
  });
  final Search? search;
  final String keyword;
  final int selectedTagId;
  final List<dynamic> results;
  final int page;
  final bool isLoadingMore;
  final bool showGrid;

  SearchState copyWith({
    Search? search,
    String? keyword,
    int? selectedTagId,
    List<dynamic>? results,
    int? page,
    bool? isLoadingMore,
    bool? showGrid,
  }) => SearchState(
    search: search ?? this.search,
    keyword: keyword ?? this.keyword,
    selectedTagId: selectedTagId ?? this.selectedTagId,
    results: results ?? this.results,
    page: page ?? this.page,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    showGrid: showGrid ?? this.showGrid,
  );
}

class SearchController extends FamilyAsyncNotifier<SearchState, Search?> {
  late Search? _initialSearch;

  @override
  Future<SearchState> build(Search? arg) async {
    _initialSearch = arg;
    return SearchState(search: arg);
  }

  void setKeyword(String value) {
    final cur = state.valueOrNull ?? SearchState(search: _initialSearch);
    state = AsyncData(cur.copyWith(keyword: value));
  }

  void setSelectedTag(int tagId) {
    final cur = state.valueOrNull ?? SearchState(search: _initialSearch);
    int t = tagId;
    if (t == 4) {
      t = 1;
    } else if (t == 5) {
      t = 3;
    }
    final s = cur.search;
    s?.genApiType(t);
    state = AsyncData(cur.copyWith(selectedTagId: t, search: s));
    startSearch();
  }

  void updateSearch(Search newSearch) {
    final cur = state.valueOrNull ?? SearchState(search: _initialSearch);
    state = AsyncData(
      cur.copyWith(search: newSearch, showGrid: newSearch.layoutType == 'grid'),
    );
    startSearch();
  }

  Future<void> startSearch({bool initialLoading = true}) async {
    final cur = state.valueOrNull ?? SearchState(search: _initialSearch);
    if (cur.search == null) return;
    if (initialLoading) {
      state = AsyncData(cur.copyWith(results: const [], page: 1));
      state = const AsyncLoading();
    } else {
      state = AsyncData(cur.copyWith(isLoadingMore: true));
    }
    state = await AsyncValue.guard(() async {
      final page = initialLoading ? 1 : (cur.page + 1);
      final results = await ref
          .read(_searchRequestProvider)
          .searchRequest(keyword: cur.keyword, search: cur.search!, page: page);
      final latestCur = state.valueOrNull ?? cur;
      return latestCur.copyWith(
        results: initialLoading ? results : [...latestCur.results, ...results],
        page: page,
        isLoadingMore: false,
      );
    });
  }

  void toggleShowGrid(bool show) {
    final cur = state.valueOrNull;
    if (cur == null) return;
    state = AsyncData(cur.copyWith(showGrid: show));
  }
}

final searchControllerProvider =
    AsyncNotifierProvider.family<SearchController, SearchState, Search?>(
      SearchController.new,
    );

class ServiceSearchController
    extends FamilyAsyncNotifier<SearchState, Search?> {
  @override
  Future<SearchState> build(Search? arg) async {
    // Apply default tag (3 = service) so the API type is set correctly
    arg?.genApiType(3);
    final initialState = SearchState(search: arg, selectedTagId: 3);
    state = AsyncData(initialState);
    // Trigger initial search with empty keyword so list loads immediately
    await _doSearch(initialState, initialLoading: true);
    return state.valueOrNull ?? initialState;
  }

  Future<void> _doSearch(
    SearchState cur, {
    required bool initialLoading,
  }) async {
    if (cur.search == null) return;
    final page = initialLoading ? 1 : (cur.page + 1);
    final results = await ref
        .read(_searchRequestProvider)
        .serviceSearchRequest(
          keyword: cur.keyword,
          search: cur.search!,
          page: page,
        );
    final cur2 = state.valueOrNull ?? cur;
    state = AsyncData(
      cur2.copyWith(
        results: initialLoading ? results : [...cur2.results, ...results],
        page: page,
      ),
    );
  }

  void setKeyword(String value) {
    final cur = state.valueOrNull;
    if (cur == null) return;
    state = AsyncData(cur.copyWith(keyword: value));
  }

  void setSelectedTag(int tagId) {
    final cur = state.valueOrNull;
    if (cur == null) return;
    int t = tagId;
    if (t == 4) {
      t = 1;
    } else if (t == 5) {
      t = 3;
    }
    final s = cur.search;
    s?.genApiType(t);
    state = AsyncData(cur.copyWith(selectedTagId: t, search: s));
    startSearch();
  }

  void updateSearch(Search newSearch) {
    final cur = state.valueOrNull;
    if (cur == null) return;
    state = AsyncData(cur.copyWith(search: newSearch));
    startSearch();
  }

  Future<void> startSearch({bool initialLoading = true}) async {
    final cur = state.valueOrNull;
    if (cur == null || cur.search == null) return;
    if (initialLoading) {
      state = AsyncData(cur.copyWith(results: const [], page: 1));
      state = const AsyncLoading();
    } else {
      state = AsyncData(cur.copyWith(isLoadingMore: true));
    }
    state = await AsyncValue.guard(() async {
      final cur2 = state.valueOrNull ?? cur;
      await _doSearch(cur2, initialLoading: initialLoading);
      return state.valueOrNull ?? cur2;
    });
  }

  void toggleShowGrid(bool show) {
    final cur = state.valueOrNull;
    if (cur == null) return;
    state = AsyncData(cur.copyWith(showGrid: show));
  }
}

final serviceSearchControllerProvider =
    AsyncNotifierProvider.family<ServiceSearchController, SearchState, Search?>(
      ServiceSearchController.new,
    );
