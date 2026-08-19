// Tarjeta de bienvenida que se muestra en los homes.

import 'package:flutter/material.dart';
import '../temas/colores_app.dart';
import '../temas/estilos_texto_app.dart';

class TarjetaBienvenida extends StatelessWidget {
  // Nombre del usuario que se muestra en el saludo.
  final String nombre;

  // Primera línea de información (aparece en color primario).
  // Ejemplo: "Nivel actual: Intermedio" o "Enseñas hasta nivel: Avanzado".
  final String detalleSuperior;

  // Segunda línea de información (aparece en texto secundario).
  // Ejemplo: "Rol: Estudiante" o "Habilidades: Python, Flutter".
  final String detalleInferior;

  const TarjetaBienvenida({
    super.key,
    required this.nombre,
    required this.detalleSuperior,
    required this.detalleInferior,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Saludo principal
            Text(
              'Bienvenido, $nombre',
              style: EstilosTextoApp.titulo,
            ),
            const SizedBox(height: 8),

            // Detalle superior (color primario)
            Text(
              detalleSuperior,
              style: EstilosTextoApp.cuerpo.copyWith(
                color: ColoresApp.primario,
              ),
            ),
            const SizedBox(height: 4),

            // Detalle inferior (texto normal)
            Text(
              detalleInferior,
              style: EstilosTextoApp.cuerpo,
            ),
          ],
        ),
      ),
    );
  }
}