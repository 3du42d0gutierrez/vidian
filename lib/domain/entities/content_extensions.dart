import 'content.dart';

extension ContentLogoExt on Content {
  /// Devuelve la imagen preferida (logo, thumbnail, poster, ...)
  String? get logo => 
      // ajusta los nombres aquí según los campos reales de Content
      (this as dynamic).logo ?? (this as dynamic).thumbnail ?? (this as dynamic).poster;
}