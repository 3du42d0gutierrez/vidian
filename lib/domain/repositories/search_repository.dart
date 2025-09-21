import 'package:vidian_stream/domain/entities/playable.dart';

abstract class SearchRepository {
  Future<List<Playable>> search(String query);
}