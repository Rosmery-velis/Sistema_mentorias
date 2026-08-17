import 'package:flutter/material.dart';
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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  // ignore: library_private_types_in_public_api
  static final GlobalKey<_MyAppState> appKey = GlobalKey<_MyAppState>();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sistema de Mentorías',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home_estudiante': (context) => const HomeEstudiante(),
        '/home_mentor': (context) => const HomeMentor(),
        '/perfil': (context) => const PerfilScreen(),
        '/buscar_mentores': (context) => const BuscarMentoresScreen(),
        '/evaluar': (context) => const EvaluarScreen(),
        '/chats': (context) => const ChatsListScreen(),
        '/estudiantes': (context) => const EstudiantesListScreen(),
        '/horarios': (context) => const HorariosScreen()
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/chat') {
          final contacto = settings.arguments as Usuario;
          return MaterialPageRoute(
            builder: (context) => ChatScreen(contacto: contacto),
          );
        }
        return null;
      },
    );
  }
}
