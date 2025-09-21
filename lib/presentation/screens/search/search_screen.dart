import 'package:flutter/material.dart';
import 'package:vidian_stream/presentation/widgets/side_nav_bar.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _query = '';
  // TODO: Integrar con CatalogBloc para búsqueda real

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const SideNavBar(selectedIndex: 1),
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
                        'Buscar',
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
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar contenido, canal o categoría...',
                      filled: true,
                      fillColor: Colors.grey[900],
                      prefixIcon: const Icon(Icons.search, color: Colors.redAccent),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      hintStyle: const TextStyle(color: Colors.white70),
                    ),
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    onChanged: (value) => setState(() => _query = value),
                  ),
                ),
                Expanded(
                  child: _query.isEmpty
                      ? const Center(
                          child: Text(
                            'Escribe para buscar contenido.',
                            style: TextStyle(color: Colors.white70),
                          ),
                        )
                      : Center(
                          child: Text(
                            'Resultados para \"$_query\" (conectar a BLoC)',
                            style: const TextStyle(color: Colors.white),
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