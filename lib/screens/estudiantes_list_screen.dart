import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/usuario.dart';

class EstudiantesListScreen extends StatefulWidget {
  const EstudiantesListScreen({super.key});

  @override
  State<EstudiantesListScreen> createState() => _EstudiantesListScreenState();
}

class _EstudiantesListScreenState extends State<EstudiantesListScreen> {
  List<Usuario> _estudiantes = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarEstudiantes();
  }

  Future<void> _cargarEstudiantes() async {
    try {
      final mentorId = ApiService.usuarioActual!.id;
      final estudiantes = await ApiService.getEstudiantesDeMentor(mentorId);
      setState(() {
        _estudiantes = estudiantes;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis Estudiantes')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : _estudiantes.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.school_outlined, size: 80, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('Aún no tienes estudiantes evaluados',
                              style: TextStyle(fontSize: 16, color: Colors.grey)),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _cargarEstudiantes,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _estudiantes.length,
                        itemBuilder: (context, index) {
                          final estudiante = _estudiantes[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.deepPurple,
                                child: Text('${estudiante.nivel}',
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                              title: Text(estudiante.nombre,
                                  style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(estudiante.correo),
                                  Text('Nivel: ${estudiante.nivel}',
                                      style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.deepPurple)),
                                  if (estudiante.habilidadesAprender.isNotEmpty)
                                    Text('Aprende: ${estudiante.habilidadesAprender}'),
                                ],
                              ),
                              isThreeLine: true,
                              trailing: IconButton(
                                icon: const Icon(Icons.chat, color: Colors.deepPurple),
                                onPressed: () {
                                  Navigator.pushNamed(context, '/chat', arguments: estudiante);
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
