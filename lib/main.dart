import 'dart:async';

import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:vidian_stream/data/repositories/content_repository_impl.dart';
import 'package:vidian_stream/data/datasources/remote/content_remote_datasource.dart';
import 'package:vidian_stream/data/datasources/local/content_hive_datasource.dart';
import 'package:vidian_stream/domain/repositories/content_repository.dart';
import 'package:vidian_stream/presentation/blocs/login/login_bloc.dart';
import 'package:vidian_stream/presentation/blocs/catalog/catalog_bloc.dart';
import 'package:vidian_stream/presentation/blocs/player/player_bloc.dart';
import 'package:vidian_stream/routes/app_router.dart';

/// Main corregido: WidgetsFlutterBinding.ensureInitialized() y
/// MediaKit.ensureInitialized() se ejecutan en la misma zona que runApp().
Future<void> main() async {
  runZonedGuarded(() async {
    // обязательное: primero en la zona
    WidgetsFlutterBinding.ensureInitialized();

    // Inicializa MediaKit antes de usar cualquier API de media_kit.
    try {
      MediaKit.ensureInitialized();
      debugPrint('MediaKit initialized');
    } catch (e, st) {
      debugPrint('MediaKit.ensureInitialized failed (will fallback to video_player): $e\n$st');
      // No abortamos: permitimos fallback a video_player si media_kit no está disponible.
    }

    // Inicializaciones app (Hive, SharedPrefs, etc.)
    await Hive.initFlutter();
    // Registra adaptadores si tienes modelos con adapters:
    // Hive.registerAdapter(MyModelAdapter());
    await Future.wait([
      Hive.openBox('settings'),
      Hive.openBox('session'),
      Hive.openBox('content_cache'),
    ]);
    final prefs = await SharedPreferences.getInstance();

    // Crear repositorios / datasources
    final remoteDs = ContentRemoteDataSourceImpl();
    final localDs = ContentHiveDataSourceImpl();
    final ContentRepository contentRepository = ContentRepositoryImpl(
      remote: remoteDs,
      local: localDs,
    );

    // runApp dentro de la misma zona
    runApp(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<ContentRepository>.value(value: contentRepository),
          RepositoryProvider<SharedPreferences>.value(value: prefs),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider<LoginBloc>(
              create: (context) => LoginBloc(contentRepository: context.read<ContentRepository>()),
            ),
            BlocProvider<CatalogBloc>(
              create: (context) => CatalogBloc(repository: context.read<ContentRepository>())..add(LoadCatalogEvent()),
            ),
            BlocProvider<PlayerBloc>(
              create: (context) => PlayerBloc(repository: context.read<ContentRepository>()),
            ),
          ],
          child: const VidianApp(),
        ),
      ),
    );
  }, (error, stack) {
    debugPrint('Uncaught zone error: $error\n$stack');
    // En producción, reportar a Sentry/u otro servicio.
  });
}

class VidianApp extends StatelessWidget {
  const VidianApp({super.key});

  @override
  Widget build(BuildContext context) {
    final GoRouter router = createRouter(context);

    return MaterialApp.router(
      title: 'Vidian Stream',
      debugShowCheckedModeBanner: false,
      routeInformationParser: router.routeInformationParser,
      routerDelegate: router.routerDelegate,
      routeInformationProvider: router.routeInformationProvider,
      theme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.dark(primary: Colors.green.shade300),
        scaffoldBackgroundColor: Colors.black,
      ),
    );
  }
}