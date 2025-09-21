import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vidian_stream/domain/entities/playable.dart';
import 'package:vidian_stream/domain/usecases/search_content_usecase.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchContentUseCase searchContent;

  SearchBloc({required this.searchContent}) : super(SearchInitial()) {
    on<PerformSearchEvent>(_onSearch);
    on<ClearSearchEvent>(_onClear);
  }

  Future<void> _onSearch(
    PerformSearchEvent event,
    Emitter<SearchState> emit,
  ) async {
    emit(SearchLoading());
    try {
      final results = await searchContent(event.query);
      emit(SearchLoaded(results: results));
    } catch (e) {
      emit(SearchError(message: e.toString()));
    }
  }

  void _onClear(
    ClearSearchEvent event,
    Emitter<SearchState> emit,
  ) {
    emit(SearchInitial());
  }
}