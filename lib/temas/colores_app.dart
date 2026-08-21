// Paleta de colores centralizada de la aplicación.
// Tema Cosmos: fondo oscuro profundo con acentos púrpura y dorado.
// Todos los colores usados en la interfaz se definen aquí.

import 'package:flutter/material.dart';

class ColoresApp {
  /// Constructor privado para evitar instancias.
  ColoresApp._();

  // ════ PRIMARIOS ════

  /// Color principal de la marca (botones, iconos destacados, AppBar).
  static const Color primario = Color(0xFF9664FF);

  /// Variante oscura del primario (estados hover, pressed).
  static const Color primarioOscuro = Color(0xFF7B4FE0);

  /// Variante clara del primario (fondos sutiles, badges, enlaces).
  static const Color primarioClaro = Color(0xFFC896FF);

  // ════ SECUNDARIOS / ACENTO ════

  /// Color de acento para elementos destacados (FAB, chips activos, badges).
  static const Color acento = Color(0xFFFFC896);

  // ════ SUPERFICIES Y FONDOS ════

  /// Fondo general de la aplicación.
  static const Color fondo = Color(0xFF080512);

  /// Fondo de tarjetas, diálogos y superficies elevadas.
  static const Color superficie = Color(0xFF110D22);

  /// Superficie para elementos que necesitan más contraste (dropdowns, drawers, SnackBar).
  static const Color superficieElevada = Color(0xFF1A1230);

  // ════ FONDO ANIMADO (CosmosBackground) ════

  /// Centro del gradiente radial animado (levemente más claro que el fondo).
  static const Color fondoGradienteCentro = Color(0xFF120826);

  /// Borde del gradiente radial animado (más oscuro que el fondo).
  static const Color fondoGradienteBorde = Color(0xFF050310);

  /// Tinte de nebulosa que se mueve lentamente sobre el fondo.
  static const Color nebulosa = Color(0xFF9664FF);

  /// Brillo difuso (glow) para sombras en botones y tarjetas.
  static const Color glow = Color(0xFFB478FF);

  // ════ TEXTO ════

  /// Texto principal (títulos, cuerpo). Lavanda claro, no blanco puro.
  static const Color textoPrincipal = Color(0xFFE8E0F0);

  /// Texto secundario (subtítulos, hints, captions). Gris con tinte púrpura.
  static const Color textoSecundario = Color(0xFF9B8FB5);

  /// Texto sobre fondos de color primario (botones, AppBar).
  static const Color textoSobrePrimario = Color(0xFFFFFFFF);

  // ════ ESTADOS ════

  /// Indica errores, validaciones fallidas o acciones destructivas.
  static const Color error = Color(0xFFFF6B6B);

  /// Indica éxito, acciones completadas o estado aprobado.
  static const Color exito = Color(0xFF4ADE80);

  /// Indica advertencias o atención.
  static const Color advertencia = Color(0xFFFFC896);

  /// Indica información general.
  static const Color info = Color(0xFF60A5FA);

  // ════ BORDES Y DIVISORES ════

  /// Borde de inputs, tarjetas y contornos generales. Púrpura oscuro, sutil.
  static const Color borde = Color(0xFF2A1F3D);

  /// Línea divisora entre secciones. Apenas perceptible.
  static const Color divisor = Color(0xFF1A1530);
}