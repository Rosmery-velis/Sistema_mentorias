import 'package:flutter/material.dart';
import '../temas/colores_app.dart';
import '../temas/estilos_texto_app.dart';

class MensajeError extends StatelessWidget {
  /// Mensaje de error a mostrar. Si es `null`, el widget no se renderiza.
  final String? mensaje;

  const MensajeError({super.key, this.mensaje});

  @override
  Widget build(BuildContext context) {
    // Si no hay error, no ocupar espacio
    if (mensaje == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            size: 18,
            color: ColoresApp.error,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              mensaje!,
              style: EstilosTextoApp.textoError,
            ),
          ),
        ],
      ),
    );
  }
}