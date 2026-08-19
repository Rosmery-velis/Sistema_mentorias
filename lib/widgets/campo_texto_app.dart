// Campo de texto reutilizable para formularios.

import 'package:flutter/material.dart';

class CampoTextoApp extends StatelessWidget {
  /// Controlador del campo de texto.
  final TextEditingController controlador;

  /// Texto de la etiqueta (label) del campo.
  final String etiqueta;

  /// Texto de ayuda que aparece cuando el campo está vacío.
  final String? hintText;

  /// Ícono que aparece al inicio del campo.
  final IconData icono;

  /// Si es `true`, el texto se oculta (útil para contraseñas).
  final bool ocultarTexto;

  /// Tipo de teclado que se muestra al enfocar el campo.
  final TextInputType tipoTeclado;

  /// Función de validación.
  /// Retorna `null` si el valor es válido, o un mensaje de error.
  final String? Function(String?)? validador;

  /// Si es `false`, el campo se deshabilita (modo solo lectura visual).
  final bool habilitado;

  /// Número máximo de líneas. Si es `null`, el campo es de una sola línea.
  /// Se ignora cuando [ocultarTexto] es `true`.
  final int? maxLineas;

  const CampoTextoApp({
    super.key,
    required this.controlador,
    required this.etiqueta,
    required this.icono,
    this.hintText,
    this.ocultarTexto = false,
    this.tipoTeclado = TextInputType.text,
    this.validador,
    this.habilitado = true,
    this.maxLineas,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controlador,
      decoration: InputDecoration(
        labelText: etiqueta,
        hintText: hintText,
        prefixIcon: Icon(icono),
      ),
      keyboardType: tipoTeclado,
      obscureText: ocultarTexto,
      validator: validador,
      enabled: habilitado,
      maxLines: ocultarTexto ? 1 : maxLineas,
    );
  }
}