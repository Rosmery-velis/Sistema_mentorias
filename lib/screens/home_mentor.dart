// Pantalla principal del mentor.

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../main.dart';
import '../temas/colores_app.dart';
import '../temas/estilos_texto_app.dart';
import '../widgets/tarjeta_bienvenida.dart';
import '../widgets/tarjeta_menu.dart';

class HomeMentor extends StatelessWidget {
  const HomeMentor({super.key});

  // ════ CONSTRUIR UI ════

  @override
  Widget build(BuildContext context) {
    final usuario = ApiService.usuarioActual!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // ─── Barra superior ───────────────────────
      appBar: _buildAppBar(context, isDark),

      // ─── Cuerpo ───────────────────────────────
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Tarjeta de bienvenida ───────────
            TarjetaBienvenida(
              nombre: usuario.nombre,
              detalleSuperior: 'Enseñas hasta nivel: ${usuario.nivelEnsenar}',
              detalleInferior:
                  'Habilidades: ${usuario.habilidadesEnsenar.isEmpty
                      ? "No definidas"
                      : usuario.habilidadesEnsenar}',
            ),
            const SizedBox(height: 24),

            // ─── Título de menú ──────────────────
            const Text('Acciones:', style: EstilosTextoApp.titulo),
            const SizedBox(height: 12),

            // ─── Opciones de menú ────────────────
            TarjetaMenu(
              icono: Icons.person,
              titulo: 'Mi Perfil',
              subtitulo: 'Editar habilidades y nivel que enseñas',
              onPressed: () => Navigator.pushNamed(context, '/perfil'),
            ),
            TarjetaMenu(
              icono: Icons.schedule,
              titulo: 'Mis Horarios',
              subtitulo: 'Configura tu disponibilidad para estudiantes',
              onPressed: () => Navigator.pushNamed(context, '/horarios'),
            ),
            TarjetaMenu(
              icono: Icons.people,
              titulo: 'Mis Estudiantes',
              subtitulo: 'Ver estudiantes que has evaluado',
              onPressed: () =>
                  Navigator.pushNamed(context, '/estudiantes'),
            ),
            TarjetaMenu(
              icono: Icons.rate_review,
              titulo: 'Evaluar Estudiantes',
              subtitulo: 'Aprueba o reprueba a tus estudiantes',
              onPressed: () => Navigator.pushNamed(context, '/evaluar'),
            ),
            TarjetaMenu(
              icono: Icons.chat,
              titulo: 'Buscar Contactos',
              subtitulo: 'Buscar y conversar con estudiantes',
              onPressed: () => Navigator.pushNamed(context, '/chats'),
            ),
          ],
        ),
      ),
    );
  }

  // ════ WIDGETS AUXILIARES ════

  /// Barra superior con título, botón de tema y cerrar sesión.
  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDark) {
    return AppBar(
      title: const Text('Panel Mentor'),
      actions: [
        // Botón para alternar tema claro/oscuro
        IconButton(
          icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
          tooltip: isDark ? 'Modo claro' : 'Modo oscuro',
          onPressed: () {
            MyApp.appKey.currentState?.toggleTheme();
          },
        ),

        // Botón para cerrar sesión
        IconButton(
          icon: const Icon(Icons.logout),
          tooltip: 'Cerrar sesión',
          onPressed: () {
            ApiService.usuarioActual = null;
            Navigator.pushReplacementNamed(context, '/login');
          },
        ),
      ],
    );
  }
}