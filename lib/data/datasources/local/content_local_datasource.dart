import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidian_stream/data/models/content_model.dart';

abstract class LocalContentDataSource {
  Future<void> cacheContents(List<ContentModel> contents);
  Future<List<ContentModel>> getCachedContents();
  Future<ContentModel?> getContentById(String id);
}

class LocalContentDataSourceImpl implements LocalContentDataSource {
  static const _cacheKey = 'cached_contents_v1';
  final SharedPreferences prefs;

  LocalContentDataSourceImpl({required this.prefs});

  @override
  Future<void> cacheContents(List<ContentModel> contents) async {
    final jsonList = contents.map((c) => json.encode(c.toJson())).toList();
    await prefs.setStringList(_cacheKey, jsonList);
  }

  @override
  Future<List<ContentModel>> getCachedContents() async {
    final list = prefs.getStringList(_cacheKey) ?? [];
    return list.map((s) => ContentModel.fromJson(json.decode(s) as Map<String, dynamic>)).toList();
  }

  @override
  Future<ContentModel?> getContentById(String id) async {
    final cached = await getCachedContents();
    try {
      return cached.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}