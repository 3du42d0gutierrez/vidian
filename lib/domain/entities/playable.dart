class Playable {
  final String id;
  final String title;
  final String? url;
  final String? category;
  final String? type;

  const Playable({
    required this.id,
    required this.title,
    this.url,
    this.category,
    this.type,
  });

  // Lógica de dominio adicional aquí si es necesario
}