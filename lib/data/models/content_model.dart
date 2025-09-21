import 'package:vidian_stream/domain/entities/content.dart';

class ContentModel {
  final String id;
  final String title;
  final String? url;
  final String? thumbnail;
  final String? category;
  final String? description;
  final Map<String, dynamic>? meta;

  ContentModel({
    required this.id,
    required this.title,
    this.url,
    this.thumbnail,
    this.category,
    this.description,
    this.meta,
  });

  /// Crea desde un Map/JSON. Acepta varias claves comunes (logo/thumbnail, group/category, stream/url).
  factory ContentModel.fromMap(Map<String, dynamic> map) {
    final id = (map['id'] ?? map['uuid'] ?? map['url'] ?? '').toString();
    final title = (map['title'] ?? map['name'] ?? map['tvg-name'] ?? '').toString();

    String? url;
    if (map['url'] is String) {
      url = map['url'] as String;
    } else if (map['stream'] is String) {
      url = map['stream'] as String;
    } else if (map['file'] is String) {
      url = map['file'] as String;
    }

    final thumbnail = (map['thumbnail'] ?? map['thumb'] ?? map['logo'] ?? map['tvg-logo']) as String?;
    final category = (map['category'] ?? map['group'] ?? map['group-title']) as String?;
    final description = (map['description'] ?? map['desc']) as String?;
    final meta = map['meta'] is Map<String, dynamic> ? map['meta'] as Map<String, dynamic> : null;

    return ContentModel(
      id: id.isNotEmpty ? id : (url ?? ''),
      title: title.isNotEmpty ? title : (url ?? ''),
      url: url,
      thumbnail: thumbnail,
      category: category,
      description: description,
      meta: meta,
    );
  }

  /// Alias por compatibilidad con nombre fromJson
  factory ContentModel.fromJson(Map<String, dynamic> json) => ContentModel.fromMap(json);

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        if (url != null) 'url': url,
        if (thumbnail != null) 'thumbnail': thumbnail,
        // incluimos alias 'logo' para mantener compatibilidad con la entidad Content
        if (thumbnail != null) 'logo': thumbnail,
        if (category != null) 'category': category,
        if (description != null) 'description': description,
        if (meta != null) 'meta': meta,
      };

  Content toEntity() {
    return Content(
      id: id,
      title: title,
      url: url,
      // Content entity defines 'logo' — mapear thumbnail a logo para compatibilidad
      logo: thumbnail,
      category: category,
      description: description,
      meta: meta,
    );
  }

  /// Crea un ContentModel mínimo a partir de title+url (útil para M3U)
  factory ContentModel.fromTitleAndUrl(String title, String url, {String? thumbnail, String? category}) {
    // Usamos la url como id para simplicidad (puedes hashear si prefieres)
    final id = url;
    return ContentModel(id: id, title: title, url: url, thumbnail: thumbnail, category: category);
  }

  /// Conveniencia: fromMap con nombres en bruto que algunos endpoints devuelven
  static ContentModel fromMapSafe(Map<String, dynamic> map) => ContentModel.fromMap(map);
}