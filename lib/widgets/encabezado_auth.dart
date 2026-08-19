// Encabezado visual para pantallas de autenticación (login / registro).

import 'package:flutter/material.dart';
import '../temas/colores_app.dart';
import '../temas/estilos_texto_app.dart';

class EncabezadoAuth extends StatelessWidget {
  /// Ícono principal que se muestra arriba.
  final IconData icono;

  /// Título debajo del ícono.
  final String titulo;

  /// Subtítulo opcional debajo del título.
  final String? subtitulo;

  const EncabezadoAuth({
    super.key,
    required this.icono,
    required this.titulo,
    this.subtitulo,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Ícono principal
        Icon(icono, size: 80, color: ColoresApp.primario),
        const SizedBox(height: 16),

        // Título
        Text(
          titulo,
          style: EstilosTextoApp.tituloGrande,
          textAlign: TextAlign.center,
        ),

        // Subtítulo (solo si se proporciona)
        if (subtitulo != null) ...[
          const SizedBox(height: 8),
          Text(
            subtitulo!,
            style: EstilosTextoApp.cuerpo,
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}