// Tema global de la aplicación.

import 'package:flutter/material.dart';
import 'colores_app.dart';
import 'estilos_texto_app.dart';

class TemaApp {
  // Constructor privado para evitar instancias.
  TemaApp._();

  // ════ TEMA CLARO ════

  static ThemeData get claro {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: ColoresApp.fondo,

      // ─── Esquema de color ───
      colorScheme: ColorScheme.fromSeed(
        seedColor: ColoresApp.primario,
        brightness: Brightness.light,
      ),

      // ─── AppBar ───
      appBarTheme: const AppBarTheme(
        backgroundColor: ColoresApp.primario,
        foregroundColor: ColoresApp.textoSobrePrimario,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: ColoresApp.textoSobrePrimario,
        ),
      ),

      // ─── Campos de texto (TextFormField) ───
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        prefixIconColor: ColoresApp.primario,
        labelStyle: EstilosTextoApp.etiqueta,
        floatingLabelStyle: const TextStyle(
          color: ColoresApp.primario,
        ),
      ),

      // ─── Botón principal (ElevatedButton) ───
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ColoresApp.primario,
          foregroundColor: ColoresApp.textoSobrePrimario,
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
          foregroundColor: ColoresApp.primario,
          textStyle: EstilosTextoApp.textoEnlace,
        ),
      ),

      // ─── Tarjetas ───
      cardTheme: CardThemeData(
        elevation: 2,
        color: ColoresApp.superficie,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // ─── SnackBar ───
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  // ════ TEMA OSCURO ════
  
  static ThemeData get oscuro {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF121212),

      // ─── Esquema de color ───
      colorScheme: ColorScheme.fromSeed(
        seedColor: ColoresApp.primario,
        brightness: Brightness.dark,
      ),

      // ─── AppBar ───
      appBarTheme: const AppBarTheme(
        backgroundColor: const Color(0xFF1E1E1E),
        foregroundColor: ColoresApp.textoSobrePrimario,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: ColoresApp.textoSobrePrimario,
        ),
      ),

      // ─── Campos de texto (TextFormField) ───
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        prefixIconColor: ColoresApp.primarioClaro,
        labelStyle: EstilosTextoApp.etiqueta.copyWith(
          color: Colors.white70,
        ),
        floatingLabelStyle: const TextStyle(
          color: ColoresApp.primarioClaro,
        ),
      ),

      // ─── Botón principal (ElevatedButton) ───
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ColoresApp.primario,
          foregroundColor: ColoresApp.textoSobrePrimario,
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
          textStyle: EstilosTextoApp.textoEnlace.copyWith(
            color: ColoresApp.primarioClaro,
          ),
        ),
      ),

      // ─── Tarjetas ───
      cardTheme: CardThemeData(
        elevation: 2,
        color: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // ─── SnackBar ───
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF2C2C2C),
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}