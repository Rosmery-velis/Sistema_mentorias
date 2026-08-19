import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/campo_texto_app.dart';
import '../widgets/boton_principal.dart';
import '../widgets/encabezado_auth.dart';
import '../widgets/mensaje_error.dart';
import '../widgets/enlace_navegacion.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // ─── Controladores ───

  // Controlador del campo de correo electrónico.
  final _correoController = TextEditingController();

  // Controlador del campo de contraseña.
  final _passwordController = TextEditingController();

  // Llave del formulario para validación.
  final _formKey = GlobalKey<FormState>();

  // ─── Estado ───

  // Indica si se está procesando la petición de login.
  bool _cargando = false;

  /// Mensaje de error a mostrar (null = sin error).
  String? _error;

  // ════ CICLO DE VIDA ════

  @override
  void dispose() {
    _correoController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ════ LÓGICA ════


  /* Envía las credenciales al backend y procesa la respuesta.
  Flujo:
    1. Valida que los campos no estén vacíos.
    2. Llama a [ApiService.login].
    3. Si es exitoso, navega al home según el rol del usuario.
    4. Si falla, muestra el mensaje de error.
  */
  Future<void> _iniciarSesion() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final usuario = await ApiService.login(
        _correoController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      // Navegar según el rol del usuario
      if (usuario.rol == 'estudiante') {
        Navigator.pushReplacementNamed(context, '/home_estudiante');
      } else {
        Navigator.pushReplacementNamed(context, '/home_mentor');
      }
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
      // ─── Barra superior ───
      appBar: AppBar(title: const Text('Iniciar Sesión')),

      // ─── Cuerpo ───
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
                    icono: Icons.school,
                    titulo: 'Sistema de Mentorías',
                  ),
                  const SizedBox(height: 32),

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
                    validador: (v) =>
                        v == null || v.isEmpty ? 'Ingrese su contraseña' : null,
                  ),

                  // ─── Mensaje de error ───────────
                  MensajeError(mensaje: _error),
                  const SizedBox(height: 24),

                  // ─── Botón de login ─────────────
                  BotonPrincipal(
                    texto: 'Iniciar Sesión',
                    cargando: _cargando,
                    onPressed: _iniciarSesion,
                  ),
                  const SizedBox(height: 12),

                  // ─── Enlace a registro ──────────
                  EnlaceNavegacion(
                    texto: '¿No tienes cuenta? Regístrate aquí',
                    onPressed: () =>
                        Navigator.pushNamed(context, '/register'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}