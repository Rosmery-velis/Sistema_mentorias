// Pantalla de búsqueda de contactos para iniciar un chat.

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/usuario.dart';
import '../temas/colores_app.dart';
import '../temas/estilos_texto_app.dart';
import '../widgets/mensaje_error.dart';
import '../widgets/avatar_usuario.dart';
import '../widgets/estado_vacio.dart';

class ChatsListScreen extends StatefulWidget {
  const ChatsListScreen({super.key});

  @override
  State<ChatsListScreen> createState() => _ChatsListScreenState();
}

class _ChatsListScreenState extends State<ChatsListScreen> {
  // ─── Controladores ─────────────────────────────

  /// Controlador del campo de búsqueda.
  final _buscadorController = TextEditingController();

  // ─── Estado ────────────────────────────────────

  /// Lista de usuarios encontrados en la búsqueda.
  List<Usuario> _resultados = [];

  /// Indica si se está ejecutando la búsqueda.
  bool _cargando = false;

  /// Mensaje de error a mostrar (null = sin error).
  String? _error;

  /// Indica si el usuario ya realizó al menos una búsqueda.
  bool _buscado = false;

  // ══════════════════════════════════════════════════
  //  CICLO DE VIDA
  // ══════════════════════════════════════════════════

  @override
  void dispose() {
    _buscadorController.dispose();
    super.dispose();
  }

  // ══════════════════════════════════════════════════
  //  LÓGICA
  // ══════════════════════════════════════════════════

  /// Busca usuarios por nombre o correo.
  ///
  /// Flujo:
  ///   1. Si el campo está vacío, limpia los resultados.
  ///   2. Llama a [ApiService.buscarUsuarios].
  ///   3. Excluye al usuario actual de los resultados.
  Future<void> _buscar() async {
    final consulta = _buscadorController.text.trim();
    if (consulta.isEmpty) {
      setState(() {
        _resultados = [];
        _buscado = false;
        _error = null;
      });
      return;
    }

    setState(() {
      _cargando = true;
      _error = null;
      _buscado = true;
    });

    try {
      final usuarios = await ApiService.buscarUsuarios(consulta);

      // Excluir al usuario actual de los resultados
      final miId = ApiService.usuarioActual!.id;
      setState(() {
        _resultados = usuarios.where((u) => u.id != miId).toList();
      });
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  /// Limpia el campo de búsqueda y los resultados.
  void _limpiarBusqueda() {
    _buscadorController.clear();
    setState(() {
      _resultados = [];
      _buscado = false;
    });
  }

  // ══════════════════════════════════════════════════
  //  CONSTRUIR UI
  // ══════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ─── Barra superior ───────────────────────
      appBar: AppBar(title: const Text('Buscar Contactos')),

      // ─── Cuerpo ───────────────────────────────
      body: Column(
        children: [
          // ─── Barra de búsqueda ─────────────────
          _buildBarraBusqueda(),

          // ─── Mensaje de error ──────────────────
          if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: MensajeError(mensaje: _error),
            ),

          // ─── Estado: sin resultados ────────────
          if (_buscado && _resultados.isEmpty && !_cargando)
            const Expanded(
              child: EstadoVacio(
                icono: Icons.person_search,
                mensaje: 'No se encontraron usuarios',
              ),
            ),

          // ─── Lista de resultados ───────────────
          if (_resultados.isNotEmpty)
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _resultados.length,
                itemBuilder: (context, index) {
                  final usuario = _resultados[index];
                  return _buildTarjetaUsuario(usuario);
                },
              ),
            ),

          // ─── Estado: búsqueda inicial ──────────
          if (!_buscado)
            const Expanded(
              child: EstadoVacio(
                icono: Icons.chat_bubble_outline,
                mensaje: 'Busca usuarios para iniciar una conversación',
              ),
            ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════
  //  WIDGETS AUXILIARES
  // ══════════════════════════════════════════════════

  /// Barra de búsqueda con campo de texto y botón.
  Widget _buildBarraBusqueda() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _buscadorController,
            decoration: InputDecoration(
              labelText: 'Buscar por nombre o correo',
              hintText: 'Ej: Juan, juan@mail.com',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _buscadorController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: _limpiarBusqueda,
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
                  : const Text('Buscar'),
            ),
          ),
        ],
      ),
    );
  }

  /// Tarjeta individual de un usuario en los resultados.
  Widget _buildTarjetaUsuario(Usuario usuario) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: AvatarUsuario(rol: usuario.rol),
        title: Text(usuario.nombre, style: EstilosTextoApp.subtitulo),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(usuario.correo),
            Text(
              usuario.rol == 'estudiante'
                  ? 'Nivel: ${usuario.nivel}'
                  : 'Enseña hasta nivel: ${usuario.nivelEnsenar}',
              style: const TextStyle(color: ColoresApp.primario),
            ),
          ],
        ),
        isThreeLine: true,
        trailing: const Icon(Icons.chat, color: ColoresApp.primario),
        onTap: () {
          Navigator.pushNamed(context, '/chat', arguments: usuario);
        },
      ),
    );
  }
}