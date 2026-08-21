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
import 'widgets/cosmos_background.dart';

void main() {
  runApp(MyApp(key: MyApp.appKey));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static final GlobalKey<_MyAppState> appKey = GlobalKey<_MyAppState>();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    // ─── App principal ───
    return MaterialApp(
      title: 'Sistema de Mentorías',
      debugShowCheckedModeBanner: false,
      theme: TemaApp.cosmos,

      // ─── Fondo animado detrás de todas las pantallas ───
      builder: (context, child) {
        return Stack(
          fit: StackFit.expand,
          children: [
            const CosmosBackground(),
            child!,
          ],
        );
      },

      initialRoute: '/login',
      routes: _buildRutas(),
      onGenerateRoute: _buildRutaDinamica,
    );
  }

  // ════ RUTAS ════

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