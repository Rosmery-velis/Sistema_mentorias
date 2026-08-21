// Botón principal reutilizable con estado de carga.

import 'package:flutter/material.dart';
import '../temas/colores_app.dart';

class BotonPrincipal extends StatelessWidget {
  /// Texto que se muestra en el botón.
  final String texto;

  /// Si es `true`, muestra un loader y deshabilita el botón.
  final bool cargando;

  /// Función que se ejecuta al presionar el botón (cuando no está cargando).
  final VoidCallback? onPressed;

  /// Ícono opcional que aparece antes del texto.
  final IconData? icono;

  const BotonPrincipal({
    super.key,
    required this.texto,
    required this.cargando,
    required this.onPressed,
    this.icono,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: cargando ? null : onPressed,
        child: _buildContenido(),
      ),
    );
  }

  /// Construye el contenido del botón: loader, ícono+texto, o solo texto.
  Widget _buildContenido() {
    // Estado de carga: mostrar indicador
    if (cargando) {
      return const SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: ColoresApp.textoSobrePrimario,
        ),
      );
    }

    // Con ícono: mostrar ícono + texto
    if (icono != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono),
          const SizedBox(width: 8),
          Text(texto),
        ],
      );
    }

    // Default: solo texto
    return Text(texto);
  }
}