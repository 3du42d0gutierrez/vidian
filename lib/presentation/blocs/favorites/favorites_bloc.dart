import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vidian_stream/data/models/playable.dart';
import 'package:vidian_stream/domain/usecases/get_favorites_usecase.dart';

part 'favorites_event.dart';
part 'favorites_state.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final GetFavoritesUseCase getFavorites;

  FavoritesBloc({required this.getFavorites}) : super(FavoritesInitial()) {
    on<LoadFavoritesEvent>(_onLoadFavorites);
    on<AddFavoriteEvent>(_onAddFavorite);
    on<RemoveFavoriteEvent>(_onRemoveFavorite);
  }

  Future<void> _onLoadFavorites(
    LoadFavoritesEvent event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(FavoritesLoading());
    try {
      final domainItems = await getFavorites();
      final items = domainItems
          .map((e) => Playable(
                id: e.id,
                title: e.title ?? '',
                url: e.url,
                // add other fields as needed
              ))
          .toList();
      emit(FavoritesLoaded(items: items));
    } catch (e) {
      emit(FavoritesError(message: e.toString()));
    }
  }

  Future<void> _onAddFavorite(
    AddFavoriteEvent event,
    Emitter<FavoritesState> emit,
  ) async {
    // Implementa lógica para añadir favorito (llama al caso de uso correspondiente)
    // ...
    add(LoadFavoritesEvent());
  }

  Future<void> _onRemoveFavorite(
    RemoveFavoriteEvent event,
    Emitter<FavoritesState> emit,
  ) async {
    // Implementa lógica para eliminar favorito (llama al caso de uso correspondiente)
    // ...
    add(LoadFavoritesEvent());
  }
}