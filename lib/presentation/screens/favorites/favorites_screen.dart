import 'package:flutter/material.dart';
import 'package:vidian_stream/presentation/widgets/side_nav_bar.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});
  // TODO: Integrar con CatalogBloc o FavoritesBloc para mostrar favoritos

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const SideNavBar(selectedIndex: 2),
          Expanded(
            child: Column(
              children: [
                Container(
                  height: 64,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 24),
                      const Text(
                        'Favoritos',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'Aquí aparecerán tus favoritos (conectar a BLoC)',
                      style: const TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: Colors.black,
    );
  }
}