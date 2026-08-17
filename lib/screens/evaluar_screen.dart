import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/usuario.dart';

class EvaluarScreen extends StatefulWidget {
  const EvaluarScreen({super.key});

  @override
  State<EvaluarScreen> createState() => _EvaluarScreenState();
}

class _EvaluarScreenState extends State<EvaluarScreen> {
  final _estudianteIdController = TextEditingController();
  bool _loading = false;
  String? _mensaje;
  Usuario? _estudiante;

  Future<void> _buscarEstudiante() async {
    final idStr = _estudianteIdController.text.trim();
    if (idStr.isEmpty) return;

    final id = int.tryParse(idStr);
    if (id == null) {
      setState(() => _mensaje = 'ID inválido');
      return;
    }

    setState(() {
      _loading = true;
      _mensaje = null;
      _estudiante = null;
    });

    try {
      final estudiante = await ApiService.getPerfil(id);
      if (estudiante.rol != 'estudiante') {
        setState(() => _mensaje = 'Este usuario no es un estudiante');
      } else {
        setState(() => _estudiante = estudiante);
      }
    } catch (e) {
      setState(() => _mensaje = 'Error: ${e.toString().replaceFirst('Exception: ', '')}');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _confirmarEvaluar(String resultado) async {
    if (_estudiante == null) return;

    final esAprobado = resultado == 'aprobado';
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(esAprobado ? 'Aprobar Estudiante' : 'Reprobar Estudiante'),
        content: Text(
          esAprobado
              ? '¿Estás seguro de aprobar a ${_estudiante!.nombre}? Su nivel subirá a ${_estudiante!.nivel + 1}.'
              : '¿Estás seguro de reprobar a ${_estudiante!.nombre}? Su nivel permanecerá en ${_estudiante!.nivel}.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: esAprobado ? Colors.green : Colors.red,
            ),
            child: Text(esAprobado ? 'Aprobar' : 'Reprobar',
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmado == true) {
      await _evaluar(resultado);
    }
  }

  Future<void> _evaluar(String resultado) async {
    setState(() {
      _loading = true;
      _mensaje = null;
    });

    try {
      final mentorId = ApiService.usuarioActual!.id;
      final data = await ApiService.evaluarEstudiante(mentorId, _estudiante!.id, resultado);
      setState(() {
        _mensaje = data['mensaje'] as String;
        // Actualizar datos del estudiante localmente
        _estudiante = Usuario(
          id: _estudiante!.id,
          nombre: _estudiante!.nombre,
          correo: _estudiante!.correo,
          rol: _estudiante!.rol,
          habilidadesAprender: _estudiante!.habilidadesAprender,
          nivel: data['nivel_actual'] as int,
        );
      });
    } catch (e) {
      setState(() => _mensaje = 'Error: ${e.toString().replaceFirst('Exception: ', '')}');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Evaluar Estudiante')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text('Buscar estudiante por ID:',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _estudianteIdController,
                              decoration: const InputDecoration(
                                labelText: 'ID del estudiante',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: _loading ? null : _buscarEstudiante,
                            child: _loading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2))
                                : const Text('Buscar'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (_estudiante != null) ...[
                const SizedBox(height: 20),
                Card(
                  color: Colors.deepPurple.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_estudiante!.nombre,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text('ID: ${_estudiante!.id}'),
                        Text('Correo: ${_estudiante!.correo}'),
                        Text('Nivel actual: ${_estudiante!.nivel}',
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple)),
                        if (_estudiante!.habilidadesAprender.isNotEmpty)
                          Text('Aprende: ${_estudiante!.habilidadesAprender}'),
                        if (_estudiante!.objetivos.isNotEmpty)
                          Text('Objetivos: ${_estudiante!.objetivos}'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Evaluar:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _loading ? null : () => _confirmarEvaluar('aprobado'),
                        icon: const Icon(Icons.check_circle, color: Colors.white),
                        label: const Text('APROBAR',
                            style: TextStyle(fontSize: 16, color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _loading ? null : () => _confirmarEvaluar('reprobado'),
                        icon: const Icon(Icons.cancel, color: Colors.white),
                        label: const Text('REPROBAR',
                            style: TextStyle(fontSize: 16, color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              if (_mensaje != null) ...[
                const SizedBox(height: 20),
                Card(
                  color: _mensaje!.startsWith('Error') ? Colors.red.shade50 : Colors.green.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(_mensaje!,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _estudianteIdController.dispose();
    super.dispose();
  }
}
