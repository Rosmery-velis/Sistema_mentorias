// Widget para estados vacíos o sin resultados.

import 'package:flutter/material.dart';
import '../temas/colores_app.dart';
import '../temas/estilos_texto_app.dart';

class EstadoVacio extends StatelessWidget {
  /// Ícono que se muestra centrado.
  final IconData icono;

  /// Mensaje descriptivo debajo del ícono.
  final String mensaje;

  const EstadoVacio({
    super.key,
    required this.icono,
    required this.mensaje,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 80, color: ColoresApp.textoSecundario),
          const SizedBox(height: 16),
          Text(
            mensaje,
            style: EstilosTextoApp.cuerpo.copyWith(
              color: ColoresApp.textoSecundario,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}