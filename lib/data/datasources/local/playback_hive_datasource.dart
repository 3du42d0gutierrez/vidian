import 'package:hive/hive.dart';

part 'playback_hive_datasource.g.dart';

@HiveType(typeId: 0)
class PlaybackProgress extends HiveObject {
  @HiveField(0)
  String contentId;

  @HiveField(1)
  int positionMillis;

  @HiveField(2)
  DateTime updatedAt;

  PlaybackProgress({
    required this.contentId,
    required this.positionMillis,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();
}

class PlaybackHiveDataSource {
  static const String boxName = 'playback_progress';
  final Box<PlaybackProgress> _box;

  PlaybackHiveDataSource._(this._box);

  static Future<PlaybackHiveDataSource> create() async {
    final box = Hive.box<PlaybackProgress>(boxName);
    return PlaybackHiveDataSource._(box);
  }

  Future<int?> getPosition(String contentId) async {
    final item = _box.values.firstWhere(
      (p) => p.contentId == contentId,
      orElse: () => null as PlaybackProgress,
    );
    return item == null ? null : item.positionMillis;
  }

  Future<void> savePosition(String contentId, int positionMillis) async {
    // Reemplaza o inserta
    final existingKey = _box.keys.firstWhere(
      (k) => _box.get(k)!.contentId == contentId,
      orElse: () => null,
    );
    if (existingKey != null) {
      final p = _box.get(existingKey)!;
      p.positionMillis = positionMillis;
      p.updatedAt = DateTime.now();
      await p.save();
    } else {
      await _box.add(PlaybackProgress(contentId: contentId, positionMillis: positionMillis));
    }
  }

  Future<void> removePosition(String contentId) async {
    final key = _box.keys.firstWhere(
      (k) => _box.get(k)!.contentId == contentId,
      orElse: () => null,
    );
    if (key != null) await _box.delete(key);
  }

  Future<List<PlaybackProgress>> allProgress() async {
    return _box.values.toList();
  }
}