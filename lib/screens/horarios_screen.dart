// Pantalla de gestión de horarios del mentor.

import 'package:flutter/material.dart';
import '../models/horario.dart';
import '../services/api_service.dart';
import '../constantes.dart';
import '../temas/colores_app.dart';
import '../temas/estilos_texto_app.dart';
import '../widgets/estado_vacio.dart';

class HorariosScreen extends StatefulWidget {
  const HorariosScreen({super.key});

  @override
  State<HorariosScreen> createState() => _HorariosScreenState();
}

class _HorariosScreenState extends State<HorariosScreen> {
  // ─── Estado ───

  /// Lista de horarios del mentor actual.
  List<Horario> _horarios = [];

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
    _cargarHorarios();
  }

  // ══════════════════════════════════════════════════
  //  LÓGICA
  // ══════════════════════════════════════════════════

  /// Carga la lista de horarios desde el backend.
  Future<void> _cargarHorarios() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final mentorId = ApiService.usuarioActual!.id;
      final horarios = await ApiService.getHorariosDeMentor(mentorId);
      setState(() {
        _horarios = horarios;
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _cargando = false;
      });
    }
  }

  /// Abre el diálogo para agregar un nuevo horario.
  ///
  /// Si el usuario completa el formulario, crea el horario
  /// en el backend y recarga la lista.
  Future<void> _agregarHorario() async {
    final resultado = await showDialog<Map<String, String>>(
      context: context,
      builder: (ctx) => const _DialogoAgregarHorario(),
    );

    if (resultado == null) return;

    try {
      final mentorId = ApiService.usuarioActual!.id;
      await ApiService.crearHorario(
        mentorId,
        resultado['dia']!,
        resultado['inicio']!,
        resultado['fin']!,
      );

      _cargarHorarios();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Horario agregado correctamente')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: ${e.toString().replaceFirst('Exception: ', '')}',
            ),
          ),
        );
      }
    }
  }

  /// Muestra un diálogo de confirmación y elimina el horario.
  Future<void> _eliminarHorario(Horario horario) async {
    final nombreDia = Constantes.nombresDias[horario.diaSemana] ?? horario.diaSemana;

    final confirmado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar horario'),
        content: Text(
          '¿Eliminar $nombreDia de ${horario.horaInicio} a ${horario.horaFin}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: ColoresApp.error),
            ),
          ),
        ],
      ),
    );

    if (confirmado != true) return;

    try {
      await ApiService.eliminarHorario(horario.id);
      _cargarHorarios();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: ${e.toString().replaceFirst('Exception: ', '')}',
            ),
          ),
        );
      }
    }
  }

  /// Agrupa los horarios por día de la semana.
  Map<String, List<Horario>> _agruparPorDia() {
    final mapa = <String, List<Horario>>{};
    for (final h in _horarios) {
      mapa.putIfAbsent(h.diaSemana, () => []).add(h);
    }
    return mapa;
  }

  // ══════════════════════════════════════════════════
  //  CONSTRUIR UI
  // ══════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ─── Barra superior ───────────────────────
      appBar: AppBar(title: const Text('Mi Disponibilidad')),

      // ─── Cuerpo ───────────────────────────────
      body: _buildContenido(),

      // ─── Botón flotante ───────────────────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _agregarHorario,
        icon: const Icon(Icons.add),
        label: const Text('Agregar Horario'),
      ),
    );
  }

  /// Construye el contenido según el estado actual.
  Widget _buildContenido() {
    // Estado: cargando
    if (_cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    // Estado: error
    if (_error != null) {
      return Center(
        child: Text(_error!, style: EstilosTextoApp.textoError),
      );
    }

    // Estado: sin horarios
    if (_horarios.isEmpty) {
      return const EstadoVacio(
        icono: Icons.schedule,
        mensaje: 'No tienes horarios configurados\n'
            'Toca "+" para agregar tu disponibilidad',
      );
    }

    // Estado: lista de horarios agrupados por día
    return _buildListaHorarios();
  }

  /// Lista de horarios agrupados por día de la semana.
  Widget _buildListaHorarios() {
    final agrupados = _agruparPorDia();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final dia in Constantes.diasSemana)
          if (agrupados.containsKey(dia))
            _buildTarjetaDia(dia, agrupados[dia]!),
      ],
    );
  }

  /// Tarjeta con los horarios de un día específico.
  Widget _buildTarjetaDia(String dia, List<Horario> horarios) {
    final nombreDia = Constantes.nombresDias[dia] ?? dia;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado del día
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 20,
                  color: ColoresApp.primario,
                ),
                const SizedBox(width: 8),
                Text(nombreDia, style: EstilosTextoApp.subtitulo),
              ],
            ),
            const Divider(),

            // Lista de horarios de ese día
            for (final h in horarios) _buildFilaHorario(h),
          ],
        ),
      ),
    );
  }

  /// Fila individual con un rango de horario y botón de eliminar.
  Widget _buildFilaHorario(Horario horario) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(
            Icons.access_time,
            size: 18,
            color: ColoresApp.textoSecundario,
          ),
          const SizedBox(width: 8),
          Text(
            '${horario.horaInicio} - ${horario.horaFin}',
            style: EstilosTextoApp.cuerpo,
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.delete, color: ColoresApp.error, size: 20),
            onPressed: () => _eliminarHorario(horario),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════
//  DIÁLOGO PARA AGREGAR HORARIO
// ══════════════════════════════════════════════════

/// Diálogo para agregar un nuevo horario de disponibilidad.
///
/// Permite seleccionar el día de la semana, hora de inicio
/// y hora de fin. Retorna un [Map] con las claves:
/// `'dia'`, `'inicio'`, `'fin'`.
class _DialogoAgregarHorario extends StatefulWidget {
  const _DialogoAgregarHorario();

  @override
  State<_DialogoAgregarHorario> createState() =>
      _DialogoAgregarHorarioState();
}

class _DialogoAgregarHorarioState extends State<_DialogoAgregarHorario> {
  // ─── Estado del formulario ─────────────────────

  /// Día de la semana seleccionado.
  String _dia = 'lunes';

  /// Hora de inicio seleccionada.
  TimeOfDay _horaInicio = const TimeOfDay(hour: 8, minute: 0);

  /// Hora de fin seleccionada.
  TimeOfDay _horaFin = const TimeOfDay(hour: 12, minute: 0);

  /// Formatea un [TimeOfDay] como string "HH:mm".
  String _formatearHora(TimeOfDay hora) {
    final hh = hora.hour.toString().padLeft(2, '0');
    final mm = hora.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Agregar Horario'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Selector de día
          _buildSelectorDia(),
          const SizedBox(height: 16),

          // Selectores de hora
          _buildSelectoresHora(),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, {
              'dia': _dia,
              'inicio': _formatearHora(_horaInicio),
              'fin': _formatearHora(_horaFin),
            });
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }

  /// Dropdown para seleccionar el día de la semana.
  Widget _buildSelectorDia() {
    return DropdownButtonFormField<String>(
      value: _dia,
      decoration: const InputDecoration(
        labelText: 'Día de la semana',
      ),
      items: Constantes.diasSemana.map((dia) {
        return DropdownMenuItem(
          value: dia,
          child: Text(Constantes.nombresDias[dia] ?? dia),
        );
      }).toList(),
      onChanged: (v) => setState(() => _dia = v!),
    );
  }

  /// Selectores de hora de inicio y fin.
  Widget _buildSelectoresHora() {
    return Row(
      children: [
        // Hora de inicio
        Expanded(
          child: _buildSelectorHora(
            etiqueta: 'Inicio',
            hora: _horaInicio,
            onSeleccionar: (t) => setState(() => _horaInicio = t),
          ),
        ),

        // Hora de fin
        Expanded(
          child: _buildSelectorHora(
            etiqueta: 'Fin',
            hora: _horaFin,
            onSeleccionar: (t) => setState(() => _horaFin = t),
          ),
        ),
      ],
    );
  }

  /// Selector individual de hora con [TimePicker].
  Widget _buildSelectorHora({
    required String etiqueta,
    required TimeOfDay hora,
    required ValueChanged<TimeOfDay> onSeleccionar,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(etiqueta, style: EstilosTextoApp.caption),
      subtitle: Text(
        _formatearHora(hora),
        style: EstilosTextoApp.titulo,
      ),
      leading: const Icon(Icons.access_time, color: ColoresApp.primario),
      onTap: () async {
        final seleccion = await showTimePicker(
          context: context,
          initialTime: hora,
        );
        if (seleccion != null) onSeleccionar(seleccion);
      },
    );
  }
}