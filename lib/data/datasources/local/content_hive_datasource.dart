import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:vidian_stream/data/models/content_model.dart';

abstract class ContentHiveDataSource {
  Future<void> saveContents(List<ContentModel> models);
  Future<void> saveContent(ContentModel model);
  Future<List<ContentModel>> getCachedContents({int page = 1, int pageSize = 20});
  Future<ContentModel?> getContentById(String id);
  Future<Set<String>> getFavorites();
  Future<Set<String>> toggleFavorite(String contentId);

  // Nuevos: persistencia de sesión / url M3U
  Future<void> saveM3uUrl(String url);
  Future<String?> loadM3uUrl();
  Future<void> clearM3uUrl();
}

class ContentHiveDataSourceImpl implements ContentHiveDataSource {
  static const String _contentsBoxName = 'contents_box_v1';
  static const String _favoritesBoxName = 'favorites_box_v1';
  static const String _favoritesKey = 'favorites';
  static const String _settingsBoxName = 'settings_box_v1';
  static const String _m3uKey = 'm3u_url';

  ContentHiveDataSourceImpl();

  Future<Box<String>> _openContentsBox() async {
    return await Hive.openBox<String>(_contentsBoxName);
  }

  Future<Box> _openFavoritesBox() async {
    return await Hive.openBox(_favoritesBoxName);
  }

  Future<Box> _openSettingsBox() async {
    return await Hive.openBox(_settingsBoxName);
  }

  @override
  Future<void> saveContents(List<ContentModel> models) async {
    final box = await _openContentsBox();
    final Map<String, String> map = {
      for (final m in models) m.id: json.encode(m.toJson())
    };
    await box.putAll(map);
  }

  @override
  Future<void> saveContent(ContentModel model) async {
    final box = await _openContentsBox();
    await box.put(model.id, json.encode(model.toJson()));
  }

  @override
  Future<List<ContentModel>> getCachedContents({int page = 1, int pageSize = 20}) async {
    final box = await _openContentsBox();
    final values = box.values.cast<String>().toList();

    final all = values.map((s) {
      try {
        final map = json.decode(s) as Map<String, dynamic>;
        return ContentModel.fromMap(map);
      } catch (_) {
        return null;
      }
    }).whereType<ContentModel>().toList();

    final start = (page - 1) * pageSize;
    if (start >= all.length) return <ContentModel>[];
    final end = (start + pageSize) > all.length ? all.length : (start + pageSize);
    return all.sublist(start, end);
  }

  @override
  Future<ContentModel?> getContentById(String id) async {
    final box = await _openContentsBox();
    final raw = box.get(id) as String?;
    if (raw == null) return null;
    try {
      final map = json.decode(raw) as Map<String, dynamic>;
      return ContentModel.fromMap(map);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Set<String>> getFavorites() async {
    final box = await _openFavoritesBox();
    final list = box.get(_favoritesKey) as List<dynamic>? ?? <dynamic>[];
    return list.map((e) => e.toString()).toSet();
  }

  @override
  Future<Set<String>> toggleFavorite(String contentId) async {
    final box = await _openFavoritesBox();
    final list = box.get(_favoritesKey) as List<dynamic>? ?? <dynamic>[];
    final set = list.map((e) => e.toString()).toSet();
    if (set.contains(contentId)) {
      set.remove(contentId);
    } else {
      set.add(contentId);
    }
    final newList = set.toList();
    await box.put(_favoritesKey, newList);
    return set;
  }

  // ---------- Nuevos métodos para M3U / sesión ----------

  @override
  Future<void> saveM3uUrl(String url) async {
    final box = await _openSettingsBox();
    await box.put(_m3uKey, url);
    await box.flush();
  }

  @override
  Future<String?> loadM3uUrl() async {
    final box = await _openSettingsBox();
    final value = box.get(_m3uKey) as String?;
    return value;
  }

  @override
  Future<void> clearM3uUrl() async {
    final box = await _openSettingsBox();
    await box.delete(_m3uKey);
    await box.flush();
  }
}