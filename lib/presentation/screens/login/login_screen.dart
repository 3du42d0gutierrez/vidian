import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vidian_stream/presentation/blocs/login/login_bloc.dart';
import 'package:vidian_stream/presentation/blocs/login/login_event.dart';
import 'package:vidian_stream/presentation/blocs/login/login_state.dart';

enum LoginMode { demo, classic, xtream, m3u }

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  LoginMode _mode = LoginMode.demo;
  final _formKey = GlobalKey<FormState>();
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _urlCtrl = TextEditingController();

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    _urlCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_mode == LoginMode.demo) {
      context.read<LoginBloc>().add(LoginDemoEvent());
      return;
    }
    if (_mode == LoginMode.classic) {
      if (!_formKey.currentState!.validate()) return;
      context.read<LoginBloc>().add(LoginClassicEvent(_userCtrl.text.trim(), _passCtrl.text));
      return;
    }
    if (_mode == LoginMode.xtream) {
      if (!_formKey.currentState!.validate()) return;
      context.read<LoginBloc>().add(LoginXtreamEvent(url: _urlCtrl.text.trim(), username: _userCtrl.text.trim(), password: _passCtrl.text));
      return;
    }
    if (_mode == LoginMode.m3u) {
      if (_urlCtrl.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Introduce la URL M3U')));
        return;
      }
      context.read<LoginBloc>().add(LoginM3uEvent(_urlCtrl.text.trim()));
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Asegúrate de instanciar LoginBloc en main.dart y de tener GoRouter configurado con '/catalog'.
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: BlocListener<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state is LoginSuccess) {
            // Usar GoRouter para navegación declarativa cuando la app está configurada con MaterialApp.router
            if (mounted) {
              // .go reemplaza la ruta actual; usa .push si quieres apilar
              context.go('/catalog');
            }
          } else if (state is LoginFailure) {
            final msg = state.message ?? 'Error en login';
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
            }
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              ToggleButtons(
                isSelected: [
                  _mode == LoginMode.demo,
                  _mode == LoginMode.classic,
                  _mode == LoginMode.xtream,
                  _mode == LoginMode.m3u,
                ],
                onPressed: (i) => setState(() {
                  _mode = LoginMode.values[i];
                }),
                children: const [
                  Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('Demo')),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('Clásico')),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('Xtream')),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('M3U')),
                ],
              ),
              const SizedBox(height: 16),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    if (_mode == LoginMode.classic || _mode == LoginMode.xtream)
                      TextFormField(
                        controller: _userCtrl,
                        decoration: const InputDecoration(labelText: 'Usuario'),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                      ),
                    if (_mode == LoginMode.classic || _mode == LoginMode.xtream)
                      TextFormField(
                        controller: _passCtrl,
                        decoration: const InputDecoration(labelText: 'Contraseña'),
                        obscureText: true,
                        validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
                      ),
                    if (_mode == LoginMode.xtream || _mode == LoginMode.m3u)
                      TextFormField(
                        controller: _urlCtrl,
                        decoration: const InputDecoration(labelText: 'URL (Xtream / M3U)'),
                        keyboardType: TextInputType.url,
                        validator: (v) {
                          if ((_mode == LoginMode.xtream || _mode == LoginMode.m3u) && (v == null || v.trim().isEmpty)) {
                            return 'La URL es requerida';
                          }
                          return null;
                        },
                      ),
                    const SizedBox(height: 20),
                    BlocBuilder<LoginBloc, LoginState>(
                      builder: (context, state) {
                        final loading = state is LoginLoading;
                        return SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: loading ? null : _submit,
                            child: loading
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Text('Entrar'),
                          ),
                        );
                      },
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}