import 'package:equatable/equatable.dart';

/// Entidad de dominio "Content".
/// Incluye campos comunes usados por la UI (logo, category, url, title, type, ...).
class Content extends Equatable {
  final String id;
  final String title;
  final String? url;
  final String? logo; // alias directo para carátula/thumbnail
  final String? category;
  final String? description;
  final String? type; // <-- campo agregado
  final Map<String, dynamic>? meta;

  const Content({
    required this.id,
    required this.title,
    this.url,
    this.logo,
    this.category,
    this.description,
    this.type, // <-- en el constructor
    this.meta,
  });

  /// Alias/normalizador: devuelve la imagen preferida para mostrar.
  String? get effectiveLogo => logo ?? (meta != null ? meta!['thumbnail'] as String? : null);

  @override
  List<Object?> get props => [id, title, url, logo, category, description, type, meta];

  /// Serialización mínima útil para mapeo desde modelos/data.
  factory Content.fromMap(Map<String, dynamic> map) {
    return Content(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      url: map['url']?.toString(),
      logo: map['logo']?.toString() ?? map['thumbnail']?.toString(),
      category: map['category']?.toString(),
      description: map['description']?.toString(),
      type: map['type']?.toString(), // <-- mapeo soportado
      meta: map['meta'] is Map<String, dynamic> ? map['meta'] as Map<String, dynamic> : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      if (url != null) 'url': url,
      if (logo != null) 'logo': logo,
      if (category != null) 'category': category,
      if (description != null) 'description': description,
      if (type != null) 'type': type, // <-- serialización soportada
      if (meta != null) 'meta': meta,
    };
  }
}