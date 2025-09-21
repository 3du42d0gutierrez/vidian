import 'package:vidian_stream/domain/entities/playable.dart';
import 'package:vidian_stream/domain/repositories/search_repository.dart';

class SearchContentUseCase {
  final SearchRepository repository;

  SearchContentUseCase(this.repository);

  Future<List<Playable>> call(String query) async {
    return await repository.search(query);
  }
}