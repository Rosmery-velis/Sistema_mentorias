// Pantalla para que el estudiante busque mentores.

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/usuario.dart';
import '../models/horario.dart';
import '../temas/colores_app.dart';
import '../temas/estilos_texto_app.dart';
import '../widgets/campo_texto_app.dart';
import '../widgets/mensaje_error.dart';
import '../widgets/avatar_usuario.dart';
import '../widgets/estado_vacio.dart';

class BuscarMentoresScreen extends StatefulWidget {
  const BuscarMentoresScreen({super.key});

  @override
  State<BuscarMentoresScreen> createState() => _BuscarMentoresScreenState();
}

class _BuscarMentoresScreenState extends State<BuscarMentoresScreen> {
  // ─── Controladores ───

  /// Controlador del campo de búsqueda por habilidad.
  final _habilidadController = TextEditingController();

  // ─── Estado ───

  /// Lista de mentores encontrados en la última búsqueda.
  List<Usuario> _mentores = [];

  /// Indica si se está ejecutando la búsqueda.
  bool _cargando = false;

  /// Mensaje de error a mostrar (null = sin error).
  String? _error;

  /// Indica si el usuario ya realizó al menos una búsqueda.
  bool _buscado = false;

  // ════ CICLO DE VIDA ════

  @override
  void dispose() {
    _habilidadController.dispose();
    super.dispose();
  }

  // ════ LÓGICA ════
  
  /* Ejecuta la búsqueda de mentores según la habilidad ingresada.
  Flujo:
    1. Valida que el campo no esté vacío.
    2. Usa el nivel del estudiante actual como filtro.
    3. Llama a [ApiService.buscarMentores].
    4. Actualiza la lista de resultados.
  */
  Future<void> _buscar() async {
    final habilidad = _habilidadController.text.trim();
    if (habilidad.isEmpty) {
      setState(() => _error = 'Ingrese una habilidad para buscar');
      return;
    }

    setState(() {
      _cargando = true;
      _error = null;
      _buscado = true;
    });

    try {
      final nivel = ApiService.usuarioActual!.nivel;
      final mentores = await ApiService.buscarMentores(habilidad, nivel);
      setState(() => _mentores = mentores);
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  /* Muestra un diálogo con los horarios disponibles de un mentor.
  
  Carga los horarios desde el backend mediante [FutureBuilder] y los agrupa por día de la semana. */
  void _verHorarios(Usuario mentor) {
    showDialog(
      context: context,
      builder: (ctx) => _DialogoHorarios(mentor: mentor),
    );
  }

  // ══════════════════════════════════════════════════
  //  CONSTRUIR UI
  // ══════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ─── Barra superior ───────────────────────
      appBar: AppBar(title: const Text('Buscar Mentores')),

      // ─── Cuerpo ───────────────────────────────
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ─── Tarjeta de búsqueda ─────────────
            _buildTarjetaBusqueda(),
            const SizedBox(height: 16),

            // ─── Mensaje de error ────────────────
            MensajeError(mensaje: _error),

            // ─── Estado: sin resultados ──────────
            if (_buscado && _mentores.isEmpty && !_cargando)
              const Expanded(
                child: EstadoVacio(
                  icono: Icons.search_off,
                  mensaje:
                      'No se encontraron mentores para esa habilidad y tu nivel.',
                ),
              ),

            // ─── Lista de mentores ───────────────
            if (_mentores.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: _mentores.length,
                  itemBuilder: (context, index) {
                    final mentor = _mentores[index];
                    return _buildTarjetaMentor(mentor);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════
  //  WIDGETS AUXILIARES
  // ══════════════════════════════════════════════════

  /// Tarjeta con el formulario de búsqueda (campo + botón).
  Widget _buildTarjetaBusqueda() {
    final nivel = ApiService.usuarioActual!.nivel;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Tu nivel actual: $nivel',
              style: EstilosTextoApp.subtitulo,
            ),
            const SizedBox(height: 12),

            // Campo de habilidad
            CampoTextoApp(
              controlador: _habilidadController,
              etiqueta: 'Habilidad que quieres aprender',
              icono: Icons.search,
            ),
            const SizedBox(height: 12),

            // Botón de búsqueda
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _cargando ? null : _buscar,
                icon: const Icon(Icons.search),
                label: _cargando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: ColoresApp.textoSobrePrimario,
                        ),
                      )
                    : const Text('Buscar Mentores'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Tarjeta individual de un mentor en la lista de resultados.
  Widget _buildTarjetaMentor(Usuario mentor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const AvatarUsuario(rol: 'mentor'),
        title: Text(mentor.nombre, style: EstilosTextoApp.subtitulo),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Enseña: ${mentor.habilidadesEnsenar}'),
            Text('Nivel que enseña: ${mentor.nivelEnsenar}'),
            if (mentor.experiencia.isNotEmpty)
              Text('Experiencia: ${mentor.experiencia}'),
          ],
        ),
        isThreeLine: true,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Botón: ver horarios
            IconButton(
              icon: const Icon(Icons.schedule, color: ColoresApp.advertencia),
              tooltip: 'Ver horarios',
              onPressed: () => _verHorarios(mentor),
            ),
            // Botón: chatear
            IconButton(
              icon: const Icon(Icons.chat, color: ColoresApp.primario),
              tooltip: 'Chatear',
              onPressed: () {
                Navigator.pushNamed(context, '/chat', arguments: mentor);
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════
//  DIÁLOGO DE HORARIOS (widget privado aparte)
// ══════════════════════════════════════════════════

/// Diálogo que muestra los horarios disponibles de un mentor.
///
/// Los horarios se cargan desde el backend y se agrupan por día
/// de la semana para una lectura clara.
class _DialogoHorarios extends StatelessWidget {
  /// Mentor cuyos horarios se van a mostrar.
  final Usuario mentor;

  const _DialogoHorarios({required this.mentor});

  /// Nombres legibles de los días de la semana.
  static const _nombresDias = {
    'lunes': 'Lunes',
    'martes': 'Martes',
    'miercoles': 'Miércoles',
    'jueves': 'Jueves',
    'viernes': 'Viernes',
    'sabado': 'Sábado',
    'domingo': 'Domingo',
  };

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Horarios de ${mentor.nombre}'),
      content: SizedBox(
        width: double.maxFinite,
        child: FutureBuilder<List<Horario>>(
          future: ApiService.getHorariosDeMentor(mentor.id),
          builder: (ctx, snapshot) {
            // Estado: cargando
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            // Estado: error
            if (snapshot.hasError) {
              return const Text('Error al cargar horarios');
            }

            final horarios = snapshot.data!;

            // Estado: sin horarios
            if (horarios.isEmpty) {
              return const Text(
                'Este mentor aún no ha configurado horarios.',
              );
            }

            // Estado: mostrar horarios agrupados por día
            return _buildListaHorarios(horarios);
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }

  /// Agrupa los horarios por día y construye la lista visual.
  Widget _buildListaHorarios(List<Horario> horarios) {
    // Agrupar horarios por día de la semana
    final agrupados = <String, List<Horario>>{};
    for (final h in horarios) {
      agrupados.putIfAbsent(h.diaSemana, () => []).add(h);
    }

    return ListView(
      shrinkWrap: true,
      children: agrupados.entries.map((entrada) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nombre del día
              Text(
                _nombresDias[entrada.key] ?? entrada.key,
                style: EstilosTextoApp.subtitulo,
              ),

              // Lista de horarios de ese día
              for (final h in entrada.value)
                Padding(
                  padding: const EdgeInsets.only(left: 16, top: 4),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 16,
                        color: ColoresApp.textoSecundario,
                      ),
                      const SizedBox(width: 6),
                      Text('${h.horaInicio} - ${h.horaFin}'),
                    ],
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }
}