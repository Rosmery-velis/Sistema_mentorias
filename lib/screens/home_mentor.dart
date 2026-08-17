import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../main.dart';
// No necesita import nuevo, solo agregar el _MenuCard

class HomeMentor extends StatelessWidget {
  const HomeMentor({super.key});

  @override
  Widget build(BuildContext context) {
    final usuario = ApiService.usuarioActual!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel Mentor'),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            tooltip: isDark ? 'Modo claro' : 'Modo oscuro',
            onPressed: () {
              MyApp.appKey.currentState?.toggleTheme();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ApiService.usuarioActual = null;
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;
          final padding = isMobile ? 16.0 : 24.0;

          return SingleChildScrollView(
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(isMobile ? 16 : 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Bienvenido, ${usuario.nombre}',
                            style: TextStyle(
                                fontSize: isMobile ? 18 : 22,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text('Enseñas hasta nivel: ${usuario.nivelEnsenar}',
                            style: TextStyle(
                                fontSize: isMobile ? 16 : 18,
                                color: Colors.deepPurple)),
                        const SizedBox(height: 4),
                        Text('Habilidades: ${usuario.habilidadesEnsenar.isEmpty ? "No definidas" : usuario.habilidadesEnsenar}'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Acciones:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                _MenuCard(
                  icon: Icons.person,
                  title: 'Mi Perfil',
                  subtitle: 'Editar habilidades y nivel que enseñas',
                  onTap: () => Navigator.pushNamed(context, '/perfil'),
                ),
                _MenuCard(
                  icon: Icons.schedule,
                  title: 'Mis Horarios',
                  subtitle: 'Configura tu disponibilidad para estudiantes',
                  onTap: () => Navigator.pushNamed(context, '/horarios'),
                ),
                _MenuCard(
                  icon: Icons.people,
                  title: 'Mis Estudiantes',
                  subtitle: 'Ver estudiantes que has evaluado',
                  onTap: () => Navigator.pushNamed(context, '/estudiantes'),
                ),
                _MenuCard(
                  icon: Icons.rate_review,
                  title: 'Evaluar Estudiantes',
                  subtitle: 'Aprueba o reprueba a tus estudiantes',
                  onTap: () => Navigator.pushNamed(context, '/evaluar'),
                ),
                _MenuCard(
                  icon: Icons.chat,
                  title: 'Buscar Contactos',
                  subtitle: 'Buscar y conversar con estudiantes',
                  onTap: () => Navigator.pushNamed(context, '/chats'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, size: 40, color: Colors.deepPurple),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
