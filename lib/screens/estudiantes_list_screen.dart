// Pantalla que muestra los estudiantes evaluados por el mentor.

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/usuario.dart';
import '../temas/colores_app.dart';
import '../temas/estilos_texto_app.dart';
import '../widgets/mensaje_error.dart';
import '../widgets/avatar_usuario.dart';
import '../widgets/estado_vacio.dart';

class EstudiantesListScreen extends StatefulWidget {
  const EstudiantesListScreen({super.key});

  @override
  State<EstudiantesListScreen> createState() => _EstudiantesListScreenState();
}

class _EstudiantesListScreenState extends State<EstudiantesListScreen> {
  // ─── Estado ────────────────────────────────────

  /// Lista de estudiantes evaluados por el mentor actual.
  List<Usuario> _estudiantes = [];

  /// Indica si se está cargando la lista por primera vez.
  bool _cargando = true;

  /// Mensaje de error a mostrar (null = sin error).
  String? _error;

  // ══════════════════════════════════════════════════
  //  CICLO DE VIDA
  // ══════════════════════════════════════════════════

  @override
  void initState() {
    super.initState();
    _cargarEstudiantes();
  }

  // ══════════════════════════════════════════════════
  //  LÓGICA
  // ══════════════════════════════════════════════════

  /// Carga la lista de estudiantes desde el backend.
  ///
  /// Se ejecuta al iniciar la pantalla y al refrescar
  /// (pull-to-refresh).
  Future<void> _cargarEstudiantes() async {
    try {
      final mentorId = ApiService.usuarioActual!.id;
      final estudiantes = await ApiService.getEstudiantesDeMentor(mentorId);
      setState(() {
        _estudiantes = estudiantes;
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _cargando = false;
      });
    }
  }

  // ══════════════════════════════════════════════════
  //  CONSTRUIR UI
  // ══════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ─── Barra superior ───────────────────────
      appBar: AppBar(title: const Text('Mis Estudiantes')),

      // ─── Cuerpo ───────────────────────────────
      body: _buildContenido(),
    );
  }

  /// Construye el contenido según el estado actual (carga, error, vacío, lista).
  Widget _buildContenido() {
    // Estado: cargando
    if (_cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    // Estado: error
    if (_error != null) {
      return Center(
        child: MensajeError(mensaje: _error),
      );
    }

    // Estado: sin estudiantes
    if (_estudiantes.isEmpty) {
      return const EstadoVacio(
        icono: Icons.school_outlined,
        mensaje: 'Aún no tienes estudiantes evaluados',
      );
    }

    // Estado: lista de estudiantes
    return RefreshIndicator(
      onRefresh: _cargarEstudiantes,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _estudiantes.length,
        itemBuilder: (context, index) {
          final estudiante = _estudiantes[index];
          return _buildTarjetaEstudiante(estudiante);
        },
      ),
    );
  }

  /// Tarjeta individual de un estudiante en la lista.
  Widget _buildTarjetaEstudiante(Usuario estudiante) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: AvatarUsuario(
          rol: 'estudiante',
          texto: '${estudiante.nivel}',
        ),
        title: Text(estudiante.nombre, style: EstilosTextoApp.subtitulo),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(estudiante.correo),
            Text(
              'Nivel: ${estudiante.nivel}',
              style: EstilosTextoApp.cuerpo.copyWith(
                color: ColoresApp.primario,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (estudiante.habilidadesAprender.isNotEmpty)
              Text('Aprende: ${estudiante.habilidadesAprender}'),
          ],
        ),
        isThreeLine: true,
        trailing: IconButton(
          icon: const Icon(Icons.chat, color: ColoresApp.primario),
          onPressed: () {
            Navigator.pushNamed(context, '/chat', arguments: estudiante);
          },
        ),
      ),
    );
  }
}