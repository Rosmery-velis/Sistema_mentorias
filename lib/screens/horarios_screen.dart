import 'package:flutter/material.dart';
import '../models/horario.dart';
import '../services/api_service.dart';

class HorariosScreen extends StatefulWidget {
  const HorariosScreen({super.key});

  @override
  State<HorariosScreen> createState() => _HorariosScreenState();
}

class _HorariosScreenState extends State<HorariosScreen> {
  List<Horario> _horarios = [];
  bool _loading = true;
  String? _error;

  static const _diasSemana = [
    'lunes', 'martes', 'miercoles', 'jueves', 'viernes', 'sabado', 'domingo',
  ];

  static const _diasLabels = {
    'lunes': 'Lunes',
    'martes': 'Martes',
    'miercoles': 'Miércoles',
    'jueves': 'Jueves',
    'viernes': 'Viernes',
    'sabado': 'Sábado',
    'domingo': 'Domingo',
  };

  @override
  void initState() {
    super.initState();
    _cargarHorarios();
  }

  Future<void> _cargarHorarios() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final mentorId = ApiService.usuarioActual!.id;
      final horarios = await ApiService.getHorariosDeMentor(mentorId);
      setState(() {
        _horarios = horarios;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  Future<void> _agregarHorario() async {
    final resultado = await showDialog<Map<String, String>>(
      context: context,
      builder: (ctx) => _AgregarHorarioDialog(),
    );

    if (resultado != null) {
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
            SnackBar(content: Text('Error: ${e.toString().replaceFirst('Exception: ', '')}')),
          );
        }
      }
    }
  }

  Future<void> _eliminarHorario(Horario horario) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar horario'),
        content: Text(
          '¿Eliminar ${_diasLabels[horario.diaSemana]} de ${horario.horaInicio} a ${horario.horaFin}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmado == true) {
      try {
        await ApiService.eliminarHorario(horario.id);
        _cargarHorarios();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString().replaceFirst('Exception: ', '')}')),
          );
        }
      }
    }
  }

  Map<String, List<Horario>> _groupByDay() {
    final map = <String, List<Horario>>{};
    for (final h in _horarios) {
      map.putIfAbsent(h.diaSemana, () => []).add(h);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _groupByDay();

    return Scaffold(
      appBar: AppBar(title: const Text('Mi Disponibilidad')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : _horarios.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.schedule, size: 80, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No tienes horarios configurados',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Toca "+" para agregar tu disponibilidad',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        for (final dia in _diasSemana)
                          if (grouped.containsKey(dia))
                            Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.calendar_today,
                                            size: 20, color: Colors.deepPurple),
                                        const SizedBox(width: 8),
                                        Text(
                                          _diasLabels[dia]!,
                                          style: const TextStyle(
                                              fontSize: 16, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    const Divider(),
                                    for (final h in grouped[dia]!)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.access_time,
                                                size: 18, color: Colors.grey),
                                            const SizedBox(width: 8),
                                            Text('${h.horaInicio} - ${h.horaFin}',
                                                style: const TextStyle(fontSize: 15)),
                                            const Spacer(),
                                            IconButton(
                                              icon: const Icon(Icons.delete,
                                                  color: Colors.red, size: 20),
                                              onPressed: () => _eliminarHorario(h),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                      ],
                    ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _agregarHorario,
        icon: const Icon(Icons.add),
        label: const Text('Agregar Horario'),
      ),
    );
  }
}

// --- Diálogo para agregar horario ---

class _AgregarHorarioDialog extends StatefulWidget {
  @override
  State<_AgregarHorarioDialog> createState() => _AgregarHorarioDialogState();
}

class _AgregarHorarioDialogState extends State<_AgregarHorarioDialog> {
  String _dia = 'lunes';
  TimeOfDay _horaInicio = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _horaFin = const TimeOfDay(hour: 12, minute: 0);

  String _fmt(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Agregar Horario'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            value: _dia,
            decoration: const InputDecoration(
              labelText: 'Día de la semana',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'lunes', child: Text('Lunes')),
              DropdownMenuItem(value: 'martes', child: Text('Martes')),
              DropdownMenuItem(value: 'miercoles', child: Text('Miércoles')),
              DropdownMenuItem(value: 'jueves', child: Text('Jueves')),
              DropdownMenuItem(value: 'viernes', child: Text('Viernes')),
              DropdownMenuItem(value: 'sabado', child: Text('Sábado')),
              DropdownMenuItem(value: 'domingo', child: Text('Domingo')),
            ],
            onChanged: (v) => setState(() => _dia = v!),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Inicio', style: TextStyle(fontSize: 13)),
                  subtitle: Text(_fmt(_horaInicio),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  leading: const Icon(Icons.access_time, color: Colors.deepPurple),
                  onTap: () async {
                    final t =
                        await showTimePicker(context: context, initialTime: _horaInicio);
                    if (t != null) setState(() => _horaInicio = t);
                  },
                ),
              ),
              Expanded(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Fin', style: TextStyle(fontSize: 13)),
                  subtitle: Text(_fmt(_horaFin),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  leading: const Icon(Icons.access_time, color: Colors.deepPurple),
                  onTap: () async {
                    final t =
                        await showTimePicker(context: context, initialTime: _horaFin);
                    if (t != null) setState(() => _horaFin = t);
                  },
                ),
              ),
            ],
          ),
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
              'inicio': _fmt(_horaInicio),
              'fin': _fmt(_horaFin),
            });
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}