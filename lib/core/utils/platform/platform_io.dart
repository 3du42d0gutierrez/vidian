// Implementación para plataformas que soportan dart:io
import 'dart:io' show Platform;

final bool isWeb = false;
final bool isWindows = Platform.isWindows;
final bool isMacOS = Platform.isMacOS;
final bool isLinux = Platform.isLinux;
final bool isAndroid = Platform.isAndroid;
final bool isIOS = Platform.isIOS;
final bool isDesktop = Platform.isWindows || Platform.isMacOS || Platform.isLinux;