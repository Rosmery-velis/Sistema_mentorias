import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/campo_texto_app.dart';
import '../widgets/boton_principal.dart';
import '../widgets/encabezado_auth.dart';
import '../widgets/mensaje_error.dart';
import '../widgets/enlace_navegacion.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // ─── Controladores ─────────────────────────────

  // Controlador del campo de nombre completo.
  final _nombreController = TextEditingController();

  // Controlador del campo de correo electrónico.
  final _correoController = TextEditingController();

  // Controlador del campo de contraseña.
  final _passwordController = TextEditingController();

  // Llave del formulario para validación.
  final _formKey = GlobalKey<FormState>();

  // ─── Estado ────────────────────────────────────

  /// Rol seleccionado por el usuario ('estudiante' o 'mentor').
  String _rol = 'estudiante';

  /// Indica si se está procesando la petición de registro.
  bool _cargando = false;

  /// Mensaje de error a mostrar (null = sin error).
  String? _error;

  // ════ CICLO DE VIDA ════

  @override
  void dispose() {
    _nombreController.dispose();
    _correoController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ════ LÓGICA ════

  /* Envía los datos de registro al backend.
  
  Flujo:
    1. Valida que los campos cumplan las reglas.
    2. Llama a [ApiService.register].
    3. Si es exitoso, muestra un SnackBar y navega al login.
    4. Si falla, muestra el mensaje de error.
  */
  Future<void> _registrarse() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      await ApiService.register(
        _nombreController.text.trim(),
        _correoController.text.trim(),
        _passwordController.text,
        _rol,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registro exitoso. Inicia sesión.')),
      );
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  // ════ CONSTRUIR UI ════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ─── Barra superior ───────────────────────
      appBar: AppBar(title: const Text('Registro')),

      // ─── Cuerpo ───────────────────────────────
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ─── Encabezado ─────────────────
                  const EncabezadoAuth(
                    icono: Icons.person_add,
                    titulo: 'Crear Cuenta',
                  ),
                  const SizedBox(height: 32),

                  // ─── Campo: Nombre ──────────────
                  CampoTextoApp(
                    controlador: _nombreController,
                    etiqueta: 'Nombre completo',
                    icono: Icons.person,
                    validador: (v) =>
                        v == null || v.isEmpty ? 'Ingrese su nombre' : null,
                  ),
                  const SizedBox(height: 16),

                  // ─── Campo: Correo ──────────────
                  CampoTextoApp(
                    controlador: _correoController,
                    etiqueta: 'Correo electrónico',
                    icono: Icons.email,
                    tipoTeclado: TextInputType.emailAddress,
                    validador: (v) =>
                        v == null || v.isEmpty ? 'Ingrese su correo' : null,
                  ),
                  const SizedBox(height: 16),

                  // ─── Campo: Contraseña ──────────
                  CampoTextoApp(
                    controlador: _passwordController,
                    etiqueta: 'Contraseña',
                    icono: Icons.lock,
                    ocultarTexto: true,
                    validador: (v) => v == null || v.length < 4
                        ? 'Mínimo 4 caracteres'
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // ─── Selector de rol ────────────
                  _buildSelectorRol(),
                  const SizedBox(height: 16),

                  // ─── Mensaje de error ───────────
                  MensajeError(mensaje: _error),
                  const SizedBox(height: 24),

                  // ─── Botón de registro ──────────
                  BotonPrincipal(
                    texto: 'Registrarse',
                    cargando: _cargando,
                    onPressed: _registrarse,
                  ),
                  const SizedBox(height: 12),

                  // ─── Enlace a login ─────────────
                  EnlaceNavegacion(
                    texto: '¿Ya tienes cuenta? Inicia sesión',
                    onPressed: () =>
                        Navigator.pushReplacementNamed(context, '/login'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ════ WIDGETS AUXILIARES ════

  /// Selector de rol (Estudiante / Mentor) usando [SegmentedButton].
  Widget _buildSelectorRol() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Rol:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(
              value: 'estudiante',
              label: Text('Estudiante'),
              icon: Icon(Icons.school),
            ),
            ButtonSegment(
              value: 'mentor',
              label: Text('Mentor'),
              icon: Icon(Icons.person),
            ),
          ],
          selected: {_rol},
          onSelectionChanged: (v) => setState(() => _rol = v.first),
        ),
      ],
    );
  }
}