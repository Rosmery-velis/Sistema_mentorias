// Pantalla de edición de perfil del usuario.

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../temas/colores_app.dart';
import '../temas/estilos_texto_app.dart';
import '../widgets/campo_texto_app.dart';
import '../widgets/boton_principal.dart';
import '../widgets/mensaje_error.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  // ─── Controladores ─────────────────────────────

  /// Controlador del campo de nombre.
  late TextEditingController _nombreController;

  /// Controlador del campo de habilidades (aprender o enseñar según rol).
  late TextEditingController _habilidadesController;

  /// Controlador del campo de objetivos (solo estudiante).
  late TextEditingController _objetivosController;

  /// Controlador del campo de experiencia (solo mentor).
  late TextEditingController _experienciaController;

  /// Controlador del campo de nivel a enseñar (solo mentor).
  late TextEditingController _nivelEnsenarController;

  /// Llave del formulario para validación.
  final _formKey = GlobalKey<FormState>();

  // ─── Estado ────────────────────────────────────

  /// Indica si se está guardando el perfil.
  bool _cargando = false;

  /// Mensaje de estado a mostrar (null = sin mensaje).
  String? _mensaje;

  // ══════════════════════════════════════════════════
  //  CICLO DE VIDA
  // ══════════════════════════════════════════════════

  @override
  void initState() {
    super.initState();
    _inicializarControladores();
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

  /// Inicializa los controladores con los datos actuales del usuario.
  void _inicializarControladores() {
    final u = ApiService.usuarioActual!;

    _nombreController = TextEditingController(text: u.nombre);
    _habilidadesController = TextEditingController(
      text: u.rol == 'estudiante' ? u.habilidadesAprender : u.habilidadesEnsenar,
    );
    _objetivosController = TextEditingController(text: u.objetivos);
    _experienciaController = TextEditingController(text: u.experiencia);
    _nivelEnsenarController = TextEditingController(
      text: u.nivelEnsenar.toString(),
    );
  }

  // ══════════════════════════════════════════════════
  //  LÓGICA
  // ══════════════════════════════════════════════════

  /// Guarda los cambios del perfil en el backend.
  ///
  /// Construye un mapa con los campos según el rol del usuario
  /// y envía la actualización mediante [ApiService.updatePerfil].
  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _cargando = true;
      _mensaje = null;
    });

    try {
      final u = ApiService.usuarioActual!;

      // Campos comunes
      final campos = <String, dynamic>{
        'nombre': _nombreController.text.trim(),
      };

      // Campos específicos según el rol
      if (u.rol == 'estudiante') {
        campos['habilidades_aprender'] = _habilidadesController.text.trim();
        campos['objetivos'] = _objetivosController.text.trim();
      } else {
        campos['habilidades_ensenar'] = _habilidadesController.text.trim();
        campos['experiencia'] = _experienciaController.text.trim();
        campos['nivel_ensenar'] =
            int.tryParse(_nivelEnsenarController.text) ?? 1;
      }

      await ApiService.updatePerfil(u.id, campos);
      setState(() => _mensaje = 'Perfil actualizado correctamente');
    } catch (e) {
      setState(() {
        _mensaje = 'Error: ${e.toString().replaceFirst('Exception: ', '')}';
      });
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  /// Indica si el usuario actual es estudiante.
  bool get _esEstudiante => ApiService.usuarioActual!.rol == 'estudiante';

  /// Indica si el mensaje actual es de error.
  bool get _esError => _mensaje != null && _mensaje!.startsWith('Error');

  // ══════════════════════════════════════════════════
  //  CONSTRUIR UI
  // ══════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final u = ApiService.usuarioActual!;

    return Scaffold(
      // ─── Barra superior ───────────────────────
      appBar: AppBar(title: const Text('Mi Perfil')),

      // ─── Cuerpo ───────────────────────────────
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── Encabezado de rol ────────────
                _buildEncabezadoRol(u),
                const SizedBox(height: 20),

                // ─── Campo: Nombre ────────────────
                CampoTextoApp(
                  controlador: _nombreController,
                  etiqueta: 'Nombre',
                  icono: Icons.person,
                  validador: (v) =>
                      v == null || v.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 16),

                // ─── Campo: Habilidades ───────────
                CampoTextoApp(
                  controlador: _habilidadesController,
                  etiqueta: _esEstudiante
                      ? 'Habilidades que quieres aprender'
                      : 'Habilidades que enseñas',
                  hintText: 'Ej: Python, Flutter, SQL',
                  icono: Icons.build,
                  maxLineas: 2,
                ),
                const SizedBox(height: 16),

                // ─── Campos específicos del rol ───
                if (_esEstudiante)
                  ..._buildCamposEstudiante()
                else
                  ..._buildCamposMentor(),

                // ─── Mensaje de estado ────────────
                if (_mensaje != null) ...[
                  const SizedBox(height: 12),
                  _buildMensajeEstado(),
                ],
                const SizedBox(height: 24),

                // ─── Botón de guardar ─────────────
                BotonPrincipal(
                  texto: 'Guardar Cambios',
                  cargando: _cargando,
                  onPressed: _guardar,
                  icono: Icons.save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════
  //  WIDGETS AUXILIARES
  // ══════════════════════════════════════════════════

  /// Encabezado que muestra el rol y nivel del usuario.
  Widget _buildEncabezadoRol(dynamic usuario) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rol: ${usuario.rol.toUpperCase()}',
          style: EstilosTextoApp.subtitulo.copyWith(
            color: ColoresApp.primario,
          ),
        ),
        if (_esEstudiante) ...[
          const SizedBox(height: 4),
          Text(
            'Nivel actual: ${usuario.nivel}',
            style: EstilosTextoApp.cuerpo,
          ),
        ],
      ],
    );
  }

  /// Campos del formulario exclusivos del estudiante.
  List<Widget> _buildCamposEstudiante() {
    return [
      CampoTextoApp(
        controlador: _objetivosController,
        etiqueta: 'Objetivos de aprendizaje',
        hintText: 'Ej: Aprender desarrollo móvil',
        icono: Icons.flag,
        maxLineas: 3,
      ),
    ];
  }

  /// Campos del formulario exclusivos del mentor.
  List<Widget> _buildCamposMentor() {
    return [
      CampoTextoApp(
        controlador: _experienciaController,
        etiqueta: 'Experiencia profesional',
        hintText: 'Ej: 5 años desarrollando apps',
        icono: Icons.work,
        maxLineas: 3,
      ),
      const SizedBox(height: 16),
      CampoTextoApp(
        controlador: _nivelEnsenarController,
        etiqueta: 'Nivel máximo que enseñas',
        icono: Icons.school,
        tipoTeclado: TextInputType.number,
      ),
    ];
  }

  /// Tarjeta que muestra el mensaje de estado (éxito o error).
  Widget _buildMensajeEstado() {
    return Card(
      color: _esError
          ? ColoresApp.error.withValues(alpha: 0.1)
          : ColoresApp.exito.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              _esError ? Icons.error_outline : Icons.check_circle_outline,
              color: _esError ? ColoresApp.error : ColoresApp.exito,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _mensaje!,
                style: EstilosTextoApp.cuerpoNegrita.copyWith(
                  color: _esError ? ColoresApp.error : ColoresApp.exito,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}