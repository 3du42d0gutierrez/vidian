import 'package:vidian_stream/domain/entities/playable.dart';
import 'package:vidian_stream/domain/repositories/favorites_repository.dart';

class GetFavoritesUseCase {
  final FavoritesRepository repository;

  GetFavoritesUseCase(this.repository);

  Future<List<Playable>> call() async {
    return await repository.getFavorites();
  }
}