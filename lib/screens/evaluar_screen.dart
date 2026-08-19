// Pantalla para que el mentor evalúe a un estudiante.
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/usuario.dart';
import '../temas/colores_app.dart';
import '../temas/estilos_texto_app.dart';
import '../widgets/campo_texto_app.dart';

class EvaluarScreen extends StatefulWidget {
  const EvaluarScreen({super.key});

  @override
  State<EvaluarScreen> createState() => _EvaluarScreenState();
}

class _EvaluarScreenState extends State<EvaluarScreen> {
  // ─── Controladores ─────────────────────────────

  /// Controlador del campo de búsqueda por ID de estudiante.
  final _estudianteIdController = TextEditingController();

  // ─── Estado ────────────────────────────────────

  /// Indica si se está procesando una petición.
  bool _cargando = false;

  /// Mensaje de estado a mostrar (éxito o error).
  String? _mensaje;

  /// Estudiante encontrado en la búsqueda (null = no buscado aún).
  Usuario? _estudiante;

  // ══════════════════════════════════════════════════
  //  CICLO DE VIDA
  // ══════════════════════════════════════════════════

  @override
  void dispose() {
    _estudianteIdController.dispose();
    super.dispose();
  }

  // ══════════════════════════════════════════════════
  //  LÓGICA
  // ══════════════════════════════════════════════════

  /// Busca un estudiante por su ID.
  ///
  /// Flujo:
  ///   1. Valida que el ID sea un número válido.
  ///   2. Consulta el perfil en el backend.
  ///   3. Verifica que el usuario sea de rol 'estudiante'.
  Future<void> _buscarEstudiante() async {
    final idTexto = _estudianteIdController.text.trim();
    if (idTexto.isEmpty) return;

    final id = int.tryParse(idTexto);
    if (id == null) {
      setState(() => _mensaje = 'ID inválido');
      return;
    }

    setState(() {
      _cargando = true;
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
      setState(() {
        _mensaje = 'Error: ${e.toString().replaceFirst('Exception: ', '')}';
      });
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  /// Muestra un diálogo de confirmación antes de evaluar.
  ///
  /// Si el usuario confirma, ejecuta [_evaluar] con el resultado.
  void _confirmarEvaluar(String resultado) {
    if (_estudiante == null) return;

    final esAprobado = resultado == 'aprobado';
    final nivelResultado = esAprobado
        ? _estudiante!.nivel + 1
        : _estudiante!.nivel;

    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          esAprobado ? 'Aprobar Estudiante' : 'Reprobar Estudiante',
        ),
        content: Text(
          esAprobado
              ? '¿Estás seguro de aprobar a ${_estudiante!.nombre}? '
                'Su nivel subirá a $nivelResultado.'
              : '¿Estás seguro de reprobar a ${_estudiante!.nombre}? '
                'Su nivel permanecerá en $nivelResultado.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  esAprobado ? ColoresApp.exito : ColoresApp.error,
            ),
            child: Text(
              esAprobado ? 'Aprobar' : 'Reprobar',
              style: const TextStyle(color: ColoresApp.textoSobrePrimario),
            ),
          ),
        ],
      ),
    ).then((confirmado) {
      if (confirmado == true) _evaluar(resultado);
    });
  }

  /// Envía la evaluación al backend y actualiza los datos locales.
  Future<void> _evaluar(String resultado) async {
    setState(() {
      _cargando = true;
      _mensaje = null;
    });

    try {
      final mentorId = ApiService.usuarioActual!.id;
      final data = await ApiService.evaluarEstudiante(
        mentorId,
        _estudiante!.id,
        resultado,
      );

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
      setState(() {
        _mensaje = 'Error: ${e.toString().replaceFirst('Exception: ', '')}';
      });
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  /// Indica si el mensaje actual es de error.
  bool get _esError => _mensaje != null && _mensaje!.startsWith('Error');

  // ══════════════════════════════════════════════════
  //  CONSTRUIR UI
  // ══════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ─── Barra superior ───────────────────────
      appBar: AppBar(title: const Text('Evaluar Estudiante')),

      // ─── Cuerpo ───────────────────────────────
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Buscador de estudiante ─────────
              _buildBuscadorEstudiante(),

              // ─── Tarjeta de estudiante ──────────
              if (_estudiante != null) ...[
                const SizedBox(height: 20),
                _buildTarjetaEstudiante(),
                const SizedBox(height: 20),
                _buildBotonesEvaluar(),
              ],

              // ─── Mensaje de estado ──────────────
              if (_mensaje != null) ...[
                const SizedBox(height: 20),
                _buildMensajeEstado(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════
  //  WIDGETS AUXILIARES
  // ══════════════════════════════════════════════════

  /// Tarjeta con el campo de búsqueda por ID y botón de buscar.
  Widget _buildBuscadorEstudiante() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Buscar estudiante por ID:',
              style: EstilosTextoApp.subtitulo,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: CampoTextoApp(
                    controlador: _estudianteIdController,
                    etiqueta: 'ID del estudiante',
                    icono: Icons.badge,
                    tipoTeclado: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _cargando ? null : _buscarEstudiante,
                  child: _cargando
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Buscar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Tarjeta con la información del estudiante encontrado.
  Widget _buildTarjetaEstudiante() {
    return Card(
      color: ColoresApp.primarioClaro.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nombre
            Text(
              _estudiante!.nombre,
              style: EstilosTextoApp.titulo,
            ),
            const SizedBox(height: 8),

            // Datos básicos
            Text('ID: ${_estudiante!.id}', style: EstilosTextoApp.cuerpo),
            Text('Correo: ${_estudiante!.correo}',
                style: EstilosTextoApp.cuerpo),
            const SizedBox(height: 4),

            // Nivel actual (destacado)
            Text(
              'Nivel actual: ${_estudiante!.nivel}',
              style: EstilosTextoApp.titulo.copyWith(
                color: ColoresApp.primario,
              ),
            ),
            const SizedBox(height: 4),

            // Habilidades y objetivos
            if (_estudiante!.habilidadesAprender.isNotEmpty)
              Text(
                'Aprende: ${_estudiante!.habilidadesAprender}',
                style: EstilosTextoApp.cuerpo,
              ),
            if (_estudiante!.objetivos.isNotEmpty)
              Text(
                'Objetivos: ${_estudiante!.objetivos}',
                style: EstilosTextoApp.cuerpo,
              ),
          ],
        ),
      ),
    );
  }

  /// Botones para aprobar o reprobar al estudiante.
  Widget _buildBotonesEvaluar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Evaluar:', style: EstilosTextoApp.titulo),
        const SizedBox(height: 12),
        Row(
          children: [
            // Botón: Aprobar
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _cargando
                    ? null
                    : () => _confirmarEvaluar('aprobado'),
                icon: const Icon(Icons.check_circle,
                    color: ColoresApp.textoSobrePrimario),
                label: const Text(
                  'APROBAR',
                  style: TextStyle(
                    fontSize: 16,
                    color: ColoresApp.textoSobrePrimario,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColoresApp.exito,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Botón: Reprobar
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _cargando
                    ? null
                    : () => _confirmarEvaluar('reprobado'),
                icon: const Icon(Icons.cancel,
                    color: ColoresApp.textoSobrePrimario),
                label: const Text(
                  'REPROBAR',
                  style: TextStyle(
                    fontSize: 16,
                    color: ColoresApp.textoSobrePrimario,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColoresApp.error,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Tarjeta que muestra el mensaje de estado (éxito o error).
  Widget _buildMensajeEstado() {
    return Card(
      color: _esError
          ? ColoresApp.error.withValues(alpha: 0.1)
          : ColoresApp.exito.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          _mensaje!,
          style: EstilosTextoApp.cuerpoNegrita,
        ),
      ),
    );
  }
}