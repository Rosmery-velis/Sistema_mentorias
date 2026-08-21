// Pantalla principal del estudiante.

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../temas/estilos_texto_app.dart';
import '../widgets/tarjeta_bienvenida.dart';
import '../widgets/tarjeta_menu.dart';

class HomeEstudiante extends StatelessWidget {
  const HomeEstudiante({super.key});

  // ════ CONSTRUIR UI ════ 

  @override
  Widget build(BuildContext context) {
    final usuario = ApiService.usuarioActual!;

    return Scaffold(
      // ─── Barra superior ───────────────────────
      appBar: _buildAppBar(context),

      // ─── Cuerpo ───────────────────────────────
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Tarjeta de bienvenida ───────────
            TarjetaBienvenida(
              nombre: usuario.nombre,
              detalleSuperior: 'Nivel actual: ${usuario.nivel}',
              detalleInferior: 'Rol: ${usuario.rol}',
            ),
            const SizedBox(height: 24),

            // ─── Título de menú ──────────────────
            const Text('Acciones:', style: EstilosTextoApp.titulo),
            const SizedBox(height: 12),

            // ─── Opciones de menú ────────────────
            TarjetaMenu(
              icono: Icons.person,
              titulo: 'Mi Perfil',
              subtitulo: 'Editar habilidades y objetivos',
              onPressed: () => Navigator.pushNamed(context, '/perfil'),
            ),
            TarjetaMenu(
              icono: Icons.search,
              titulo: 'Buscar Mentores',
              subtitulo:
                  'Encuentra mentores según tu nivel y habilidades',
              onPressed: () =>
                  Navigator.pushNamed(context, '/buscar_mentores'),
            ),
            TarjetaMenu(
              icono: Icons.chat,
              titulo: 'Buscar Contactos',
              subtitulo: 'Buscar y conversar con mentores',
              onPressed: () => Navigator.pushNamed(context, '/chats'),
            ),
          ],
        ),
      ),
    );
  }

  // ════ WIDGETS AUXILIARES ════

  // Barra superior con título, botón de tema y cerrar sesión.
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Panel Estudiante'),
      actions: [
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