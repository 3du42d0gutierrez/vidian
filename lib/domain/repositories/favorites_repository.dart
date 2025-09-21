import 'package:vidian_stream/domain/entities/playable.dart';

abstract class FavoritesRepository {
  Future<List<Playable>> getFavorites();
  Future<void> addFavorite(Playable item);
  Future<void> removeFavorite(Playable item);
}