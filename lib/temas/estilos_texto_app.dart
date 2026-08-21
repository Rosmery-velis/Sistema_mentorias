// Estilos de texto centralizados de la aplicación.
// Define los estilos tipográficos reutilizables en toda la app.
// Se usan junto con [ColoresApp] para mantener consistencia visual.

import 'package:flutter/material.dart';
import 'colores_app.dart';

class EstilosTextoApp {
  /// Constructor privado para evitar instancias.
  EstilosTextoApp._();

  // ════ TÍTULOS ════

  /// Título principal grande (nombre de la app, encabezados de pantalla).
  static const TextStyle tituloGrande = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: ColoresApp.textoPrincipal,
  );

  /// Título de sección.
  static const TextStyle titulo = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: ColoresApp.textoPrincipal,
  );

  /// Subtítulo (títulos de tarjetas, nombres de usuario).
  static const TextStyle subtitulo = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: ColoresApp.textoPrincipal,
  );

  // ════ CUERPO ════

  /// Texto de cuerpo normal (descripciones, párrafos).
  static const TextStyle cuerpo = TextStyle(
    fontSize: 14,
    color: ColoresApp.textoPrincipal,
  );

  /// Texto de cuerpo en negrita (datos destacados).
  static const TextStyle cuerpoNegrita = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: ColoresApp.textoPrincipal,
  );

  // ════ ESPECIALIZADOS ════

  /// Etiqueta de campos de formulario.
  static const TextStyle etiqueta = TextStyle(
    fontSize: 14,
    color: ColoresApp.textoSecundario,
  );

  /// Texto dentro de botones principales.
  static const TextStyle textoBoton = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    color: ColoresApp.textoSobrePrimario,
  );

  /// Mensaje de error (validación, excepciones).
  static const TextStyle textoError = TextStyle(
    fontSize: 14,
    color: ColoresApp.error,
  );

  /// Texto de enlaces navegables ("¿No tienes cuenta?").
  static const TextStyle textoEnlace = TextStyle(
    fontSize: 14,
    color: ColoresApp.primarioClaro,
    fontWeight: FontWeight.w500,
  );

  /// Texto de acento (badges, etiquetas destacadas, elementos dorados).
  static const TextStyle textoAcento = TextStyle(
    fontSize: 14,
    color: ColoresApp.acento,
    fontWeight: FontWeight.w600,
  );

  /// Texto pequeño (fechas, metadatos, pies de tarjeta).
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    color: ColoresApp.textoSecundario,
  );
}