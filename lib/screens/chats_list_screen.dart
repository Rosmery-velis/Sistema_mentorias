import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/usuario.dart';

class ChatsListScreen extends StatefulWidget {
  const ChatsListScreen({super.key});

  @override
  State<ChatsListScreen> createState() => _ChatsListScreenState();
}

class _ChatsListScreenState extends State<ChatsListScreen> {
  final _searchController = TextEditingController();
  List<Usuario> _resultados = [];
  bool _loading = false;
  String? _error;
  bool _buscado = false;

  Future<void> _buscar() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _resultados = [];
        _buscado = false;
        _error = null;
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _buscado = true;
    });

    try {
      final usuarios = await ApiService.buscarUsuarios(query);
      // Excluir al usuario actual
      final miId = ApiService.usuarioActual!.id;
      setState(() {
        _resultados = usuarios.where((u) => u.id != miId).toList();
      });
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buscar Contactos')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Buscar por nombre o correo',
                    hintText: 'Ej: Juan, juan@mail.com',
                    prefixIcon: const Icon(Icons.search),
                    border: const OutlineInputBorder(),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _resultados = [];
                                _buscado = false;
                              });
                            },
                          )
                        : null,
                  ),
                  onChanged: (_) => setState(() {}),
                  onSubmitted: (_) => _buscar(),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _loading ? null : _buscar,
                    icon: const Icon(Icons.search),
                    label: _loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Buscar'),
                  ),
                ),
              ],
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            ),
          if (_buscado && _resultados.isEmpty && !_loading)
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.person_search, size: 80, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('No se encontraron usuarios',
                        style: TextStyle(fontSize: 16, color: Colors.grey)),
                  ],
                ),
              ),
            ),
          if (_resultados.isNotEmpty)
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _resultados.length,
                itemBuilder: (context, index) {
                  final usuario = _resultados[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: usuario.rol == 'mentor'
                            ? Colors.orange
                            : Colors.deepPurple,
                        child: Icon(
                          usuario.rol == 'mentor' ? Icons.person : Icons.school,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(usuario.nombre,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(usuario.correo),
                          Text(
                            usuario.rol == 'estudiante'
                                ? 'Nivel: ${usuario.nivel}'
                                : 'Enseña hasta nivel: ${usuario.nivelEnsenar}',
                            style: const TextStyle(color: Colors.deepPurple),
                          ),
                        ],
                      ),
                      isThreeLine: true,
                      trailing: const Icon(Icons.chat, color: Colors.deepPurple),
                      onTap: () {
                        Navigator.pushNamed(context, '/chat', arguments: usuario);
                      },
                    ),
                  );
                },
              ),
            ),
          if (!_buscado)
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('Busca usuarios para iniciar una conversación',
                        style: TextStyle(fontSize: 16, color: Colors.grey)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
