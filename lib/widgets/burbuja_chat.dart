// Burbuja de mensaje para la pantalla de chat.

import 'package:flutter/material.dart';
import '../temas/colores_app.dart';
import '../temas/estilos_texto_app.dart';

class BurbujaChat extends StatelessWidget {
  // Texto del mensaje.
  final String contenido;

  // Si es `true`, el mensaje se alinea a la derecha (mensaje propio).
  // Si es `false`, se alinea a la izquierda (mensaje del contacto).
  final bool esMio;

  const BurbujaChat({
    super.key,
    required this.contenido,
    required this.esMio,
  });

  // Color de fondo según si el mensaje es propio o del contacto.
  Color get _colorFondo {
    return esMio ? ColoresApp.primarioClaro : ColoresApp.divisor;
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: esMio ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: _colorFondo,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(esMio ? 16 : 4),
            bottomRight: Radius.circular(esMio ? 4 : 16),
          ),
        ),
        child: Text(
          contenido,
          style: EstilosTextoApp.cuerpo,
        ),
      ),
    );
  }
}