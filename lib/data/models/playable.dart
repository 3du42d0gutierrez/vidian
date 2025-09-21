import 'package:vidian_stream/domain/entities/content.dart';

class Playable {
  final String id;
  final String title;
  final String? url;
  final String? thumbnail;
  final String? category;
  final String? type;
  final String? description;
  bool isFavorite; // mutable para actualizar desde UI/Bloc

  Playable({
    required this.id,
    required this.title,
    this.url,
    this.thumbnail,
    this.category,
    this.type,
    this.description,
    this.isFavorite = false,
  });

  // Getter para compatibilidad con UI donde esperan imageUrl
  String? get imageUrl => thumbnail;

  // Factory para crear Playable desde ContentModel
  factory Playable.fromContentModel(dynamic m, {bool isFavorite = false}) {
    return Playable(
      id: m.id,
      title: m.title,
      url: m.url,
      thumbnail: m.thumbnail,
      category: m.category,
      type: m.type,
      description: m.description,
      isFavorite: isFavorite,
    );
  }

  // Factory para crear Playable desde Content
  factory Playable.fromContent(Content c, {bool isFavorite = false}) {
    return Playable(
      id: c.id,
      title: c.title,
      url: c.url,
      thumbnail: (c as dynamic).effectiveLogo ?? (c as dynamic).logo,
      category: (c as dynamic).category,
      type: (c as dynamic).type,
      description: (c as dynamic).description,
      isFavorite: isFavorite,
    );
  }

  Playable copyWith({
    String? id,
    String? title,
    String? url,
    String? thumbnail,
    String? category,
    String? type,
    String? description,
    bool? isFavorite,
  }) {
    return Playable(
      id: id ?? this.id,
      title: title ?? this.title,
      url: url ?? this.url,
      thumbnail: thumbnail ?? this.thumbnail,
      category: category ?? this.category,
      type: type ?? this.type,
      description: description ?? this.description,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  factory Playable.fromJson(Map<String, dynamic> json) => Playable(
        id: json['id'] as String,
        title: json['title'] as String,
        url: json['url'] as String?,
        thumbnail: json['thumbnail'] as String?,
        category: json['category'] as String?,
        type: json['type'] as String?,
        description: json['description'] as String?,
        isFavorite: json['isFavorite'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'url': url,
        'thumbnail': thumbnail,
        'category': category,
        'type': type,
        'description': description,
        'isFavorite': isFavorite,
      };
}