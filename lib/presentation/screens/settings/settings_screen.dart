import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidian_stream/presentation/widgets/side_nav_bar.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    GoRouter.of(context).go('/');
  }

  void _showParentalControlDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        String pin = '';
        return AlertDialog(
          title: const Text('Configurar PIN parental'),
          content: TextField(
            keyboardType: TextInputType.number,
            obscureText: true,
            maxLength: 4,
            decoration: const InputDecoration(
              hintText: 'Introduce un PIN de 4 dígitos',
            ),
            onChanged: (value) => pin = value,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                if (pin.length == 4) {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('parental_pin', pin);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('PIN guardado')),
                  );
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  void _showLanguageSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('Español'),
              onTap: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Idioma cambiado a Español')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('English'),
              onTap: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Language changed to English')),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _showAppInfo(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Vidian Stream',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.tv),
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: Text(
            'App desarrollada con Flutter, arquitectura DDD + Clean Architecture.\n'
            'Soporta Xtream, modo demo y clásico.\n'
            '© 2025 Vidian Stream.',
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const SideNavBar(selectedIndex: 3),
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
                        'Ajustes',
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
                  child: ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      Card(
                        color: Colors.grey[900],
                        child: ListTile(
                          leading: const Icon(Icons.lock, color: Colors.redAccent),
                          title: const Text('Control parental', style: TextStyle(color: Colors.white)),
                          subtitle: const Text('Configura PIN y restricciones', style: TextStyle(color: Colors.white70)),
                          onTap: () => _showParentalControlDialog(context),
                        ),
                      ),
                      Card(
                        color: Colors.grey[900],
                        child: ListTile(
                          leading: const Icon(Icons.language, color: Colors.redAccent),
                          title: const Text('Idioma', style: TextStyle(color: Colors.white)),
                          subtitle: const Text('Selecciona idioma de la app', style: TextStyle(color: Colors.white70)),
                          onTap: () => _showLanguageSelector(context),
                        ),
                      ),
                      Card(
                        color: Colors.grey[900],
                        child: ListTile(
                          leading: const Icon(Icons.exit_to_app, color: Colors.redAccent),
                          title: const Text('Cerrar sesión', style: TextStyle(color: Colors.white)),
                          onTap: () => _logout(context),
                        ),
                      ),
                      Card(
                        color: Colors.grey[900],
                        child: ListTile(
                          leading: const Icon(Icons.info, color: Colors.redAccent),
                          title: const Text('Acerca de', style: TextStyle(color: Colors.white)),
                          subtitle: const Text('Versión y créditos', style: TextStyle(color: Colors.white70)),
                          onTap: () => _showAppInfo(context),
                        ),
                      ),
                    ],
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