import 'package:flutter/material.dart';
import '../services/api_service.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _habilidadesController;
  late TextEditingController _objetivosController;
  late TextEditingController _experienciaController;
  late TextEditingController _nivelEnsenarController;
  bool _loading = false;
  String? _mensaje;

  @override
  void initState() {
    super.initState();
    final u = ApiService.usuarioActual!;
    _nombreController = TextEditingController(text: u.nombre);
    _habilidadesController = TextEditingController(
      text: u.rol == 'estudiante' ? u.habilidadesAprender : u.habilidadesEnsenar,
    );
    _objetivosController = TextEditingController(text: u.objetivos);
    _experienciaController = TextEditingController(text: u.experiencia);
    _nivelEnsenarController = TextEditingController(text: u.nivelEnsenar.toString());
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _mensaje = null;
    });

    try {
      final u = ApiService.usuarioActual!;
      final campos = <String, dynamic>{
        'nombre': _nombreController.text.trim(),
      };

      if (u.rol == 'estudiante') {
        campos['habilidades_aprender'] = _habilidadesController.text.trim();
        campos['objetivos'] = _objetivosController.text.trim();
      } else {
        campos['habilidades_ensenar'] = _habilidadesController.text.trim();
        campos['experiencia'] = _experienciaController.text.trim();
        campos['nivel_ensenar'] = int.tryParse(_nivelEnsenarController.text) ?? 1;
      }

      await ApiService.updatePerfil(u.id, campos);
      setState(() => _mensaje = 'Perfil actualizado correctamente');
    } catch (e) {
      setState(() => _mensaje = 'Error: ${e.toString().replaceFirst('Exception: ', '')}');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final u = ApiService.usuarioActual!;
    final esEstudiante = u.rol == 'estudiante';

    return Scaffold(
      appBar: AppBar(title: const Text('Mi Perfil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Rol: ${u.rol.toUpperCase()}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                if (esEstudiante)
                  Text('Nivel actual: ${u.nivel}', style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nombreController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _habilidadesController,
                  decoration: InputDecoration(
                    labelText: esEstudiante ? 'Habilidades que quieres aprender' : 'Habilidades que enseñas',
                    hintText: 'Ej: Python, Flutter, SQL',
                    border: const OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                if (esEstudiante) ...[
                  TextFormField(
                    controller: _objetivosController,
                    decoration: const InputDecoration(
                      labelText: 'Objetivos de aprendizaje',
                      hintText: 'Ej: Aprender desarrollo móvil',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ] else ...[
                  TextFormField(
                    controller: _experienciaController,
                    decoration: const InputDecoration(
                      labelText: 'Experiencia profesional',
                      hintText: 'Ej: 5 años desarrollando apps',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nivelEnsenarController,
                    decoration: const InputDecoration(
                      labelText: 'Nivel máximo que enseñas',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],
                if (_mensaje != null) ...[
                  const SizedBox(height: 12),
                  Text(_mensaje!,
                      style: TextStyle(
                        color: _mensaje!.startsWith('Error') ? Colors.red : Colors.green,
                      )),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _guardar,
                    child: _loading
                        ? const CircularProgressIndicator()
                        : const Text('Guardar Cambios', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _habilidadesController.dispose();
    _objetivosController.dispose();
    _experienciaController.dispose();
    _nivelEnsenarController.dispose();
    super.dispose();
  }
}
