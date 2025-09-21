import 'dart:async';

import 'package:flutter/material.dart';

class SimpleSearchBar extends StatefulWidget {
  final String initial;
  final ValueChanged<String> onChanged;
  final Duration debounce;

  const SimpleSearchBar({super.key, this.initial = '', required this.onChanged, this.debounce = const Duration(milliseconds: 400)});

  @override
  State<SimpleSearchBar> createState() => _SimpleSearchBarState();
}

class _SimpleSearchBarState extends State<SimpleSearchBar> {
  late final TextEditingController _ctrl;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initial);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  void _onTextChanged(String v) {
    _debounce?.cancel();
    _debounce = Timer(widget.debounce, () => widget.onChanged(v));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _ctrl,
      onChanged: _onTextChanged,
      decoration: InputDecoration(
        hintText: 'Buscar contenido',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _ctrl.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _ctrl.clear();
                  widget.onChanged('');
                  setState(() {});
                },
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      ),
    );
  }
}