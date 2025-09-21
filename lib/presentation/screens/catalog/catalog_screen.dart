import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:vidian_stream/presentation/blocs/catalog/catalog_bloc.dart';
import 'package:vidian_stream/data/models/playable.dart';
import 'package:vidian_stream/presentation/widgets/side_nav_bar.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({Key? key}) : super(key: key);

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // Cargar catálogo al iniciar
    context.read<CatalogBloc>().add(LoadCatalogEvent());
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<CatalogBloc>().add(LoadMoreCatalogEvent());
    }
  }

  void _openPlayer(BuildContext context, Playable item) {
    GoRouter.of(context).go(
      '/player',
      extra: <String, dynamic>{
        'id': item.id,
        'url': item.url,
        'title': item.title,
        'description': item.description,
        'imageUrl': item.imageUrl,
        'category': item.category,
        'type': item.type,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const SideNavBar(selectedIndex: 0),
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
                        'Catálogo',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.settings, color: Colors.white),
                        onPressed: () => GoRouter.of(context).go('/settings'),
                      ),
                      const SizedBox(width: 12),
                    ],
                  ),
                ),
                Expanded(
                  child: BlocBuilder<CatalogBloc, CatalogState>(
                    builder: (context, state) {
                      if (state is CatalogLoading || state is CatalogInitial) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (state is CatalogError) {
                        return Center(
                          child: Text(
                            'Error: ${state.message}',
                            style: const TextStyle(color: Colors.redAccent),
                          ),
                        );
                      }
                      if (state is CatalogLoaded) {
                        final items = state.items.cast<Playable>();
                        if (items.isEmpty) {
                          return const Center(
                            child: Text(
                              'No hay contenido disponible.',
                              style: TextStyle(color: Colors.white70),
                            ),
                          );
                        }

                        return GridView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(24.0),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 16 / 9,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                          ),
                          itemCount: items.length + (state.hasReachedMax ? 0 : 1),
                          itemBuilder: (context, index) {
                            if (index >= items.length) {
                              // indicador de carga al final
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            final item = items[index];
                            return GestureDetector(
                              onTap: () => _openPlayer(context, item),
                              child: Card(
                                color: Colors.grey[900],
                                elevation: 3,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black38,
                                          borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                                        ),
                                        child: Center(
                                          child: Text(
                                            item.title?.isNotEmpty == true ? item.title! : item.id,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 17,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      child: Text(
                                        item.description ?? '',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }
                      return const SizedBox.shrink();
                    },
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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
