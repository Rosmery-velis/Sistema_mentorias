// Tema global de la aplicación — Cosmos.
// Tema único: fondo oscuro profundo con acentos púrpura y dorado.

import 'package:flutter/material.dart';
import 'colores_app.dart';
import 'estilos_texto_app.dart';

class TemaApp {
  /// Constructor privado para evitar instancias.
  TemaApp._();

  // ════ TEMA COSMOS ════

  static ThemeData get cosmos {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      // Transparente para que se vea el CosmosBackground detrás.
      scaffoldBackgroundColor: Colors.transparent,

      // ─── Esquema de color ───
      colorScheme: ColorScheme.fromSeed(
        seedColor: ColoresApp.primario,
        brightness: Brightness.dark,
      ),

      // ─── AppBar ───
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: ColoresApp.textoPrincipal,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: ColoresApp.textoPrincipal,
        ),
        iconTheme: IconThemeData(
          color: ColoresApp.textoPrincipal,
        ),
      ),

      // ─── Campos de texto (TextFormField) ───
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ColoresApp.superficie,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ColoresApp.borde),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ColoresApp.borde),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ColoresApp.primario, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ColoresApp.error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        prefixIconColor: ColoresApp.primarioClaro,
        labelStyle: EstilosTextoApp.etiqueta,
        hintStyle: const TextStyle(color: ColoresApp.textoSecundario),
        floatingLabelStyle: const TextStyle(color: ColoresApp.primarioClaro),
      ),

      // ─── Botón principal (ElevatedButton) ───
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ColoresApp.primario,
          foregroundColor: ColoresApp.textoSobrePrimario,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
          textStyle: EstilosTextoApp.textoBoton,
        ),
      ),

      // ─── Botón de texto (TextButton) ───
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: ColoresApp.primarioClaro,
          textStyle: EstilosTextoApp.textoEnlace,
        ),
      ),

      // ─── Tarjetas ───
      cardTheme: CardThemeData(
        elevation: 0,
        color: ColoresApp.superficie,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: ColoresApp.borde, width: 0.5),
        ),
      ),

      // ─── SnackBar ───
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: ColoresApp.superficieElevada,
        contentTextStyle: const TextStyle(color: ColoresApp.textoPrincipal),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: ColoresApp.borde, width: 0.5),
        ),
      ),

      // ─── Iconos ───
      iconTheme: const IconThemeData(
        color: ColoresApp.primarioClaro,
      ),

      // ─── Divisores ───
      dividerTheme: const DividerThemeData(
        color: ColoresApp.divisor,
        thickness: 1,
      ),
    );
  }
}