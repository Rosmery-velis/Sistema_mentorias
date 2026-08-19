// Texto con enlace para navegar entre pantallas de autenticación.

import 'package:flutter/material.dart';

class EnlaceNavegacion extends StatelessWidget {
  /// Texto del enlace.
  final String texto;

  /// Función que se ejecuta al presionar el enlace.
  final VoidCallback onPressed;

  const EnlaceNavegacion({
    super.key,
    required this.texto,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(texto),
    );
  }
}