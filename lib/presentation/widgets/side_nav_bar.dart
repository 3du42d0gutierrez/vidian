import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Barra de navegación lateral estilo Netflix para Vidian Stream.
/// Permite navegar entre catálogo, búsqueda, favoritos y ajustes.
/// Responsive y lista para producción (mobile, desktop, web).
class SideNavBar extends StatefulWidget {
  final int selectedIndex;
  const SideNavBar({Key? key, required this.selectedIndex}) : super(key: key);

  @override
  State<SideNavBar> createState() => _SideNavBarState();
}

class _SideNavBarState extends State<SideNavBar> {
  late int _selectedIndex;

  static const _tabs = [
    {'route': '/catalog', 'label': 'Inicio', 'icon': Icons.home_outlined, 'activeIcon': Icons.home_rounded},
    {'route': '/search', 'label': 'Buscar', 'icon': Icons.search_outlined, 'activeIcon': Icons.search},
    {'route': '/favorites', 'label': 'Favoritos', 'icon': Icons.favorite_outline, 'activeIcon': Icons.favorite},
    {'route': '/settings', 'label': 'Ajustes', 'icon': Icons.settings_outlined, 'activeIcon': Icons.settings},
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
  }

  @override
  void didUpdateWidget(covariant SideNavBar oldWidget) {
    if (widget.selectedIndex != _selectedIndex) {
      setState(() {
        _selectedIndex = widget.selectedIndex;
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;
    setState(() {
      _selectedIndex = index;
    });
    GoRouter.of(context).go(_tabs[index]['route'] as String);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navColor = isDark ? Colors.black : Colors.grey[50]!;
    final selectedColor = Colors.redAccent;
    final unselectedColor = isDark ? Colors.white70 : Colors.black87;

    return Container(
      width: 80,
      color: navColor,
      child: Column(
        children: [
          const SizedBox(height: 16),
          // Logo superior
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Image.asset(
              'assets/logo.png',
              height: 40,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) =>
                  Icon(Icons.tv, size: 40, color: selectedColor),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _tabs.length,
              itemBuilder: (context, index) {
                final tab = _tabs[index];
                final selected = _selectedIndex == index;
                return _NavBarItem(
                  icon: selected
                      ? tab['activeIcon'] as IconData
                      : tab['icon'] as IconData,
                  label: tab['label'] as String,
                  selected: selected,
                  selectedColor: selectedColor,
                  unselectedColor: unselectedColor,
                  onTap: () => _onItemTapped(index),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final Color selectedColor;
  final Color unselectedColor;
  final VoidCallback onTap;

  const _NavBarItem({
    Key? key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.selectedColor,
    required this.unselectedColor,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? selectedColor.withOpacity(0.12) : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8),
          child: Column(
            children: [
              Icon(
                icon,
                color: selected ? selectedColor : unselectedColor,
                size: selected ? 30 : 26,
              ),
              SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: selected ? selectedColor : unselectedColor,
                  fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                  fontSize: selected ? 13 : 12,
                  letterSpacing: selected ? 0.5 : 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}