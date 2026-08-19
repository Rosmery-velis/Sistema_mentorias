// Tarjeta de navegación para menús de home.

import 'package:flutter/material.dart';
import '../temas/colores_app.dart';
import '../temas/estilos_texto_app.dart';

class TarjetaMenu extends StatelessWidget {
  // Ícono que se muestra a la izquierda de la tarjeta.
  final IconData icono;

  // Título principal de la opción de menú.
  final String titulo;

  // Descripción breve de la opción de menú.
  final String subtitulo;

  // Función que se ejecuta al presionar la tarjeta.
  final VoidCallback onPressed;

  const TarjetaMenu({
    super.key,
    required this.icono,
    required this.titulo,
    required this.subtitulo,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icono, size: 40, color: ColoresApp.primario),
        title: Text(titulo, style: EstilosTextoApp.subtitulo),
        subtitle: Text(subtitulo),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: ColoresApp.textoSecundario,
        ),
        onTap: onPressed,
      ),
    );
  }
}