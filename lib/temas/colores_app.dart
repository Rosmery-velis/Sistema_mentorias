// Paleta de colores centralizada de la aplicación. 
// Todos los colores usados en la interfaz se definen aquí.
// Para cambiar el tema visual de la app, solo modificar este archivo.
//
// Uso:
// ```dart
// color: ColoresApp.primario
// ```
library;

import 'package:flutter/material.dart';

class ColoresApp {
  /// Constructor privado para evitar instancias.
  ColoresApp._();

  // ════ PRIMARIOS ════

  /// Color principal de la marca (botones, iconos destacados, AppBar).
  static const Color primario = Color(0xFF673AB7);

  /// Variante oscura del primario (estados hover, pressed).
  static const Color primarioOscuro = Color(0xFF512DA8);

  /// Variante clara del primario (fondos sutiles, badges).
  static const Color primarioClaro = Color(0xFFD1C4E9);

  // ════ SECUNDARIOS / ACENTO ════

  /// Color de acento para elementos destacados (FAB, chips activos).
  static const Color acento = Color(0xFF00BCD4);

  // ════ SUPERFICIES Y FONDOS ════

  /// Fondo general de la aplicación.
  static const Color fondo = Color(0xFFF5F5F5);

  /// Fondo de tarjetas, diálogos y superficies elevadas.
  static const Color superficie = Color(0xFFFFFFFF);

  // ════ TEXTO ════

  /// Texto principal (títulos, cuerpo).
  static const Color textoPrincipal = Color(0xFF212121);

  /// Texto secundario (subtítulos, hints, captions).
  static const Color textoSecundario = Color(0xFF757575);

  /// Texto sobre fondos de color primario (botones, AppBar).
  static const Color textoSobrePrimario = Color(0xFFFFFFFF);

  // ════ ESTADOS ════

  /// Indica errores, validaciones fallidas o acciones destructivas.
  static const Color error = Color(0xFFD32F2F);

  /// Indica éxito, acciones completadas o estado aprobado.
  static const Color exito = Color(0xFF388E3C);

  /// Indica advertencias o atención.
  static const Color advertencia = Color(0xFFF57C00);

  /// Indica información general.
  static const Color info = Color(0xFF1976D2);

  // ════ BORDES Y DIVISORES ════

  /// Borde de inputs, tarjetas y contornos generales.
  static const Color borde = Color(0xFFBDBDBD);

  /// Línea divisora entre secciones.
  static const Color divisor = Color(0xFFE0E0E0);
}