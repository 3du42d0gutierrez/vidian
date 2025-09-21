import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:vidian_stream/domain/repositories/content_repository.dart';
import 'package:vidian_stream/domain/entities/content.dart';
import 'package:vidian_stream/data/models/playable.dart';

part 'catalog_event.dart';
part 'catalog_state.dart';

class CatalogBloc extends Bloc<CatalogEvent, CatalogState> {
  final ContentRepository repository;
  int _currentPage = 1;
  final int _pageSize;

  final List<Playable> _items = [];
  bool _hasReachedMax = false;

  CatalogBloc({required this.repository, int pageSize = 40})
      : _pageSize = pageSize,
        super(CatalogInitial()) {
    on<LoadCatalogEvent>(_onLoad);
    on<LoadMoreCatalogEvent>(_onLoadMore);
    on<RefreshCatalogEvent>(_onRefresh);
  }

  Future<void> _onLoad(LoadCatalogEvent event, Emitter<CatalogState> emit) async {
    emit(CatalogLoading());
    try {
      _currentPage = event.page;
      final pageSize = event.pageSize > 0 ? event.pageSize : _pageSize;

      final List<Content> contents = await repository.fetchContentsPage(page: _currentPage, pageSize: pageSize);

      _items.clear();
      _items.addAll(contents.map((c) => Playable.fromContent(c)).toList());

      _hasReachedMax = contents.length < pageSize;

      if (_items.isEmpty) {
        emit(CatalogEmpty());
      } else {
        emit(CatalogLoaded(items: List.unmodifiable(_items), hasReachedMax: _hasReachedMax, page: _currentPage));
      }
    } catch (e) {
      emit(CatalogError(message: e.toString()));
    }
  }

  Future<void> _onLoadMore(LoadMoreCatalogEvent event, Emitter<CatalogState> emit) async {
    if (_hasReachedMax) return;
    if (state is CatalogLoading) return;

    final currentState = state;
    emit(CatalogLoading());
    try {
      final nextPage = _currentPage + 1;
      final pageSize = event.pageSize > 0 ? event.pageSize : _pageSize;

      final List<Content> contents = await repository.fetchContentsPage(page: nextPage, pageSize: pageSize);
      final mapped = contents.map((c) => Playable.fromContent(c)).toList();

      _items.addAll(mapped);
      _currentPage = nextPage;
      _hasReachedMax = mapped.length < pageSize;

      emit(CatalogLoaded(items: List.unmodifiable(_items), hasReachedMax: _hasReachedMax, page: _currentPage));
    } catch (e) {
      // restaurar estado previo o emitir error
      if (currentState is CatalogLoaded) {
        emit(currentState);
      } else {
        emit(CatalogError(message: e.toString()));
      }
    }
  }

  Future<void> _onRefresh(RefreshCatalogEvent event, Emitter<CatalogState> emit) async {
    add(LoadCatalogEvent(page: 1, pageSize: _pageSize));
  }
}