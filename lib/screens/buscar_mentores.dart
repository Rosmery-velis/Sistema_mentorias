import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/usuario.dart';
import '../models/horario.dart';

class BuscarMentoresScreen extends StatefulWidget {
  const BuscarMentoresScreen({super.key});

  @override
  State<BuscarMentoresScreen> createState() => _BuscarMentoresScreenState();
}

class _BuscarMentoresScreenState extends State<BuscarMentoresScreen> {
  final _habilidadController = TextEditingController();
  List<Usuario> _mentores = [];
  bool _loading = false;
  String? _error;
  bool _buscado = false;

  Future<void> _buscar() async {
    final habilidad = _habilidadController.text.trim();
    if (habilidad.isEmpty) {
      setState(() => _error = 'Ingrese una habilidad para buscar');
      return;
    }

    setState(() {
      _loading = true;
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
      if (mounted) setState(() => _loading = false);
    }
  }
  
  void _verHorarios(Usuario mentor) {
    final diasLabels = {
      'lunes': 'Lunes',
      'martes': 'Martes',
      'miercoles': 'Miércoles',
      'jueves': 'Jueves',
      'viernes': 'Viernes',
      'sabado': 'Sábado',
      'domingo': 'Domingo',
    };

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Horarios de ${mentor.nombre}'),
        content: SizedBox(
          width: double.maxFinite,
          child: FutureBuilder<List<Horario>>(
            future: ApiService.getHorariosDeMentor(mentor.id),
            builder: (ctx, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return const Text('Error al cargar horarios');
              }
              final horarios = snapshot.data!;
              if (horarios.isEmpty) {
                return const Text('Este mentor aún no ha configurado horarios.');
              }
              // Agrupar por día
              final grouped = <String, List<Horario>>{};
              for (final h in horarios) {
                grouped.putIfAbsent(h.diaSemana, () => []).add(h);
              }
              return ListView(
                shrinkWrap: true,
                children: grouped.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          diasLabels[entry.key] ?? entry.key,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        for (final h in entry.value)
                          Padding(
                            padding: const EdgeInsets.only(left: 16, top: 4),
                            child: Row(
                              children: [
                                const Icon(Icons.access_time, size: 16, color: Colors.grey),
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
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buscar Mentores')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;
          final padding = isMobile ? 16.0 : 24.0;

          return Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              children: [
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(isMobile ? 12 : 16),
                    child: Column(
                      children: [
                        Text('Tu nivel actual: ${ApiService.usuarioActual!.nivel}',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _habilidadController,
                          decoration: const InputDecoration(
                            labelText: 'Habilidad que quieres aprender',
                            hintText: 'Ej: Python, Flutter',
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _loading ? null : _buscar,
                            icon: const Icon(Icons.search),
                            label: _loading
                                ? const CircularProgressIndicator()
                                : const Text('Buscar Mentores'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (_error != null)
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                if (_buscado && _mentores.isEmpty && !_loading)
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(isMobile ? 16 : 20),
                      child: const Text('No se encontraron mentores para esa habilidad y tu nivel.',
                          style: TextStyle(fontSize: 16)),
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _mentores.length,
                    itemBuilder: (context, index) {
                      final mentor = _mentores[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Colors.deepPurple,
                            child: Icon(Icons.person, color: Colors.white),
                          ),
                          title: Text(mentor.nombre,
                              style: const TextStyle(fontWeight: FontWeight.bold)),
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
                              IconButton(
                                icon: const Icon(Icons.schedule, color: Colors.orange),
                                tooltip: 'Ver horarios',
                                onPressed: () => _verHorarios(mentor),
                              ),
                              IconButton(
                                icon: const Icon(Icons.chat, color: Colors.deepPurple),
                                tooltip: 'Chatear',
                                onPressed: () {
                                  Navigator.pushNamed(context, '/chat', arguments: mentor);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _habilidadController.dispose();
    super.dispose();
  }
}
