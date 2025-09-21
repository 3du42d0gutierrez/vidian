import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vidian_stream/presentation/screens/login/login_screen.dart';
import 'package:vidian_stream/presentation/screens/catalog/catalog_screen.dart';
import 'package:vidian_stream/presentation/screens/player/player_screen.dart';
import 'package:vidian_stream/presentation/screens/settings/settings_screen.dart';
import 'package:vidian_stream/presentation/screens/search/search_screen.dart';
import 'package:vidian_stream/presentation/screens/favorites/favorites_screen.dart';
import 'package:vidian_stream/presentation/blocs/login/login_bloc.dart';
import 'package:vidian_stream/presentation/blocs/login/login_state.dart';

GoRouter createRouter(BuildContext context) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/catalog',
        name: 'catalog',
        builder: (context, state) => const CatalogScreen(),
      ),

      // Ruta que acepta extra (sin id en path). Útil cuando pasas toda la metadata vía extra.
      GoRoute(
        path: '/player',
        name: 'player_without_id',
        builder: (context, state) {
          String? id;
          String? url;
          String? title;
          String? description;
          String? imageUrl;
          String? category;
          String? type;

          if (state.extra is Map<String, dynamic>) {
            final m = state.extra as Map<String, dynamic>;
            id = m['id'] as String?;
            url = m['url'] as String?;
            title = m['title'] as String?;
            description = m['description'] as String?;
            imageUrl = m['imageUrl'] as String?;
            category = m['category'] as String?;
            type = m['type'] as String?;
          } else if (state.extra is Map) {
            final m = state.extra as Map;
            id = m['id'] as String?;
            url = m['url'] as String?;
            title = m['title'] as String?;
            description = m['description'] as String?;
            imageUrl = m['imageUrl'] as String?;
            category = m['category'] as String?;
            type = m['type'] as String?;
          }

          return PlayerScreen(
            contentId: id,
            contentUrl: url,
            title: title,
          );
        },
      ),

      // Ruta con id en path (si la necesitas)
      GoRoute(
        path: '/player/:id',
        name: 'player',
        builder: (context, state) {
          final id = state.params['id']!;
          String? url;
          if (state.extra is Map && (state.extra as Map).containsKey('url')) {
            url = (state.extra as Map)['url'] as String?;
          }
          return PlayerScreen(contentId: id, contentUrl: url);
        },
      ),

      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/search',
        name: 'search',
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/favorites',
        name: 'favorites',
        builder: (context, state) => const FavoritesScreen(),
      ),
    ],
    redirect: (context, state) {
      // Solo lectura del LoginBloc: redirect debe ser síncrono y puro.
      final loginState = context.read<LoginBloc>().state;
      final loggedIn = loginState is LoginSuccess;
      final goingToLogin = state.subloc == '/';

      if (!loggedIn && !goingToLogin) return '/';
      if (loggedIn && goingToLogin) return '/catalog';
      return null;
    },
    refreshListenable: GoRouterRefreshStreamWrapper(context.read<LoginBloc>().stream),
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Ruta no encontrada')),
      body: Center(child: Text('No hay ruta para: ${state.location}')),
    ),
  );
}

/// Envuelve un Stream y notifica a GoRouter cuando hay nuevos eventos.
class GoRouterRefreshStreamWrapper extends ChangeNotifier {
  StreamSubscription<dynamic>? _sub;

  GoRouterRefreshStreamWrapper(Stream<dynamic> stream) {
    _sub = stream.listen((_) => notifyListeners(), onError: (_) => notifyListeners());
  }

  @override
  void dispose() {
    _sub?.cancel();
    _sub = null;
    super.dispose();
  }
}