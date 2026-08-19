import 'package:flutter/material.dart';
import 'temas/tema_app.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_estudiante.dart';
import 'screens/home_mentor.dart';
import 'screens/perfil_screen.dart';
import 'screens/buscar_mentores.dart';
import 'screens/chat_screen.dart';
import 'screens/evaluar_screen.dart';
import 'screens/chats_list_screen.dart';
import 'screens/estudiantes_list_screen.dart';
import 'models/usuario.dart';
import 'screens/horarios_screen.dart';

void main() {
  runApp(MyApp(key: MyApp.appKey));
}

/* Widget raíz de la aplicación.

Mantiene el estado del tema (claro/oscuro) y expone [appKey] para que otras pantallas puedan alternar el tema mediante
[MyApp.appKey.currentState?.toggleTheme()].
*/
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  // Llave global para acceder al estado del tema desde cualquier pantalla.
  // ignore: library_private_types_in_public_api
  static final GlobalKey<_MyAppState> appKey = GlobalKey<_MyAppState>();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // ─── Estado ────────────────────────────────────

  // Modo de tema actual (claro u oscuro).
  ThemeMode _modoTema = ThemeMode.light;

  // ══════════════════════════════════════════════════
  //  MÉTODOS PÚBLICOS
  // ══════════════════════════════════════════════════

  // Alterna entre tema claro y oscuro.
  void toggleTheme() {
    setState(() {
      _modoTema = _modoTema == ThemeMode.light
          ? ThemeMode.dark
          : ThemeMode.light;
    });
  }

  // ══════════════════════════════════════════════════
  //  CONSTRUIR UI
  // ══════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sistema de Mentorías',
      debugShowCheckedModeBanner: false,

      // ─── Temas ────────────────────────────────
      themeMode: _modoTema,
      theme: TemaApp.claro,
      darkTheme: TemaApp.oscuro,

      // ─── Rutas ────────────────────────────────
      initialRoute: '/login',
      routes: _buildRutas(),
      onGenerateRoute: _buildRutaDinamica,
    );
  }

  // ══════════════════════════════════════════════════
  //  RUTAS
  // ══════════════════════════════════════════════════

  // Define las rutas estáticas de la aplicación.

  // Cada ruta corresponde a una pantalla principal.
  Map<String, WidgetBuilder> _buildRutas() {
    return {
      '/login': (context) => const LoginScreen(),
      '/register': (context) => const RegisterScreen(),
      '/home_estudiante': (context) => const HomeEstudiante(),
      '/home_mentor': (context) => const HomeMentor(),
      '/perfil': (context) => const PerfilScreen(),
      '/buscar_mentores': (context) => const BuscarMentoresScreen(),
      '/evaluar': (context) => const EvaluarScreen(),
      '/chats': (context) => const ChatsListScreen(),
      '/estudiantes': (context) => const EstudiantesListScreen(),
      '/horarios': (context) => const HorariosScreen(),
    };
  }

  // Genera rutas dinámicas que requieren argumentos.

  // Actualmente solo se usa para `/chat`, que recibe un [Usuario] como argumento (el contacto con el que se va a chatear).
  Route<dynamic>? _buildRutaDinamica(RouteSettings settings) {
    if (settings.name == '/chat') {
      final contacto = settings.arguments as Usuario;
      return MaterialPageRoute(
        builder: (context) => ChatScreen(contacto: contacto),
      );
    }
    return null;
  }
}
