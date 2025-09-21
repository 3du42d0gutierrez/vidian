// Selector de plataforma con import condicional.
// Exporta banderas simples para decidir qué player usar sin romper la compilación en Web.
export 'platform_stub.dart'
    if (dart.library.io) 'platform_io.dart'
    if (dart.library.html) 'platform_web.dart';